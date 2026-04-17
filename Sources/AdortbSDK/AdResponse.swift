import Foundation

public struct NativeAdData: Decodable {
    public let title: String?
    public let description: String?
    public let imageURL: String?
    public let clickURL: String?
    public let sponsoredBy: String?

    enum CodingKeys: String, CodingKey {
        case title
        case description
        case imageURL = "image_url"
        case clickURL = "click_url"
        case sponsoredBy = "sponsored_by"
    }
}

struct BidResponseSeatBid: Decodable {
    let bid: [BidResponseBid]
}

struct BidResponseBid: Decodable {
    let id: String
    let impid: String
    let price: Double
    let adm: String?
    let nurl: String?
    let w: Int?
    let h: Int?
    let native: NativeAdData?

    enum CodingKeys: String, CodingKey {
        case id, impid, price, adm, nurl, w, h, native
    }
}

struct BidResponse: Decodable {
    let id: String
    let seatbid: [BidResponseSeatBid]?
    let cur: String?
}

public enum AdError: Error, LocalizedError {
    case notInitialized
    case noBid
    case networkError(Error)
    case invalidResponse
    case encodingError(Error)

    public var errorDescription: String? {
        switch self {
        case .notInitialized: return "SDK not initialized. Call AdortbSDK.shared.configure() first."
        case .noBid: return "No bid received for this slot."
        case .networkError(let err): return "Network error: \(err.localizedDescription)"
        case .invalidResponse: return "Invalid response from server."
        case .encodingError(let err): return "Encoding error: \(err.localizedDescription)"
        }
    }
}
