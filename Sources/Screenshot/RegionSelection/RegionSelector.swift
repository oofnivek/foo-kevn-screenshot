import AppKit

/// Presents a full-desktop overlay so the user can drag-select an arbitrary
/// rectangular region on any connected display, then returns the selection
/// in Cocoa screen coordinates (origin bottom-left, y-up), or nil if cancelled.
///
/// One borderless window is created per `NSScreen` rather than a single
/// window spanning the union of all screens. With the (default) "Displays
/// have separate Spaces" setting, macOS only renders a window on the one
/// display/Space it's assigned to, so a single window whose frame spans two
/// monitors would silently fail to appear on the second one.
enum RegionSelector {
    private static var activeWindows: [SelectionOverlayWindow] = []

    static func select(completion: @escaping (CGRect?) -> Void) {
        let screens = NSScreen.screens
        guard !screens.isEmpty else {
            completion(nil)
            return
        }

        var finished = false
        func finish(_ rect: CGRect?) {
            guard !finished else { return }
            finished = true
            for window in activeWindows {
                window.orderOut(nil)
            }
            activeWindows = []
            completion(rect)
        }

        let windows = screens.map { screen -> SelectionOverlayWindow in
            let window = SelectionOverlayWindow(coveringFrame: screen.frame)
            let view = SelectionOverlayView(frame: CGRect(origin: .zero, size: screen.frame.size))
            view.onFinish = { localRect in
                guard let localRect else {
                    finish(nil)
                    return
                }
                let screenRect = CGRect(
                    x: localRect.minX + window.frame.minX,
                    y: localRect.minY + window.frame.minY,
                    width: localRect.width,
                    height: localRect.height
                )
                finish(screenRect)
            }
            window.contentView = view
            return window
        }

        activeWindows = windows
        for window in windows {
            window.orderFront(nil)
        }
        if let mainWindow = windows.first(where: { $0.screen == NSScreen.main }) ?? windows.first {
            mainWindow.makeKeyAndOrderFront(nil)
            if let view = mainWindow.contentView as? SelectionOverlayView {
                mainWindow.makeFirstResponder(view)
            }
        }
        NSCursor.crosshair.set()
    }
}
