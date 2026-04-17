import UIKit

public final class ImpressionTracker {
    private weak var targetView: UIView?
    private var displayLink: CADisplayLink?
    private var visibleDuration: TimeInterval = 0
    private var lastTimestamp: CFTimeInterval = 0
    private let visibilityThreshold: Double = 0.5
    private let durationThreshold: TimeInterval = 1.0
    private var hasFired = false
    private let onViewable: () -> Void

    public init(view: UIView, onViewable: @escaping () -> Void) {
        self.targetView = view
        self.onViewable = onViewable
    }

    public func start() {
        guard displayLink == nil else { return }
        let link = CADisplayLink(target: self, selector: #selector(tick(_:)))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    public func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func tick(_ link: CADisplayLink) {
        guard !hasFired, let view = targetView else {
            stop()
            return
        }

        let now = link.timestamp
        let delta = lastTimestamp == 0 ? 0 : now - lastTimestamp
        lastTimestamp = now

        if isViewVisible(view) {
            visibleDuration += delta
            if visibleDuration >= durationThreshold {
                hasFired = true
                stop()
                DispatchQueue.main.async { [weak self] in
                    self?.onViewable()
                }
            }
        } else {
            visibleDuration = 0
        }
    }

    private func isViewVisible(_ view: UIView) -> Bool {
        guard !view.isHidden, view.alpha > 0, view.window != nil else { return false }
        guard let window = view.window else { return false }

        let viewFrameInWindow = view.convert(view.bounds, to: window)
        let windowBounds = window.bounds
        let intersection = viewFrameInWindow.intersection(windowBounds)

        guard !intersection.isNull else { return false }

        let viewArea = view.bounds.width * view.bounds.height
        guard viewArea > 0 else { return false }

        let visibleArea = intersection.width * intersection.height
        return (visibleArea / viewArea) >= CGFloat(visibilityThreshold)
    }
}
