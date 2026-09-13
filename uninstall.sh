#!/bin/zsh
LABEL="com.codeparth.hdmi-watch"
launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
rm -f "$HOME/Library/LaunchAgents/$LABEL.plist" "$HOME/.local/bin/hdmi-watch"
echo "removed"
