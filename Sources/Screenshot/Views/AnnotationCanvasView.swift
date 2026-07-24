import SwiftUI

func pathFor(type: AnnotationShapeType, rect: CGRect) -> Path {
    switch type {
    case .rectangle: return Path(rect)
    case .oval: return Path(ellipseIn: rect)
    }
}

struct CanvasDisplaySizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct AnnotationCanvasView: View {
    let image: NSImage
    @Binding var shapes: [AnnotationShape]
    var currentType: AnnotationShapeType
    var currentColor: Color
    var currentLineWidth: CGFloat

    @State private var dragStart: CGPoint?
    @State private var dragCurrent: CGPoint?

    var body: some View {
        GeometryReader { geo in
            let displaySize = fittedSize(imageSize: image.size, in: geo.size)

            ZStack {
                Image(nsImage: image)
                    .resizable()
                    .frame(width: displaySize.width, height: displaySize.height)

                Canvas { context, _ in
                    for shape in shapes {
                        let path = pathFor(type: shape.type, rect: shape.rect)
                        context.stroke(path, with: .color(shape.color), lineWidth: shape.lineWidth)
                    }
                    if let start = dragStart, let current = dragCurrent {
                        let rect = CGRect(start: start, end: current)
                        let path = pathFor(type: currentType, rect: rect)
                        context.stroke(path, with: .color(currentColor), lineWidth: currentLineWidth)
                    }
                }
                .frame(width: displaySize.width, height: displaySize.height)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 2, coordinateSpace: .local)
                        .onChanged { value in
                            if dragStart == nil { dragStart = value.startLocation }
                            dragCurrent = value.location
                        }
                        .onEnded { value in
                            if let start = dragStart {
                                let rect = CGRect(start: start, end: value.location)
                                if rect.width > 2 && rect.height > 2 {
                                    shapes.append(
                                        AnnotationShape(
                                            type: currentType,
                                            rect: rect,
                                            color: currentColor,
                                            lineWidth: currentLineWidth
                                        )
                                    )
                                }
                            }
                            dragStart = nil
                            dragCurrent = nil
                        }
                )
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .preference(key: CanvasDisplaySizeKey.self, value: displaySize)
        }
    }

    private func fittedSize(imageSize: CGSize, in containerSize: CGSize) -> CGSize {
        guard imageSize.width > 0, imageSize.height > 0,
              containerSize.width > 0, containerSize.height > 0 else {
            return containerSize
        }
        let scale = min(containerSize.width / imageSize.width, containerSize.height / imageSize.height)
        return CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
    }
}

private extension CGRect {
    init(start: CGPoint, end: CGPoint) {
        self.init(
            x: min(start.x, end.x),
            y: min(start.y, end.y),
            width: abs(end.x - start.x),
            height: abs(end.y - start.y)
        )
    }
}
