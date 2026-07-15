#!/bin/bash
set -euo pipefail

CONFIG_PATH="${HOME}/.config/napalm.json"

if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <app name> [app name ...]" >&2
    echo 'Example: ./whitelist-add.sh "Slack" "Discord"' >&2
    exit 1
fi

bundle_ids=()
for app_name in "$@"; do
    bundle_id=$(osascript -e 'on run argv
        return id of application (item 1 of argv)
    end run' "$app_name" 2>/dev/null) || {
        echo "Warning: could not resolve bundle ID for \"${app_name}\", skipping" >&2
        continue
    }
    echo "Resolved \"${app_name}\" -> ${bundle_id}"
    bundle_ids+=("$bundle_id")
done

if [ "${#bundle_ids[@]}" -eq 0 ]; then
    echo "No apps resolved, nothing to add." >&2
    exit 1
fi

python3 - "$CONFIG_PATH" "${bundle_ids[@]}" << 'PY'
import json
import os
import sys

path = sys.argv[1]
new_ids = sys.argv[2:]

try:
    with open(path) as f:
        data = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    data = {}

whitelist = set(data.get("whitelist", []))
whitelist.update(new_ids)
data["whitelist"] = sorted(whitelist)

os.makedirs(os.path.dirname(path), exist_ok=True)
with open(path, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")

print(f"Wrote {path} with whitelist: {data['whitelist']}")
PY
