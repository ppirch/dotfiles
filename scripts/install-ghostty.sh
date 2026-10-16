#!/usr/bin/env bash
# Standalone Ghostty installer (https://ghostty.org). Safe to re-run:
# no-op when ghostty is present.
#
# This is opt-in (a GUI terminal makes no sense on headless machines),
# so `install.sh` only runs it when asked:
#   ./install.sh ghostty
#
# Usage:
#   scripts/install-ghostty.sh
set -euo pipefail

if command -v ghostty >/dev/null 2>&1; then
  echo "ghostty already present: $(ghostty --version 2>&1 | head -n 1)"
else

case "$(uname -s)" in
  Darwin)
    if ! command -v brew >/dev/null 2>&1; then
      echo "error: Homebrew is required to install Ghostty on macOS." >&2
      echo "See https://brew.sh, then re-run this script." >&2
      exit 1
    fi
    echo "installing Ghostty (cask)..."
    brew install --cask ghostty
    ;;
  Linux)
    if command -v pacman >/dev/null 2>&1; then
      sudo pacman -S --noconfirm --needed ghostty
    else
      echo "error: no one-line Ghostty install for this distro." >&2
      echo "See https://ghostty.org/docs/install/binary (apt/dnf need the" >&2
      echo "official repo or a manual .deb/.rpm), then re-run this script." >&2
      exit 1
    fi
    ;;
  *)
    echo "error: unsupported OS '$(uname -s)'. Install Ghostty manually:" >&2
    echo "https://ghostty.org/docs/install/binary" >&2
    exit 1
    ;;
  esac
  echo "done. ($(ghostty --version 2>&1 | head -n 1))"
fi

# Official Catppuccin port (https://github.com/catppuccin/ghostty).
# Shadows Ghostty's built-in theme of the same name once present.
THEME_DIR="$HOME/.config/ghostty/themes"
THEME_FILE="$THEME_DIR/catppuccin-macchiato"
if [ ! -f "$THEME_FILE" ]; then
  if ! command -v curl >/dev/null 2>&1; then
    echo "error: curl is required to fetch the Catppuccin theme." >&2
    exit 1
  fi
  echo "fetching Catppuccin Macchiato theme..."
  mkdir -p "$THEME_DIR"
  curl -LsSf -o "$THEME_FILE" \
    https://github.com/catppuccin/ghostty/raw/main/themes/catppuccin-macchiato.conf
else
  echo "Catppuccin Macchiato theme already present"
fi
