#!/bin/zsh
# Builds hdmi-watch and registers it as a login LaunchAgent.
set -euo pipefail

DISPLAY_NAME="${1:-Odyssey G91SD}"
SCRIPT="${2:-${0:A:h}/monitor-changed.sh}"

LABEL="com.codeparth.hdmi-watch"
BIN="$HOME/.local/bin/hdmi-watch"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
LOG="$HOME/Library/Logs/hdmi-watch.log"

mkdir -p "$HOME/.local/bin" "$HOME/Library/LaunchAgents"
swiftc -O "${0:A:h}/HDMIWatch.swift" -o "$BIN"

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
    <string>${SCRIPT:A}</string>
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
