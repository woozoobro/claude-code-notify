# claude-code-notify

Native macOS notifications for Claude Code with Claude icon.

![macOS](https://img.shields.io/badge/macOS-only-black)

## Install

Run the following two commands in order:

```bash
# Step 1: Register the marketplace
claude plugin marketplace add woozoobro/claude-code-notify

# Step 2: Install the plugin
claude plugin install claude-code-notify@woozoobro-claude-code-notify
```

On first run, the plugin compiles a native Swift app and caches it at `~/.cache/claude-code-notify/`.
macOS will ask for notification permission — make sure to allow it.

## Uninstall

```bash
claude plugin uninstall claude-code-notify
rm -rf ~/.cache/claude-code-notify
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

## Troubleshooting

If notifications aren't working as expected:

1. Delete the cached app bundle and let it rebuild on next run:
   ```bash
   rm -rf ~/.cache/claude-code-notify
   ```
2. Go to **System Settings → Notifications**, find **CC**, right-click and reset notification settings
