import AppKit
import CoreGraphics

enum ScreenshotCapture {
    /// Hides `window`, lets the user drag-select a region of the desktop,
    /// captures exactly that region, then restores `window`.
    /// Calls `completion(nil)` if the user cancels (Escape or a degenerate drag).
    static func captureRegion(hiding window: NSWindow?, completion: @escaping (NSImage?) -> Void) {
        window?.orderOut(nil)

        // Give the window server a moment to actually hide the window before
        // we paint the selection overlay, otherwise it can briefly flash.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            RegionSelector.select { cocoaScreenRect in
                guard let cocoaScreenRect else {
                    window?.makeKeyAndOrderFront(nil)
                    completion(nil)
                    return
                }

                let cgRect = self.cgGlobalRect(fromCocoaScreenRect: cocoaScreenRect)
                let image = self.captureImage(in: cgRect)
                window?.makeKeyAndOrderFront(nil)
                completion(image)
            }
        }
    }

    /// Converts a Cocoa screen rect (origin bottom-left of the primary
    /// screen, y-up) to the CoreGraphics global display space (origin
    /// top-left of the primary screen, y-down) expected by CGWindowListCreateImage.
    private static func cgGlobalRect(fromCocoaScreenRect rect: CGRect) -> CGRect {
        guard let primaryScreen = NSScreen.screens.first else { return rect }
        let primaryHeight = primaryScreen.frame.height
        return CGRect(
            x: rect.minX,
            y: primaryHeight - rect.maxY,
            width: rect.width,
            height: rect.height
        )
    }

    private static func captureImage(in cgRect: CGRect) -> NSImage? {
        guard let cgImage = CGWindowListCreateImage(
            cgRect,
            .optionOnScreenOnly,
            kCGNullWindowID,
            .bestResolution
        ) else {
            return nil
        }
        return NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
    }
}
