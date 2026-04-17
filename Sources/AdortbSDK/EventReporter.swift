import Foundation

public enum EventType: String, Encodable {
    case impression
    case click
    case viewable
}

struct EventPayload: Encodable {
    let type: String
    let slotID: String
    let timestamp: Int64
    let appBundle: String
    let deviceID: String?

    enum CodingKeys: String, CodingKey {
        case type
        case slotID = "slot_id"
        case timestamp
        case appBundle = "app_bundle"
        case deviceID = "device_id"
    }
}

public final class EventReporter {
    private let eventURL: URL
    private let httpClient: HTTPClient
    private let queue = DispatchQueue(label: "com.adortb.sdk.event", qos: .background)
    private let retryQueue = PersistentQueue(key: "AdortbSDK.eventQueue")

    init(eventURL: URL, timeout: TimeInterval) {
        self.eventURL = eventURL
        self.httpClient = HTTPClient(timeout: timeout)
        replayPendingEvents()
    }

    func report(type: EventType, slotID: String, deviceID: String?) {
        let payload = EventPayload(
            type: type.rawValue,
            slotID: slotID,
            timestamp: Int64(Date().timeIntervalSince1970 * 1000),
            appBundle: Bundle.main.bundleIdentifier ?? "",
            deviceID: deviceID
        )
        sendEvent(payload)
    }

    private func sendEvent(_ payload: EventPayload) {
        guard let data = try? JSONEncoder().encode(payload) else { return }
        queue.async { [weak self] in
            guard let self = self else { return }
            self.httpClient.upload(url: self.eventURL, body: data)
            self.retryQueue.enqueue(data)
        }
    }

    private func replayPendingEvents() {
        queue.async { [weak self] in
            guard let self = self else { return }
            while let data = self.retryQueue.dequeue() {
                self.httpClient.upload(url: self.eventURL, body: data)
            }
        }
    }
}

final class PersistentQueue {
    private let key: String
    private let lock = NSLock()

    init(key: String) {
        self.key = key
    }

    func enqueue(_ data: Data) {
        lock.lock()
        defer { lock.unlock() }
        var queue = load()
        queue.append(data)
        save(queue)
    }

    func dequeue() -> Data? {
        lock.lock()
        defer { lock.unlock() }
        var queue = load()
        guard !queue.isEmpty else { return nil }
        let item = queue.removeFirst()
        save(queue)
        return item
    }

    private func load() -> [Data] {
        guard let raw = UserDefaults.standard.array(forKey: key) as? [Data] else { return [] }
        return raw
    }

    private func save(_ queue: [Data]) {
        let capped = Array(queue.suffix(100))
        UserDefaults.standard.set(capped, forKey: key)
    }
}
