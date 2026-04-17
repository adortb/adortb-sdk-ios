import Foundation

#if canImport(AppTrackingTransparency)
import AppTrackingTransparency
import AdSupport
#endif

public enum TrackingStatus {
    case authorized
    case denied
    case restricted
    case notDetermined
}

public final class PrivacyCompat {
    public static let shared = PrivacyCompat()
    private init() {}

    public var trackingStatus: TrackingStatus {
        #if canImport(AppTrackingTransparency)
        if #available(iOS 14, *) {
            switch ATTrackingManager.trackingAuthorizationStatus {
            case .authorized: return .authorized
            case .denied: return .denied
            case .restricted: return .restricted
            case .notDetermined: return .notDetermined
            @unknown default: return .notDetermined
            }
        }
        #endif
        return .authorized
    }

    public var idfa: String? {
        #if canImport(AppTrackingTransparency)
        if #available(iOS 14, *) {
            guard ATTrackingManager.trackingAuthorizationStatus == .authorized else { return nil }
        }
        if #available(iOS 14, *) {
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString
        }
        #endif
        #if canImport(AdSupport)
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
        #else
        return nil
        #endif
    }

    public var idfv: String? {
        UIDevice.current.identifierForVendor?.uuidString
    }

    public var deviceID: String? {
        idfa ?? idfv
    }

    public var dnt: Int {
        trackingStatus == .denied || trackingStatus == .restricted ? 1 : 0
    }

    public func requestTrackingAuthorization(completion: @escaping (TrackingStatus) -> Void) {
        #if canImport(AppTrackingTransparency)
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized: completion(.authorized)
                    case .denied: completion(.denied)
                    case .restricted: completion(.restricted)
                    case .notDetermined: completion(.notDetermined)
                    @unknown default: completion(.notDetermined)
                    }
                }
            }
            return
        }
        #endif
        completion(.authorized)
    }
}

import UIKit
