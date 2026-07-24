import SwiftUI
import AppKit

struct ContentView: View {
    @State private var screenshot: NSImage?
    @State private var shapes: [AnnotationShape] = []
    @State private var shapeType: AnnotationShapeType = .rectangle
    @State private var color: Color = .red
    @State private var lineWidth: CGFloat = 3

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
            } else {
                emptyState
            }
        }
        .frame(minWidth: 900, minHeight: 650)
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
        HStack(spacing: 16) {
            Button {
                takeScreenshot()
            } label: {
                Label("New Screenshot", systemImage: "camera")
            }
            .keyboardShortcut("s", modifiers: [.command])

            Picker("Shape", selection: $shapeType) {
                ForEach(AnnotationShapeType.allCases) { type in
                    Label(type.rawValue, systemImage: type.systemImage).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 200)

            ColorPicker("Color", selection: $color)
                .frame(width: 140)

            HStack {
                Text("Width")
                Slider(value: $lineWidth, in: 1...20)
                    .frame(width: 120)
                Text("\(Int(lineWidth))")
                    .frame(width: 20)
                    .monospacedDigit()
            }

            Spacer()

            Button(role: .destructive) {
                shapes.removeAll()
            } label: {
                Label("Clear", systemImage: "trash")
            }
            .disabled(shapes.isEmpty)
        }
        .padding(12)
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
