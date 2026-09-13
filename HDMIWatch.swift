// Watches for a specific external display and runs a hook script on connect/disconnect.
// Usage: hdmi-watch "<display name substring>" "<hook path>"
//        hdmi-watch --list
// The hook receives "connected" or "disconnected" and the display name as arguments.
import AppKit

// launchd pipes stdout to a file, which is fully buffered by default; log lines would never appear.
setvbuf(stdout, nil, _IOLBF, 0)

let args = CommandLine.arguments
if args.count == 2 && args[1] == "--list" {
    NSScreen.screens.forEach { print($0.localizedName) }
    exit(0)
}
guard args.count == 3 else {
    FileHandle.standardError.write("usage: hdmi-watch <display-name> <hook>\n       hdmi-watch --list\n".data(using: .utf8)!)
    exit(64)
}
let displayName = args[1]
let hook = args[2]

func targetConnected() -> Bool {
    NSScreen.screens.contains { $0.localizedName.lowercased().contains(displayName.lowercased()) }
}

func runHook(state: String) {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/bin/zsh")
    task.arguments = [hook, state, displayName]
    task.terminationHandler = { if $0.terminationStatus != 0 { print("\(hook) exited \($0.terminationStatus)") } }
    do { try task.run() } catch { print("failed to run \(hook): \(error)") }
}

// Track state so we only fire on a real transition. Display-change notifications
// also arrive for resolution changes, sleep/wake and arrangement edits.
var wasConnected = targetConnected()
print("watching for \"\(displayName)\", currently connected: \(wasConnected)")

NotificationCenter.default.addObserver(
    forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: .main
) { _ in
    // The screen list can lag the notification briefly while the display handshakes.
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        let isConnected = targetConnected()
        guard isConnected != wasConnected else { return }
        wasConnected = isConnected
        let state = isConnected ? "connected" : "disconnected"
        print("\(Date()) \(state)")
        runHook(state: state)
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.prohibited)
app.run()
