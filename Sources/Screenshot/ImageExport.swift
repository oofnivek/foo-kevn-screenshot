import SwiftUI
import AppKit
import UniformTypeIdentifiers

private struct ComposedAnnotationView: View {
    let image: NSImage
    let shapes: [AnnotationShape]
    let lineWidthScale: CGFloat

    var body: some View {
        ZStack {
            Image(nsImage: image)
            Canvas { context, _ in
                for shape in shapes {
                    let rect = CGRect(
                        x: shape.rect.origin.x * image.size.width,
                        y: shape.rect.origin.y * image.size.height,
                        width: shape.rect.width * image.size.width,
                        height: shape.rect.height * image.size.height
                    )
                    let path = pathFor(type: shape.type, rect: rect)
                    context.stroke(path, with: .color(shape.color), lineWidth: shape.lineWidth * lineWidthScale)
                }
            }
        }
        .frame(width: image.size.width, height: image.size.height)
    }
}

@MainActor
enum ImageExport {
    static func composedImage(screenshot: NSImage, shapes: [AnnotationShape], displaySize: CGSize) -> NSImage? {
        let lineWidthScale = displaySize.width > 0 ? screenshot.size.width / displaySize.width : 1
        let renderer = ImageRenderer(
            content: ComposedAnnotationView(image: screenshot, shapes: shapes, lineWidthScale: lineWidthScale)
        )
        renderer.scale = 1
        return renderer.nsImage
    }

    static func copyToClipboard(_ image: NSImage) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects([image])
    }

    static func saveToFile(_ image: NSImage) {
        guard
            let tiffData = image.tiffRepresentation,
            let bitmap = NSBitmapImageRep(data: tiffData),
            let pngData = bitmap.representation(using: .png, properties: [:])
        else { return }

        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png]
        panel.nameFieldStringValue = defaultFileName()
        guard panel.runModal() == .OK, let url = panel.url else { return }

        try? pngData.write(to: url)
    }

    private static func defaultFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH.mm.ss"
        return "Screenshot \(formatter.string(from: Date()))"
    }
}
