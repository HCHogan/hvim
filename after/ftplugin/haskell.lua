vim.bo.expandtab = true -- local to buffer
vim.bo.tabstop = 2      -- local to buffer
vim.bo.softtabstop = 2  -- local to buffer
vim.bo.shiftwidth = 2   -- local to buffer

vim.cmd('TSEnable highlight')
-- ~/.config/nvim/after/ftplugin/haskell.lua
local ht = require('haskell-tools')
local bufnr = vim.api.nvim_get_current_buf()
local opts = { noremap = true, silent = true, buffer = bufnr, }

-- haskell-language-server relies heavily on codeLenses,
-- so auto-refresh (see advanced configuration) is enabled by default
vim.keymap.set('n', '<space>ll', vim.lsp.codelens.run, opts)
-- Evaluate all code snippets
vim.keymap.set('n', '<space>le', ht.lsp.buf_eval_all, opts)
