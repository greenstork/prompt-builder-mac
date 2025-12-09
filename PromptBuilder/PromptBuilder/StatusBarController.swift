import AppKit

final class StatusBarController {

    private let statusItem: NSStatusItem
    private let startNewPromptHandler: () -> Void

    init(startNewPromptHandler: @escaping () -> Void) {
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.startNewPromptHandler = startNewPromptHandler

        if let button = statusItem.button {
            // Use a distinct icon for Prompt Builder
            button.image = NSImage(
                systemSymbolName: "square.and.pencil",
                accessibilityDescription: "Prompt Builder"
            )
            button.image?.isTemplate = true
        }

        constructMenu()
    }

    // MARK: - Menu

    private func constructMenu() {
        let menu = NSMenu()

        // New prompt (shows ⌥⇧P in the menu)
        let newPromptItem = NSMenuItem(
            title: "New prompt",
            action: #selector(didSelectNewPrompt),
            keyEquivalent: "p"
        )
        newPromptItem.keyEquivalentModifierMask = [.option, .shift]
        newPromptItem.target = self
        menu.addItem(newPromptItem)

        menu.addItem(NSMenuItem.separator())

        // Quit app
        let quitItem = NSMenuItem(
            title: "Quit Prompt Builder",
            action: #selector(didSelectQuit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    // MARK: - Actions

    @objc private func didSelectNewPrompt() {
        print("StatusBarController: New prompt selected from menu")
        startNewPromptHandler()
    }

    @objc private func didSelectQuit() {
        NSApp.terminate(nil)
    }
}
