import Foundation

struct BidRequestImp: Encodable {
    let id: String
    let banner: BannerObject?
    let native: NativeObject?

    struct BannerObject: Encodable {
        let w: Int
        let h: Int
    }

    struct NativeObject: Encodable {
        let request: String
    }
}

struct BidRequestApp: Encodable {
    let bundle: String
    let name: String
    let publisher: BidRequestPublisher
}

struct BidRequestPublisher: Encodable {
    let id: String
}

struct BidRequestDevice: Encodable {
    let ua: String
    let make: String
    let model: String
    let os: String
    let osv: String
    let w: Int
    let h: Int
    let ifa: String?
    let dnt: Int
}

struct BidRequest: Encodable {
    let id: String
    let imp: [BidRequestImp]
    let app: BidRequestApp
    let device: BidRequestDevice
}
