#!/usr/bin/env bash
# Standalone Nerd Font installer (JetBrains Mono + FiraCode Nerd Fonts).
#
# Required by this dotfiles setup (`vim.g.have_nerd_font = true` in
# init.lua enables icons everywhere), so `install.sh` runs it by
# default — not opt-in. Safe to re-run: installed fonts are skipped.
#
# macOS: via Homebrew casks. Linux: zip downloads from the nerd-fonts
# GitHub releases into ~/.local/share/fonts + fc-cache.
#
# Usage:
#   scripts/install-fonts.sh
set -euo pipefail

# "Nerd Fonts code:cask name" pairs (zip name matches the code).
FONT_SPECS="JetBrainsMono:font-jetbrains-mono-nerd-font FiraCode:font-fira-code-nerd-font"

font_present() {
  local code="$1"
  case "$(uname -s)" in
    Darwin)
      ls "$HOME/Library/Fonts" 2>/dev/null | grep -qi "${code}.*nerd" && return 0
      return 1
      ;;
    *)
      if command -v fc-list >/dev/null 2>&1; then
        fc-list 2>/dev/null | grep -qi "$(echo "$code" | tr '[:upper:]' '[:lower:]') nerd font" && return 0
        return 1
      fi
      ls "$HOME/.local/share/fonts" "$HOME/.fonts" 2>/dev/null | grep -qi "${code}.*nerd" && return 0
      return 1
      ;;
  esac
}

install_macos() {
  local code="$1" cask="$2"
  if ! command -v brew >/dev/null 2>&1; then
    echo "error: Homebrew is required to install fonts on macOS." >&2
    echo "See https://brew.sh, then re-run this script." >&2
    exit 1
  fi
  echo "installing $cask (cask)..."
  brew install --cask "$cask"
}

install_linux() {
  local code="$1"
  if ! command -v curl >/dev/null 2>&1 || ! command -v unzip >/dev/null 2>&1; then
    echo "error: curl and unzip are required to install fonts on Linux." >&2
    exit 1
  fi
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' EXIT
  echo "downloading $code Nerd Font..."
  curl -LsSf -o "$tmpdir/$code.zip" \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$code.zip"
  mkdir -p "$HOME/.local/share/fonts"
  unzip -oq "$tmpdir/$code.zip" -d "$HOME/.local/share/fonts"
  trap - EXIT
  rm -rf "$tmpdir"
}

need_fc_cache=false
for spec in $FONT_SPECS; do
  code="${spec%%:*}"
  cask="${spec##*:}"
  if font_present "$code"; then
    echo "$code Nerd Font already installed"
    continue
  fi
  case "$(uname -s)" in
    Darwin) install_macos "$code" "$cask" ;;
    Linux)
      install_linux "$code"
      need_fc_cache=true
      ;;
    *)
      echo "error: unsupported OS '$(uname -s)'. Install a Nerd Font manually:" >&2
      echo "https://www.nerdfonts.com/font-downloads" >&2
      exit 1
      ;;
  esac
done

if [ "$need_fc_cache" = true ]; then
  command -v fc-cache >/dev/null 2>&1 && fc-cache -f >/dev/null 2>&1 || true
fi

echo "done. Select a Nerd Font in your terminal (e.g. Ghostty) to see icons."
