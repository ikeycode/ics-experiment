/*
 * SPDX-FileCopyrightText: Copyright © 2020-2023 Ikey Doherty
 *
 * SPDX-License-Identifier: Zlib
 */

/**
 * ics.todo
 *
 * Support for ICS TODOs
 *
 * Authors: Copyright © 2020-2023 Ikey Doherty
 * License: Zlib
 */

module ics.todo;

public import ics : icsID;
public import ics.calendar : Calendar;
public import std.datetime.systime;
public import std.stdint : uint64_t;

/** 
 * Encapsulates an ICS TODO
 */
public struct Todo
{
    /** 
     * Unique identifier for this TODO
     */
    @icsID("UID") string uid;

    /** 
     * How many times has this been modified?
     */
    @icsID("SEQUENCE") uint64_t sequence;

    /** 
     * Creation date/time stamp
     */
    @icsID("DTSTAMP") SysTime dateTimeStamp;

    /** 
     * When is this due by?
     */
    @icsID("DUE") SysTime dateTimeDue;

    /** 
     * i.e. NEEDS-ACTION
     * TODO: Convert to an enum
     */
    @icsID("STATUS") string status;

    /**
     * Contents of the TODO
     */
    @icsID("SUMMARY") string summary;

package:

    Calendar* _parent;
}
