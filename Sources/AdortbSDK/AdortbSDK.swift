import Foundation

public final class AdortbSDK {
    public static let shared = AdortbSDK()

    private(set) var config: AdortbConfig?
    private(set) var loader: AdLoader?

    private init() {}

    public func configure(publisherID: String, serverURL: URL, eventServerURL: URL? = nil, timeout: TimeInterval = 3.0, debug: Bool = false) {
        let eventURL: URL
        if let customEventURL = eventServerURL {
            eventURL = customEventURL
        } else {
            // 默认事件端口 8083
            var components = URLComponents(url: serverURL, resolvingAgainstBaseURL: false) ?? URLComponents()
            components.port = 8083
            eventURL = components.url ?? serverURL
        }

        let cfg = AdortbConfig(
            publisherID: publisherID,
            serverURL: serverURL,
            eventURL: eventURL,
            timeout: timeout,
            debug: debug
        )
        self.config = cfg
        self.loader = AdLoader(config: cfg)
    }

    public func loadNativeAd(slotID: String, completion: @escaping (Result<NativeAd, AdError>) -> Void) {
        guard let loader = loader else {
            completion(.failure(.notInitialized))
            return
        }

        let slot = AdSlot(slotID: slotID, adType: .native, size: .banner300x250)
        loader.requestBid(slot: slot) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard let seatbid = response.seatbid?.first,
                          let bid = seatbid.bid.first,
                          let nativeData = bid.native else {
                        completion(.failure(.noBid))
                        return
                    }
                    let nativeAd = NativeAd(
                        slotID: slotID,
                        data: nativeData,
                        nurl: bid.nurl,
                        reporter: loader.makeEventReporter(),
                        deviceID: PrivacyCompat.shared.deviceID
                    )
                    completion(.success(nativeAd))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    public var isConfigured: Bool { config != nil }

    public var sdkVersion: String { "1.0.0" }
}
