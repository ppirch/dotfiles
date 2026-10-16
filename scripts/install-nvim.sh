#!/usr/bin/env bash
# Standalone Neovim + companion tools installer (macOS + Linux).
#
# Ensures `nvim` plus the tools the dotfiles nvim config relies on:
# ripgrep (rg), fd, and the tree-sitter CLI. Safe to re-run: present
# tools are skipped. On Debian/Ubuntu a `fd` -> `fdfind` shim is created
# in ~/.local/bin when only `fdfind` exists.
#
# Version notes (non-negotiable for this config):
# - Neovim must provide `vim.pack` (https://neovim.io/doc/user/pack.html).
#   Distro packages (e.g. Ubuntu's 0.9.x) are far too old, so on Linux an
#   official neovim.io release tarball is used instead of the package
#   manager. On macOS Homebrew's neovim is always fresh.
# - The tree-sitter CLI must be >= 0.25 for nvim-treesitter's `main`
#   branch. Apt's 0.20 is replaced with a GitHub release binary.
#
# Usage:
#   scripts/install-nvim.sh
set -euo pipefail

install_packages() {
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y "$@"
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

# Feature-detect: the config needs `vim.pack`, not just any `nvim`.
nvim_has_pack() {
  command -v nvim >/dev/null 2>&1 || return 1
  nvim --headless --clean +'lua if vim.pack == nil then vim.cmd("cquit 1") end' +quit >/dev/null 2>&1
}

# Official neovim.io build (Linux). Distro packages lag years behind.
install_nvim_tarball() {
  local arch
  case "$(uname -m)" in
    x86_64) arch="x86_64" ;;
    aarch64 | arm64) arch="arm64" ;;
    *)
      echo "error: unsupported arch '$(uname -m)' for official nvim builds." >&2
      exit 1
      ;;
  esac
  if ! command -v curl >/dev/null 2>&1; then
    echo "error: curl is required to install neovim." >&2
    exit 1
  fi
  echo "installing official neovim release (vim.pack-capable)..."
  local tmpdir
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' EXIT
  curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${arch}.tar.gz" -o "$tmpdir/nvim.tar.gz"
  sudo rm -rf "/opt/nvim-linux-${arch}"
  sudo tar -C /opt -xzf "$tmpdir/nvim.tar.gz"
  sudo ln -sf "/opt/nvim-linux-${arch}/bin/nvim" /usr/local/bin/nvim
  trap - EXIT
  rm -rf "$tmpdir"
}

# tree-sitter CLI >= 0.25 is required by nvim-treesitter's `main` branch.
ts_cli_ok() {
  command -v tree-sitter >/dev/null 2>&1 || return 1
  local ver
  ver="$(tree-sitter --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -n 1)"
  [ -n "$ver" ] || return 1
  local major minor
  IFS=. read -r major minor _ <<<"$ver"
  [ "${major:-0}" -gt 0 ] || [ "${minor:-0}" -ge 25 ]
}

# GitHub release binary (Linux). Replaces fossils like apt's 0.20.
install_ts_cli_binary() {
  local asset
  case "$(uname -m)" in
    x86_64) asset="tree-sitter-linux-x64.gz" ;;
    aarch64 | arm64) asset="tree-sitter-linux-arm64.gz" ;;
    *)
      echo "error: unsupported arch '$(uname -m)' for tree-sitter binaries." >&2
      exit 1
      ;;
  esac
  if ! command -v curl >/dev/null 2>&1; then
    echo "error: curl is required to install the tree-sitter CLI." >&2
    exit 1
  fi
  echo "installing tree-sitter CLI from GitHub releases..."
  local tmpdir
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' EXIT
  curl -fsSL "https://github.com/tree-sitter/tree-sitter/releases/latest/download/${asset}" -o "$tmpdir/ts.gz"
  gunzip -f "$tmpdir/ts.gz"
  chmod +x "$tmpdir/${asset%.gz}"
  sudo install -m755 "$tmpdir/${asset%.gz}" /usr/local/bin/tree-sitter
  trap - EXIT
  rm -rf "$tmpdir"
}

missing=()
nvim_has_pack >/dev/null 2>&1 || missing+=(nvim)
command -v rg >/dev/null 2>&1 || missing+=(rg)
if ! command -v fd >/dev/null 2>&1 && ! command -v fdfind >/dev/null 2>&1; then
  missing+=(fd)
fi
ts_cli_ok || missing+=(tree-sitter)

if [ "${#missing[@]}" -eq 0 ]; then
  echo "neovim + companions already present"
else
  echo "missing tools: ${missing[*]}"
  if [ "$(uname -s)" = "Darwin" ]; then
    # Homebrew's `tree-sitter` formula is the library only; the CLI is `tree-sitter-cli`.
    # Homebrew's neovim is always fresh enough for `vim.pack`.
    brew_pkgs=()
    for tool in "${missing[@]}"; do
      case "$tool" in
        rg) brew_pkgs+=(ripgrep) ;;
        tree-sitter) brew_pkgs+=(tree-sitter-cli) ;;
        *) brew_pkgs+=("$tool") ;;
      esac
    done
    install_packages "${brew_pkgs[@]}"
  else
    # Never take neovim/tree-sitter from Linux package managers here:
    # their versions (e.g. nvim 0.9, ts-cli 0.20) predate `vim.pack`
    # and nvim-treesitter's `main` branch. Companions are fine.
    companion_pkgs=()
    for tool in "${missing[@]}"; do
      case "$tool" in
        nvim | tree-sitter) ;;
        rg) companion_pkgs+=(ripgrep) ;;
        fd)
          if command -v apt-get >/dev/null 2>&1 || command -v dnf >/dev/null 2>&1; then
            companion_pkgs+=(fd-find)
          else
            companion_pkgs+=(fd)
          fi
          ;;
      esac
    done
    if [ "${#companion_pkgs[@]}" -gt 0 ]; then
      if command -v apt-get >/dev/null 2>&1 || command -v dnf >/dev/null 2>&1 || command -v pacman >/dev/null 2>&1; then
        install_packages "${companion_pkgs[@]}" unzip
      else
        install_packages "${companion_pkgs[@]}"
      fi
    fi
  fi
fi

# Companions installed above have no version gate; fail loudly if the
# install attempt left them missing (a failed apt update must not read
# as success).
command -v rg >/dev/null 2>&1 || {
  echo "error: ripgrep install finished but 'rg' is still missing." >&2
  exit 1
}
if ! command -v fd >/dev/null 2>&1 && ! command -v fdfind >/dev/null 2>&1; then
  echo "error: fd install finished but 'fd'/'fdfind' is still missing." >&2
  exit 1
fi

# Authoritative installs (version-checked, manager-independent).
if ! nvim_has_pack; then
  if [ "$(uname -s)" = "Darwin" ]; then
    install_packages neovim
  else
    install_nvim_tarball
  fi
fi
nvim_has_pack || {
  echo "error: nvim still lacks vim.pack after install." >&2
  exit 1
}

if ! ts_cli_ok; then
  if [ "$(uname -s)" = "Darwin" ]; then
    install_packages tree-sitter-cli
  else
    install_ts_cli_binary
  fi
fi
ts_cli_ok || {
  echo "error: tree-sitter CLI still too old after install." >&2
  exit 1
}

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
