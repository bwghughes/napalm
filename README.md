```
 ███╗   ██╗ █████╗ ██████╗  █████╗ ██╗     ███╗   ███╗
 ████╗  ██║██╔══██╗██╔══██╗██╔══██╗██║     ████╗ ████║
 ██╔██╗ ██║███████║██████╔╝███████║██║     ██╔████╔██║
 ██║╚██╗██║██╔══██║██╔═══╝ ██╔══██║██║     ██║╚██╔╝██║
 ██║ ╚████║██║  ██║██║     ██║  ██║███████╗██║ ╚═╝ ██║
 ╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝
```

A fast, no-nonsense macOS command-line tool that quits all running GUI applications in one shot. Written in Rust.

> **macOS only** — uses native AppKit/NSWorkspace APIs via Objective-C bindings. Will not compile on Linux or Windows.

## Set up a new Mac

The bootstrap installs Homebrew, GitHub CLI, uv, Node.js, Go, the latest
uv-managed Python, the stable Rust toolchain, Napalm, Zed, Ghostty, and Slack.
It also applies the preferred Dock layout.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/bwghughes/napalm/master/setupmachine.sh)"
```

To keep the current Dock layout:

```bash
SKIP_DOCK=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/bwghughes/napalm/master/setupmachine.sh)"
```

The script is safe to run again: existing tools are left in place, Rust is
updated, and the Napalm checkout is fast-forwarded rather than replaced.

## Install

```bash
cargo build --release
cp target/release/napalm /usr/local/bin/
```

## Usage

```bash
napalm              # Gracefully quit all apps
napalm --force      # Force-terminate all apps (no save prompts)
napalm --dry-run    # Preview what would be quit
```

## Config

Apps can be whitelisted via `~/.config/napalm.json`:

```json
{
  "whitelist": [
    "com.apple.Safari",
    "com.apple.Terminal"
  ]
}
```

Whitelisted apps are skipped during quit, just like the built-in safelist (Finder, System Preferences).

To find an app's bundle ID:

```bash
osascript -e 'id of app "Safari"'
```

## Built-in Safelist

These apps are **never** quit, regardless of config:

- `com.apple.finder`
- `com.apple.systempreferences`
