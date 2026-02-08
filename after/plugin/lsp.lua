vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
    end

    map("<leader>ld", function()
      vim.diagnostic.open_float()
    end, "Hover diagnostic")
    map("<leader>lr", vim.lsp.buf.rename, "rename")
    map("<leader>la", function()
      vim.lsp.buf.code_action()
    end, "format")
    -- map('<leader>lf', function() vim.lsp.buf.format({ async = true }) end, 'format')

    map("gd", vim.lsp.buf.definition, "goto definition")
    map("gr", vim.lsp.buf.references, "goto definition")
    map("gD", vim.lsp.buf.declaration, "goto definition")
    map("gi", vim.lsp.buf.implementation, "goto implementation")
    map("gh", vim.lsp.buf.typehierarchy, "goto implementation")
    map("K", function() vim.lsp.buf.hover({ border = 'rounded' }) end, "Hover")

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
      map("<leader>lH", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
      end, "Toggle Inlay Hints")
    end
  end,
})

local capabilities = vim.lsp.protocol.make_client_capabilities()

vim.lsp.config("*", {
  capabilities = capabilities,
})

local lsps = { "clangd", "basedpyright", "luals", "nil", "neocmake", "bashls" }

for _, lsp in ipairs(lsps) do
  if vim.fn.executable(vim.lsp.config[lsp].cmd[1]) == 1 then
    vim.lsp.enable(lsp)
  end
end
