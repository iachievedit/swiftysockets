// TCPServerSocket.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Zewo
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

import Tide
#if os(Linux)
import Glibc
#else
import Darwin
#endif

public final class TCPServerSocket {
    private var socket: tcpsock
    public private(set) var closed = false

    public var port: Int {
        return Int(tcpport(self.socket))
    }

    public var fileDescriptor: Int32 {
        return tcpfd(socket)
    }

    public init(ip: IP, backlog: Int = 10) throws {
        self.socket = tcplisten(ip.address, Int32(backlog))

        if errno != 0 {
            closed = true
            let description = TCPError.lastSystemErrorDescription
            throw TCPError(description: description)
        }
    }

    public init(fileDescriptor: Int32) throws {
        self.socket = tcpattach(fileDescriptor, 1)

        if errno != 0 {
            closed = true
            let description = TCPError.lastSystemErrorDescription
            throw TCPError(description: description)
        }
    }

    deinit {
        close()
    }

    public func accept() throws -> TCPClientSocket {
        if closed {
            throw TCPError(description: "Closed socket")
        }

        let clientSocket = tcpaccept(socket)

        if errno != 0 {
            let description = TCPError.lastSystemErrorDescription
            throw TCPError(description: description)
        }

        return TCPClientSocket(socket: clientSocket)
    }

    public func attach(fileDescriptor: Int32) throws {
        if !closed {
            tcpclose(socket)
        }

        socket = tcpattach(fileDescriptor, 1)

        if errno != 0 {
            closed = true
            let description = TCPError.lastSystemErrorDescription
            throw TCPError(description: description)
        }

        closed = false
    }

    public func detach() throws -> Int32 {
        if closed {
            throw TCPError(description: "Closed socket")
        }

        closed = true
        return tcpdetach(socket)
    }

    public func close() {
        if !closed {
            closed = true
            tcpclose(socket)
        }
    }
}
