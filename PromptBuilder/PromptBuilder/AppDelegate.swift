import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusBarController: StatusBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        HotKeyManager.shared.registerGlobalHotKey()
        statusBarController = StatusBarController()
    }

    func applicationWillTerminate(_ notification: Notification) {
        HotKeyManager.shared.unregisterGlobalHotKey()
    }
}
