# Prompt Builder for macOS

Prompt Builder is a native macOS app that turns quick voice thoughts into structured prompts for LLMs such as ChatGPT, Gemini, and Claude.

You define reusable prompt templates for the artifacts you create most often (Slack updates, PRD outlines, executive notes, hero slides, formal emails, vision docs). Then you trigger a global shortcut, choose a template, speak your context, and get a ready-to-paste prompt.

This is a personal project and is not affiliated with any employer.

---

## Core concepts

Prompt Builder is built around three ideas:

1. **Templates**  
   Reusable prompt scaffolds that describe task, audience, tone, output structure, constraints, and other guidance.

2. **Voice to Text**  
   You speak once. The app uses macOS speech recognition to capture that as text.

3. **Wizard flow**  
   A three-step guided process:  
   1) Choose template → 2) Capture voice context → 3) Review and copy prompt.

---

## Features

### Three-step wizard

#### Step 1 – Choose template

- List of templates, each with:
  - SF Symbol icon
  - Template name
  - Short summary
- Inline actions on each template:
  - Edit (pencil icon)
  - Delete (trash icon)
- Button to create a **New template**
- Wizard header that shows progress:  
  `1  Choose template  >  2  Enter prompt context  >  3  Copy prompt`

#### Step 2 – Enter prompt context (Voice to Text)

- Large, centered button that toggles between:
  - “Start recording”
  - “Stop recording”
- Status text that explains:
  - When the app is ready for a voice prompt
  - When it is listening
  - When a transcript has been captured
  - When something went wrong (for example, speech not authorized)
- Transcript preview box:
  - Shows your spoken text as it is recognized
  - Lets you visually confirm what was captured
- Navigation controls:
  - Back to template selection
  - Next to prompt review (using the current transcript)

#### Step 3 – Review and copy prompt

- Shows the selected template’s icon, name, and summary
- Displays the full synthesized prompt, including:
  - Task and objective
  - Audience and channel
  - Tone and style
  - Length guidance
  - Structure and formatting rules
  - Constraints and persona guidance
  - Any example outputs
  - Your captured voice context in a clearly separated section
- Uses a monospaced font for the prompt body for easier scanning
- **Copy prompt** button:
  - Copies the full prompt to the clipboard
  - Shows a brief “Copied” confirmation

---

## Template system

Templates are first-class, user-editable objects stored as JSON so changes persist across app launches.

Each template contains:

**Basic info**

- Template name  
- Short summary  
- Icon (SF Symbol name, for example `doc.text.fill`, `square.and.pencil`)

**Task and audience**

- One-line task description  
- Objective (what success looks like)  
- Audience description

**Output and tone**

- Output channel or type (for example Slack message, email, PRD, slide, plain text)  
- Tone and style (for example formal, casual, executive-ready, brief)  
- Length guidance (sentences, words, or a free-form description)

**Structure and formatting**

- Expected structure (intro, bullets, sections, numbered list, etc.)  
- Formatting preferences (headings, bullets, paragraph style, etc.)

**Constraints and persona**

- Constraints and “do not do” rules  
- Persona or role for the model to adopt (for example “senior PM at an enterprise SaaS company”)

**Examples**

- Optional example outputs or stylistic patterns

All of these fields are free text. Icons are chosen from a predefined list of SF Symbols, but the prompt attributes themselves are unconstrained.

### Template editor

The template editor provides:

- Section headers with stronger typography (Basic info, Task and audience, Tone and length, Structure and formatting, Constraints and persona, Examples)
- Input fields with placeholder “Example:” text that disappears when typing begins
- Consistent alignment and spacing
- Save and Cancel actions
- Pre-filled values when editing an existing template

### Template persistence

Template data is owned by `TemplateStore`, which:

- Loads templates from disk under the user’s Application Support directory at launch
- Saves templates whenever they change (create, edit, delete)
- Installs a default set of templates on first run (Slack summary, formal email, PRD outline, vision doc summary, hero slide content)

No external database or cloud service is required.

---

## Voice to Text

Prompt Builder integrates with macOS speech frameworks to implement Voice to Text:

- Requests microphone and speech recognition authorization on first run
- Tracks and exposes state such as:
  - Authorization status
  - Whether the app is currently listening
  - The current transcript text
  - Any user-facing error message
- Handles common failure modes, surfacing messages such as:
  - “Voice to Text is not authorized. Enable microphone and speech access in System Settings.”
  - “Could not understand your voice prompt. Please try again.”

The transcript captured in Step 2 flows directly into prompt construction in Step 3.

---

## Global hotkey

Prompt Builder registers a global hotkey using Carbon `EventHotKey` APIs.

- Default chord: **Option + Shift + P (⌥⇧P)**
- Works while the app process is running, regardless of which app is frontmost
- When pressed, the hotkey:
  - Activates Prompt Builder
  - Brings the window to the front
  - Resets wizard state (clears transcript and copied state)
  - Jumps to **Step 1 – Choose template**

