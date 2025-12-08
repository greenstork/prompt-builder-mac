import Foundation

enum TemplateId: String, CaseIterable {
    case prd
    case execSlackSummary
    case formalEmail
    case visionDoc
    case heroSlide
}

/// A single prompt template definition.
struct Template {
    let id: TemplateId
    let label: String
    let description: String

    /// SF Symbol name for the visual icon in the template chooser.
    /// - PRD: doc icon (Google Docs vibe)
    /// - Exec Slack: chat bubbles
    /// - Email: envelope
    /// - Vision: sparkles
    /// - Hero slide: slide icon
    let iconSystemName: String

    let systemPreamble: String
    let toneGuidance: String
    let formatGuidance: [String]
    let sections: [String]?
}

let ALL_TEMPLATES: [Template] = [

    // 1. Product Requirements Document – Google Docs style icon
    Template(
        id: .prd,
        label: "Product Requirements Document",
        description: "Structured PRD for engineers and PMs.",
        iconSystemName: "doc.text.fill",
        systemPreamble: """
        You are an experienced product manager writing a clear, concise Product Requirements Document (PRD) for a complex SaaS product.
        """,
        toneGuidance: """
        Direct and structured. Assume the audience is senior engineers, architects, and PM leaders. Avoid fluff and marketing language. Make tradeoffs and risks explicit.
        """,
        formatGuidance: [
            "Use H2 style headings for main sections.",
            "Use bullet lists for requirements, acceptance criteria, and risks.",
            "Call out assumptions and open questions explicitly.",
            "Write in plain business English. No em dashes. Use commas or short sentences instead.",
            "Focus on clarity and decision making, not persuasion."
        ],
        sections: [
            "Context and problem statement",
            "Goals and non goals",
            "Target users and key use cases",
            "Scope and requirements",
            "User experience notes and constraints",
            "Dependencies, risks, and tradeoffs",
            "Tracking, metrics, and success criteria",
            "Open questions and decisions needed"
        ]
    ),

    // 2. Executive Slack summary – Slack-like chat icon
    Template(
        id: .execSlackSummary,
        label: "Executive Slack Summary",
        description: "Short Slack update to a VP or GM.",
        iconSystemName: "bubble.left.and.bubble.right.fill",
        systemPreamble: """
        You are a senior product leader writing a short Slack message to an executive. The goal is to update them quickly, surface decisions, and show ownership.
        """,
        toneGuidance: """
        Direct and concise. One step more casual than email, but still executive ready. Assume the reader will skim on a phone. Avoid soft language and selling.
        """,
        formatGuidance: [
            "Start with a one line TLDR that fits on a single Slack line.",
            "After TLDR, use at most 3 to 6 bullet points.",
            "Bullets should emphasize outcomes, decisions, and risk, not process detail.",
            "If there is an explicit ask or decision needed, call it out clearly as a bullet.",
            "No em dashes. Use commas or periods.",
            "Avoid heavy formatting. Occasional bold is fine, but do not overuse."
        ],
        sections: [
            "TLDR",
            "Progress and recent outcomes",
            "Risks or blockers",
            "Decisions or asks",
            "Next steps"
        ]
    ),

    // 3. Formal email – email icon
    Template(
        id: .formalEmail,
        label: "Formal Email",
        description: "Structured email to senior leaders or external stakeholders.",
        iconSystemName: "envelope.fill",
        systemPreamble: """
        You are a senior product manager writing a clear, formal email to busy senior stakeholders. The goal is to be respectful of their time, direct about the purpose, and explicit about any asks.
        """,
        toneGuidance: """
        Professional, steady, and direct. No hype, no drama. Use short paragraphs and concrete language. Write in a way that a VP could forward directly without editing.
        """,
        formatGuidance: [
            "Provide a subject line that is informative and specific.",
            "Start with a one or two sentence purpose statement in the first paragraph.",
            "Use short paragraphs, each with a single main idea.",
            "Use bullet points for lists of options, risks, or next steps.",
            "End with a clear ask or confirmation of next steps if appropriate.",
            "No em dashes. Use commas or periods instead.",
            "Avoid slang and internal shorthand unless it is widely understood in the org."
        ],
        sections: [
            "Subject line",
            "Greeting and purpose",
            "Context and key facts",
            "Proposal, options, or update",
            "Risks and tradeoffs if relevant",
            "Explicit ask or next steps",
            "Closing"
        ]
    ),

    // 4. Vision document – vision icon
    Template(
        id: .visionDoc,
        label: "Vision Document",
        description: "Narrative statement of product vision and direction.",
        iconSystemName: "sparkles",
        systemPreamble: """
        You are a senior product leader writing a vision document. The goal is to describe the future state, why it matters, and how the org gets there, in a way that is both inspiring and concrete.
        """,
        toneGuidance: """
        Strategic and confident, but grounded in reality. Balance inspiration with specificity. Write for a mixed audience of executives, PMs, and senior engineers.
        """,
        formatGuidance: [
            "Open with a short narrative that describes the future state in a way that feels tangible.",
            "Use clear section headings so the document can be skimmed.",
            "Introduce 3 to 5 strategic pillars, each with a one line summary and supporting detail.",
            "Call out what is intentionally out of scope or deferred.",
            "Include a high level milestone or phase view to anchor timelines.",
            "No em dashes. Use commas or short sentences instead.",
            "Avoid buzzwords unless they are necessary and well defined."
        ],
        sections: [
            "Executive summary",
            "Current state and problem",
            "North star vision",
            "Strategic pillars",
            "Customer and business impact",
            "Phasing and milestones",
            "Risks and dependencies",
            "What success looks like"
        ]
    ),

    // 5. Hero slide – slide icon
    Template(
        id: .heroSlide,
        label: "Hero Slide",
        description: "Single slide that captures the core story.",
        iconSystemName: "rectangle.fill.on.rectangle.fill",
        systemPreamble: """
        You are creating content for a single hero slide in a presentation. The slide must stand on its own and tell the core story in a simple, visual friendly way.
        """,
        toneGuidance: """
        Clear and punchy. Assume the slide will be shown on a projector and maybe screenshotted into Slack. Each line should be short, sharp, and meaningful.
        """,
        formatGuidance: [
            "Provide a slide title that is a clear outcome oriented statement, not a label.",
            "Provide an optional subtitle that adds a bit of context if needed.",
            "Provide 3 to 5 main bullets that tell the story in order.",
            "If relevant, provide 1 to 3 proof points or data points that could sit on the slide.",
            "Write bullets as short phrases, not full paragraphs.",
            "No em dashes. Use commas or slashes if you need to join ideas.",
            "Do not describe design or colors, focus on content only."
        ],
        sections: [
            "Slide title",
            "Subtitle",
            "Key story bullets",
            "Proof points or metrics"
        ]
    )
]

func template(for id: TemplateId) -> Template {
    guard let t = ALL_TEMPLATES.first(where: { $0.id == id }) else {
        fatalError("Unknown template id \(id)")
    }
    return t
}

func buildPrompt(template: Template, notes: String) -> String {
    let sectionsText: String
    if let sections = template.sections, !sections.isEmpty {
        sectionsText = sections.enumerated().map { idx, s in
            "\(idx + 1). \(s)"
        }.joined(separator: "\n")
    } else {
        sectionsText = ""
    }

    let formattingText = template.formatGuidance.map { "- \($0)" }.joined(separator: "\n")

    return """
    \(template.systemPreamble)

    Tone:
    \(template.toneGuidance)

    Formatting:
    \(formattingText)

    Structure:
    \(sectionsText)

    Here are raw notes from the product manager. Rewrite them into the final artifact described above, following all tone and formatting guidance. If the notes are incomplete, make reasonable assumptions and call out uncertainties clearly.

    Notes:
    \(notes)
    """
}
