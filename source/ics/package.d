/*
 * SPDX-FileCopyrightText: Copyright © 2020-2023 Ikey Doherty
 *
 * SPDX-License-Identifier: Zlib
 */

/**
 * ics
 *
 * ICS (iCalendar File) parsing support
 *
 * Authors: Copyright © 2020-2023 Ikey Doherty
 * License: Zlib
 */

module ics;

public import ics.event;
public import ics.todo;
public import std.sumtype;

/** 
 * Encapsulates an ICS parsing error
 */
public struct ICSError
{
    /** 
     * Construct a new lightweight ICSError
     *
     * Params:
     *   errorMsg = Underlying cause for the error
     */
    this(in string errorMsg) @safe @nogc
    {
        this._message = errorMsg;
    }

    /** 
     * Returns: Readable error message
     */
    pure string toString() @safe nothrow const
    {
        return _message;
    }

    /** 
     * Expose the message but do not allow modification
     */
    pure @property auto message() @safe @nogc nothrow const
    {
        return _message;
    }

private:
    /** 
     * The error that occured
     */
    string _message;
}

/** 
 * An ICSEntry is an algebraic type that can be a valid entry or an error.
 */
public alias ICSEntry = SumType!(Event, Todo, ICSError);
