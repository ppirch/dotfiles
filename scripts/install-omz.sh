#!/usr/bin/env bash
# Standalone zsh + oh-my-zsh installer.
#
# Installs the zsh binary (if missing) and clones oh-my-zsh plus extra
# plugins with git. Safe to re-run: everything is skipped when present.
# Uses plain `git clone` (not the OMZ installer script) so an existing
# ~/.zshrc — e.g. the one stowed from this repo — is never touched.
#
# Usage:
#   scripts/install-omz.sh
#
# Environment overrides:
#   OMZ_DIR     install location (default: $HOME/.oh-my-zsh)
#   ZSH_CUSTOM  oh-my-zsh custom dir (default: $OMZ_DIR/custom)
set -euo pipefail

OMZ_DIR="${OMZ_DIR:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM="${ZSH_CUSTOM:-$OMZ_DIR/custom}"
OMZ_REPO="${OMZ_REPO:-https://github.com/ohmyzsh/ohmyzsh.git}"

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

if ! command -v zsh >/dev/null 2>&1; then
  echo "zsh not found, attempting to install..."
  install_system_package zsh
fi

if ! command -v git >/dev/null 2>&1; then
  echo "error: git is required to install oh-my-zsh." >&2
  exit 1
fi

if [ ! -d "$OMZ_DIR" ]; then
  echo "cloning oh-my-zsh -> $OMZ_DIR"
  git clone --depth=1 "$OMZ_REPO" "$OMZ_DIR"
else
  echo "oh-my-zsh already present at $OMZ_DIR"
fi

for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
  if [ ! -d "$ZSH_CUSTOM/plugins/$plugin" ]; then
    echo "cloning $plugin"
    git clone --depth=1 "https://github.com/zsh-users/$plugin.git" "$ZSH_CUSTOM/plugins/$plugin"
  else
    echo "$plugin already present"
  fi
done

if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  echo "cloning powerlevel10k"
  git clone --depth=1 "https://github.com/romkatv/powerlevel10k.git" "$ZSH_CUSTOM/themes/powerlevel10k"
else
  echo "powerlevel10k already present"
fi

echo "done. (To make zsh your login shell: chsh -s \"\$(command -v zsh)\")"
