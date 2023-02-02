/*
 * SPDX-FileCopyrightText: Copyright © 2020-2023 Ikey Doherty
 *
 * SPDX-License-Identifier: Zlib
 */

/**
 * ics.parser
 *
 * The actual parser.
 *
 * Authors: Copyright © 2020-2023 Ikey Doherty
 * License: Zlib
 */

module ics.parser;

public import ics : ICSResult, ICSEntry, ICSError, icsID;
public import std.sumtype;
import ics.calendar;
import ics.event;
import ics.todo;
import std.stdio : File, KeepTerminator, writefln;
import std.string : indexOf, format;
import std.traits : getUDAs, FieldNameTuple, OriginalType, isBoolean, isNumeric, isFloatingPoint;
import std.datetime.systime;
import std.conv : to;

/** 
 * Separators and \r\n
 */
private static const minLineLength = 4;

/** 
 * Every line requires a proper format ending
 */
private static const requiredLineEnding = "\r\n";

/**
 * Used to separate all key/vals except ORGANIZER, which
 * needs further processing
 */
private static const keyvalSeparator = ':';

/**
 * The current context in processing
 */
private enum Context
{
    None, /* Unvisited */
    Calendar,
    Event,
    Todo
}

/** 
 * Parse an ICS file
 *
 * This will return a Calendar parent of various entries
 *
 * When the first error has occured, bail.
 *
 * Params:
 *   filepath = path to the file to parse
 * Returns: A Valid calendar ICSResult or an ICSError
 */
public ICSResult parseICS(string filepath) @trusted
{
    auto fi = File(filepath, "r");
    scope (exit)
    {
        fi.close();
    }

    auto context = Context.None;
    auto prevContext = Context.None;

    ICSEntry currentNode = ICSEntry(ICSError("unset"));

    Calendar rootCalendar;

    /**
     * Walk every line by the \r\n ending
     *
     * TODO: Support multiline descriptions indent by space
     */
    foreach (ref line; fi.byLine(KeepTerminator.no, requiredLineEnding))
    {
        if (line.length < minLineLength)
        {
            return ICSResult(ICSError("Line length too short"));
        }

        immutable colonIndex = line.indexOf(keyvalSeparator);
        if (colonIndex < 1)
        {
            return ICSResult(ICSError("Line doesn't include key/value mapping"));
        }

        const key = line[0 .. colonIndex];
        const value = line[colonIndex + 1 .. $];

        switch (key)
        {
        case "BEGIN":
            /* Set the current scope */
            writefln!"Begin scope: %s"(value);
            prevContext = context;
            /* Grab the calendar back */
            if (prevContext == Context.Calendar)
            {
                rootCalendar = currentNode.tryMatch!((Calendar c) => c);
            }
            switch (value)
            {
            case "VCALENDAR":
                context = Context.Calendar;
                currentNode = ICSEntry(rootCalendar);
                break;
            case "VEVENT":
                context = Context.Event;
                auto event = Event();
                event._parent = &rootCalendar;
                currentNode = ICSEntry(event);
                break;
            case "VTODO":
                context = Context.Todo;
                auto todo = Todo();
                todo._parent = &rootCalendar;
                currentNode = ICSEntry(todo);
                break;
            default:
                return ICSResult(ICSError(format!"Unhandled scope: %s"(value)));
            }
            break;
        case "END":
            /* TODO: For nested, go up the parent scope */
            switch (context)
            {
            case Context.Todo:
                rootCalendar.todos ~= currentNode.tryMatch!((Todo t) => t);
                break;
            case Context.Event:
                rootCalendar.events ~= currentNode.tryMatch!((Event t) => t);
                break;
            default:
                break;
            }

            context = prevContext;
            prevContext = Context.None;
            break;
        default:
            handleEvent(context, currentNode, key, value);
            break;
        }
    }

    return ICSResult(rootCalendar);
}

