#!/usr/bin/env bash
# Standalone GitHub CLI installer (https://cli.github.com). Safe to
# re-run: no-op when gh is present.
#
# This is opt-in, so `install.sh` only runs it when asked:
#   ./install.sh gh
#
# Note: authentication is interactive and never automated — run
# `gh auth login` yourself after installing.
#
# Usage:
#   scripts/install-gh.sh
set -euo pipefail

if command -v gh >/dev/null 2>&1; then
  echo "gh already present: $(gh --version 2>&1 | head -n 1)"
  if gh auth status >/dev/null 2>&1; then
    echo "gh is authenticated."
  else
    echo "note: gh is not authenticated yet — run 'gh auth login'."
  fi
  echo "done."
  exit 0
fi

if command -v apt-get >/dev/null 2>&1; then
  sudo mkdir -p -m 755 /etc/apt/keyrings
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  sudo apt-get update
  sudo apt-get install -y gh
elif command -v dnf >/dev/null 2>&1; then
  sudo dnf install -y 'dnf-command(config-manager)' >/dev/null 2>&1 || true
  sudo dnf config-manager addrepo --from-repofile=https://cli.github.com/packages/rpm/gh-cli.repo
  sudo dnf install -y gh
elif command -v pacman >/dev/null 2>&1; then
  sudo pacman -S --noconfirm --needed github-cli
elif command -v brew >/dev/null 2>&1; then
  brew install gh
else
  echo "error: no supported package manager found (apt/dnf/pacman/brew)." >&2
  echo "Install gh manually: https://github.com/cli/cli#installation" >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "error: gh install finished but 'gh' is still missing." >&2
  exit 1
fi

echo "done. ($(gh --version 2>&1 | head -n 1))"
echo "note: authenticate with 'gh auth login'."
