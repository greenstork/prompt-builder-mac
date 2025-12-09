import Cocoa
import Carbon

final class HotKeyManager {

    static let shared = HotKeyManager()
    private init() {}

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?

    func registerGlobalHotKey() {
        guard hotKeyRef == nil else { return }

        // Option + Shift + P
        let keyCode: UInt32 = UInt32(kVK_ANSI_P)
        let modifiers: UInt32 = UInt32(optionKey | shiftKey)

        // Event we care about
        var eventSpec = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let callback: EventHandlerUPP = { _, eventRef, _ in
            guard let eventRef = eventRef else { return noErr }

            var hotKeyID = EventHotKeyID()
            GetEventParameter(
                eventRef,
                UInt32(kEventParamDirectObject),
                UInt32(typeEventHotKeyID),
                nil,
                MemoryLayout.size(ofValue: hotKeyID),
                nil,
                &hotKeyID
            )

            if hotKeyID.id == 1 {
                HotKeyManager.shared.handleHotKeyPressed()
            }

            return noErr
        }

        InstallEventHandler(
            GetEventDispatcherTarget(),
            callback,
            1,
            &eventSpec,
            nil,
            &eventHandlerRef
        )

        var hotKeyID = EventHotKeyID(
            signature: OSType(0x50424248), // 'PBBH' arbitrary signature
            id: 1
        )

        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetEventDispatcherTarget(),
            0,
            &hotKeyRef
        )

        if status != noErr {
            print("HotKeyManager: failed to register hotkey, status \(status)")
        } else {
            print("HotKeyManager: registered Option+Shift+P")
        }
    }

    private func handleHotKeyPressed() {
        print("HotKeyManager: Option+Shift+P pressed")
        NotificationCenter.default.post(name: .promptBuilderActivate, object: nil)
    }

    func unregisterGlobalHotKey() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        if let eventHandlerRef = eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
            self.eventHandlerRef = nil
        }
    }
}
