# hdmi-watch

Switches the menu bar auto-hide setting when a specific external monitor connects or disconnects: "Always" with the monitor attached, "Never" on the MacBook screen alone. No Shortcuts involved.

## Layout

| Path | What |
|---|---|
| `HDMIWatch.swift` | Background watcher; listens for display changes and runs the script with `connected` or `disconnected` on a real transition |
| `monitor-changed.sh` | The action: sets the two menu bar keys for the given state |
| `install.sh` | Builds to `~/.local/bin/hdmi-watch` and loads the LaunchAgent `com.codeparth.hdmi-watch` |
| `uninstall.sh` | Unloads the agent and removes the binary and plist |

## Invariants

1. **The LaunchAgent stores the script's absolute path.** Moving or renaming this folder breaks the watcher until `install.sh` is re-run. Edits to `monitor-changed.sh` take effect on the next event with no reinstall; edits to `HDMIWatch.swift` need one.
2. **The display name is a case-insensitive substring of `NSScreen.localizedName`.** Check the real name with `system_profiler SPDisplaysDataType` before changing it.
3. **Write `AppleMenuBarVisibleInFullscreen` before toggling auto-hide.** System Events only controls `_HIHideMenuBar`; toggling it alone gives "In Full Screen Only" instead of "Never". The toggle is what makes macOS reload both keys live.
4. **The watcher only fires on a connected/disconnected change.** Display notifications also arrive for resolution changes and sleep/wake; acting on every one would reapply the setting constantly.

| Setting | `_HIHideMenuBar` | `AppleMenuBarVisibleInFullscreen` |
|---|---|---|
| Always | 1 | 0 |
| Never | 0 | 1 |

## Commands

```bash
./install.sh "Odyssey G91SD"
./monitor-changed.sh disconnected
./monitor-changed.sh connected
tail -f ~/Library/Logs/hdmi-watch.log
./uninstall.sh
```

A failing script shows up in the log as `... exited <code>`.
