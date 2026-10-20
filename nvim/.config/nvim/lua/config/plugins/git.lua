local gh = require('config.plugins.manager')

-- Neogit provides an interactive Git interface; Diffview handles repository
-- diffs, file history, and merge conflict views.
vim.pack.add {
  gh 'tpope/vim-fugitive',
  gh 'NeogitOrg/neogit',
  gh 'sindrets/diffview.nvim',
}

-- Fugitive remains available for its Git command interface and conflict tools.
vim.keymap.set('n', '<leader>gs', vim.cmd.Git, { desc = 'Fugitive: [G]it [S]tatus' })
vim.keymap.set('n', 'gu', '<cmd>diffget //2<CR>', { desc = 'Fugitive: take ours (stage 2)' })
vim.keymap.set('n', 'gh', '<cmd>diffget //3<CR>', { desc = 'Fugitive: take theirs (stage 3)' })

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('config-fugitive', { clear = true }),
  pattern = 'fugitive',
  callback = function(event)
    vim.keymap.set('n', '<leader>p', function() vim.cmd.Git 'push' end, { buffer = event.buf, desc = 'Fugitive: push' })
    vim.keymap.set('n', '<leader>P', function() vim.cmd.Git { 'pull', '--rebase' } end, { buffer = event.buf, desc = 'Fugitive: pull with rebase' })
    vim.keymap.set('n', '<leader>t', ':Git push -u origin ', { buffer = event.buf, desc = 'Fugitive: set upstream and push' })
  end,
})

require('neogit').setup {
  graph_style = 'unicode',
  integrations = {
    diffview = true,
    telescope = true,
  },
}

require('diffview').setup {
  enhanced_diff_hl = true,
  view = {
    merge_tool = {
      layout = 'diff3_mixed',
      disable_diagnostics = true,
    },
  },
}

local neogit = require 'neogit'
vim.keymap.set('n', '<leader>gg', function() neogit.open() end, { desc = '[G]it open Neo[G]it' })
vim.keymap.set('n', '<leader>gp', function() neogit.open { 'push' } end, { desc = '[G]it [P]ush' })
vim.keymap.set('n', '<leader>gP', function() neogit.open { 'pull' } end, { desc = '[G]it [P]ull' })
vim.keymap.set('n', '<leader>gm', function() neogit.open { 'merge' } end, { desc = '[G]it [M]erge' })
vim.keymap.set('n', '<leader>gr', function() neogit.open { 'rebase' } end, { desc = '[G]it [R]ebase' })

vim.keymap.set('n', '<leader>gd', '<cmd>DiffviewOpen<CR>', { desc = '[G]it [D]iff' })
vim.keymap.set('n', '<leader>gD', '<cmd>DiffviewClose<CR>', { desc = '[G]it close [D]iff' })
vim.keymap.set('n', '<leader>gh', '<cmd>DiffviewFileHistory %<CR>', { desc = '[G]it file [H]istory' })
vim.keymap.set('n', '<leader>gH', '<cmd>DiffviewFileHistory<CR>', { desc = '[G]it repository [H]istory' })
