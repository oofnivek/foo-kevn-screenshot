import SwiftUI
import AppKit

struct ContentView: View {
    @State private var screenshot: NSImage?
    @State private var shapes: [AnnotationShape] = []
    @State private var shapeType: AnnotationShapeType = .rectangle
    @State private var color: Color = .red
    @State private var lineWidth: CGFloat = 5
    @State private var canvasDisplaySize: CGSize = .zero

    var body: some View {
        VStack(spacing: 0) {
            if let screenshot {
                controls
                Divider()
                AnnotationCanvasView(
                    image: screenshot,
                    shapes: $shapes,
                    currentType: shapeType,
                    currentColor: color,
                    currentLineWidth: lineWidth
                )
                .onPreferenceChange(CanvasDisplaySizeKey.self) { canvasDisplaySize = $0 }
            } else {
                emptyState
            }
        }
        .frame(minWidth: 300, maxWidth: .infinity, minHeight: 200, maxHeight: .infinity)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                NSApplication.shared.windows.first?.setContentSize(NSSize(width: 640, height: 480))
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Take a screenshot to get started")
                .foregroundStyle(.secondary)
            Button("Take Screenshot") {
                takeScreenshot()
            }
            .keyboardShortcut("s", modifiers: [.command])
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var controls: some View {
        HStack(spacing: 10) {
            Button {
                takeScreenshot()
            } label: {
                Image(systemName: "camera")
            }
            .keyboardShortcut("s", modifiers: [.command])
            .help("New Screenshot")
            .frame(height: 24)

            Picker("Shape", selection: $shapeType) {
                ForEach(AnnotationShapeType.allCases) { type in
                    Image(systemName: type.systemImage)
                        .tag(type)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .fixedSize()
            .help(shapeType.rawValue)
            .frame(height: 24)

            ColorPicker("Color", selection: $color)
                .labelsHidden()
                .fixedSize()
                .frame(height: 24)

            HStack(spacing: 10) {
                Slider(value: $lineWidth, in: 1...20)
                    .frame(width: 60)
                Text("\(Int(lineWidth))")
                    .frame(width: 20)
                    .monospacedDigit()
            }
            .help("Width")
            .frame(height: 24)

            Button {
                undo()
            } label: {
                Image(systemName: "arrow.uturn.backward")
            }
            .keyboardShortcut("z", modifiers: [.command])
            .disabled(shapes.isEmpty)
            .help("Undo")
            .frame(height: 24)

            Button(role: .destructive) {
                shapes.removeAll()
            } label: {
                Image(systemName: "trash")
            }
            .disabled(shapes.isEmpty)
            .help("Clear")
            .frame(height: 24)

            Button {
                copyToClipboard()
            } label: {
                Image(systemName: "doc.on.doc")
            }
            .keyboardShortcut("c", modifiers: [.command, .shift])
            .help("Copy to Clipboard")
            .frame(height: 24)

            Button {
                saveToFile()
            } label: {
                Image(systemName: "square.and.arrow.down")
            }
            .keyboardShortcut("s", modifiers: [.command, .shift])
            .help("Save As…")
            .frame(height: 24)
        }
        .padding(8)
    }

    private func undo() {
        guard !shapes.isEmpty else { return }
        shapes.removeLast()
    }

    private func copyToClipboard() {
        guard let screenshot,
              let composed = ImageExport.composedImage(screenshot: screenshot, shapes: shapes, displaySize: canvasDisplaySize)
        else { return }
        ImageExport.copyToClipboard(composed)
    }

    private func saveToFile() {
        guard let screenshot,
              let composed = ImageExport.composedImage(screenshot: screenshot, shapes: shapes, displaySize: canvasDisplaySize)
        else { return }
        ImageExport.saveToFile(composed)
    }

    private func takeScreenshot() {
        let window = NSApplication.shared.windows.first
        ScreenshotCapture.captureRegion(hiding: window) { image in
            guard let image else { return }
            self.shapes.removeAll()
            self.screenshot = image
        }
    }
}
