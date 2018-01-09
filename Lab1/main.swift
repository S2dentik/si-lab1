import SwiftSocket
import Commander
import Foundation

let sendCommand = command(
    Argument<String>("address", description: "Destination IP address"),
    Argument<Int>("port", description: "Destination port"),
    Argument<String>("message", description: "Message to send"),
    Option<TimeInterval>("repeat_interval", default: 0, description: "The interval at which to repeatedly send the message", validator: { $0 < 0 ? 0 : $0 }),
    Option<Int>("max_repeat_times", default: 1, description: "Maximum number of times to repeatedly send the message", validator: { $0 < 1 ? 1 : $0 })
) { address, port, message, interval, maxRepeat in
    var timesSent = 0
    let send = {
        var sender = Sender(address: address, port: Int32(port))
        sender.send(message)
    }
    var recursivelySend: (() -> Void)!
    recursivelySend = {
        send()
        timesSent += 1
        if timesSent >= maxRepeat { return }
        sleep(UInt32(interval))
        recursivelySend()
    }

    if interval > 0 {
        recursivelySend()
    } else {
        send()
    }

}

let listenCommand = command(
    Argument<String>("address", description: "IP address to be listening on"),
    Argument<Int>("port", description: "Port to be listening on")
) { address, port in
    Receiver(address: address, port: Int32(port)).read { print($0) }
    RunLoop.main.run()
}

let proxyCommand = command(
    Argument<String>("address", description: "IP address to be listening on"),
    Argument<Int>("port", description: "Port to be listenining on"),
    Argument<String>("destination_address", description: "IP address to be proxying to"),
    Argument<Int>("destination_port", description: "Port to be proxying to")
) { address, port, destinationAddress, destinationPort in
    var sender = Sender(address: destinationAddress, port: Int32(destinationPort))
    Receiver(address: address, port: Int32(port)).read {
        sender.send($0)
    }
    RunLoop.main.run()
}

let fileCommand = command(
    Argument<String>("address", description: "IP address to send the file to"),
    Argument<Int>("port", description: "Port to send the file to"),
    Argument<String>("file", description: "Path to the file to send")
) { address, port, file in
    guard let data = FileManager.default.contents(atPath: file), let contents = String(data: data, encoding: .utf8) else {
        return log("File does not exist")
    }
    var sender = Sender(address: address, port: Int32(port))
    sender.send(contents)
}

let group = Group()
group.addCommand("send", sendCommand)
group.addCommand("listen", listenCommand)
group.addCommand("proxy", proxyCommand)
group.addCommand("file", fileCommand)
group.run()
