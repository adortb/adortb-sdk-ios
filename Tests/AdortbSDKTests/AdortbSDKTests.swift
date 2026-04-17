import XCTest
@testable import AdortbSDK

final class AdortbSDKTests: XCTestCase {

    // MARK: - AdortbSDK configure

    func testConfigureSetsSdkAsConfigured() {
        let sdk = AdortbSDK.shared
        sdk.configure(
            publisherID: "pub_test",
            serverURL: URL(string: "http://localhost:8080")!
        )
        XCTAssertTrue(sdk.isConfigured)
    }

    func testSdkVersion() {
        XCTAssertFalse(AdortbSDK.shared.sdkVersion.isEmpty)
    }

    // MARK: - AdSize

    func testAdSizeBanner320x50() {
        let size = AdSize.banner320x50
        XCTAssertEqual(size.width, 320)
        XCTAssertEqual(size.height, 50)
    }

    func testAdSizeBanner300x250() {
        let size = AdSize.banner300x250
        XCTAssertEqual(size.width, 300)
        XCTAssertEqual(size.height, 250)
    }

    func testAdSizeCustom() {
        let size = AdSize.custom(width: 480, height: 60)
        XCTAssertEqual(size.width, 480)
        XCTAssertEqual(size.height, 60)
    }

    // MARK: - BidResponse Decoding

    func testBidResponseDecoding() throws {
        let json = """
        {
            "id": "resp-001",
            "seatbid": [{
                "bid": [{
                    "id": "bid-001",
                    "impid": "slot_xxx",
                    "price": 1.5,
                    "adm": "<div>Ad</div>",
                    "nurl": "http://example.com/nurl",
                    "w": 320,
                    "h": 50
                }]
            }],
            "cur": "USD"
        }
        """
        let data = json.data(using: .utf8)!
        let response = try JSONDecoder().decode(BidResponse.self, from: data)
        XCTAssertEqual(response.id, "resp-001")
        XCTAssertEqual(response.seatbid?.first?.bid.first?.price, 1.5)
        XCTAssertEqual(response.seatbid?.first?.bid.first?.adm, "<div>Ad</div>")
        XCTAssertEqual(response.seatbid?.first?.bid.first?.w, 320)
    }

    func testBidResponseNativeDecoding() throws {
        let json = """
        {
            "id": "resp-002",
            "seatbid": [{
                "bid": [{
                    "id": "bid-002",
                    "impid": "slot_native",
                    "price": 2.0,
                    "native": {
                        "title": "Test Ad",
                        "description": "This is a test",
                        "image_url": "http://example.com/img.jpg",
                        "click_url": "http://example.com/click",
                        "sponsored_by": "TestBrand"
                    }
                }]
            }]
        }
        """
        let data = json.data(using: .utf8)!
        let response = try JSONDecoder().decode(BidResponse.self, from: data)
        let nativeData = response.seatbid?.first?.bid.first?.native
        XCTAssertEqual(nativeData?.title, "Test Ad")
        XCTAssertEqual(nativeData?.sponsoredBy, "TestBrand")
        XCTAssertEqual(nativeData?.imageURL, "http://example.com/img.jpg")
    }

    func testEmptySeatbidDecoding() throws {
        let json = """
        {"id": "resp-003", "seatbid": [], "cur": "USD"}
        """
        let data = json.data(using: .utf8)!
        let response = try JSONDecoder().decode(BidResponse.self, from: data)
        XCTAssertTrue(response.seatbid?.isEmpty ?? true)
    }

    // MARK: - EventPayload Encoding

    func testEventPayloadEncoding() throws {
        let payload = EventPayload(
            type: "impression",
            slotID: "slot_abc",
            timestamp: 1700000000000,
            appBundle: "com.example.app",
            deviceID: "device-id-123"
        )
        let data = try JSONEncoder().encode(payload)
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        XCTAssertEqual(dict?["type"] as? String, "impression")
        XCTAssertEqual(dict?["slot_id"] as? String, "slot_abc")
        XCTAssertEqual(dict?["device_id"] as? String, "device-id-123")
    }

    // MARK: - PersistentQueue

    func testPersistentQueueEnqueueDequeue() {
        let key = "AdortbSDK.test.queue.\(UUID().uuidString)"
        let queue = PersistentQueue(key: key)

        let data1 = "event1".data(using: .utf8)!
        let data2 = "event2".data(using: .utf8)!
        queue.enqueue(data1)
        queue.enqueue(data2)

        XCTAssertEqual(queue.dequeue(), data1)
        XCTAssertEqual(queue.dequeue(), data2)
        XCTAssertNil(queue.dequeue())

        UserDefaults.standard.removeObject(forKey: key)
    }

    func testPersistentQueueCapAt100() {
        let key = "AdortbSDK.test.cap.\(UUID().uuidString)"
        let queue = PersistentQueue(key: key)

        for i in 0..<110 {
            queue.enqueue("event-\(i)".data(using: .utf8)!)
        }

        var count = 0
        while queue.dequeue() != nil { count += 1 }
        XCTAssertLessThanOrEqual(count, 100)

        UserDefaults.standard.removeObject(forKey: key)
    }

    // MARK: - PrivacyCompat

    func testPrivacyCompatDntDefault() {
        let privacy = PrivacyCompat.shared
        XCTAssertTrue(privacy.dnt == 0 || privacy.dnt == 1)
    }

    // MARK: - AdError

    func testAdErrorDescriptions() {
        XCTAssertNotNil(AdError.notInitialized.errorDescription)
        XCTAssertNotNil(AdError.noBid.errorDescription)
        XCTAssertNotNil(AdError.invalidResponse.errorDescription)
    }
}
