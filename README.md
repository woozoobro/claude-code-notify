# claude-code-notify

Native macOS notifications for Claude Code with Claude icon.

> 🇰🇷 [한국어](./README.ko.md)

![macOS](https://img.shields.io/badge/macOS-only-black)

## Install

```bash
claude plugin marketplace add woozoobro/claude-code-notify && claude plugin install claude-code-notify@woozoobro-claude-code-notify
```

On first run, the plugin compiles a native Swift app and caches it at `~/.cache/claude-code-notify/`.
macOS will ask for notification permission — make sure to allow it.

## Update

If the plugin doesn't update properly, clear the cache and reinstall:

```bash
rm -rf ~/.claude/plugins/cache/woozoobro-claude-code-notify/
claude plugin install claude-code-notify@woozoobro-claude-code-notify
```

## Uninstall

```bash
claude plugin uninstall claude-code-notify
rm -rf ~/.cache/claude-code-notify
rm -rf ~/.config/claude-code-notify
```

**Requires**: `jq` (install via `brew install jq`)

## What it does

Sends a desktop notification when Claude Code:

| Event | Sound | When |
|-------|-------|------|
| **Stop** | Hero | Claude finishes a task |
| **Permission** | Submarine | Waiting for your approval |
| **Idle** | Glass | Assistant goes idle |
| **Tool Failed** | Basso | A tool call fails |

Clicking a notification brings focus back to your terminal/editor.

## Sound Themes

Change notification sounds with the `/notify-theme` slash command inside Claude Code:

**Silent mode:**

Use the `silent` theme to disable all notification sounds while keeping visual alerts:

| Theme | Vibe |
|-------|------|
| **silent** | Visual-only, no sound |

**Game themes** (custom sound files):

| Theme | Vibe |
|-------|------|
| **lol** | Summoner's Rift vibes |
| **hearthstone** | Tavern warmth and card magic |
| **starcraft** | Terran command center alerts |

Game themes use custom audio files stored in `resources/<theme>/`. You can replace them with your own sound files — just drop files named `stop`, `permission`, `idle`, and `tool_failed` with any audio extension (`.mp3`, `.wav`, `.aiff`, `.m4a`, etc.) into the theme folder.

**System themes** (macOS built-in sounds):

| Theme | Stop | Permission | Idle | Tool Failed | Vibe |
|-------|------|-----------|------|-------------|------|
| **default** | Hero | Submarine | Glass | Basso | Clean, professional |
| **retro** | Purr | Morse | Pop | Sosumi | 8-bit nostalgia |
| **minimal** | Tink | Blow | Pop | Funk | Subtle, understated |
| **custom** | — | — | — | — | Pick each sound yourself |

Theme config is stored at `~/.config/claude-code-notify/config.json`.

## How it works

1. Claude Code hook fires → `notify.sh` runs
2. Script auto-compiles a Swift `.app` bundle on first run (cached in `~/.cache/claude-code-notify/`)
3. Notification is delivered via native macOS API with Claude icon
4. Click notification → focus returns to caller app (VSCode, Cursor, iTerm, Terminal, ghostty, Warp, Alacritty, kitty, Windsurf)

## Troubleshooting

If notifications aren't working as expected:

1. Delete the cached app bundle and let it rebuild on next run:
   ```bash
   rm -rf ~/.cache/claude-code-notify
   ```
2. Go to **System Settings → Notifications**, find **CC**, right-click and reset notification settings
