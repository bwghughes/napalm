#!/usr/bin/env bash
set -euo pipefail

# Bootstrap a new Mac:
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/bwghughes/napalm/main/setupmachine.sh)"
#
# Optional overrides:
#   NAPALM_DIR="$HOME/code/napalm" SKIP_DOCK=1 /bin/bash setupmachine.sh

NAPALM_REPO="${NAPALM_REPO:-https://github.com/bwghughes/napalm.git}"
NAPALM_DIR="${NAPALM_DIR:-${HOME}/code/napalm}"
SKIP_DOCK="${SKIP_DOCK:-0}"

log() {
  printf '\n\033[1;34m==>\033[0m %s\n' "$1"
}

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This setup script only supports macOS." >&2
  exit 1
fi

log "Installing Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
else
  echo "Homebrew was installed but could not be found." >&2
  exit 1
fi

BREW_SHELLENV='eval "$('"$(brew --prefix)"'/bin/brew shellenv)"'
touch "${HOME}/.zprofile"
if ! grep -Fq "${BREW_SHELLENV}" "${HOME}/.zprofile"; then
  printf '\n%s\n' "${BREW_SHELLENV}" >> "${HOME}/.zprofile"
fi

log "Installing command-line tools"
brew update
brew install gh uv node go dockutil mole

log "Installing the latest Python managed by uv"
(cd / && uv python install --default)

log "Installing the Rust toolchain"
if ! command -v rustup >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs |
    sh -s -- -y --profile default
fi
# shellcheck disable=SC1091
source "${HOME}/.cargo/env"
rustup update stable
rustup default stable

log "Installing Napalm"
mkdir -p "$(dirname "${NAPALM_DIR}")"
if [[ -d "${NAPALM_DIR}/.git" ]]; then
  git -C "${NAPALM_DIR}" pull --ff-only
elif [[ -e "${NAPALM_DIR}" ]]; then
  echo "${NAPALM_DIR} exists but is not a Git checkout; refusing to overwrite it." >&2
  exit 1
else
  git clone "${NAPALM_REPO}" "${NAPALM_DIR}"
fi
cargo install --locked --force --path "${NAPALM_DIR}"

if [[ "${SKIP_DOCK}" != "1" ]]; then
  log "Setting up the Dock"
  keep_apps=(
    "/System/Applications/Finder.app"
    "/Applications/Safari.app"
    "/System/Applications/Mail.app"
    "/System/Applications/Calendar.app"
    "/System/Applications/Notes.app"
    "/Applications/Ghostty.app"
    "/Applications/Zed.app"
    "/Applications/Slack.app"
    "/Applications/ChatGPT.app"
  )

  dockutil --remove all --no-restart
  for app in "${keep_apps[@]}"; do
    [[ -d "${app}" ]] && dockutil --add "${app}" --no-restart
  done
  defaults write com.apple.dock tilesize -int 60
  killall Dock >/dev/null 2>&1 || true
fi

log "Setup complete"
printf '%s\n' \
  "Open a new terminal, then verify with:" \
  "  brew --version" \
  "  gh --version" \
  "  uv --version" \
  "  node --version" \
  "  go version" \
  "  python3 --version" \
  "  rustc --version" \
  "  napalm --dry-run"
