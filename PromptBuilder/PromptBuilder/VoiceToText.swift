import Foundation
import Combine
import Speech
import AVFoundation

final class VoiceToText: NSObject, ObservableObject {

    @Published var transcript: String = ""
    @Published var isAuthorized: Bool = false
    @Published var isListening: Bool = false
    @Published var errorMessage: String?

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    // Ask user for speech recognition permission
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                self.isAuthorized = (status == .authorized)
                if !self.isAuthorized {
                    self.errorMessage = "Voice to Text is not authorized in System Settings. Could not capture your voice prompt."
                }
            }
        }
    }

    func start() {
        // Do not start twice
        guard !isListening else { return }

        errorMessage = nil
        transcript = ""

        guard isAuthorized else {
            errorMessage = "Voice to Text is not authorized. Could not read your voice prompt. Please enable it in System Settings and try again."
            return
        }

        guard let recognizer = recognizer, recognizer.isAvailable else {
            errorMessage = "Voice to Text is not available right now. Could not read your voice prompt. Please try again."
            return
        }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        let request = SFSpeechAudioBufferRecognitionRequest()
        self.request = request
        request.shouldReportPartialResults = true

        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let result = result {
                    self.transcript = result.bestTranscription.formattedString
                    if result.isFinal {
                        self.stop()
                    }
                }

                if let error = error {
                    self.errorMessage = "Voice to Text could not understand your voice prompt. Please try again. (\(error.localizedDescription))"
                    self.stop()
                }
            }
        }

        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0,
                             bufferSize: 1024,
                             format: recordingFormat) { [weak self] buffer, _ in
            self?.request?.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
            DispatchQueue.main.async {
                self.isListening = true
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Voice to Text could not start the microphone. Please try your voice prompt again."
                self.stop()
            }
        }
    }

    func stop() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        request?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        DispatchQueue.main.async {
            self.isListening = false
        }
    }

    func reset() {
        transcript = ""
        errorMessage = nil
        if isListening {
            stop()
        }
    }
}
