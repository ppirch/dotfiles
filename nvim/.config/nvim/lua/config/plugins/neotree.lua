local gh = require('config.plugins.manager')

-- Neo-tree dependencies. plenary.nvim is already installed for Telescope.
vim.pack.add {
  gh 'MunifTanjim/nui.nvim',
  gh 'nvim-tree/nvim-web-devicons',
  gh 'nvim-neo-tree/neo-tree.nvim',
}

require('neo-tree').setup {
  close_if_last_window = true,
  filesystem = {
    hijack_netrw_behavior = 'disabled',
    follow_current_file = { enabled = true },
    filtered_items = {
      hide_dotfiles = false,
      hide_gitignored = false,
      hide_by_name = { '.DS_Store', 'thumbs.db' },
    },
  },
  window = {
    position = 'left',
    width = 32,
    mappings = {
      ['<space>'] = 'none',
    },
  },
}

vim.keymap.set('n', '<leader>e', '<cmd>Neotree toggle<CR>', { desc = '[E]xplorer toggle Neo-tree' })
vim.keymap.set('n', '<leader>ef', '<cmd>Neotree reveal<CR>', { desc = '[E]xplorer reveal current [F]ile' })
