# hdmi-watch

Run your own commands when a specific monitor is plugged into or unplugged from your Mac. A tiny background watcher calls a hook script with `connected` or `disconnected`; you decide what the hook does: run a Shortcut, open apps, change settings.

Works for any external display macOS sees (HDMI, USB-C, DisplayPort, Thunderbolt), matched by name.

## Quick start

```bash
git clone https://github.com/Code-Parth/hdmi-watch && cd hdmi-watch
./install.sh                        # builds, then lists connected displays
./install.sh "Odyssey G91SD"        # watch that display, run ./hook.sh
```

Edit [`hook.sh`](hook.sh), then plug and unplug the monitor:

```bash
tail -f ~/Library/Logs/hdmi-watch.log
```

## Writing a hook

The hook gets two arguments: `$1` is `connected` or `disconnected`, `$2` is the display name.

```zsh
case "$1" in
  connected)    shortcuts run "Desk Mode" ;;
  disconnected) shortcuts run "Mobile Mode" ;;
esac
```

- **Use a Shortcut** for anything easier to build in the Shortcuts app (Focus, HomeKit, multi-step flows): `shortcuts run "Name"`.
- **Use shell commands** for everything else: `open -a`, `osascript`, `defaults write`.
- Edits to the hook apply on the next plug event. To switch to a different hook file, re-run `install.sh`.
- Test without unplugging: `./hook.sh connected "Odyssey G91SD"`.

## Examples

| File | What it does |
|---|---|
| [`examples/oled-menu-bar.sh`](examples/oled-menu-bar.sh) | Auto-hides the menu bar while an OLED monitor is attached to avoid burn-in; shows it again on the laptop screen |

```bash
./install.sh "Odyssey G91SD" examples/oled-menu-bar.sh
```

## Layout

| Path | What |
|---|---|
| `HDMIWatch.swift` | The watcher; `hdmi-watch --list` prints connected display names |
| `hook.sh` | Default hook template |
| `examples/` | Ready-made hooks |
| `install.sh` | Builds to `~/.local/bin/hdmi-watch` and loads the LaunchAgent `com.codeparth.hdmi-watch` |
| `uninstall.sh` | Unloads the agent and removes the binary and plist |

## Notes

1. **The LaunchAgent stores the hook's absolute path.** Moving or renaming the repo folder breaks the watcher until `install.sh` is re-run.
2. **The display name is a case-insensitive substring.** `"Odyssey"` matches `"Odyssey G91SD"`; get exact names from `~/.local/bin/hdmi-watch --list`.
3. **The hook only fires on a real connect or disconnect.** macOS also sends display events for resolution changes and sleep/wake; those are ignored.
4. **Hooks run in the background, not in a terminal.** The first command that controls another app (for example `osascript` talking to System Events) may trigger a macOS permission prompt. A failing hook is logged as `... exited <code>`.
5. **One watched display at a time.** Re-running `install.sh` replaces the previous setup.

```bash
./uninstall.sh
```
