// EventLoop.swift
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

public typealias EvPtr = COpaquePointer

public protocol EventLoopDelegate {
	func serverSocketEvent(event: Event)
	func clientSocketEvent(event: Event)
}

public class EventLoop
{
	public static let defaultLoop = EventLoop()

	private let eventBase: EvPtr
	private var events:    [Event] = [Event]()

	public var delegate: EventLoopDelegate?

	private static var eventCallBack: CEventCallBack {
		let callback: CEventCallBack = {
			(a,b,c) in
			// Get us back inside swift ASAP.
			// Right now we don't pass the event/socket object as a userInfo
			// instance as I have noticed it can actually cause a segmentation fault
			// Why, I do not know, maybe a compiler / swift opensource issue?
			EventLoop.defaultLoop.fireEvent(a, type: b, userInfo: c)
		}
		return callback
	}

	/**
	 * Unblocks a socket from the thread. Use this instead of accept() and
	 * receive etc. when working with sockets
	 *
	 * @return void
	**/
	public class func unblockSocket(socket: TCPSocket) -> Void {
		evutil_make_socket_nonblocking(socket.fileDescriptor)
	}

	init() {
		eventBase = event_base_new()
	}

	deinit {
		event_free(eventBase)
	}

	public func fireEvent(fd: Int32, type: Int16, userInfo: UnsafeMutablePointer<Void>) -> Void {
		for event in events {
			if( event.socket!.fileDescriptor == fd ) {

				// Determine the type of socket we're dealing with here
				// in order to call the right delegate method.
				if let _ = (event.socket as? TCPServerSocket) {
					delegate?.serverSocketEvent(event)
				} else if let _ = (event.socket as? TCPClientSocket) {
					delegate?.clientSocketEvent(event)
				} else {
					print("Unknown socket in socket event!")
					remove(event.socket!) // THIS CAN BE OPTIMIZED ( direct removal in this loop )
				}
				return
			}
		}
		print("Event was fired but unable to find the event/socket")
	}

	public func add(socket: TCPSocket, event: Event) -> Void {
		// TODO: Probably check if the event already exists in our list
		event.socket = socket
		event.register(socket.fileDescriptor, eventBase: eventBase, callback: EventLoop.eventCallBack)
		events.append(event)
	}

	public func remove(socket: TCPSocket) {
		for (index, element) in events.enumerate() {
			if( element.socket!.fileDescriptor == socket.fileDescriptor ) {
				events.removeAtIndex(index)
				break
			}
		}
		//events = events.filter{ ($0.socket!) !== socket }
	}

	public func run() {
		let r = event_base_dispatch(eventBase)
		if( r == 1 ) {
			run()
		} else if( r == -1 ) {
			// TODO: Throw?
			print("Event loop error")
		}
	}
}
