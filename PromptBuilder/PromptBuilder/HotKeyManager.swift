import Cocoa
import Carbon

final class HotKeyManager {
    static let shared = HotKeyManager()

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?

    func registerGlobalHotKey() {
        unregisterGlobalHotKey()

        // Option + Shift
        let modifiers: UInt32 = UInt32(optionKey | shiftKey)
        let keyCode: UInt32 = UInt32(kVK_ANSI_P)   // the "P" key

        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType(0)  // signature is unused here
        hotKeyID.id = UInt32(1)

        var eventSpec = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        // Callback for when the hotkey is pressed
        let callback: EventHandlerUPP = { _, event, _ in
            var hkID = EventHotKeyID()
            GetEventParameter(
                event,
                EventParamName(kEventParamDirectObject),
                EventParamType(typeEventHotKeyID),
                nil,
                MemoryLayout<EventHotKeyID>.size,
                nil,
                &hkID
            )

            if hkID.id == 1 {
                NotificationCenter.default.post(name: .promptBuilderStartVoice, object: nil)
            }

            return noErr
        }

        // Install the handler
        let statusHandler = InstallEventHandler(
            GetEventDispatcherTarget(),
            callback,
            1,
            &eventSpec,
            nil,
            &eventHandlerRef
        )

        if statusHandler != noErr {
            NSLog("Failed to install hotkey event handler, status \(statusHandler)")
        }

        // Register the hot key
        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetEventDispatcherTarget(),
            0,
            &hotKeyRef
        )

        if status != noErr {
            NSLog("Failed to register global hot key, status \(status)")
        }
    }

    func unregisterGlobalHotKey() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        if let eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
            self.eventHandlerRef = nil
        }
    }
}
