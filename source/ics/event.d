/*
 * SPDX-FileCopyrightText: Copyright © 2020-2023 Ikey Doherty
 *
 * SPDX-License-Identifier: Zlib
 */

/**
 * ics.event
 *
 * Support for ICS events
 *
 * Authors: Copyright © 2020-2023 Ikey Doherty
 * License: Zlib
 */

module ics.event;

public import ics : icsID;
public import std.datetime.systime;

/** 
 * Encapsultes an ICS Event
 */
public struct Event
{
    /**
     * Unique identifier for the event 
     */
    @icsID("UID") string uid;

    /** 
     * Full date/time stamp of the event
     */
    @icsID("DTSTAMP") SysTime dateTimeStamp;

    /** 
     * When does the event start?
     */
    @icsID("DTSTART") SysTime dateTimeStart;

    /**
     * When does the event end?
     */
    @icsID("DTEND") SysTime dateTimeEnd;

    /** 
     * Description of the event
     */
    @icsID("SUMMARY") string summary;
}
