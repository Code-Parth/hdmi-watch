#!/bin/zsh
# Run by hdmi-watch with "connected" or "disconnected".
# Menu bar auto-hide: Always with the external monitor, Never on the built-in screen alone.
set -eu

case "${1:-}" in
  connected)    fullscreen=false autohide=true ;;
  disconnected) fullscreen=true  autohide=false ;;
  *) echo "usage: monitor-changed.sh connected|disconnected" >&2; exit 64 ;;
esac

# System Events only controls _HIHideMenuBar, so write the full-screen key first;
# the toggle is what makes macOS reload both. Without it "Never" lands on "In Full Screen Only".
defaults write NSGlobalDomain AppleMenuBarVisibleInFullscreen -bool $fullscreen
osascript -e "tell application \"System Events\" to set autohide menu bar of dock preferences to $autohide"
