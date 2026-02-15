import Cocoa

// MARK: - Notification Delegate

class NotificationDelegate: NSObject, NSUserNotificationCenterDelegate {
    var terminalBundleId: String?

    func userNotificationCenter(_ center: NSUserNotificationCenter,
                                didActivate notification: NSUserNotification) {
        if let bundleId = terminalBundleId,
           let app = NSRunningApplication.runningApplications(withBundleIdentifier: bundleId).first {
            app.activate()
        }
        CFRunLoopStop(CFRunLoopGetMain())
    }

    func userNotificationCenter(_ center: NSUserNotificationCenter,
                                shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
}

// MARK: - Helpers

func detectTerminalBundleId() -> String? {
    if let cfBundle = ProcessInfo.processInfo.environment["__CFBundleIdentifier"],
       !cfBundle.isEmpty {
        return cfBundle
    }

    let termProgram = ProcessInfo.processInfo.environment["TERM_PROGRAM"] ?? ""
    switch termProgram {
    case "iTerm.app":       return "com.googlecode.iterm2"
    case "Apple_Terminal":  return "com.apple.Terminal"
    case "WarpTerminal":    return "dev.warp.Warp-Stable"
    case "ghostty":         return "com.mitchellh.ghostty"
    case "Alacritty":       return "org.alacritty"
    case "kitty":           return "net.kovidgoyal.kitty"
    case "vscode":          return "com.microsoft.VSCode"
    case "cursor":          return "com.todesktop.runtime.Cursor"
    case "windsurf":        return "com.codeium.windsurf"
    case "tmux":            return nil
    default:                return nil
    }
}

// MARK: - Main

// CLI args: arg1 = title, arg2 = sound, arg3 = caller bundle ID, arg4 = subtitle
let args = CommandLine.arguments
let argTitle    = args.count > 1 ? args[1] : nil
let argSound    = args.count > 2 ? args[2] : nil
let argBundleId = args.count > 3 ? args[3] : nil
let argSubtitle = args.count > 4 ? args[4] : nil

let title = argTitle ?? "Claude Code"
let subtitle = argSubtitle.flatMap { $0.isEmpty ? nil : $0 }
let sound = argSound ?? "default"

// Set up delegate for notification click → activate caller app
let delegate = NotificationDelegate()
delegate.terminalBundleId = argBundleId.flatMap { $0.isEmpty ? nil : $0 } ?? detectTerminalBundleId()
NSUserNotificationCenter.default.delegate = delegate

// Build and deliver notification — 2 lines only: title + subtitle
let notification = NSUserNotification()
notification.title = title
notification.subtitle = subtitle
notification.hasActionButton = true
notification.actionButtonTitle = "Open"

if !sound.isEmpty {
    notification.soundName = sound
}

NSUserNotificationCenter.default.deliver(notification)

// Run loop: wait up to 5s for user to click, then exit
let _ = CFRunLoopRunInMode(.defaultMode, 5.0, false)