/** 
 * Handle processing of key/value pair
 *
 * Params:
 *   context = Current processing context
 *   currentEntry = The currently processed entry
 *   key = The key to set
 *   value = The provided value
 */
pragma(inline, true) static private void handleEvent(Context context,
        ref ICSEntry currentEntry, const(char[]) key, const(char[]) value) @safe
{
    final switch (context)
    {
    case Context.Calendar:
        handleTypedEvent!Calendar(currentEntry, key, value);
        break;
    case Context.Event:
        handleTypedEvent!Event(currentEntry, key, value);
        break;
    case Context.Todo:
        handleTypedEvent!Todo(currentEntry, key, value);
        break;
    case Context.None:
        throw new Exception("breakdown");
    }
}

/** 
 * Handle event deserialisation
 *
 * Params:
 *   T = Type of struct
 *   currentEntry = The currently processed entry
 *   key = Key to find a icsID for
 *   value = Value to set on the struct
 */
static private void handleTypedEvent(T)(ref ICSEntry currentEntry,
        const(char[]) key, const(char[]) value) @safe if (is(T == struct))
{
    /* Big bada boom */
    T nodeStruct = currentEntry.tryMatch!((T val) => val);

key_check:
    switch (key)
    {
        static foreach (field; FieldNameTuple!T)
        {
            {
                /* Grab the UDA (icsID) and generate case 'identifier' for it */
                mixin("enum fieldIDs = getUDAs!(T." ~ field ~ ", icsID);");
                static if (fieldIDs.length > 0)
                {
                    mixin("enum caseID = fieldIDs[0].identifier;");

                    mixin("alias fieldType = OriginalType!(typeof(nodeStruct." ~ field ~ "));");

    case caseID:
                    /* Set from a string */
                    static if (is(fieldType == string))
                    {
                        mixin(
                                "nodeStruct." ~ field
                                ~ " = () @trusted { return (cast(string)value.dup);}();");
                        break key_check;
                    }
                    /* Set a systime value */
                else static if (is(fieldType == SysTime))
                    {
                        mixin("nodeStruct." ~ field ~ " = SysTime.fromISOString(value);");
                        break key_check;
                    }
                    /* Set a numerical value */
                else static if (!isBoolean!fieldType && isNumeric!fieldType
                            && !isFloatingPoint!fieldType)
                    {
                        fieldType val = to!fieldType(value);
                        /* TODO: Check if the val is valid */
                        mixin("nodeStruct." ~ field ~ " = val;");
                        break key_check;
                    }
                    else
                    {
                        static assert(0,
                                "Unsupported type '" ~ fieldType.stringof
                                ~ "' in " ~ T.stringof ~ "#" ~ field);
                    }
                }
            }
        }
    default:
        writefln!"Unknown: %s.%s"(T.stringof, key);
        break;
    }

    /* Stash it back again */
    () @trusted { currentEntry = nodeStruct; }();
}

@safe @("Test the event parsing")
unittest
{
    auto entry = parseICS("data/event.ics");
    entry.match!((Calendar c) {
        assert(c.events.length == 1, "Should have 1 event");
        auto event = c.events[0];
        assert(event.summary == "Bastille Day Party", "Wrong summary");
        assert(event.dateTimeStamp.year == 1997, "Lost in space");
        writefln!"Got a calendar: %s"(c);
    }, (ICSError e) { assert(0, e.message); });
}

@safe @("Test the TODO parsing")
unittest
{
    auto entry = parseICS("data/todo.ics");
    entry.match!((Calendar c) {
        assert(c.todos.length == 1, "Should have 1 todo");
        auto todo = c.todos[0];
        assert(todo.summary == "Submit Income Taxes", "Wrong summary");
        assert(todo.dateTimeStamp.year == 1998, "Lost in space");
        assert(todo.sequence == 2, "Invalid sequence");
        writefln!"Got a calendar: %s"(c);
    }, (ICSError e) { assert(0, e.message); });
}
