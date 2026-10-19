local gh = require('config.plugins.manager')

vim.pack.add { gh 'tpope/vim-fugitive' }

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
