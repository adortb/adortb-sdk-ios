import Foundation

final class AdLoader {
    private let config: AdortbConfig
    private let httpClient: HTTPClient
    private let reporter: EventReporter

    init(config: AdortbConfig) {
        self.config = config
        self.httpClient = HTTPClient(timeout: config.timeout)
        self.reporter = EventReporter(
            eventURL: config.eventURL.appendingPathComponent("v1/event"),
            timeout: config.timeout
        )
    }

    func requestBid(slot: AdSlot, completion: @escaping (Result<BidResponse, AdError>) -> Void) {
        let device = DeviceInfo.collect()
        let privacy = PrivacyCompat.shared

        let imp = BidRequestImp(
            id: slot.slotID,
            banner: slot.adType == .banner
                ? BidRequestImp.BannerObject(w: slot.size.width, h: slot.size.height)
                : nil,
            native: slot.adType == .native
                ? BidRequestImp.NativeObject(request: "{\"ver\":\"1.1\"}")
                : nil
        )

        let bidRequest = BidRequest(
            id: UUID().uuidString,
            imp: [imp],
            app: BidRequestApp(
                bundle: Bundle.main.bundleIdentifier ?? "",
                name: Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "",
                publisher: BidRequestPublisher(id: config.publisherID)
            ),
            device: BidRequestDevice(
                ua: device.userAgent,
                make: device.make,
                model: device.model,
                os: device.os,
                osv: device.osVersion,
                w: device.screenWidth,
                h: device.screenHeight,
                ifa: privacy.idfa,
                dnt: privacy.dnt
            )
        )

        let bidURL = config.serverURL.appendingPathComponent("v1/bid")
        httpClient.post(url: bidURL, body: bidRequest, responseType: BidResponse.self) { result in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                if let adError = error as? AdError {
                    completion(.failure(adError))
                } else {
                    completion(.failure(.networkError(error)))
                }
            }
        }
    }

    func makeEventReporter() -> EventReporter {
        reporter
    }
}
