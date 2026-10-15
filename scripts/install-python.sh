#!/usr/bin/env bash
# Standalone Python installer via uv (https://docs.astral.sh/uv/).
#
# Installs uv when missing, then ensures a uv-managed Python exists
# (`uv python install`). Safe to re-run: present tools are skipped.
# The Python is managed by uv (under ~/.local/share/uv/python) and
# does not touch system Pythons. Use it with `uv run`, `uvx`,
# `uv venv`, or `uv tool install ...`.
#
# Usage:
#   scripts/install-python.sh
set -euo pipefail

if ! command -v uv >/dev/null 2>&1; then
  if ! command -v curl >/dev/null 2>&1; then
    echo "error: curl is required to install uv." >&2
    exit 1
  fi
  echo "installing uv..."
  curl -LsSf astral.sh/uv/install.sh | sh
  case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
  esac
else
  echo "uv already present: $(uv --version)"
fi

if ! command -v uv >/dev/null 2>&1; then
  echo "error: uv installed but not on PATH." >&2
  echo "Make sure \"\$HOME/.local/bin\" is on PATH." >&2
  exit 1
fi

echo "ensuring a uv-managed Python..."
uv python install 2>&1 | tail -n 3

echo "done. ($(uv --version), python: $(uv python find 2>/dev/null || echo 'see uv python list'))"
