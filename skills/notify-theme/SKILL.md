---
name: notify-theme
description: Change the notification sound theme for claude-code-notify
allowed-tools: Read, Write, Bash
---

# Notify Theme

Change the notification sound theme for claude-code-notify.

## Instructions

1. Read `~/.config/claude-code-notify/config.json` if it exists. Note the current theme so you can indicate it to the user.

2. Use AskUserQuestion to present the available themes. Mark the current theme with "(Current)" in its label.

   Since AskUserQuestion supports max 4 options per question, split into two questions. **The first question MUST show game themes**, the second shows system themes:

   **First question — Game themes & Silent** (custom sound files + silent mode):

   | Theme | Vibe |
   |-------|------|
   | **silent** | Visual-only, no sound |
   | **lol** | Summoner's Rift vibes |
   | **hearthstone** | Tavern warmth and card magic |
   | **starcraft** | Terran command center alerts |

   Game themes play custom audio files from `resources/<theme>/`. Users can replace them with their own files — just use filenames `stop`, `permission`, `idle`, `tool_failed` with any audio extension (`.mp3`, `.wav`, `.aiff`, `.m4a`, etc.).

   The **silent** theme disables all notification sounds while keeping visual alerts.

   **Second question — System sound themes** (macOS built-in sounds):

   | Theme | Stop | Permission | Idle | Tool Failed | Vibe |
   |-------|------|-----------|------|-------------|------|
   | **default** | Hero | Submarine | Glass | Basso | Clean, professional |
   | **retro** | Purr | Morse | Pop | Sosumi | Playful 8-bit nostalgia |
   | **minimal** | Tink | Blow | Pop | Funk | Subtle, understated |

   Also include a **Custom** option in the second question that lets the user pick each sound individually from macOS system sounds.

3. If the user selects **Custom**, use AskUserQuestion 4 times — once for each event (stop, permission, idle, tool_failed) — letting them choose from available macOS system sounds:

   Basso, Blow, Bottle, Frog, Funk, Glass, Hero, Morse, Ping, Pop, Purr, Sosumi, Submarine, Tink

4. Create the config directory if needed and write the selection:

   ```bash
   mkdir -p ~/.config/claude-code-notify
   ```

   For a preset theme (both system and game themes):
   ```json
   { "theme": "retro" }
   ```

   For a custom theme:
   ```json
   {
     "theme": "custom",
     "sounds": {
       "stop": "Purr",
       "permission": "Ping",
       "idle": "Pop",
       "tool_failed": "Sosumi"
     }
   }
   ```

5. Confirm the change with a brief summary showing the selected sounds for each event.
