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

/** 
 * Separators and \r\n
 */
private static const minLineLength = 4;

/** 
 * Every line requires a proper format ending
 */
private static const requiredLineEnding = "\r\n";

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

    foreach (ref line; fi.byLine(KeepTerminator.no, requiredLineEnding))
    {
        if (line.length < minLineLength)
        {
            return ICSEntry(ICSError("Line length too short"));
        }
        writefln!"__debug: Processing: %s"(line);
    }
    return ICSEntry(ICSError("unparsed"));
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
