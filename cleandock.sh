#!/usr/bin/env bash
set -euo pipefail

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

killall Dock
