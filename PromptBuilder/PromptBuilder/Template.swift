import Foundation

/// Represents a reusable prompt template in Prompt Builder.
///
/// Design:
/// - Some fields are "internal" (used to describe the template in the UI).
/// - Other fields are "prompt guidance" (used to actually build the LLM prompt).
struct Template: Identifiable, Codable, Equatable {

    // MARK: - Identity and basic info

    var id: UUID
    var name: String                 // Display name
    var summary: String              // Short description shown in the list
    var iconSystemName: String       // SF Symbols name for the icon

    // MARK: - Internal / organizational fields

    /// Internal one-line description of what the template is for.
    /// This does not need to be included in the final prompt.
    var internalDescription: String

    /// Optional channel or environment, for example "Slack message",
    /// "Email", "PRD", "Presentation slide", "Slack AI search".
    /// You can use this to influence role framing, but it does not
    /// need to be printed as a labeled line in the final prompt.
    var channelOrEnvironment: String

    // MARK: - Prompt guidance fields (drive the final prompt)

    /// The primary instruction to the LLM. This should usually be the
    /// first line of the prompt.
    var objective: String

    /// Who the output is for.
    var audience: String

    /// Tone and style guidance, for example "brief and executive ready".
    var toneAndStyle: String

    /// High level length guidance (words, sentences, or free form).
    var lengthGuidance: String

    /// Description of how the output should be structured.
    var outputStructure: String

    /// Any specific formatting rules.
    var formattingRules: String

    /// Constraints and "do not do" rules.
    var constraints: String

    /// Persona or role for the model, for example "senior PM at an enterprise SaaS company".
    var persona: String

    /// Example outputs or stylistic patterns (optional).
    var examples: String

    // MARK: - New designated initializer

    init(
        id: UUID = UUID(),
        name: String,
        summary: String,
        iconSystemName: String,
        internalDescription: String = "",
        channelOrEnvironment: String = "",
        objective: String,
        audience: String,
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
        self.iconSystemName = iconSystemName
        self.internalDescription = internalDescription
        self.channelOrEnvironment = channelOrEnvironment
        self.objective = objective
        self.audience = audience
        self.toneAndStyle = toneAndStyle
        self.lengthGuidance = lengthGuidance
        self.outputStructure = outputStructure
        self.formattingRules = formattingRules
        self.constraints = constraints
        self.persona = persona
        self.examples = examples
    }

    // MARK: - Backwards compatibility initializer
    //
    // This matches the old signature:
    // init(id:name:summary:outputChannel:iconSystemName:taskOneLiner:detailedObjective:audience:toneAndStyle:lengthGuidance:outputStructure:formattingRules:constraints:persona:examples:)

    init(
        id: UUID,
        name: String,
        summary: String,
        outputChannel: String,
        iconSystemName: String,
        taskOneLiner: String,
        detailedObjective: String,
        audience: String,
        toneAndStyle: String,
        lengthGuidance: String,
        outputStructure: String,
        formattingRules: String,
        constraints: String,
        persona: String,
        examples: String
    ) {
        self.id = id
        self.name = name
        self.summary = summary
        self.iconSystemName = iconSystemName

        self.internalDescription = taskOneLiner
        self.channelOrEnvironment = outputChannel
        self.objective = detailedObjective
        self.audience = audience
        self.toneAndStyle = toneAndStyle
        self.lengthGuidance = lengthGuidance
        self.outputStructure = outputStructure
        self.formattingRules = formattingRules
        self.constraints = constraints
        self.persona = persona
        self.examples = examples
    }

    // MARK: - Computed properties to keep old call sites compiling

    /// Old name for `channelOrEnvironment`.
    var outputChannel: String {
        get { channelOrEnvironment }
        set { channelOrEnvironment = newValue }
    }

    /// Old name for `internalDescription`.
    var taskOneLiner: String {
        get { internalDescription }
        set { internalDescription = newValue }
    }

    /// Old name for `objective`.
    var detailedObjective: String {
        get { objective }
        set { objective = newValue }
    }
}

// MARK: - Default templates

extension Template {

