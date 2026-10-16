#!/usr/bin/env bash
# Standalone bat installer (https://github.com/sharkdp/bat). Safe to
# re-run: no-op when bat is present.
#
# Included in the default `install.sh` run (which also stows
# bat/.config/bat/config), also works standalone:
#   ./install.sh bat
#
# Usage:
#   scripts/install-bat.sh
set -euo pipefail

if command -v bat >/dev/null 2>&1; then
  echo "bat already present: $(bat --version 2>&1 | head -n 1)"
  echo "done."
  exit 0
fi

if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y bat
elif command -v dnf >/dev/null 2>&1; then
  sudo dnf install -y bat
elif command -v pacman >/dev/null 2>&1; then
  sudo pacman -S --noconfirm --needed bat
elif command -v brew >/dev/null 2>&1; then
  brew install bat
else
  echo "error: no supported package manager found (apt/dnf/pacman/brew)." >&2
  echo "Install bat manually: https://github.com/sharkdp/bat#installation" >&2
  exit 1
fi

# Debian/Ubuntu ship the binary as `batcat`; link it as `bat` when needed.
if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
  mkdir -p "$HOME/.local/bin"
  ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
  export PATH="$HOME/.local/bin:$PATH"
fi

if ! command -v bat >/dev/null 2>&1; then
  echo "error: bat install finished but 'bat' is still missing." >&2
  exit 1
fi

echo "done. ($(bat --version 2>&1 | head -n 1))"
