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

public import ics : ICSEntry, ICSError, icsID;
public import std.sumtype;
import ics.calendar;
import ics.event;
import std.stdio : File, KeepTerminator, writefln;
import std.string : indexOf, format;

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
 * Returns: A Valid calendar ICSEntry or an ICSError
 */
public ICSEntry parseICS(string filepath) @trusted
{
    auto fi = File(filepath, "r");
    scope (exit)
    {
        fi.close();
    }

    auto context = Context.None;
    auto prevContext = Context.None;

    /**
     * Walk every line by the \r\n ending
     *
     * TODO: Support multiline descriptions indent by space
     */
    foreach (ref line; fi.byLine(KeepTerminator.no, requiredLineEnding))
    {
        if (line.length < minLineLength)
        {
            return ICSEntry(ICSError("Line length too short"));
        }

        immutable colonIndex = line.indexOf(keyvalSeparator);
        if (colonIndex < 1)
        {
            return ICSEntry(ICSError("Line doesn't include key/value mapping"));
        }

        const key = line[0 .. colonIndex];
        const value = line[colonIndex + 1 .. $];

        switch (key)
        {
        case "BEGIN":
            /* Set the current scope */
            writefln!"Begin scope: %s"(value);
            prevContext = context;
            switch (value)
            {
            case "VCALENDAR":
                context = Context.Calendar;
                break;
            case "VEVENT":
                context = Context.Event;
                break;
            case "VTODO":
                context = Context.Todo;
                break;
            default:
                return ICSEntry(ICSError(format!"Unhandled scope: %s"(value)));
            }
            break;
        case "END":
            context = prevContext;
            prevContext = Context.None;
            writefln!"End scope: %s"(value);
            break;
        default:
            writefln!"Unhandled: %s"(value);
            break;
        }
    }

    return ICSEntry(ICSError("unparsed"));
}

/** 
 * Handle processing of key/value pair
 *
 * Params:
 *   context = Current processing context
 *   key = The key to set
 *   value = The provided value
 */
private void handleEvent(Context context, scope const ref string key, scope const ref string value) @safe
{

}

@safe @("Test the event parsing")
unittest
{
    auto entry = parseICS("data/event.ics");
    entry.match!((Calendar _) {}, (ICSError e) { assert(0, e.message); });
}

@safe @("Test the TODO parsing")
unittest
{
    auto entry = parseICS("data/todo.ics");
    auto cal = entry.tryMatch!((Calendar c) => c);
}
