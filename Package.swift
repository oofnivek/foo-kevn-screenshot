// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Screenshot",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "Screenshot",
            path: "Sources/Screenshot"
        )
    ]
)
