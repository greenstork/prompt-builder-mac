# Prompt Builder for macOS

Prompt Builder is a small native macOS app that helps you turn quick voice thoughts into high-quality prompts for LLMs (ChatGPT, Gemini, Claude, etc.).

You define reusable prompt templates for your common work artifacts (Slack posts, PRDs, executive updates, vision one-pagers, hero slides, emails). Then you hit a global shortcut, talk, and get a ready-to-paste prompt that includes both your template guidance and your spoken context.

This is a personal side project. It is not affiliated with or supported by any employer.

---

## Core concepts

Prompt Builder is built around three ideas:

1. **Templates**  
   Reusable prompt scaffolds that define task, audience, tone, output structure, constraints, and other guidance.

2. **Voice to Text**  
   You speak context once. The app uses macOS speech recognition to capture that as text.

3. **Wizard flow**  
   A three step flow:
   1. Choose template  
   2. Capture voice context  
   3. Review and copy the generated prompt

---

## Features

### Three step wizard

- **Step 1 – Choose template**  
  - List of templates with:
    - Icon (SF Symbol)  
    - Name  
    - Short summary  
  - Inline actions on each template:
    - Edit template  
    - Delete template  
  - Button to create a **New template**
  - Wizard header at the top shows:
    - Step 1: Choose template  
    - Step 2: Enter prompt context  
    - Step 3: Copy prompt  

- **Step 2 – Enter prompt context (Voice to Text)**  
  - Large record / stop button with clear states:
    - Start recording  
    - Stop recording  
  - Status text that explains:
    - When the app is ready for a voice prompt  
    - When it is listening  
    - When a transcript has been captured  
    - When there is an error (for example, speech not authorized, prompt not understood)
  - Transcript preview box:
    - Shows your spoken text in real time  
    - Lets you visually confirm what was captured
  - Navigation:
    - Back to template selection  
    - Skip to prompt (uses the current transcript)  

- **Step 3 – Review and copy prompt**  
  - Shows selected template icon, name, and summary  
  - Shows full generated prompt, including:
    - Task, objective, audience, tone, length, structure, constraints, persona, examples  
    - Your captured voice context appended in a clear section  
  - Uses a monospaced font for the prompt body for easier scanning  
  - **Copy prompt** button:
    - Copies the full prompt to the clipboard (Pasteboard)  
    - Shows a brief “Copied” state

### Template system

Templates are first class objects, not hard coded strings.

Each template contains:

- Name and short summary  
- Icon system name (SF Symbol string, for example `doc.text.fill`, `square.and.pencil`)  
- Prompt attributes, all free text:
  - Task one liner  
  - Detailed objective  
  - Output channel (Slack, email, PRD, slide, etc.)  
  - Audience  
  - Tone and style  
  - Length guidance  
  - Output structure  
  - Formatting rules  
  - Constraints and guardrails  
  - Persona or role to adopt  
  - Example outputs

Key behaviors:

- Templates are persisted to JSON on disk, so edits survive app restarts  
- You can:
  - Create new templates  
  - Edit existing templates  
  - Delete templates  
- The template editor:
  - Groups fields into logical sections (Basic info, Tone and length, Structure and formatting, Constraints and persona, Examples)  
  - Uses clear labels and placeholder examples (placeholder text disappears when you start typing)  
  - Uses free text for all fields so you can describe whatever you want the LLM to do

### Voice to Text

The app uses macOS speech recognition and microphone access to implement Voice to Text:

- Requests and checks authorization for speech and microphone usage  
- Tracks listening state:
  - Not authorized  
  - Ready  
  - Listening  
  - Transcript captured  
  - Error states  
- Captures a transcript string, which:
  - Is shown in Step 2  
  - Feeds into prompt construction in Step 3

Voice errors are surfaced as short human readable messages such as:

- Voice to Text is not authorized. Enable microphone and speech access in System Settings.  
- Could not understand your voice prompt. Please try again.

### Global hotkey

Prompt Builder registers a **global hotkey** using the Carbon EventHotKey APIs:

- Default chord: **Option + Shift + P (⌥⇧P)**  
- The hotkey works as long as the app is running, regardless of which app is frontmost  
- When pressed:
  - Prompt Builder is activated and brought to the front  
  - Wizard jumps to **Step 1 – Choose template**  
  - Previous transcript and “copied” state are cleared  
  - Templates remain as configured

### Menu bar status item

Prompt Builder runs as a normal app with a Dock icon, but it also provides a status item in the macOS menu bar:

- Status icon:
  - Uses an SF Symbol such as `square.and.pencil`, not the generic mic indicator  
  - Appears near the system clock while the app is running  

- Status item menu:
  - **New prompt**  
    - Brings the app to the front  
    - Jumps to Step 1 of the wizard  
    - Same logical action as the global hotkey  
    - Shows the ⌥⇧P shortcut in the menu  
  - Separator  
  - **Quit Prompt Builder**  
    - Fully terminates the app and removes the status icon

### Window behavior and layout

- Window automatically resizes based on the number of templates in Step 1:
  - Grows as you add templates, up to a maximum number of visible rows  
  - Shrinks as you delete templates, but never below a minimum height  
- Minimum height is set high enough so that:
  - Wizard header is always visible  
  - Step content (especially Step 2) is fully visible  
  - Bottom navigation bar is not clipped  
- Additional layout polish:
  - Wizard header band with consistent height and padding  
  - Better vertical spacing for navigation controls  
  - Icons and typography sized for legibility

---

## How it works at a high level

### Prompt construction

The central builder is:

```swift
func buildPrompt(template: Template, notes: String) -> String