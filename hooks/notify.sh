#!/bin/bash
# Claude Code notification hook — auto-compiles Swift .app bundle on first run
# Usage: notify.sh <event>
#   Events: stop, permission, idle, tool_failed
# Reads JSON from stdin with context fields (cwd, message, tool_name, etc.)

set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CACHE_DIR="$HOME/.cache/claude-code-notify"
APP_BUNDLE="$CACHE_DIR/ClaudeNotify.app"
BINARY="$APP_BUNDLE/Contents/MacOS/ClaudeNotify"
SWIFT_SRC="$PLUGIN_ROOT/src/main.swift"
ICON_SRC="$PLUGIN_ROOT/resources/AppIcon.icns"

INPUT=$(cat)
EVENT="${1:-stop}"

# ── Extract context from JSON ─────────────────────────────────────────

JSON_MESSAGE=$(echo "$INPUT" | jq -r '.message // empty' 2>/dev/null || true)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null || true)
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty' 2>/dev/null || true)

# ── Resolve event → title, sound, subtitle ────────────────────────────

case "$EVENT" in
    stop)
        TITLE="Stop"
        SOUND="Hero"
        ;;
    permission)
        TITLE="Permission"
        SOUND="Submarine"
        ;;
    idle)
        TITLE="Idle"
        SOUND="Glass"
        ;;

    tool_failed)
        TITLE="Tool Failed"
        SOUND="Basso"
        [ -n "$TOOL_NAME" ] && TITLE="Tool Failed: $TOOL_NAME"
        ;;
    *)
        TITLE="Claude Code"
        SOUND="default"
        ;;
esac

# ── Apply theme config ───────────────────────────────────────────────

THEME_CONFIG="$HOME/.config/claude-code-notify/config.json"

if [ ! -f "$THEME_CONFIG" ]; then
    mkdir -p "$(dirname "$THEME_CONFIG")"
    echo '{ "theme": "default" }' > "$THEME_CONFIG"
fi

THEME=$(jq -r '.theme // "default"' "$THEME_CONFIG" 2>/dev/null || echo "default")

if [ "$THEME" = "custom" ]; then
    CUSTOM_SOUND=$(jq -r ".sounds.${EVENT} // empty" "$THEME_CONFIG" 2>/dev/null || true)
    [ -n "$CUSTOM_SOUND" ] && SOUND="$CUSTOM_SOUND"
elif [ "$THEME" != "default" ]; then
    THEME_FILE="$PLUGIN_ROOT/themes.json"
    if [ -f "$THEME_FILE" ]; then
        THEME_SOUND=$(jq -r ".[\"${THEME}\"].sounds.${EVENT} // empty" "$THEME_FILE" 2>/dev/null || true)
        [ -n "$THEME_SOUND" ] && SOUND="$THEME_SOUND"
    fi
fi

# ── For stop event, extract last assistant message from transcript ─────

