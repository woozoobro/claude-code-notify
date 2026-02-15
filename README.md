# claude-code-notify

Native macOS notifications for Claude Code with Claude icon.

![macOS](https://img.shields.io/badge/macOS-only-black)

## Install

Pick whichever method you prefer:

From your terminal:

```bash
claude plugin add https://github.com/woozoobro/claude-code-notify
```

Or from inside a Claude Code session:

```
/plugin install https://github.com/woozoobro/claude-code-notify
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

## How it works

1. Claude Code hook fires → `notify.sh` runs
2. Script auto-compiles a Swift `.app` bundle on first run (cached in `~/.cache/claude-code-notify/`)
3. Notification is delivered via native macOS API with Claude icon
4. Click notification → focus returns to caller app (VSCode, Cursor, iTerm, Terminal, ghostty, Warp, Alacritty, kitty, Windsurf)
