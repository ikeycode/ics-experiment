/*
 * SPDX-FileCopyrightText: Copyright © 2020-2023 Ikey Doherty
 *
 * SPDX-License-Identifier: Zlib
 */

/**
 * ics.calendar
 *
 * Support for ICS calendar object
 *
 * Authors: Copyright © 2020-2023 Ikey Doherty
 * License: Zlib
 */

module ics.calendar;

public import ics : icsID;

public import ics.event : Event;
public import ics.todo : Todo;

/** 
 * Encapsultes an ICS Calendar
 */
public struct Calendar
{
    /** 
     * Calendar format version
     */
    @icsID("VERSION") string versionIdentifier;

    /**
     * Product ID used to generate the calendar
     */
    @icsID("PRODID") string productID;

    /** 
     * Any number of owned events
     */
    Event[] events;

    /** 
     * Any number of todos
     */
    Todo[] todos;
}
