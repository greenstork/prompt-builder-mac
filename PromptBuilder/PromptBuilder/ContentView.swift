import SwiftUI
import AppKit

private enum WizardStep: Int {
    case chooseTemplate = 0
    case captureContext = 1
    case reviewPrompt = 2
}

struct ContentView: View {
    @State private var step: WizardStep = .chooseTemplate
    @State private var selectedTemplateId: TemplateId = .prd
    @State private var notes: String = ""
    @State private var hasCopied: Bool = false

    @StateObject private var voiceToText = VoiceToText()

    private var currentTemplate: Template {
        template(for: selectedTemplateId)
    }

    private var prompt: String {
        buildPrompt(template: currentTemplate, notes: notes)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Slim wizard header band
            wizardBar

            // Main step content area
            contentForCurrentStep
                .padding(.top, 8)
                .padding(.horizontal, 20)

            Divider()

            // Bottom nav bar
            navigationBar
                .padding(.top, 8)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
        }
        .frame(minWidth: 720, minHeight: 460)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            voiceToText.requestAuthorization()
        }
    }

    // MARK: Wizard header band

    private var wizardBar: some View {
        ZStack {
            // Background band across full width
            Color.accentColor.opacity(0.07)

            // Step pills + arrows
            HStack(spacing: 8) {
                StepPill(
                    index: 1,
                    title: "Choose template",
                    isActive: step == .chooseTemplate
                )

                WizardArrow()

                StepPill(
                    index: 2,
                    title: "Enter prompt context",
                    isActive: step == .captureContext
                )

                WizardArrow()

                StepPill(
                    index: 3,
                    title: "Copy prompt",
                    isActive: step == .reviewPrompt
                )

                Spacer()
            }
            .padding(.horizontal, 20)
        }
        // Fixed slim height for the header, roughly a bit taller than the pills
        .frame(maxWidth: .infinity, minHeight: 60, maxHeight: 60)
    }

    // MARK: Step content

    @ViewBuilder
    private var contentForCurrentStep: some View {
        switch step {
        case .chooseTemplate:
            chooseTemplateStep
        case .captureContext:
            captureContextStep
        case .reviewPrompt:
            reviewPromptStep
        }
    }

    // STEP 1 – template chooser with strong icons

    private var chooseTemplateStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What do you want to generate?")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Pick the artifact. You will speak your voice prompt next.")
                .font(.body)
                .foregroundColor(.secondary)

            List {
                ForEach(ALL_TEMPLATES, id: \.id) { template in
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(colorForTemplate(template.id).opacity(0.18))
                                .frame(width: 34, height: 34)

                            Image(systemName: template.iconSystemName)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(colorForTemplate(template.id))
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text(template.label)
                                .font(.system(size: 14, weight: .semibold))
                            Text(template.description)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }

                        Spacer()

                        if template.id == selectedTemplateId {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .padding(.vertical, 6)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedTemplateId = template.id
                    }
                }
            }
            .listStyle(.inset)
        }
    }

    // STEP 2 – Voice to Text capture

    private var captureContextStep: some View {
        VStack(alignment: .center, spacing: 16) {
            Text(currentTemplate.label)
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Press record and speak your voice prompt. When you stop, we build the prompt for you.")
                .font(.body)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer().frame(height: 6)

            HStack {
                Spacer()
                VStack(spacing: 12) {
                    recordButton

                    if let error = voiceToText.errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 360)
                    } else if !voiceToText.isAuthorized {
                        Text("Voice to Text is not authorized. Ready for voice prompt once you enable microphone and speech access in System Settings.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 360)
                    } else if voiceToText.isListening {
                        Text("Listening. Speak your voice prompt at a normal pace. Tap Stop when you are finished.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 360)
                    } else if !voiceToText.transcript.isEmpty {
                        Text("Voice prompt captured. You can re-record to replace it or go to the prompt.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 360)
                    } else {
                        Text("Ready for voice prompt. You can always go back and choose a different template.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 360)
                    }
                }
                Spacer()
            }

            Spacer().frame(height: 12)

            GroupBox("Transcript preview") {
                ScrollView {
                    Text(voiceToText.transcript.isEmpty
                         ? "Your voice prompt will appear here while you speak."
                         : voiceToText.transcript)
                        .font(.system(size: 13))
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .padding(.vertical, 2)
                }
                .frame(minHeight: 120)
            }
            .frame(maxWidth: .infinity)

            Spacer()
        }
    }

    private var recordButton: some View {
        Button(action: toggleRecording) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(voiceToText.isListening ? Color.red : Color.accentColor)
                        .frame(width: 80, height: 80)

                    Image(systemName: voiceToText.isListening ? "stop.fill" : "mic.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 28, weight: .bold))
                }

                Text(voiceToText.isListening ? "Stop recording" : "Start recording")
                    .font(.body)
                    .fontWeight(.semibold)
            }
        }
        .buttonStyle(.plain)
        .disabled(!voiceToText.isAuthorized)
    }

    // STEP 3 – prompt review

    private var reviewPromptStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Generated prompt")
                .font(.title2)
                .fontWeight(.semibold)

            Text("This is ready to paste into ChatGPT, Gemini, or Claude.")
                .font(.body)
                .foregroundColor(.secondary)

            GroupBox {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(colorForTemplate(currentTemplate.id).opacity(0.18))
                            .frame(width: 32, height: 32)

                        Image(systemName: currentTemplate.iconSystemName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(colorForTemplate(currentTemplate.id))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(currentTemplate.label)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text(currentTemplate.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
            }

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color.gray.opacity(0.3))
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color(NSColor.textBackgroundColor))
                    )

            ScrollView {
                    Text(notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                         ? "Voice prompt not recognized. Go back to Voice to Text and try recording again."
                         : prompt)
                        .font(.system(size: 13, design: .monospaced))
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
            }
            .frame(maxHeight: .infinity)

            HStack {
                Spacer()
                Button(action: copyPromptToClipboard) {
                    HStack(spacing: 6) {
                        Image(systemName: hasCopied ? "checkmark.circle.fill" : "doc.on.doc")
                        Text(hasCopied ? "Copied" : "Copy prompt")
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.accentColor.opacity(0.15))
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: Navigation bar

    private var navigationBar: some View {
        HStack {
            Button("Back") {
                goBack()
            }
            .disabled(step == .chooseTemplate)

            Spacer()

            switch step {
            case .chooseTemplate:
                Button("Next") {
                    goForward()
                }
            case .captureContext:
                Button("Skip to prompt") {
                    notes = voiceToText.transcript
                    goForward()
                }
            case .reviewPrompt:
                Button("Start over") {
                    notes = ""
                    hasCopied = false
                    voiceToText.reset()
                    step = .chooseTemplate
                }
            }
        }
    }

    // MARK: Step transitions

    private func goBack() {
        switch step {
        case .chooseTemplate:
            break
        case .captureContext:
            step = .chooseTemplate
        case .reviewPrompt:
            step = .captureContext
            hasCopied = false
            voiceToText.reset()
        }
    }

    private func goForward() {
        switch step {
        case .chooseTemplate:
            step = .captureContext
        case .captureContext:
            step = .reviewPrompt
        case .reviewPrompt:
            break
        }
        hasCopied = false
    }

    // MARK: Recording + clipboard

    private func toggleRecording() {
        if voiceToText.isListening {
            voiceToText.stop()
            notes = voiceToText.transcript
            if notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                voiceToText.errorMessage = "Could not understand your voice prompt. Please try again."
            } else {
                goForward()
            }
        } else {
            hasCopied = false
            notes = ""
            voiceToText.reset()
            voiceToText.start()
        }
    }

    private func copyPromptToClipboard() {
        guard !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(prompt, forType: .string)
        hasCopied = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            hasCopied = false
        }
    }

    // MARK: Icon color helper

    private func colorForTemplate(_ id: TemplateId) -> Color {
        switch id {
        case .execSlackSummary:
            return Color.purple
        case .formalEmail:
            return Color.orange
        case .prd:
            return Color.blue
        case .visionDoc:
            return Color.green
        case .heroSlide:
            return Color.cyan
        }
    }
}

// Wizard step block
private struct StepPill: View {
    let index: Int
    let title: String
    let isActive: Bool

    var body: some View {
        HStack(spacing: 8) {
            Text("\(index)")
                .font(.system(size: 13, weight: .bold))
                .frame(width: 22, height: 22)
                .background(
                    Circle()
                        .fill(isActive ? Color.white.opacity(0.95) : Color.white.opacity(0.85))
                )
                .foregroundColor(isActive ? Color.accentColor : Color.gray)

            Text(title)
                .font(.system(size: 13, weight: isActive ? .semibold : .regular))
                .foregroundColor(isActive ? .primary : .secondary)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isActive ? Color.accentColor.opacity(0.22) : Color.gray.opacity(0.14))
        )
    }
}

// Arrow between steps
private struct WizardArrow: View {
    var body: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.secondary)
            .padding(.horizontal, 4)
    }
}
