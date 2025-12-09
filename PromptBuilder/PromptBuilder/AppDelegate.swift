import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {

    private var window: NSWindow?
    private var statusBarController: StatusBarController?
    private let templateStore = TemplateStore()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Global Option+Shift+P hotkey
        HotKeyManager.shared.registerGlobalHotKey()

        // Status bar icon and menu
        statusBarController = StatusBarController(startNewPromptHandler: { [weak self] in
            self?.handleActivateRequest()
        })

        // Listen for hotkey activation
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleActivateNotification(_:)),
            name: .promptBuilderActivate,
            object: nil
        )

        // Show the main window on first launch
        handleActivateRequest()
    }

    func applicationWillTerminate(_ notification: Notification) {
        HotKeyManager.shared.unregisterGlobalHotKey()
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Activation

    @objc private func handleActivateNotification(_ note: Notification) {
        handleActivateRequest()
    }

    /// Entry point for both the status bar "New prompt" and the hotkey.
    private func handleActivateRequest() {
        print("AppDelegate: handleActivateRequest()")

        showMainWindow()

        // Tell ContentView to reset the wizard and get ready for a new voice prompt.
        NotificationCenter.default.post(name: .promptBuilderStartVoice, object: nil)
    }

    // MARK: - Window management

    private func showMainWindow() {
        if window == nil {
            createMainWindow()
        }

        guard let window = window else { return }

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func createMainWindow() {
        let rootView = ContentView()
            .environmentObject(templateStore)

        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 980, height: 640),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        win.center()
        win.title = "Prompt Builder"
        win.isReleasedWhenClosed = false                      // keep the window object alive
        win.contentView = NSHostingView(rootView: rootView)

        self.window = win
    }
}
