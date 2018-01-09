import SwiftSocket

struct Sender {

    private let client: TCPClient
    private var isConnected = false

    init(address: String, port: Int32) {
        client = TCPClient(address: address, port: port)
    }

    mutating func send(_ message: String) {
        if !isConnected { connect() }
        switch client.send(string: message) {
        case .success:
            log("Sent \"\(message)\"")
        case .failure(let error):
            log("Failed to send \"\(message)\" - \(error.localizedDescription)")
        }
    }

    /// Blocks the current thread
    mutating private func connect() {
        while true {
            switch client.connect(timeout: 1) {
            case .success:
                log("Successfully connected to receiver - \(client.address):\(client.port)")
                self.isConnected = true
                return
            case .failure(let error):
                log("Couldn't connect to receiver - \(error.localizedDescription)")
                sleep(1)
            }
        }
    }
}