The same action is available in the main app menu and is displayed as the keyboard shortcut for “New prompt” in the status-item menu.

Because global hotkeys depend on a running process, the hotkey only works while Prompt Builder is running (for example, with the window closed but the app not quit).

---

## Menu-bar status item

The app also runs as a lightweight menu-bar utility.

- Creates an `NSStatusItem` in the macOS status bar
- Uses an SF Symbol such as `square.and.pencil` (avoiding the generic mic-in-use icon)
- Clicking the icon opens a compact menu with exactly two commands:

  1. **New prompt**  
     - Brings the app to the foreground  
     - Triggers the same behavior as the global hotkey (go to Step 1)  
     - Shows **⌥⇧P** as its keyboard shortcut

  2. **Quit Prompt Builder**  
     - Terminates the app process and removes the status icon

As long as the app is running (window open or closed), both the status item and the global hotkey remain active.

---

## Window layout and resizing

- Main window uses a wizard layout:
  - Wizard header band across the top
  - Step content in the center
  - Navigation bar at the bottom
- The bottom navigation bar uses a fixed height of 60 points for better visual weight and click targets.
- On Step 1, the window height is computed based on the number of templates:
  - Grows as templates are added, up to a maximum number of visible rows
  - Shrinks as templates are removed, but never below a minimum height that keeps:
    - Wizard header visible
    - Step content visible
    - Bottom navigation bar visible

---

## How the prompt is constructed

At a high level, prompt construction works as follows:

1. Start with the template’s task and objective.  
2. Add audience and channel information.  
3. Add tone, style, and length guidance.  
4. Add structure and formatting expectations.  
5. Add constraints and persona guidance if present.  
6. Add example outputs if defined on the template.  
7. Append the captured Voice to Text transcript as a dedicated “Context” section.  
8. Finish with a clear directive to produce a single final output without restating the instructions.

The resulting text is intended to be pasted directly into ChatGPT, Gemini, Claude, or any other LLM interface.

---

## Technology

Prompt Builder is implemented with:

- **SwiftUI** for most UI elements (wizard, forms, lists, dialogs)
- **AppKit** for:
  - `NSApplication` and `NSWindow`
  - Status-bar item and menu (`NSStatusBar`, `NSStatusItem`, `NSMenu`)
  - Clipboard access (`NSPasteboard`)
- **Carbon** for global hotkey registration
- **Speech** and **AVFoundation** for Voice to Text
- **Codable** and JSON for template persistence

---

## Development setup

### Requirements

- macOS 14 (Sonoma) or later recommended  
- Xcode 15 or later  
- Swift 5.9 or later

### Running from source

1. Clone the repository to your machine.  
2. Open the Xcode project file.  
3. Select the `Prompt Builder` target.  
4. Choose `My Mac` as the run destination.  
5. Build and run.  
6. On first launch, grant microphone and speech recognition permissions when prompted.

---

## Building a Release app

To create a Release build that you can install in Applications:

1. In Xcode, open the scheme editor (Product → Scheme → Edit Scheme).  
2. Under “Run”, set the build configuration to `Release`.  
3. Build the project (Product → Build).  
4. Use Product → Show Build Folder in Finder.  
5. Navigate to `Build/Products/Release`.  
6. Drag `Prompt Builder.app` into `/Applications` or `~/Applications`.  
7. Launch it from Applications or via Spotlight.

You can add the app as a Login Item in System Settings if you want it to start automatically and keep the global hotkey available after login.

---

## Sharing the app

For informal sharing with friends:

1. In Finder, locate `Prompt Builder.app` in Applications.  
2. Right-click and select “Compress Prompt Builder”.  
3. Share the resulting `Prompt Builder.zip`.

On another Mac:

1. Unzip the archive.  
2. Drag `Prompt Builder.app` into Applications.  
3. On first launch, macOS may show a warning because the app is not notarized:
   - Right-click the app, choose “Open”, and confirm  
   - Or use System Settings → Privacy & Security → “Open Anyway”

After the first successful launch, the app will run normally on that machine.

---

## Usage notes

- The global hotkey works only while the app is running. Close the window instead of quitting if you want the hotkey to stay active.
- Templates are the main lever for quality. Start with a few and refine them over time as you see how prompts perform with your LLM.
- All processing happens locally on your Mac. The app does not send your transcript or templates anywhere by itself.

---

## Roadmap ideas

Potential future enhancements:

- Preferences panel:
  - Change or disable the global hotkey
  - Configure auto-advance behavior after recording

- Template management:
  - Duplicate templates
  - Reorder templates via drag and drop
  - Import and export templates as JSON

- UX:
  - Optional auto-advance from Step 2 to Step 3 when recording stops
  - Optional “menu-bar only” mode with no Dock icon

---

## License

Prompt Builder is distributed under the **Apache License, Version 2.0**.

See the `LICENSE` file in this repository for the full license text.