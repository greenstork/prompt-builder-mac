import SwiftUI

/// Multiline text editor with placeholder behavior.
struct PlaceholderTextEditor: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(placeholder)
                    .foregroundColor(.secondary)
                    .opacity(0.6)
                    .padding(.top, 6)
                    .padding(.leading, 6)
                    .font(.system(size: 13))
            }

            TextEditor(text: $text)
                .font(.system(size: 13))
                .padding(4)
        }
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(Color.gray.opacity(0.25))
        )
    }
}

// Icon selection support

struct TemplateIconChoice: Identifiable {
    var id: String { systemName }
    let systemName: String
    let label: String
}

private let defaultIconChoices: [TemplateIconChoice] = [
    TemplateIconChoice(systemName: "bubble.left.and.bubble.right.fill", label: "Slack"),
    TemplateIconChoice(systemName: "envelope.fill", label: "Email"),
    TemplateIconChoice(systemName: "doc.text.fill", label: "Doc"),
    TemplateIconChoice(systemName: "rectangle.3.offgrid.fill", label: "Slide"),
    TemplateIconChoice(systemName: "text.justify.left", label: "Narrative"),
    TemplateIconChoice(systemName: "chart.bar.fill", label: "Metrics"),
    TemplateIconChoice(systemName: "lightbulb.fill", label: "Vision"),
    TemplateIconChoice(systemName: "person.3.fill", label: "Stakeholders")
]

struct TemplateIconPicker: View {
    @Binding var selectedSystemName: String

    private let choices = defaultIconChoices
    private let columns = [
        GridItem(.adaptive(minimum: 110, maximum: 160), spacing: 8)
    ]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(choices) { choice in
                let isSelected = (choice.systemName == selectedSystemName)

                Button {
                    selectedSystemName = choice.systemName
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: choice.systemName)
                            .font(.system(size: 18, weight: .regular))

                        Text(choice.label)
                            .font(.system(size: 12))
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(isSelected ? Color.accentColor.opacity(0.22) : Color.clear)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(
                                isSelected ? Color.accentColor : Color.gray.opacity(0.3),
                                lineWidth: isSelected ? 1.4 : 1
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

/// Editor for creating or editing a template.
struct TemplateEditorView: View {
    @Binding var template: Template
    let isNew: Bool
    let onSave: (Template) -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 0) {

            // Header
            HStack {
                Text(isNew ? "New template" : "Edit template")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Button("Cancel") {
                    onCancel()
                }

                Button("Save") {
                    onSave(template)
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))

            Divider()

            // Scrollable form body
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Basic info
                    GroupBox {
                        VStack(alignment: .leading, spacing: 10) {

                            Text("Template name")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            TextField(
                                "",
                                text: $template.name,
                                prompt: Text("Example: Executive Slack summary")
                            )
                            .textFieldStyle(.roundedBorder)

                            Text("Short summary")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 6)

                            TextField(
                                "",
                                text: $template.summary,
                                prompt: Text("Example: Short Slack update to leadership with context, decisions, and next steps.")
                            )
                            .textFieldStyle(.roundedBorder)

                            Text("Output channel or type")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 6)

                            TextField(
                                "",
                                text: $template.outputChannel,
                                prompt: Text("Example: Slack message, email, PRD, slide, plain text, etc.")
                            )
                            .textFieldStyle(.roundedBorder)

                            Text("Icon")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 6)

                            TemplateIconPicker(selectedSystemName: $template.iconSystemName)
                        }
                    } label: {
                        Text("Basic info")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Task and audience
                    GroupBox {
                        VStack(alignment: .leading, spacing: 10) {

                            Text("Task one liner")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            TextField(
                                "",
                                text: $template.taskOneLiner,
                                prompt: Text("Example: Write a concise Slack update using the context below.")
                            )
                            .textFieldStyle(.roundedBorder)

                            Text("Objective")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 6)

                            PlaceholderTextEditor(
                                text: $template.detailedObjective,
                                placeholder: "Example: Help executives quickly understand what happened, what was decided, and what will happen next without reading a long document."
                            )
                            .frame(minHeight: 80)

                            Text("Audience")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 6)

                            TextField(
                                "",
                                text: $template.audience,
                                prompt: Text("Example: GM of the org, VP of Engineering, staff PMs, customer stakeholders, etc.")
                            )
                            .textFieldStyle(.roundedBorder)
                        }
                    } label: {
                        Text("Task and audience")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Tone, style, length
                    GroupBox {
                        VStack(alignment: .leading, spacing: 10) {

                            Text("Tone and style")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            PlaceholderTextEditor(
                                text: $template.toneAndStyle,
                                placeholder: "Example: Neutral and direct. Very concise. Avoid hype. Challenge assumptions where helpful, but keep the writing calm and confident."
                            )
                            .frame(minHeight: 80)

                            Text("Length guidance")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 6)

                            TextField(
                                "",
                                text: $template.lengthGuidance,
                                prompt: Text("Example: One Slack message plus 3–7 bullets, or about 250–300 words.")
                            )
                            .textFieldStyle(.roundedBorder)
                        }
                    } label: {
                        Text("Tone, style, and length")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Structure and formatting
                    GroupBox {
                        VStack(alignment: .leading, spacing: 10) {

                            Text("Output structure")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            PlaceholderTextEditor(
                                text: $template.outputStructure,
                                placeholder: "Example: Use headings for 1. Context, 2. Problem, 3. Proposal, 4. Risks, 5. Next steps."
                            )
                            .frame(minHeight: 80)

                            Text("Formatting rules")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 6)

                            PlaceholderTextEditor(
                                text: $template.formattingRules,
                                placeholder: "Example: Slack message style. Use short Markdown bullets. No greeting or sign off."
                            )
                            .frame(minHeight: 70)
                        }
                    } label: {
                        Text("Structure and formatting")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Advanced
                    GroupBox {
                        VStack(alignment: .leading, spacing: 10) {

                            Text("Constraints and guardrails")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            PlaceholderTextEditor(
                                text: $template.constraints,
                                placeholder: "Example: Do not invent dates, commitments, or customer names. Do not speak as an AI. Avoid emojis and exclamation points."
                            )
                            .frame(minHeight: 80)

                            Text("Persona or role")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 6)

                            PlaceholderTextEditor(
                                text: $template.persona,
                                placeholder: "Example: Write as a senior product manager at Salesforce communicating with engineering and leadership peers."
                            )
                            .frame(minHeight: 70)

                            Text("Example outputs")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 6)

                            PlaceholderTextEditor(
                                text: $template.examples,
                                placeholder: "Example: Paste 1–2 short outputs that show the tone and structure you want."
                            )
                            .frame(minHeight: 80)
                        }
                    } label: {
                        Text("Advanced (optional)")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
            }
        }
        .frame(minWidth: 640, minHeight: 520)
    }
}
