#!/usr/bin/env bash
set -euo pipefail

# Chekc for dockutil, installl of not there.
if ! command -v dockutil >/dev/null 2>&1; then
  echo "Installing dockutil…"
  brew install dockutil
fi

keep_apps=(
  "/System/Applications/Finder.app"
  "/Applications/Safari.app"
  "/System/Applications/Mail.app"
  "/System/Applications/Calendar.app"
  "/System/Applications/Notes.app"
  "/Applllications/Ghostty.app"
  "/Applications/Zed.app"
  "/Applications/Slack.app"
  "/Applications/ChatGPT.app"
)

dockutil --remove all --no-restart

for app in "${keep_apps[@]}"; do
  [[ -d "$app" ]] && dockutil --add "$app" --no-restart
done

# Resize dock
defaults write com.apple.dock tilesize -int 60
killall Dock
