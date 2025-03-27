vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    map('<leader>ld', function() vim.diagnostic.open_float() end, 'Hover diagnostic')
    map('<leader>lr', vim.lsp.buf.rename, 'rename')
    map('<leader>lf', vim.lsp.buf.format, 'format')

    map('gd', vim.lsp.buf.definition, 'goto definition')
    map('gD', vim.lsp.buf.declaration, 'goto definition')
    map('gi', vim.lsp.buf.implementation, 'goto implementation')

    -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
    ---@param client vim.lsp.Client
    ---@param method vim.lsp.protocol.Method
    ---@param bufnr? integer some lsp support methods only in specific files
    ---@return boolean
    local function client_supports_method(client, method, bufnr)
      return client:supports_method(method, bufnr)
    end

    local client = vim.lsp.get_client_by_id(event.data.client_id)

    if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint) then
      map('<leader>lH', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
      end, 'Toggle Inlay Hints')
    end

    -- The following two autocommands are used to highlight references of the
    -- word under your cursor when your cursor rests there for a little while.
    --    See `:help CursorHold` for information about when this is executed
    if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight) then
      local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
        end,
      })
    end
  end
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend('force', capabilities, require('blink.cmp').get_lsp_capabilities())

vim.lsp.config("*", {
  capabilities = capabilities
})

local lsps = { "clangd", "basedpyright", "luals", "hls", "rust_analyzer" }

for _, lsp in ipairs(lsps) do
  if vim.fn.executable(vim.lsp.config[lsp].cmd[1]) == 1 then
    vim.lsp.enable(lsp)
  end
end
