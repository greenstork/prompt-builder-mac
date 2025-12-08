import AppKit

final class StatusBarController: NSObject {

    private let statusItem: NSStatusItem
    private let menu: NSMenu
    private let startNewPromptHandler: () -> Void

    init(startNewPrompt: @escaping () -> Void) {
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.menu = NSMenu()
        self.startNewPromptHandler = startNewPrompt

        super.init()

        if let button = statusItem.button {
            // Use a distinct icon so it is not confused with the generic microphone.
            button.image = NSImage(
                systemSymbolName: "text.bubble",
                accessibilityDescription: "Prompt Builder"
            )
        }

        configureMenu()
    }

    private func configureMenu() {
        // New Prompt
        let newPromptItem = NSMenuItem(
            title: "New prompt    ⌥⇧P",
            action: #selector(didSelectNewPrompt),
            keyEquivalent: ""
        )
        newPromptItem.target = self
        menu.addItem(newPromptItem)

        menu.addItem(.separator())

        // Quit
        let quitItem = NSMenuItem(
            title: "Quit Prompt Builder",
            action: #selector(didSelectQuit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    @objc private func didSelectNewPrompt() {
        startNewPromptHandler()
    }

    @objc private func didSelectQuit() {
        NSApp.terminate(nil)
    }
}
