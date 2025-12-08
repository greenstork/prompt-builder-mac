import SwiftUI
import AppKit

@main
struct PromptBuilderApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var templateStore = TemplateStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(templateStore)
        }
        .commands {
            CommandMenu("Prompt Builder") {
                Button("Start voice prompt") {
                    NotificationCenter.default.post(name: .promptBuilderStartVoice, object: nil)
                }
                .keyboardShortcut("p", modifiers: [.option, .shift])  // ⌥⇧P
            }
        }
    }
}
