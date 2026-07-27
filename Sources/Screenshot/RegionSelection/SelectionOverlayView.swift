import AppKit

/// Draws the dimming scrim + drag rectangle and reports the finished
/// selection (or cancellation) back to the caller.
final class SelectionOverlayView: NSView {
    var onFinish: ((CGRect?) -> Void)?

    private var dragStart: CGPoint?
    private var dragCurrent: CGPoint?

    private var selectionRect: CGRect? {
        guard let start = dragStart, let current = dragCurrent else { return nil }
        return CGRect(
            x: min(start.x, current.x),
            y: min(start.y, current.y),
            width: abs(current.x - start.x),
            height: abs(current.y - start.y)
        )
    }

    override var isFlipped: Bool { false }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.black.withAlphaComponent(0.25).setFill()
        bounds.fill()

        guard let rect = selectionRect else { return }

        // Cut out the selection so it reads as "unshaded".
        NSGraphicsContext.saveGraphicsState()
        NSColor.clear.setFill()
        rect.fill(using: .copy)
        NSGraphicsContext.restoreGraphicsState()

        NSColor.white.setStroke()
        let border = NSBezierPath(rect: rect)
        border.lineWidth = 1.5
        border.stroke()

        drawSizeLabel(for: rect)
    }

    private func drawSizeLabel(for rect: CGRect) {
        let text = "\(Int(rect.width)) × \(Int(rect.height))"
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: NSColor.white,
        ]
        let size = text.size(withAttributes: attrs)
        let padding: CGFloat = 4
        var labelOrigin = CGPoint(x: rect.minX, y: rect.maxY + 6)
        if labelOrigin.y + size.height > bounds.maxY {
            labelOrigin.y = rect.minY - size.height - 12
        }
        let backgroundRect = CGRect(
            x: labelOrigin.x - padding,
            y: labelOrigin.y - padding / 2,
            width: size.width + padding * 2,
            height: size.height + padding
        )
        NSColor.black.withAlphaComponent(0.6).setFill()
        NSBezierPath(roundedRect: backgroundRect, xRadius: 4, yRadius: 4).fill()
        text.draw(at: labelOrigin, withAttributes: attrs)
    }

    override func mouseMoved(with event: NSEvent) {
        NSCursor.crosshair.set()
    }

    override func mouseDown(with event: NSEvent) {
        NSCursor.crosshair.set()
        dragStart = convert(event.locationInWindow, from: nil)
        dragCurrent = dragStart
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        dragCurrent = convert(event.locationInWindow, from: nil)
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        defer {
            dragStart = nil
            dragCurrent = nil
            needsDisplay = true
        }
        guard let rect = selectionRect, rect.width > 4, rect.height > 4 else {
            onFinish?(nil)
            return
        }
        // Reported in view-local coords; RegionSelector translates this to
        // global screen coords using this view's own window's origin.
        onFinish?(rect)
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // Escape
            onFinish?(nil)
        }
    }

    override var acceptsFirstResponder: Bool { true }

    // A click on whichever overlay window isn't yet key would otherwise
    // just activate that window (becoming key) without registering as a
    // real mouseDown — so the very first click on the "other" screen would
    // do nothing. Forward it as a genuine click instead.
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .crosshair)
    }
}