    static func defaultTemplates() -> [Template] {
        return [

            // 1. Executive Slack summary
            Template(
                name: "Executive Slack summary",
                summary: "Short Slack update to leadership with context, decisions, and next steps.",
                iconSystemName: "bubble.left.and.bubble.right.fill",
                internalDescription: "Slack update to VP or GM about a project or decision.",
                channelOrEnvironment: "Slack message",
                objective: "Write a concise Slack update for executive leadership summarizing the current situation, key decisions, and next steps.",
                audience: "VP or GM and their staff.",
                toneAndStyle: "Brief, direct, executive ready. No fluff.",
                lengthGuidance: "3 to 6 short paragraphs or bullet blocks, max 200 to 250 words.",
                outputStructure: "Start with one sentence headline, then 3 to 5 bullets: context, what changed or was decided, and what happens next.",
                formattingRules: "Use short paragraphs and bullets. Avoid markdown headings unless they add real clarity.",
                constraints: "Do not restate basic company history. Focus on what is new, risky, or needs attention.",
                persona: "You are a senior product manager reporting status to an executive sponsor.",
                examples: ""
            ),

            // 2. Formal email
            Template(
                name: "Formal email",
                summary: "Polished email suitable for external or senior internal stakeholders.",
                iconSystemName: "envelope.fill",
                internalDescription: "Structured email with greeting, clear ask, and close.",
                channelOrEnvironment: "Email",
                objective: "Draft a clear and professional email that I can send directly after light editing.",
                audience: "Senior internal stakeholders or external partners.",
                toneAndStyle: "Professional, concise, courteous.",
                lengthGuidance: "3 to 6 short paragraphs.",
                outputStructure: "Greeting, one paragraph of context, one paragraph that states the ask or decision, supporting details, then a crisp closing.",
                formattingRules: "No bullet lists unless truly needed. Keep line length comfortable on desktop and mobile.",
                constraints: "Avoid slang and emojis. Do not over-apologize.",
                persona: "You are a senior PM or director representing an enterprise SaaS company.",
                examples: ""
            ),

            // 3. Product requirements outline
            Template(
                name: "Product requirements outline",
                summary: "Structured PRD style outline that you can paste into a doc.",
                iconSystemName: "doc.text.fill",
                internalDescription: "Outline for a PRD / spec that engineers and stakeholders can read.",
                channelOrEnvironment: "PRD document",
                objective: "Create a structured product requirements outline for the described feature or initiative.",
                audience: "Engineers, PMs, designers, and technical stakeholders.",
                toneAndStyle: "Clear, structured, and neutral. No marketing language.",
                lengthGuidance: "As long as needed, but in outline form.",
                outputStructure: "Sections for Overview, Problem / Opportunity, Goals and non-goals, Users and use cases, Requirements, Open questions, Risks.",
                formattingRules: "Use numbered headings and bullet lists where appropriate. Make section titles easy to scan.",
                constraints: "Do not invent requirements that conflict with the context. Call out assumptions explicitly.",
                persona: "You are a product manager writing a first draft PRD.",
                examples: ""
            ),

            // 4. Vision doc summary
            Template(
                name: "Vision doc summary",
                summary: "High level narrative about the future direction of a product.",
                iconSystemName: "lightbulb.fill",
                internalDescription: "Narrative that explains a product vision and why it matters.",
                channelOrEnvironment: "Vision document",
                objective: "Write a narrative summary of the product vision described in my context.",
                audience: "Executives, cross functional partners, and senior ICs.",
                toneAndStyle: "Aspirational but grounded. Clear and confident.",
                lengthGuidance: "500 to 1000 words for a full vision; shorter if the context suggests a brief.",
                outputStructure: "Opening that frames the problem and opportunity, then sections for Current state, Future state, Key bets, and Impact.",
                formattingRules: "Use headings and short paragraphs. Avoid long unbroken walls of text.",
                constraints: "Do not promise things that contradict the context. Make tradeoffs and risks explicit.",
                persona: "You are a product leader explaining a 1 to 3 year vision.",
                examples: ""
            ),

            // 5. Hero slide content
            Template(
                name: "Hero slide content",
                summary: "Content for a single slide that tells the story crisply.",
                iconSystemName: "rectangle.3.offgrid.fill",
                internalDescription: "Generate content for a single slide that summarizes the story.",
                channelOrEnvironment: "Presentation slide",
                objective: "Summarize the key points from my context into content for a single hero slide.",
                audience: "Executive review audience.",
                toneAndStyle: "Crisp and distilled. Each bullet should carry real signal.",
                lengthGuidance: "Title plus 3 to 5 bullets. Optionally one short takeaway line.",
                outputStructure: "Hero title, 3 to 5 bullets for key points, and an optional one line takeaway at the bottom.",
                formattingRules: "Bullets should be short phrases, not full sentences where possible.",
                constraints: "Do not overload with detail. Avoid more than 5 bullets.",
                persona: "You are preparing content for an exec deck.",
                examples: ""
            ),

            // 6. Find Slack person or conversation
            Template(
                name: "Find Slack person or conversation",
                summary: "Use Slack AI to search my message history for a specific person or conversation based on my description.",
                iconSystemName: "magnifyingglass.circle",
                internalDescription: "Prompt for Slack AI to search my past conversations for a person or specific discussion.",
                channelOrEnvironment: "Slack AI search",
                objective: "Search my Slack message history to find the specific person or conversation I am referring to, based on the context I provide.",
                audience: "Me, using Slack AI to search my own workspace.",
                toneAndStyle: "Be concise and focused on actionable search results, not long explanations.",
                lengthGuidance: "Short reply: one or two sentences plus a compact list of matches.",
                outputStructure: "Start with a brief statement of what you found, then list each likely match as a bullet with person name, channel, approximate date, and one short summary line.",
                formattingRules: "",
                constraints: "Do not invent people or conversations that do not exist in my Slack workspace. If you are not confident about a match, say so explicitly and ask for one clarifying detail.",
                persona: "You are a helpful search assistant operating inside Slack, specialized in searching my own message history.",
                examples: "For example, you might say: \"It looks like you are referring to Jane Doe in #payments on March 3. Here are the top matches...\" followed by a short bulleted list."
            ),
            
        ]
    }
    static func empty() -> Template {
            Template(
                name: "Untitled template",
                summary: "",
                iconSystemName: "doc.text",              // any neutral SF Symbol
                internalDescription: "",
                channelOrEnvironment: "",
                objective: "Help me with the task described in the context below.",
                audience: "",
                toneAndStyle: "",
                lengthGuidance: "",
                outputStructure: "",
                formattingRules: "",
                constraints: "",
                persona: "",
                examples: ""
            )
        }
}
