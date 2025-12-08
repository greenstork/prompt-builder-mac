import SwiftUI

@main
struct PromptBuilderApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(TemplateStore())
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusBarController: StatusBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarController = StatusBarController {
            // When the user clicks "New prompt" in the menu bar
            NotificationCenter.default.post(name: .promptBuilderShowMainWindow, object: nil)
        }
    }
}

extension Notification.Name {
    static let promptBuilderShowMainWindow = Notification.Name("promptBuilderShowMainWindow")
}
