import SwiftUI
import AppKit

// Build the final prompt string from a template and captured notes
func buildPrompt(template: Template, notes: String) -> String {
    var lines: [String] = []

    // 1. Objective – always first
    let objective = template.objective.trimmingCharacters(in: .whitespacesAndNewlines)
    if !objective.isEmpty {
        lines.append(objective)
    } else {
        // Defensive fallback if someone left objective blank
        lines.append("Help me with the task described below.")
    }

    // 2. Role, environment, and audience (if present)
    var roleLines: [String] = []

    let persona = template.persona.trimmingCharacters(in: .whitespacesAndNewlines)
    if !persona.isEmpty {
        // Assume persona may already start with "You are". Do not wrap it again.
        roleLines.append(persona)
    }

    let channel = template.channelOrEnvironment.trimmingCharacters(in: .whitespacesAndNewlines)
    if !channel.isEmpty {
        roleLines.append("You are working in \(channel).")
    }

    let audience = template.audience.trimmingCharacters(in: .whitespacesAndNewlines)
    if !audience.isEmpty {
        roleLines.append("The primary audience is: \(audience).")
    }

    if !roleLines.isEmpty {
        lines.append("")
        lines.append(roleLines.joined(separator: " "))
    }

    // 3. Style and constraints block
    var styleItems: [String] = []

    let tone = template.toneAndStyle.trimmingCharacters(in: .whitespacesAndNewlines)
    if !tone.isEmpty {
        styleItems.append("Tone and style: \(tone)")
    }

    let length = template.lengthGuidance.trimmingCharacters(in: .whitespacesAndNewlines)
    if !length.isEmpty {
        styleItems.append("Length: \(length)")
    }

    let structure = template.outputStructure.trimmingCharacters(in: .whitespacesAndNewlines)
    if !structure.isEmpty {
        styleItems.append("Output structure: \(structure)")
    }

    let formatting = template.formattingRules.trimmingCharacters(in: .whitespacesAndNewlines)
    if !formatting.isEmpty {
        styleItems.append("Formatting rules: \(formatting)")
    }

    let constraints = template.constraints.trimmingCharacters(in: .whitespacesAndNewlines)
    if !constraints.isEmpty {
        styleItems.append("Constraints: \(constraints)")
    }

    if !styleItems.isEmpty {
        lines.append("")
        lines.append("Style and constraints:")
        for item in styleItems {
            lines.append("- \(item)")
        }
    }

    // 4. Optional examples
    let examples = template.examples.trimmingCharacters(in: .whitespacesAndNewlines)
    if !examples.isEmpty {
        lines.append("")
        lines.append("Examples or patterns to follow (do not copy verbatim):")
        lines.append(examples)
    }

    // 5. Context from you
    let context = notes.trimmingCharacters(in: .whitespacesAndNewlines)
    if !context.isEmpty {
        lines.append("")
        lines.append("Context:")
        lines.append(context)
    }

    // 6. Final directive
    lines.append("")
    lines.append("Using the objective, style guidance, and context above, produce a single final answer. Do not restate these instructions.")

    return lines.joined(separator: "\n")
}

private enum WizardStep: Int {
    case chooseTemplate = 0
    case captureContext = 1
    case reviewPrompt = 2
}

struct ContentView: View {
    @EnvironmentObject var templateStore: TemplateStore

    @State private var step: WizardStep = .chooseTemplate
    @State private var selectedTemplateId: UUID?
    @State private var notes: String = ""
    @State private var hasCopied: Bool = false

    @State private var isShowingTemplateEditor = false
    @State private var editorIsNew = true
    @State private var editorDraft = Template.empty()

    @State private var isShowingDeleteAlert = false
    @State private var templatePendingDelete: Template?

    @StateObject private var voiceToText = VoiceToText()

    private var currentTemplate: Template {
        if let id = selectedTemplateId,
           let found = templateStore.templates.first(where: { $0.id == id }) {
            return found
        }
        return templateStore.templates.first ?? Template.empty()
    }

    private var prompt: String {
        buildPrompt(template: currentTemplate, notes: notes)
    }

