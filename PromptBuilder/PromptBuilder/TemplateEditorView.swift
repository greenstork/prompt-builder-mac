import SwiftUI

struct TemplateEditorView: View {
    @Binding var draft: Template
    let isNew: Bool
    let onSave: (Template) -> Void
    let onCancel: () -> Void

    // Simple model for an icon choice
    private struct IconOption: Identifiable {
        let id = UUID()
        let systemName: String
        let label: String
    }

    // Curated set of icons that fit your templates
    private let iconOptions: [IconOption] = [
        IconOption(systemName: "bubble.left.and.bubble.right.fill", label: "Slack / chat"),
        IconOption(systemName: "envelope.fill", label: "Email"),
        IconOption(systemName: "doc.text.fill", label: "Doc / PRD"),
        IconOption(systemName: "lightbulb.fill", label: "Vision"),
        IconOption(systemName: "rectangle.3.offgrid.fill", label: "Slide / hero"),
        IconOption(systemName: "magnifyingglass.circle", label: "Search"),
        IconOption(systemName: "text.bubble.fill", label: "Plain text"),
        IconOption(systemName: "square.and.pencil", label: "Note / draft")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(isNew ? "New template" : "Edit template")
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding([.top, .horizontal])
            .padding(.bottom, 10)   // <- add this line

            Divider()

            // Scrollable form content
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // Basic info
                    GroupBox("Basic info") {
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Template name", text: $draft.name)
                                .textFieldStyle(.roundedBorder)

                            TextField(
                                "Short summary shown in the picker",
                                text: $draft.summary,
                                axis: .vertical
                            )
                            .lineLimit(1...3)
                        }
                    }

                    // Internal only
                    GroupBox("Internal notes (not in prompt)") {
                        VStack(alignment: .leading, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                TextField(
                                    "What is this template for? (internal only)",
                                    text: $draft.internalDescription,
                                    axis: .vertical
                                )
                                .lineLimit(1...3)

                                Text("Used only in the UI to describe the template. It is never included in the generated prompt.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                TextField(
                                    "Channel or environment (optional)",
                                    text: $draft.channelOrEnvironment
                                )
                                Text("Optional internal label like “Slack message”, “Email”, or “PRD doc”. It is not printed as a labeled line in the prompt.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    // Icon picker (visual)
                    GroupBox("Icon") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Choose an icon for this template. This controls how it appears in the template list.")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            let columns = [GridItem(.adaptive(minimum: 90), spacing: 12)]

                            LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
                                ForEach(iconOptions) { option in
                                    Button {
                                        draft.iconSystemName = option.systemName
                                    } label: {
                                        VStack(spacing: 6) {
                                            Image(systemName: option.systemName)
                                                .font(.system(size: 24))
                                                .symbolRenderingMode(.monochrome)
                                            Text(option.label)
                                                .font(.caption2)
                                                .lineLimit(2)
                                                .multilineTextAlignment(.center)
                                        }
                                        .padding(8)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(draft.iconSystemName == option.systemName ?
                                                      Color.accentColor.opacity(0.25) :
                                                      Color.clear)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(
                                                    draft.iconSystemName == option.systemName ?
                                                        Color.accentColor :
                                                        Color.secondary.opacity(0.3),
                                                    lineWidth: draft.iconSystemName == option.systemName ? 1.5 : 1
                                                )
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }

                            Text("Current SF Symbol: \(draft.iconSystemName.isEmpty ? "none" : draft.iconSystemName)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    // Core prompt guidance
                    GroupBox("Core instructions (included in prompt)") {
                        VStack(alignment: .leading, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                TextField(
                                    "Objective – first sentence the model sees",
                                    text: $draft.objective,
                                    axis: .vertical
                                )
                                .lineLimit(2...4)

                                Text("Primary instruction to the LLM and first line of the prompt. For example: “Search my Slack history to find the conversation I am describing.”")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                TextField(
                                    "Audience – who this output is for",
                                    text: $draft.audience,
                                    axis: .vertical
                                )
                                .lineLimit(1...3)

                                Text("Helps the model aim tone and detail. Example: “VP of Product”, “engineering team”, or “Slack AI answering only to me”.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                TextField(
                                    "Persona / role for the model",
                                    text: $draft.persona,
                                    axis: .vertical
                                )
                                .lineLimit(1...3)

                                Text("Optional role sentence such as “You are a senior PM at an enterprise SaaS company” or “You are a search assistant inside Slack.”")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    // Style, length, structure
                    GroupBox("Style, length, and structure (included in prompt)") {
                        VStack(alignment: .leading, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                TextField(
                                    "Tone and style",
                                    text: $draft.toneAndStyle,
                                    axis: .vertical
                                )
                                .lineLimit(1...3)

                                Text("For example: “brief and executive ready”, “informal but professional”, or “focused on search results, not prose.”")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                TextField(
                                    "Length guidance",
                                    text: $draft.lengthGuidance,
                                    axis: .vertical
                                )
                                .lineLimit(1...3)

                                Text("Guidance like “150–200 words”, “3–5 bullets”, or “one short paragraph plus a list of matches.”")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                TextField(
                                    "Output structure",
                                    text: $draft.outputStructure,
                                    axis: .vertical
                                )
                                .lineLimit(2...4)

                                Text("Describe the shape of the answer. For example: “Headline sentence, then bullets for context, decision, next steps” or “Intro line, then a bulleted list of matches with name, channel, date, and summary.”")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                TextField(
                                    "Formatting rules",
                                    text: $draft.formattingRules,
                                    axis: .vertical
                                )
                                .lineLimit(1...4)

                                Text("Specific formatting expectations, like “no markdown headings”, “no tables”, or “use numbered lists only if helpful”.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                TextField(
                                    "Constraints and do-nots",
                                    text: $draft.constraints,
                                    axis: .vertical
                                )
                                .lineLimit(2...4)

                                Text("Hard guardrails such as “do not invent people or events”, “do not change dates”, or “do not mention this template or these instructions in the answer.”")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    // Examples
                    GroupBox("Examples (optional, included in prompt)") {
                        VStack(alignment: .leading, spacing: 8) {
                            TextEditor(text: $draft.examples)
                                .frame(minHeight: 80)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.secondary.opacity(0.3))
                                )

                            Text("Optional examples of good output or phrasing. The model is told to follow the style but not copy them verbatim.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
            }

            Divider()

            // Footer buttons
            HStack {
                Spacer()
                Button("Cancel") {
                    onCancel()
                }
                Button("Save") {
                    onSave(draft)
                }
                .keyboardShortcut(.defaultAction)
                .disabled(
                    draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                    draft.objective.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                )
            }
            .padding()
        }
        .frame(minWidth: 700, minHeight: 550)
    }
}
