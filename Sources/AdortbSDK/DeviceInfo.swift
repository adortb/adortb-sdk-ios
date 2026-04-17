import Foundation
import UIKit

struct DeviceInfo {
    let userAgent: String
    let make: String
    let model: String
    let os: String
    let osVersion: String
    let screenWidth: Int
    let screenHeight: Int

    static func collect() -> DeviceInfo {
        let screen = UIScreen.main.bounds
        let scale = UIScreen.main.scale
        return DeviceInfo(
            userAgent: buildUserAgent(),
            make: "Apple",
            model: modelIdentifier(),
            os: "iOS",
            osVersion: UIDevice.current.systemVersion,
            screenWidth: Int(screen.width * scale),
            screenHeight: Int(screen.height * scale)
        )
    }

    private static func buildUserAgent() -> String {
        let systemVersion = UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "_")
        return "Mozilla/5.0 (iPhone; CPU iPhone OS \(systemVersion) like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"
    }

    private static func modelIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)
        let identifier = mirror.children.reduce("") { id, element in
            guard let value = element.value as? Int8, value != 0 else { return id }
            return id + String(UnicodeScalar(UInt8(value)))
        }
        return identifier.isEmpty ? UIDevice.current.model : identifier
    }
}
