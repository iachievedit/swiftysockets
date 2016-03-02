// Event.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2016 Antwan van Houdt
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import EventC

typealias CEventCallBack = @convention(c) (Int32, Int16, UnsafeMutablePointer<Void>) -> ()

public final class Event
{
	public var type: Int32
	public var socket: TCPSocket?
	private(set) var event: EvPtr?

	/**
	 * "Accept" events are automatically made persistent
	 * as they most often will be used for a server scenario where multiple
	 * connections are to be expected ( and handled )
	**/
	public class func acceptEvent() -> Event {
		return Event(evType: EV_READ+EV_PERSIST)
	}

	public class func readableEvent() -> Event {
		return Event(evType: EV_READ)
	}

	public class func writableEvent() -> Event {
		return Event(evType: EV_WRITE)
	}

	public class func readWriteEvent() -> Event {
		return Event(evType: EV_WRITE+EV_READ)
	}

	init(evType: Int32 = 0x0) {
		type    = evType
		socket  = nil
	}

	deinit {
		if let ev = event {
			event_del(ev)
			event_free(ev)
		}
	}

	public func register(fd: Int32, eventBase: EvPtr, callback: CEventCallBack) {
		if( event == nil ) {
			event = event_new(
				eventBase,
				fd,
				Int16(type),
				callback,
				nil
			)
			event_add(event!, nil)
		} else {
			print("Event \(self) is already registered")
		}
	}

	public func remove() {
		guard let ev = event else {
			return
		}
		event_del(ev)
		event_free(ev)
		event = nil
	}

	public func makePersistent() {
		if( (type & EV_PERSIST) == 0 ) {
			type = type + EV_PERSIST
		}
	}
}
