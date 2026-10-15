#!/usr/bin/env bash
# Install/symlink dotfiles packages with GNU Stow.
#
# Usage:
#   ./install.sh [package ...]   # default: nvim zsh rust
#
# Examples:
#   ./install.sh                 # stow the default packages
#   ./install.sh nvim            # stow just nvim (-> ~/.config/nvim)
#   ./install.sh docker          # optional: install Docker only (nothing stowed)
#   ./install.sh python          # optional: install Python via uv (nothing stowed)
#   ./install.sh node            # optional: install Node via nvm (nothing stowed)
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$HOME"
PACKAGES=("$@")

if [ "${#PACKAGES[@]}" -eq 0 ]; then
  PACKAGES=(nvim zsh rust)
fi

install_system_package() {
  local pkg="$1"
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update && sudo apt-get install -y "$pkg"
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y "$pkg"
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --noconfirm --needed "$pkg"
  elif command -v brew >/dev/null 2>&1; then
    brew install "$pkg"
  else
    echo "error: could not install '$pkg' automatically (no apt/dnf/pacman/brew)." >&2
    exit 1
  fi
}

# Clones oh-my-zsh + extra plugins via scripts/install-omz.sh (plain
# `git clone`, so the stowed ~/.zshrc symlink is never touched).
# No-ops when already installed.
bootstrap_oh_my_zsh() {
  "$DOTFILES_DIR/scripts/install-omz.sh"
}

if ! command -v stow >/dev/null 2>&1; then
  echo "stow not found, attempting to install..."
  install_system_package stow
fi

for pkg in "${PACKAGES[@]}"; do
  # Tool-only installers (no stow package directory).
  case "$pkg" in
    rust)
      "$DOTFILES_DIR/scripts/install-rust.sh"
      continue
      ;;
    docker)
      "$DOTFILES_DIR/scripts/install-docker.sh"
      continue
      ;;
    python)
      "$DOTFILES_DIR/scripts/install-python.sh"
      continue
      ;;
    node)
      "$DOTFILES_DIR/scripts/install-node.sh"
      continue
      ;;
  esac

  if [ ! -d "$DOTFILES_DIR/$pkg" ]; then
    echo "error: package '$pkg' not found in $DOTFILES_DIR" >&2
    exit 1
  fi

  if [ "$pkg" = "zsh" ]; then
    bootstrap_oh_my_zsh
  fi

  if [ "$pkg" = "nvim" ]; then
    "$DOTFILES_DIR/scripts/install-nvim.sh"
  fi

  echo "stowing $pkg -> $TARGET"
  stow -R -d "$DOTFILES_DIR" -t "$TARGET" "$pkg"
done

if [[ " ${PACKAGES[*]} " == *" zsh "* ]] && [ "$(basename "${SHELL:-}")" != "zsh" ]; then
  echo "note: your login shell is '${SHELL:-unknown}'. To make zsh the default, run:"
  echo "  chsh -s \"\$(command -v zsh)\""
fi

echo "done."
