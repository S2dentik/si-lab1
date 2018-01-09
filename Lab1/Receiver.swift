import SwiftSocket

struct Receiver {

    private let server: TCPServer

    init(address: String, port: Int32) {
        server = TCPServer(address: address, port: port)
    }

    func read(_ handler: @escaping (String) -> Void) {
        Thread.detachNewThread { self.continouslyRead(handler) }
    }

    private func continouslyRead(_ handler: @escaping (String) -> Void) {
        start()
        waitForConnection { client in
            log("Accepted \(client.address):\(client.port)")
            Thread.detachNewThread { self.read(client: client, handler: handler) }
        }
    }

    private func waitForConnection(_ handler: (TCPClient) -> Void) {
        while true {
            server.accept().map(handler)
            sleep(1)
        }
    }

    private func read(client: TCPClient, handler: (String) -> Void) {
        while true {
            var bytes = [Byte]()
            while let newBytes = client.read(1024) {
                bytes += newBytes
            }
            if bytes.isEmpty { return client.close() }
            guard let message = String(data: Data(bytes: bytes), encoding: .utf8) else { continue }
            handler(message)
        }
    }

    /// Block current thread until server starts
    private func start() {
        while true {
            switch server.listen() {
            case .success:
                log("Successfully started")
                return
            case .failure(let error):
                log(error.localizedDescription)
                sleep(1)
            }
        }
    }
}

