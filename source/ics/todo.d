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
public import std.datetime.systime;

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
}
