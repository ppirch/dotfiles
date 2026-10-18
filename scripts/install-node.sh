#!/usr/bin/env bash
# Standalone Node.js installer via nvm (https://github.com/nvm-sh/nvm).
#
# Clones nvm when missing, ensures Node 24 (+ npm) and pnpm are
# installed under it, and removes the nvm-managed yarn (pnpm is the
# default package manager here). Safe to re-run: present tools are
# skipped. The oh-my-zsh `nvm` plugin (or the fallback block in
# zsh/.config/zsh/.zshrc) loads nvm into interactive shells.
#
# Usage:
#   scripts/install-node.sh
#
# Environment overrides:
#   NVM_DIR        install location (default: $HOME/.nvm)
#   NODE_VERSION   node line to install (default: 24)
set -euo pipefail

NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
NVM_REPO="${NVM_REPO:-https://github.com/nvm-sh/nvm.git}"
NODE_VERSION="${NODE_VERSION:-24}"

if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  if ! command -v git >/dev/null 2>&1; then
    echo "error: git is required to install nvm." >&2
    exit 1
  fi
  echo "cloning nvm -> $NVM_DIR"
  git clone "$NVM_REPO" "$NVM_DIR"
  (cd "$NVM_DIR" && git checkout -q "$(git describe --abbrev=0 --tags --match 'v[0-9]*')")
else
  echo "nvm already present at $NVM_DIR"
fi

# shellcheck disable=SC1091
. "$NVM_DIR/nvm.sh"

if [ "$(nvm version "$NODE_VERSION" 2>/dev/null)" = "N/A" ]; then
  echo "installing node $NODE_VERSION..."
  nvm install "$NODE_VERSION"
else
  echo "node already present: $(nvm version "$NODE_VERSION")"
fi

if [ "$(nvm version default 2>/dev/null)" = "N/A" ]; then
  nvm alias default "$NODE_VERSION"
fi
nvm use --silent default >/dev/null 2>&1 || true

if npm ls -g --depth=0 2>/dev/null | grep -q 'yarn@'; then
  echo "removing nvm-managed yarn (pnpm is the default)..."
  npm uninstall -g yarn >/dev/null 2>&1 || true
fi

if npm ls -g --depth=0 2>/dev/null | grep -q 'pnpm@'; then
  echo "pnpm already installed: $(pnpm --version)"
else
  echo "installing pnpm..."
  npm install -g pnpm 2>&1 | tail -n 1
fi

echo "done. ($(nvm current), npm $(npm --version), pnpm $(pnpm --version))"
