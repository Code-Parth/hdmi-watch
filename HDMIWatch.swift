// Watches for a specific external display and runs a script on connect/disconnect.
// Usage: hdmi-watch "<display name substring>" "<script path>"
// The script receives "connected" or "disconnected" as its only argument.
import AppKit

// launchd pipes stdout to a file, which is fully buffered by default; log lines would never appear.
setvbuf(stdout, nil, _IOLBF, 0)

let args = CommandLine.arguments
guard args.count == 3 else {
    FileHandle.standardError.write("usage: hdmi-watch <display-name> <script>\n".data(using: .utf8)!)
    exit(64)
}
let target = args[1].lowercased()
let script = args[2]

func targetConnected() -> Bool {
    NSScreen.screens.contains { $0.localizedName.lowercased().contains(target) }
}

func runScript(state: String) {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/bin/zsh")
    task.arguments = [script, state]
    task.terminationHandler = { if $0.terminationStatus != 0 { print("\(script) exited \($0.terminationStatus)") } }
    do { try task.run() } catch { print("failed to run \(script): \(error)") }
}

// Track state so we only fire on a real transition. Display-change notifications
// also arrive for resolution changes, sleep/wake and arrangement edits.
var wasConnected = targetConnected()
print("watching for \"\(args[1])\", currently connected: \(wasConnected)")

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
        runScript(state: state)
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.prohibited)
app.run()
