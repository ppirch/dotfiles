local gh = require('config.plugins.manager')

-- ============================================================
-- SECTION: FORMATTING
-- conform.nvim setup and keymap
-- ============================================================
do
  -- [[ Formatting ]]
  vim.pack.add { gh 'stevearc/conform.nvim' }
  require('conform').setup {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- You can specify filetypes to autoformat on save here:
      local enabled_filetypes = {
        -- lua = true,
        -- python = true,
      }
      if enabled_filetypes[vim.bo[bufnr].filetype] then
        return { timeout_ms = 500 }
      else
        return nil
      end
    end,
    default_format_opts = {
      lsp_format = 'fallback', -- Use external formatters if configured below, otherwise use LSP formatting. Set to `false` to disable LSP formatting entirely.
    },
    -- You can also specify external formatters in here.
    formatters_by_ft = {
      rust = { 'rustfmt' },
      -- Ruff formats and organizes imports (installed via Mason, see above)
      python = { 'ruff_format', 'ruff_organize_imports' },
      -- Biome formats and organizes imports (installed via Mason, see above)
      javascript = { 'biome', 'biome-organize-imports' },
      typescript = { 'biome', 'biome-organize-imports' },
      javascriptreact = { 'biome', 'biome-organize-imports' },
      typescriptreact = { 'biome', 'biome-organize-imports' },
      json = { 'biome' },
      css = { 'biome' },
      sql = { 'sql_formatter' },
      -- Conform can also run multiple formatters sequentially.
      -- Use 'stop_after_first' to run the first available formatter from the list,
      -- e.g. typescript = { 'biome', stop_after_first = true },
    },
  }

  vim.keymap.set({ 'n', 'v' }, '<leader>f', function() require('conform').format { async = true } end, { desc = '[F]ormat buffer' })
end
