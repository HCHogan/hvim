vim.bo.expandtab = true -- local to buffer
vim.bo.tabstop = 4         -- local to buffer
vim.bo.softtabstop = 4     -- local to buffer
vim.bo.shiftwidth = 4      -- local to buffer

local bufnr = vim.api.nvim_get_current_buf()
vim.keymap.set('n', '<leader>a', function()
  vim.cmd.RustLsp 'codeAction' -- supports rust-analyzer's grouping
  -- or vim.lsp.buf.codeAction() if you don't want grouping.
end, { silent = true, buffer = bufnr })
