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
public ICSEntry parseICS(string filepath) @safe
{
    return ICSEntry(ICSError("Not implemented"));
}

@safe @("Test the event parsing")
unittest
{
    auto entry = parseICS("data/event.ics");
    auto cal = entry.tryMatch!((Calendar c) => c);
}

@safe @("Test the TODO parsing")
unittest
{
    auto entry = parseICS("data/todo.ics");
    auto cal = entry.tryMatch!((Calendar c) => c);
}
