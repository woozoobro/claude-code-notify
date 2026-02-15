---
name: notify-theme
description: Change the notification sound theme for claude-code-notify
---

# Notify Theme

Change the notification sound theme for claude-code-notify.

## Instructions

1. Read `~/.config/claude-code-notify/config.json` if it exists. Note the current theme so you can indicate it to the user.

2. Use AskUserQuestion to present the available themes. Mark the current theme with "(Current)" in its label:

   | Theme | Stop | Permission | Idle | Tool Failed | Vibe |
   |-------|------|-----------|------|-------------|------|
   | **default** | Hero | Submarine | Glass | Basso | Clean, professional |
   | **retro** | Purr | Morse | Pop | Sosumi | Playful 8-bit nostalgia |
   | **minimal** | Tink | Blow | Pop | Funk | Subtle, understated |
   | **arcade** | Bottle | Frog | Morse | Basso | Fun, attention-grabbing |
   | **zen** | Glass | Blow | Submarine | Tink | Calm, peaceful |

   Also include a **Custom** option that lets the user pick each sound individually.

3. If the user selects **Custom**, use AskUserQuestion 4 times — once for each event (stop, permission, idle, tool_failed) — letting them choose from available macOS system sounds:

   Basso, Blow, Bottle, Frog, Funk, Glass, Hero, Morse, Ping, Pop, Purr, Sosumi, Submarine, Tink

4. Create the config directory if needed and write the selection:

   ```bash
   mkdir -p ~/.config/claude-code-notify
   ```

   For a preset theme:
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
