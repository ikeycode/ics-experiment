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
}