    var body: some View {
        VStack(spacing: 0) {
            wizardBar

            contentForCurrentStep
                .padding(.top, 8)
                .padding(.horizontal, 20)

            Divider()

            navigationBar
                .padding(.top, 8)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
        }
        .frame(minWidth: 720, minHeight: 560)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            voiceToText.requestAuthorization()
            if selectedTemplateId == nil {
                selectedTemplateId = templateStore.templates.first?.id
            }

            DispatchQueue.main.async {
                resizeWindowToFitCurrentTemplates()
            }
        }
        .onChange(of: templateStore.templates.count, initial: false) { oldCount, newCount in
            DispatchQueue.main.async {
                resizeWindowForTemplateCountChange(from: oldCount, to: newCount)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .promptBuilderStartVoice)) { _ in
            handleGlobalStartVoice()
        }
        .sheet(isPresented: $isShowingTemplateEditor) {
            TemplateEditorView(
                draft: $editorDraft,
                isNew: editorIsNew,
                onSave: { updated in
                    if editorIsNew {
                        templateStore.add(updated)
                        selectedTemplateId = updated.id
                    } else {
                        templateStore.update(updated)
                        selectedTemplateId = updated.id
                    }
                    isShowingTemplateEditor = false
                },
                onCancel: {
                    isShowingTemplateEditor = false
                }
            )
        }
        .alert("Delete template", isPresented: $isShowingDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let template = templatePendingDelete {
                    performDelete(template)
                }
                templatePendingDelete = nil
            }
            Button("Cancel", role: .cancel) {
                templatePendingDelete = nil
            }
        } message: {
            Text("Are you sure you want to delete \"\(templatePendingDelete?.name ?? "this template")\"? This cannot be undone.")
        }
    }

    // MARK: Wizard header band

    private var wizardBar: some View {
        ZStack {
            Color.accentColor.opacity(0.07)

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

    // MARK: Step 1 - template chooser

    private var chooseTemplateStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("What do you want to generate?")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Pick the prompt output and format. You will speak your voice prompt next.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button {
                    startNewTemplate()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("New template")
                    }
                }
                .buttonStyle(.bordered)
            }

            List {
                ForEach(templateStore.templates) { template in
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(colorForTemplate(template).opacity(0.18))
                                .frame(width: 34, height: 34)

                            Image(systemName: template.iconSystemName)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(colorForTemplate(template))
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text(template.name)
                                .font(.system(size: 14, weight: .semibold))
                            Text(template.summary)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }

                        Spacer()

                        HStack(spacing: 8) {
                            if template.id == selectedTemplateId {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.accentColor)
                            }

                            Button {
                                startEditing(template)
                            } label: {
                                Image(systemName: "pencil")
                            }
                            .buttonStyle(.borderless)

                            Button {
                                queueDelete(template)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.borderless)
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

    // MARK: Step 2 - voice capture

    private var captureContextStep: some View {
        VStack(alignment: .center, spacing: 16) {
            Text(currentTemplate.name)
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
                        Text("Voice prompt captured. You can re record to replace it or go to the prompt.")
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

    // MARK: Step 3 - prompt review

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
                            .fill(colorForTemplate(currentTemplate).opacity(0.18))
                            .frame(width: 32, height: 32)

                        Image(systemName: currentTemplate.iconSystemName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(colorForTemplate(currentTemplate))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(currentTemplate.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text(currentTemplate.summary)
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

    // MARK: Recording and clipboard

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

    // MARK: Global "New prompt" handler

    private func handleGlobalStartVoice() {
        // Bring Prompt Builder to the front
        NSApp.activate(ignoringOtherApps: true)

        // Go to Step 1 of the wizard
        step = .chooseTemplate

        // Reset state, but do not start recording
        hasCopied = false
        notes = ""
        voiceToText.reset()

        // Optionally, you could pick a default template here if none is selected
        if selectedTemplateId == nil {
            selectedTemplateId = templateStore.templates.first?.id
        }
    }

    // MARK: Template editor helpers

    private func startNewTemplate() {
        editorIsNew = true
        editorDraft = Template.empty()
        isShowingTemplateEditor = true
    }

    private func startEditing(_ template: Template) {
        editorIsNew = false
        editorDraft = template
        isShowingTemplateEditor = true
    }

    private func queueDelete(_ template: Template) {
        templatePendingDelete = template
        isShowingDeleteAlert = true
    }

    private func performDelete(_ template: Template) {
        guard let index = templateStore.templates.firstIndex(of: template) else {
            return
        }

        templateStore.delete(at: IndexSet(integer: index))

        if template.id == selectedTemplateId {
            selectedTemplateId = templateStore.templates.first?.id
        }

        if templateStore.templates.isEmpty {
            step = .chooseTemplate
        }

        DispatchQueue.main.async {
            resizeWindowToFitCurrentTemplates()
        }
    }

    // MARK: Window sizing

    private func heightForTemplateCount(_ count: Int) -> CGFloat {
        let minHeight: CGFloat = 560
        let maxHeight: CGFloat = 860

        // Less “base chrome” above and below the list
        let chromeHeight: CGFloat = 230

        // Closer to the actual row height inside the List
        let rowHeight: CGFloat = 54

        let maxVisibleRows: CGFloat = 7

        let clampedCount = max(count, 1)
        let rows = min(CGFloat(clampedCount), maxVisibleRows)

        var target = chromeHeight + rowHeight * rows

        if target < minHeight {
            target = minHeight
        } else if target > maxHeight {
            target = maxHeight
        }

        return target
    }

    private func resizeWindowToFitCurrentTemplates() {
        guard let window = NSApplication.shared.windows.first(where: { $0.isVisible && $0.isKeyWindow }) else {
            return
        }
        if window.attachedSheet != nil { return }

        let targetHeight = heightForTemplateCount(templateStore.templates.count)

        var frame = window.frame
        let currentHeight = frame.size.height
        let delta = targetHeight - currentHeight

        if abs(delta) < 1 { return }

        frame.origin.y -= delta
        frame.size.height = targetHeight
        window.setFrame(frame, display: true, animate: true)
    }

    private func resizeWindowForTemplateCountChange(from oldCount: Int, to newCount: Int) {
        guard oldCount != newCount else { return }
        guard let window = NSApplication.shared.windows.first(where: { $0.isVisible && $0.isKeyWindow }) else {
            return
        }
        if window.attachedSheet != nil { return }

        let currentHeight = window.frame.size.height
        let computedHeight = heightForTemplateCount(newCount)

        var targetHeight: CGFloat

        if newCount > oldCount {
            targetHeight = max(currentHeight, computedHeight)
        } else {
            targetHeight = min(currentHeight, computedHeight)
        }

        let delta = targetHeight - currentHeight
        if abs(delta) < 1 { return }

        var frame = window.frame
        frame.origin.y -= delta
        frame.size.height = targetHeight
        window.setFrame(frame, display: true, animate: true)
    }

    // MARK: Color helper

    private func colorForTemplate(_ template: Template) -> Color {
        let name = template.name.lowercased()
        if name.contains("slack") {
            return .purple
        } else if name.contains("email") {
            return .orange
        } else if name.contains("prd") || name.contains("requirements") {
            return .blue
        } else if name.contains("vision") {
            return .green
        } else if name.contains("slide") {
            return .cyan
        } else {
            return .accentColor
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
