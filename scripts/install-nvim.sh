#!/usr/bin/env bash
# Standalone Neovim + companion tools installer (macOS + Linux).
#
# Ensures `nvim` plus the tools the dotfiles nvim config relies on:
# ripgrep (rg), fd, and the tree-sitter CLI. Safe to re-run: present
# tools are skipped. On Debian/Ubuntu a `fd` -> `fdfind` shim is created
# in ~/.local/bin when only `fdfind` exists.
#
# Usage:
#   scripts/install-nvim.sh
set -euo pipefail

install_packages() {
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update && sudo apt-get install -y "$@"
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y "$@"
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --noconfirm --needed "$@"
  elif command -v brew >/dev/null 2>&1; then
    brew install "$@"
  else
    echo "error: no supported package manager found (apt/dnf/pacman/brew)." >&2
    echo "Please install neovim, ripgrep, fd and tree-sitter manually." >&2
    exit 1
  fi
}

missing=()
command -v nvim >/dev/null 2>&1 || missing+=(nvim)
command -v rg >/dev/null 2>&1 || missing+=(rg)
if ! command -v fd >/dev/null 2>&1 && ! command -v fdfind >/dev/null 2>&1; then
  missing+=(fd)
fi
command -v tree-sitter >/dev/null 2>&1 || missing+=(tree-sitter)

if [ "${#missing[@]}" -eq 0 ]; then
  echo "neovim + companions already present"
else
  echo "missing tools: ${missing[*]}"
  if command -v apt-get >/dev/null 2>&1; then
    install_packages neovim ripgrep fd-find tree-sitter-cli unzip
  elif command -v dnf >/dev/null 2>&1; then
    install_packages neovim ripgrep fd-find tree-sitter-cli unzip
  elif command -v pacman >/dev/null 2>&1; then
    install_packages neovim ripgrep fd tree-sitter-cli unzip
  elif command -v brew >/dev/null 2>&1; then
    install_packages neovim ripgrep fd tree-sitter
  else
    install_packages neovim ripgrep fd tree-sitter
  fi
fi

# Debian/Ubuntu name the binary `fdfind`; telescope expects `fd`.
if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
  mkdir -p "$HOME/.local/bin"
  ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  echo "created ~/.local/bin/fd shim -> $(command -v fdfind)"
fi

if ! command -v cc >/dev/null 2>&1 || ! command -v make >/dev/null 2>&1; then
  echo "note: a C compiler + make are needed to build telescope-fzf-native."
  if [ "$(uname -s)" = "Darwin" ]; then
    echo "Install them with: xcode-select --install"
  else
    echo "Install them with your package manager, e.g.:"
    echo "  Debian/Ubuntu: sudo apt-get install -y build-essential"
    echo "  Fedora:        sudo dnf groupinstall -y 'Development Tools'"
    echo "  Arch:          sudo pacman -S --needed base-devel"
  fi
fi

echo "done."