if [ "$EVENT" = "stop" ] && [ -z "$JSON_MESSAGE" ] \
   && [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
    # Wait briefly for transcript to be flushed with the current turn
    sleep 0.5
    LAST_MSG=$(tail -20 "$TRANSCRIPT_PATH" \
        | jq -r 'select(.type == "assistant") | .message.content[] | select(.type == "text") | .text' 2>/dev/null \
        | tail -1 \
        | tr '\n' ' ' \
        | sed 's/  */ /g; s/^[[:space:]]*//; s/[[:space:]]*$//')
    if [ -n "$LAST_MSG" ]; then
        # Truncate for notification subtitle
        if [ ${#LAST_MSG} -gt 50 ]; then
            LAST_MSG="${LAST_MSG:0:47}..."
        fi
        JSON_MESSAGE="$LAST_MSG"
    fi
fi

# For permission events, shorten the message
if [ "$EVENT" = "permission" ] && [ -n "$JSON_MESSAGE" ]; then
    TOOL=$(echo "$JSON_MESSAGE" | sed -n 's/.*to use \(.*\)/\1/p')
    if [ -n "$TOOL" ]; then
        JSON_MESSAGE="$TOOL"
    elif echo "$JSON_MESSAGE" | grep -q "needs your attention"; then
        JSON_MESSAGE="Input needed"
    fi
fi

SUBTITLE="${JSON_MESSAGE:-Claude Code}"

# ── Resolve repo name ─────────────────────────────────────────────────

CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || true)
if [ -z "$CWD" ]; then
    CWD="${CLAUDE_PROJECT_DIR:-}"
fi

REPO=""
if [ -n "$CWD" ] && [ -d "$CWD" ]; then
    REPO=$(cd "$CWD" 2>/dev/null && basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null) || true
fi

# Append repo to title
if [ -n "$REPO" ]; then
    TITLE="$TITLE · $REPO"
fi

# ── Build .app bundle ─────────────────────────────────────────────────

build_app_bundle() {
    mkdir -p "$APP_BUNDLE/Contents/MacOS"
    mkdir -p "$APP_BUNDLE/Contents/Resources"

    swiftc "$SWIFT_SRC" \
        -o "$BINARY" \
        -framework Cocoa \
        -suppress-warnings \
        2>/dev/null

    if [ -f "$ICON_SRC" ]; then
        cp "$ICON_SRC" "$APP_BUNDLE/Contents/Resources/AppIcon.icns"
    fi

    cat > "$APP_BUNDLE/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>com.woozoobro.claude-code-notify</string>
    <key>CFBundleName</key>
    <string>CC</string>
    <key>CFBundleExecutable</key>
    <string>ClaudeNotify</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
PLIST

    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
        -f "$APP_BUNDLE" 2>/dev/null || true
}

send_osascript_fallback() {
    local safe_title="${TITLE//\\/\\\\}" safe_subtitle="${SUBTITLE//\\/\\\\}"
    safe_title="${safe_title//\"/\\\"}"
    safe_subtitle="${safe_subtitle//\"/\\\"}"
    osascript -e "display notification \"${safe_subtitle}\" with title \"${safe_title}\" sound name \"${SOUND}\"" 2>/dev/null || true
}

# Build if missing or source is newer
if [ ! -x "$BINARY" ] || [ "$SWIFT_SRC" -nt "$BINARY" ]; then
    if command -v swiftc &>/dev/null; then
        build_app_bundle
    else
        send_osascript_fallback
        exit 0
    fi
fi

# ── Detect caller app ─────────────────────────────────────────────────

CALLER_BUNDLE_ID="${__CFBundleIdentifier:-}"

if [ -z "$CALLER_BUNDLE_ID" ]; then
    case "${TERM_PROGRAM:-}" in
        vscode)          CALLER_BUNDLE_ID="com.microsoft.VSCode" ;;
        cursor)          CALLER_BUNDLE_ID="com.todesktop.runtime.Cursor" ;;
        windsurf)        CALLER_BUNDLE_ID="com.codeium.windsurf" ;;
        iTerm.app)       CALLER_BUNDLE_ID="com.googlecode.iterm2" ;;
        Apple_Terminal)  CALLER_BUNDLE_ID="com.apple.Terminal" ;;
        WarpTerminal)    CALLER_BUNDLE_ID="dev.warp.Warp-Stable" ;;
        ghostty)         CALLER_BUNDLE_ID="com.mitchellh.ghostty" ;;
        Alacritty)       CALLER_BUNDLE_ID="org.alacritty" ;;
        kitty)           CALLER_BUNDLE_ID="net.kovidgoyal.kitty" ;;
    esac
fi

# ── Send notification ─────────────────────────────────────────────────

if [ -x "$BINARY" ]; then
    "$BINARY" "$TITLE" "$SOUND" "${CALLER_BUNDLE_ID:-}" "$SUBTITLE"
else
    send_osascript_fallback
fi
