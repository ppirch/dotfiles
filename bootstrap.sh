#!/bin/sh
# Universal dotfiles entrypoint (macOS + Linux, POSIX sh compatible).
#
# One-liner install:
#   curl -fsSL https://raw.githubusercontent.com/ppirch/dotfiles/main/bootstrap.sh | sh
#
# With package arguments (forwarded to install.sh):
#   curl -fsSL .../bootstrap.sh | sh -s -- nvim zsh
#
# Environment overrides:
#   DOTFILES_DIR   where to clone (default: $HOME/dotfiles)
#   DOTFILES_REPO  git remote (default: https://github.com/ppirch/dotfiles.git)
#   DOTFILES_REF   branch to clone (default: main)
set -eu

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/ppirch/dotfiles.git}"
DOTFILES_REF="${DOTFILES_REF:-main}"

if [ "$(uname -s)" = "Darwin" ]; then
  if ! xcode-select -p >/dev/null 2>&1; then
    echo "error: Xcode Command Line Tools are required on macOS." >&2
    echo "Run 'xcode-select --install' first, then re-run this script." >&2
    exit 1
  fi
fi

if ! command -v git >/dev/null 2>&1; then
  echo "error: git is required to install dotfiles." >&2
  exit 1
fi

if [ -d "$DOTFILES_DIR/.git" ]; then
  echo "updating $DOTFILES_DIR"
  git -C "$DOTFILES_DIR" pull --ff-only
else
  if [ -e "$DOTFILES_DIR" ]; then
    echo "error: $DOTFILES_DIR exists and is not a git repository." >&2
    exit 1
  fi
  echo "cloning dotfiles -> $DOTFILES_DIR"
  git clone --depth=1 --branch "$DOTFILES_REF" "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

exec "$DOTFILES_DIR/install.sh" "$@"
