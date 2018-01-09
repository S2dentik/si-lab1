import Foundation

func log(_ message: String, _ file: StaticString = #file) {
    print("[\(URL(string: String(describing: file))!.lastPathComponent.replacingOccurrences(of: ".swift", with: "").uppercased())] \(message)")
}

