-- Load plugin setup in dependency order. Keep this explicit: several sections
-- rely on plugins installed or initialized by an earlier section. Add future
-- plugin modules here next to the section they belong to.
require 'config.plugins.manager'
require 'config.plugins.ui'
require 'config.plugins.search'
require 'config.plugins.fugitive'
require 'config.plugins.lsp'
require 'config.plugins.rust'
require 'config.plugins.format'
require 'config.plugins.completion'
require 'config.plugins.treesitter'
require 'config.plugins.examples'
