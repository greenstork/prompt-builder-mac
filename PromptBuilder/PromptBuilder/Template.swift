import Foundation

struct Template: Identifiable, Codable, Equatable {
    var id: UUID

    // Meta / UI fields
    var name: String
    var summary: String
    var outputChannel: String
    var iconSystemName: String

    // Prompt behavior fields (all free text)
    var taskOneLiner: String
    var detailedObjective: String
    var audience: String
    var toneAndStyle: String
    var lengthGuidance: String
    var outputStructure: String
    var formattingRules: String
    var constraints: String
    var persona: String
    var examples: String

    init(
        id: UUID = UUID(),
        name: String,
        summary: String,
        outputChannel: String = "",
        iconSystemName: String,
        taskOneLiner: String = "",
        detailedObjective: String = "",
        audience: String = "",
        toneAndStyle: String = "",
        lengthGuidance: String = "",
        outputStructure: String = "",
        formattingRules: String = "",
        constraints: String = "",
        persona: String = "",
        examples: String = ""
    ) {
        self.id = id
        self.name = name
        self.summary = summary
        self.outputChannel = outputChannel
        self.iconSystemName = iconSystemName
        self.taskOneLiner = taskOneLiner
        self.detailedObjective = detailedObjective
        self.audience = audience
        self.toneAndStyle = toneAndStyle
        self.lengthGuidance = lengthGuidance
        self.outputStructure = outputStructure
        self.formattingRules = formattingRules
        self.constraints = constraints
        self.persona = persona
        self.examples = examples
    }
}

extension Template {
    static func empty() -> Template {
        Template(
            name: "Untitled template",
            summary: "",
            iconSystemName: "doc.text.fill"
        )
    }

    static func defaultTemplates() -> [Template] {
        [
            Template(
                name: "Executive Slack summary",
                summary: "Short Slack update to leadership with context, decisions, and next steps.",
                outputChannel: "Slack message",
                iconSystemName: "bubble.left.and.bubble.right.fill",
                taskOneLiner: "Write a concise Slack update using the context below.",
                detailedObjective: "Help a VP or GM quickly understand what happened, what was decided, and what will happen next, without reading a long document.",
                audience: "VP, GM, and senior engineering and product leaders.",
                toneAndStyle: "Very concise, neutral, and direct. Avoid hype. Focus on signal over detail.",
                lengthGuidance: "One Slack message plus 3 to 7 short bullet points if needed.",
                outputStructure: "Start with a one sentence headline. Then bullets for Context, Decisions, and Next steps.",
                formattingRules: "Slack message style. Use short Markdown bullets. No greeting or sign off.",
                constraints: "Do not invent dates, commitments, or customer names. Do not use emojis or exclamation marks.",
                persona: "Write as a senior product manager communicating with peers and leadership.",
                examples: ""
            ),
            Template(
                name: "Formal email",
                summary: "Polished email suitable for external or senior internal stakeholders.",
                outputChannel: "Email",
                iconSystemName: "envelope.fill",
                taskOneLiner: "Draft a clear, professional email from the context below.",
                detailedObjective: "Communicate the key message, decisions, and asks in a way that is easy for a busy reader to scan.",
                audience: "Senior internal stakeholders or external partners.",
                toneAndStyle: "Professional, calm, and clear. Not chatty, not overly formal.",
                lengthGuidance: "3 to 6 short paragraphs, or roughly 250 to 400 words.",
                outputStructure: "Greeting, brief purpose paragraph, 1 to 3 paragraphs of detail, bullets for key points if helpful, closing and sign off.",
                formattingRules: "Plain text email or simple Markdown. Use bullets sparingly to make scanning easier.",
                constraints: "Do not commit to dates or scope that are not explicitly provided. Do not use slang.",
                persona: "Write as a senior product manager representing the team.",
                examples: ""
            ),
            Template(
                name: "Product requirements outline",
                summary: "Structured PRD style outline that you can paste into a doc.",
                outputChannel: "Google Doc PRD",
                iconSystemName: "doc.text.fill",
                taskOneLiner: "Turn the context below into a structured product requirements outline.",
                detailedObjective: "Capture problem, goals, requirements, and open questions in a way that engineering and leadership can follow.",
                audience: "Engineering leads, architects, and product leadership.",
                toneAndStyle: "Neutral, precise, and un-opinionated in wording, but clear about tradeoffs and risks.",
                lengthGuidance: "As long as needed to capture the requirements clearly, but keep prose tight.",
                outputStructure: "Headings and subheadings for Problem, Goals, Non goals, Users and use cases, Requirements, Open questions, Risks.",
                formattingRules: "Use Markdown headings and bullet lists. No long walls of text under a single heading.",
                constraints: "Flag uncertainty explicitly. Do not fabricate metrics or customer names.",
                persona: "Write as a senior PM documenting requirements for a cross functional team.",
                examples: ""
            ),
            Template(
                name: "Vision doc summary",
                summary: "High level narrative about the future direction of a product.",
                outputChannel: "Vision document",
                iconSystemName: "lightbulb.fill",
                taskOneLiner: "Write a concise vision narrative based on the context below.",
                detailedObjective: "Explain where we are going, why it matters, and what it unlocks for customers and the business.",
                audience: "Leadership, cross functional partners, and possibly customers.",
                toneAndStyle: "Confident but grounded. Avoid hype. Emphasize clarity and direction.",
                lengthGuidance: "Roughly 500 to 900 words.",
                outputStructure: "Sections for Context, Vision, Key pillars, Impact, and Next steps.",
                formattingRules: "Use headings and short paragraphs. Bullets only where they help clarify pillars or impact.",
                constraints: "Avoid detailed implementation discussions. Focus on outcomes and direction.",
                persona: "Write as someone setting direction for a product area.",
                examples: ""
            ),
            Template(
                name: "Hero slide content",
                summary: "Content for a single slide that tells the story crisply.",
                outputChannel: "Presentation slide",
                iconSystemName: "rectangle.3.offgrid.fill",
                taskOneLiner: "Generate content for a single hero slide that summarizes the story.",
                detailedObjective: "Give a title, 3 to 5 key bullets, and an optional one line takeaway that can stand alone.",
                audience: "Executive review audience.",
                toneAndStyle: "Crisp and distilled. Each bullet should carry real signal.",
                lengthGuidance: "Title plus 3 to 5 bullets. Optionally one short takeaway line.",
                outputStructure: "Hero title, bullets for key points, optional takeaway line at the bottom.",
                formattingRules: "Bullets should be short phrases, not full sentences where possible.",
                constraints: "Do not overload with detail. Avoid more than 5 bullets.",
                persona: "Write as someone preparing an exec deck.",
                examples: ""
            )
        ]
    }
}


