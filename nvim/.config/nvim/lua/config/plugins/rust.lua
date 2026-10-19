local gh = require('config.plugins.manager')

-- ============================================================
-- SECTION: RUST (rustaceanvim)
-- rustaceanvim configures its own rust-analyzer client (filetype
-- plugin, no setup() call needed) plus :RustLsp commands.
-- rust-analyzer itself comes from the rustup toolchain
-- (scripts/install-rust.sh), deliberately NOT Mason's copy,
-- to avoid toolchain version mismatches. Debugging: codelldb comes
-- from Mason (lua/kickstart/plugins/debug.lua) and is auto-detected;
-- async Tokio tasks are inspected with tokio-console (also installed
-- by scripts/install-rust.sh).
-- ============================================================
do
  -- NOTE: no `lazy = false`/ft spec needed: this plugin lazy-loads by design.
  vim.pack.add { { src = gh 'mrcjkb/rustaceanvim', version = vim.version.range '^9' } }

  vim.g.rustaceanvim = {
    server = {
      default_settings = {
        ['rust-analyzer'] = {
          check = { command = 'clippy' },
        },
      },
    },
    -- No `dap` section needed: rustaceanvim auto-detects Mason's
    -- codelldb and autoloads DAP configurations on attach.
  }
end
