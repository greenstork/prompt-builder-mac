import Foundation

extension Notification.Name {
    /// Sent by AppDelegate whenever a new prompt should start.
    static let promptBuilderStartVoice = Notification.Name("PromptBuilderStartVoice")

    /// Sent by HotKeyManager when the global hotkey fires.
    static let promptBuilderActivate = Notification.Name("PromptBuilderActivate")
}
