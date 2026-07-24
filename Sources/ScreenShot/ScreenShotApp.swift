import SwiftUI

@main
struct ScreenShotApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentMinSize)
        .defaultSize(width: 640, height: 480)
    }
}
