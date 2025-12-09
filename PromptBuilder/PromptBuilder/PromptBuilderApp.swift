import SwiftUI

@main
struct PromptBuilderApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // No normal windows managed by SwiftUI.
        // The AppDelegate creates and manages the main window.
        Settings {
            EmptyView()
        }
    }
}
