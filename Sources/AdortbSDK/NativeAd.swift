import Foundation

public final class NativeAd {
    public let slotID: String
    public let title: String?
    public let adDescription: String?
    public let imageURL: URL?
    public let clickURL: URL?
    public let sponsoredBy: String?
    public let nurl: String?

    private let reporter: EventReporter
    private let deviceID: String?
    private var impressionFired = false
    private var clickFired = false

    init(
        slotID: String,
        data: NativeAdData,
        nurl: String?,
        reporter: EventReporter,
        deviceID: String?
    ) {
        self.slotID = slotID
        self.title = data.title
        self.adDescription = data.description
        self.imageURL = data.imageURL.flatMap { URL(string: $0) }
        self.clickURL = data.clickURL.flatMap { URL(string: $0) }
        self.sponsoredBy = data.sponsoredBy
        self.nurl = nurl
        self.reporter = reporter
        self.deviceID = deviceID
    }

    public func recordImpression() {
        guard !impressionFired else { return }
        impressionFired = true
        reporter.report(type: .impression, slotID: slotID, deviceID: deviceID)
        fireNurl()
    }

    public func recordClick() {
        guard !clickFired else { return }
        clickFired = true
        reporter.report(type: .click, slotID: slotID, deviceID: deviceID)
    }

    public func recordViewable() {
        reporter.report(type: .viewable, slotID: slotID, deviceID: deviceID)
    }

    private func fireNurl() {
        guard let nurlString = nurl, let url = URL(string: nurlString) else { return }
        URLSession.shared.dataTask(with: url) { _, _, _ in }.resume()
    }
}
