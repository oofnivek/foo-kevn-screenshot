import AppKit

/// A borderless, transparent window spanning the full desktop (all screens)
/// used purely to host the drag-to-select UI. It sits above everything,
/// including the menu bar, like the system screenshot tool's selection UI.
final class SelectionOverlayWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    init(coveringFrame frame: CGRect) {
        super.init(
            contentRect: frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        ignoresMouseEvents = false
        // Needed so this window gets mouseMoved: even while another of our
        // overlay windows (on a different screen) is the key window — the
        // crosshair cursor is set from mouseMoved rather than relying on
        // cursor rects, which only reliably refresh for the key window.
        acceptsMouseMovedEvents = true
        level = NSWindow.Level(rawValue: Int(CGShieldingWindowLevel()))
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        isReleasedWhenClosed = false
    }
}
