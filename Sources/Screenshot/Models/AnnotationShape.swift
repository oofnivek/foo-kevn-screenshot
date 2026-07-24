import SwiftUI

enum AnnotationShapeType: String, CaseIterable, Identifiable {
    case rectangle = "Rectangle"
    case oval = "Oval"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .rectangle: return "rectangle"
        case .oval: return "circle"
        }
    }
}

struct AnnotationShape: Identifiable {
    let id = UUID()
    var type: AnnotationShapeType
    var rect: CGRect
    var color: Color
    var lineWidth: CGFloat
}
