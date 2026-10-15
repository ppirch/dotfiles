#!/usr/bin/env bash
# Standalone Rust toolchain installer (rustc/cargo via rustup).
#
# Installs rustup when missing, pins the stable toolchain, and ensures
# the `rustfmt` component (used by conform.nvim) plus the `rust-analyzer`
# CLI component. Safe to re-run: present tools are skipped.
#
# Note: Neovim itself gets rust-analyzer from Mason
# (mason-tool-installer, driven by the `servers` table in init.lua),
# so the editor works even on machines where this script never ran.
#
# Usage:
#   scripts/install-rust.sh
set -euo pipefail

if ! command -v rustup >/dev/null 2>&1; then
  if ! command -v curl >/dev/null 2>&1; then
    echo "error: curl is required to install rustup." >&2
    exit 1
  fi
  echo "installing rustup (stable toolchain)..."
  curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  # shellcheck disable=SC1091
  [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
else
  echo "rustup already present: $(rustup --version)"
fi

if ! command -v rustc >/dev/null 2>&1 || ! command -v cargo >/dev/null 2>&1; then
  echo "error: rustup installed but rustc/cargo not on PATH." >&2
  echo "Make sure \"\$HOME/.cargo/bin\" is on PATH (or '\$HOME/.cargo/env' is sourced)." >&2
  exit 1
fi

rustup default stable >/dev/null 2>&1 || true
for component in rustfmt rust-analyzer; do
  if rustup component list --installed 2>/dev/null | grep -q "^${component}"; then
    echo "$component already installed"
  else
    echo "adding rustup component: $component"
    rustup component add "$component"
  fi
done

echo "done. ($(rustc --version), $(cargo --version))"
