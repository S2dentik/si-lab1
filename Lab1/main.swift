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

let group = Group()
group.addCommand("send", sendCommand)
group.addCommand("listen", listenCommand)
group.run()