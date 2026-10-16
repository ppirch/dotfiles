#!/usr/bin/env bash
# Standalone tmux installer. Safe to re-run: no-op when tmux is present.
#
# Included in the default `install.sh` run (which also stows ~/.tmux.conf),
# also works standalone:
#   ./install.sh tmux
#
# Usage:
#   scripts/install-tmux.sh
set -euo pipefail

if command -v tmux >/dev/null 2>&1; then
  echo "tmux already present: $(tmux -V)"
else
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update && sudo apt-get install -y tmux
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y tmux
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --noconfirm --needed tmux
  elif command -v brew >/dev/null 2>&1; then
    brew install tmux
  else
    echo "error: no supported package manager found (apt/dnf/pacman/brew)." >&2
    echo "Install tmux manually: https://github.com/tmux/tmux/wiki/Installing" >&2
    exit 1
  fi
fi

# TPM (tmux plugin manager), required by ~/.tmux.conf (`run .../tpm/tpm`).
fresh_tpm=0
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  if ! command -v git >/dev/null 2>&1; then
    echo "error: git is required to install tpm." >&2
    exit 1
  fi
  echo "cloning tpm -> $HOME/.tmux/plugins/tpm"
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  fresh_tpm=1
else
  echo "tpm already present at $HOME/.tmux/plugins/tpm"
fi

# Install the `@plugin`s from ~/.tmux.conf right away (headless-safe).
# Without this the theme and status modules stay inactive until someone
# presses `<prefix> I` inside tmux.
if [ "$fresh_tpm" = "1" ] && [ -f "$HOME/.tmux.conf" ]; then
  echo "installing tmux plugins..."
  "$HOME/.tmux/plugins/tpm/bin/install_plugins"
elif [ ! -f "$HOME/.tmux.conf" ]; then
  echo "note: ~/.tmux.conf not stowed yet — run ./install.sh tmux, then"
  echo "press '<prefix> I' inside tmux to install the configured plugins."
fi

echo "done. ($(tmux -V))"
