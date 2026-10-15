#!/usr/bin/env bash
# Optional Docker installer. Safe to re-run: no-op when docker is present.
#
# This is opt-in on purpose (heavyweight install, daemon setup differs
# per OS), so `install.sh` only runs it when asked:
#   ./install.sh docker
#
# Usage:
#   scripts/install-docker.sh
set -euo pipefail

if command -v docker >/dev/null 2>&1; then
  echo "docker already present: $(docker --version)"
  echo "done."
  exit 0
fi

case "$(uname -s)" in
  Darwin)
    if ! command -v brew >/dev/null 2>&1; then
      echo "error: Homebrew is required to install Docker Desktop on macOS." >&2
      echo "See https://brew.sh, then re-run this script." >&2
      exit 1
    fi
    echo "installing Docker Desktop (cask)..."
    brew install --cask docker-desktop
    echo "done. Launch Docker Desktop once to finish setup (daemon + login)."
    ;;
  Linux)
    if command -v apt-get >/dev/null 2>&1; then
      sudo apt-get update && sudo apt-get install -y docker.io
    elif command -v dnf >/dev/null 2>&1; then
      sudo dnf install -y docker
    elif command -v pacman >/dev/null 2>&1; then
      sudo pacman -S --noconfirm --needed docker
    else
      echo "error: no supported package manager found (apt/dnf/pacman)." >&2
      echo "Install Docker Engine manually: https://docs.docker.com/engine/install/" >&2
      exit 1
    fi
    echo "done. You may need: sudo usermod -aG docker \"\$USER\" (then log out/in)."
    ;;
  *)
    echo "error: unsupported OS '$(uname -s)'. Install Docker manually:" >&2
    echo "https://docs.docker.com/engine/install/" >&2
    exit 1
    ;;
esac
