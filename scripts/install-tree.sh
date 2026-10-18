#!/usr/bin/env bash
# Standalone tree installer (https://oldmanprogrammer.net/source.php?dir=projects/tree).
# Safe to re-run: no-op when tree is present.
#
# Included in the default `install.sh` run (nothing is stowed), also
# works standalone:
#   ./install.sh tree
#
# Usage:
#   scripts/install-tree.sh
set -euo pipefail

if command -v tree >/dev/null 2>&1; then
  echo "tree already present: $(tree --version 2>&1 | head -n 1)"
  exit 0
fi

if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y tree
elif command -v dnf >/dev/null 2>&1; then
  sudo dnf install -y tree
elif command -v pacman >/dev/null 2>&1; then
  sudo pacman -S --noconfirm --needed tree
elif command -v brew >/dev/null 2>&1; then
  brew install tree
else
  echo "error: no supported package manager found (apt/dnf/pacman/brew)." >&2
  echo "Install tree manually: http://mama.indstate.edu/users/ice/tree/" >&2
  exit 1
fi

if ! command -v tree >/dev/null 2>&1; then
  echo "error: tree install finished but 'tree' is still missing." >&2
  exit 1
fi

echo "done. ($(tree --version 2>&1 | head -n 1))"
