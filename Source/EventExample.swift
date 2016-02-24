import Foundation

class TestDelegate: EventLoopDelegate {
	init() {

	}

	func serverSocketEvent(event: Event) {
		guard let serverSock = event.socket as? TCPServerSocket else {
			return
		}
		do {
			let newClient = try serverSock.accept()
			print("Got a new client")
			EventLoop.unblockSocket(newClient)
			// Schedule like the other one
			// Event.acceptEvent() is the same, but this is clearer for the code reader
			let event = Event.readableEvent()
			event.makePersistent()
			EventLoop.defaultLoop.add(newClient, event: event)
		} catch {
			print("\(error)")
		}
	}

	func clientSocketEvent(event: Event) {
		guard let clientSock = event.socket as? TCPClientSocket else {
			return
		}
		do {
			let data = try clientSock.readData()
			print("Client socket: \(String(data: data, encoding: NSUTF8StringEncoding))")
		} catch {
			print("\(error)")
		}
	}
}

do {
	let address = try IP(port: 2554)
	let socket = try TCPServerSocket(ip: address)
	let event = Event.acceptEvent()
	let dele  = TestDelegate()
	EventLoop.defaultLoop.add(socket, event: event)
	EventLoop.defaultLoop.delegate = dele
	EventLoop.defaultLoop.run()
} catch {
	print("\(error)")
}
