#!/usr/bin/env bash
# Standalone Rust toolchain installer (rustc/cargo via rustup).
#
# Installs rustup when missing, pins the stable toolchain, and ensures
# the `rustfmt` component (used by conform.nvim), the `rust-analyzer` CLI
# component (used by rustaceanvim in Neovim), and the `tokio-console`
# async debugger. Safe to re-run: present tools are skipped.
#
# Note: rustaceanvim deliberately uses this toolchain's rust-analyzer,
# not Mason's copy, to avoid toolchain version mismatches.
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

# tokio-console: TUI debugger for async Tokio apps. Requires the app to
# depend on `console-subscriber` with tokio's `tracing` feature enabled,
# then run `tokio-console` while the app runs.
if command -v tokio-console >/dev/null 2>&1; then
  echo "tokio-console already installed: $(tokio-console --version 2>&1 | head -n 1)"
else
  echo "installing tokio-console (this compiles a while on first run)..."
  cargo install --locked tokio-console
fi

echo "done. ($(rustc --version), $(cargo --version))"
