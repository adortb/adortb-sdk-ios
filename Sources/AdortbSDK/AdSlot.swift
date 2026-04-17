import Foundation

public enum AdSize {
    case banner320x50
    case banner300x250
    case banner728x90
    case custom(width: Int, height: Int)

    var width: Int {
        switch self {
        case .banner320x50: return 320
        case .banner300x250: return 300
        case .banner728x90: return 728
        case .custom(let w, _): return w
        }
    }

    var height: Int {
        switch self {
        case .banner320x50: return 50
        case .banner300x250: return 250
        case .banner728x90: return 90
        case .custom(_, let h): return h
        }
    }
}

public enum AdType {
    case banner
    case native
}

public struct AdSlot {
    public let slotID: String
    public let adType: AdType
    public let size: AdSize

    public init(slotID: String, adType: AdType, size: AdSize) {
        self.slotID = slotID
        self.adType = adType
        self.size = size
    }
}
