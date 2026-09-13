#!/bin/zsh
# Your automation. hdmi-watch runs this on every connect and disconnect of the display you chose.
#   $1  "connected" or "disconnected"
#   $2  the display name passed to install.sh
# Edits take effect on the next plug event; no reinstall needed. Output lands in ~/Library/Logs/hdmi-watch.log.
set -eu
display="${2:-display}"

case "${1:-}" in
  connected)
    echo "$display connected"
    # Run a Shortcut you built in the Shortcuts app:
    # shortcuts run "Desk Mode"

    # Open an app:
    # open -a "Spotify"

    # Set output volume (0-100):
    # osascript -e 'set volume output volume 40'
    ;;

  disconnected)
    echo "$display disconnected"
    # shortcuts run "Mobile Mode"
    ;;

  *)
    echo "usage: hook.sh connected|disconnected [display name]" >&2
    exit 64
    ;;
esac
