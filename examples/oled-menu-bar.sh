#!/bin/zsh
# Menu bar auto-hide: Always while an OLED monitor is attached (avoids burn-in from a static
# menu bar), Never on the built-in screen alone.
# Install with: ./install.sh "<display name>" examples/oled-menu-bar.sh
set -eu

case "${1:-}" in
  connected)    fullscreen=false autohide=true ;;
  disconnected) fullscreen=true  autohide=false ;;
  *) echo "usage: oled-menu-bar.sh connected|disconnected" >&2; exit 64 ;;
esac

# System Events only controls _HIHideMenuBar, so write the full-screen key first;
# the toggle is what makes macOS reload both. Without it "Never" lands on "In Full Screen Only".
defaults write NSGlobalDomain AppleMenuBarVisibleInFullscreen -bool $fullscreen
osascript -e "tell application \"System Events\" to set autohide menu bar of dock preferences to $autohide"
