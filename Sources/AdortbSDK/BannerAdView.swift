import UIKit
import SafariServices

public final class BannerAdView: UIView {
    public let slotID: String
    public let adSize: AdSize
    public var onLoaded: ((Result<Void, AdError>) -> Void)?

    private weak var sdk: AdortbSDK?
    private var impressionTracker: ImpressionTracker?
    private var currentClickURL: URL?
    private var nurl: String?
    private var impressionFired = false

    public init(slotID: String, size: AdSize, sdk: AdortbSDK = .shared) {
        self.slotID = slotID
        self.adSize = size
        self.sdk = sdk
        super.init(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        clipsToBounds = true
        backgroundColor = .clear
        addTapGesture()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    public func load(completion: ((Result<Void, AdError>) -> Void)? = nil) {
        self.onLoaded = completion
        guard let sdk = sdk, let loader = sdk.loader else {
            let err = AdError.notInitialized
            completion?(.failure(err))
            return
        }

        let slot = AdSlot(slotID: slotID, adType: .banner, size: adSize)
        loader.requestBid(slot: slot) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    self.handleBidResponse(response, reporter: loader.makeEventReporter())
                case .failure(let error):
                    self.onLoaded?(.failure(error))
                }
            }
        }
    }

    private func handleBidResponse(_ response: BidResponse, reporter: EventReporter) {
        guard let seatbid = response.seatbid?.first,
              let bid = seatbid.bid.first else {
            onLoaded?(.failure(.noBid))
            return
        }

        self.nurl = bid.nurl
        self.currentClickURL = bid.adm.flatMap { _ in nil }

        if let adMarkup = bid.adm {
            renderBanner(markup: adMarkup, w: bid.w ?? adSize.width, h: bid.h ?? adSize.height)
            fireImpression(reporter: reporter)
            setupImpressionTracker(reporter: reporter)
            onLoaded?(.success(()))
        } else {
            onLoaded?(.failure(.noBid))
        }
    }

    private func renderBanner(markup: String, w: Int, h: Int) {
        subviews.forEach { $0.removeFromSuperview() }
        let webView = UIWebViewCompat(frame: CGRect(x: 0, y: 0, width: w, height: h))
        webView.loadHTMLString(markup, baseURL: nil)
        addSubview(webView)
    }

    private func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }

    @objc private func handleTap() {
        guard let url = currentClickURL,
              let vc = nearestViewController() else { return }
        let safari = SFSafariViewController(url: url)
        vc.present(safari, animated: true)
        sdk?.loader?.makeEventReporter().report(
            type: .click, slotID: slotID,
            deviceID: PrivacyCompat.shared.deviceID
        )
    }

    private func fireImpression(reporter: EventReporter) {
        guard !impressionFired else { return }
        impressionFired = true
        reporter.report(type: .impression, slotID: slotID, deviceID: PrivacyCompat.shared.deviceID)
        if let nurlStr = nurl, let url = URL(string: nurlStr) {
            URLSession.shared.dataTask(with: url) { _, _, _ in }.resume()
        }
    }

    private func setupImpressionTracker(reporter: EventReporter) {
        let tracker = ImpressionTracker(view: self) { [weak self, weak reporter] in
            guard let self = self, let reporter = reporter else { return }
            reporter.report(type: .viewable, slotID: self.slotID, deviceID: PrivacyCompat.shared.deviceID)
        }
        self.impressionTracker = tracker
        tracker.start()
    }

    private func nearestViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let r = responder {
            if let vc = r as? UIViewController { return vc }
            responder = r.next
        }
        return nil
    }
}

private final class UIWebViewCompat: UIView {
    private let webView: WKWebView

    override init(frame: CGRect) {
        webView = WKWebView(frame: frame)
        super.init(frame: frame)
        addSubview(webView)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.scrollView.isScrollEnabled = false
    }

    required init?(coder: NSCoder) { fatalError() }

    func loadHTMLString(_ html: String, baseURL: URL?) {
        webView.loadHTMLString(html, baseURL: baseURL)
    }
}

import WebKit
