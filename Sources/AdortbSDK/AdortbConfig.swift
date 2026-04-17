import Foundation

public struct AdortbConfig {
    public let publisherID: String
    public let serverURL: URL
    public let eventURL: URL
    public let timeout: TimeInterval
    public let debug: Bool

    public init(
        publisherID: String,
        serverURL: URL,
        eventURL: URL? = nil,
        timeout: TimeInterval = 3.0,
        debug: Bool = false
    ) {
        self.publisherID = publisherID
        self.serverURL = serverURL
        self.eventURL = eventURL ?? serverURL.deletingLastPathComponent().appendingPathComponent("").absoluteURL
        self.timeout = timeout
        self.debug = debug
    }
}
