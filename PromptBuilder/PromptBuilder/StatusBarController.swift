import AppKit

final class StatusBarController {
    private let statusItem: NSStatusItem

    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            // Pick a symbol that feels like "prompt builder", not the system mic.
            // Feel free to swap to another SF Symbol, e.g. "square.and.pencil", "doc.text", etc.
            button.image = NSImage(
                systemSymbolName: "square.and.pencil",
                accessibilityDescription: "Prompt Builder"
            )
            button.image?.isTemplate = true   // let macOS tint it appropriately

            // Important: no action/target here, so click shows the menu instead of firing directly
            button.action = nil
            button.target = nil
        }

        constructMenu()
    }

    private func constructMenu() {
        let menu = NSMenu()

        // New prompt
        let newPromptItem = NSMenuItem(
            title: "New prompt",
            action: #selector(newPrompt),
            keyEquivalent: ""
        )
        newPromptItem.target = self
        menu.addItem(newPromptItem)

        menu.addItem(NSMenuItem.separator())

        // Quit application
        let quitItem = NSMenuItem(
            title: "Quit Prompt Builder",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    @objc private func newPrompt() {
        // Bring app to front
        NSApp.activate(ignoringOtherApps: true)
        if let window = NSApp.windows.first {
            window.makeKeyAndOrderFront(nil)
        }

        // Trigger step 1 of the wizard (our handler in ContentView)
        NotificationCenter.default.post(name: .promptBuilderStartVoice, object: nil)
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
