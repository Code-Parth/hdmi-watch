#!/bin/zsh
# Builds hdmi-watch and registers it as a login LaunchAgent.
# Usage: ./install.sh "<display name>" [hook script, default ./hook.sh]
set -euo pipefail

LABEL="com.codeparth.hdmi-watch"
BIN="$HOME/.local/bin/hdmi-watch"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
LOG="$HOME/Library/Logs/hdmi-watch.log"

mkdir -p "$HOME/.local/bin" "$HOME/Library/LaunchAgents"
swiftc -O "${0:A:h}/HDMIWatch.swift" -o "$BIN"

if [[ $# -lt 1 ]]; then
  echo "usage: ./install.sh \"<display name>\" [hook script]" >&2
  echo "connected displays:" >&2
  "$BIN" --list | sed 's/^/  /' >&2
  exit 64
fi
DISPLAY_NAME="$1"
HOOK="${2:-${0:A:h}/hook.sh}"
[[ -f "$HOOK" ]] || { echo "hook not found: $HOOK" >&2; exit 66; }

cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>$BIN</string>
    <string>$DISPLAY_NAME</string>
    <string>${HOOK:A}</string>
  </array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
  <key>StandardOutPath</key><string>$LOG</string>
  <key>StandardErrorPath</key><string>$LOG</string>
</dict>
</plist>
EOF

launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"
echo "installed; log at $LOG"
