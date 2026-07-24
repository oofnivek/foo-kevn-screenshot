import AppKit

/// Presents a full-desktop overlay so the user can drag-select an arbitrary
/// rectangular region (spanning any screen). Returns the selection in Cocoa
/// screen coordinates (origin bottom-left, y-up), or nil if cancelled.
enum RegionSelector {
    private static var activeWindow: SelectionOverlayWindow?

    static func select(completion: @escaping (CGRect?) -> Void) {
        let unionFrame = NSScreen.screens.reduce(CGRect.null) { $0.union($1.frame) }
        guard !unionFrame.isEmpty else {
            completion(nil)
            return
        }

        let window = SelectionOverlayWindow(coveringFrame: unionFrame)
        let view = SelectionOverlayView(frame: CGRect(origin: .zero, size: unionFrame.size))
        view.onFinish = { rect in
            activeWindow?.orderOut(nil)
            activeWindow = nil
            completion(rect)
        }
        window.contentView = view
        activeWindow = window

        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(view)
        NSCursor.crosshair.set()
    }
}
