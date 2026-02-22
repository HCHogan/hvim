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
    end, "code action")
    -- map('<leader>lf', function() vim.lsp.buf.format({ async = true }) end, 'format')

    map("gd", vim.lsp.buf.definition, "goto definition")
    map("gr", vim.lsp.buf.references, "goto references")
    map("gD", vim.lsp.buf.declaration, "goto declaration")
    map("gi", vim.lsp.buf.implementation, "goto implementation")
    map("gh", vim.lsp.buf.typehierarchy, "goto type hierarchy")
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
capabilities.textDocument = capabilities.textDocument or {}
capabilities.textDocument.completion = capabilities.textDocument.completion or {}
capabilities.textDocument.completion.completionItem = capabilities.textDocument.completion.completionItem or {}
capabilities.textDocument.completion.completionItem.snippetSupport = true

local ok_blink, blink = pcall(require, "blink.cmp")
if ok_blink and blink.get_lsp_capabilities then
  capabilities = blink.get_lsp_capabilities(capabilities)
end

vim.lsp.config("*", {
  capabilities = capabilities,
})

local lsps = { "clangd", "basedpyright", "luals", "nil", "neocmake", "bashls", "elmls", "html", "jsonls", "taplo",
  "yamlls", "cssls" }

for _, lsp in ipairs(lsps) do
  local config = vim.lsp.config[lsp]
  if config then
    local cmd = config.cmd
    if type(cmd) == "function" then
      vim.lsp.enable(lsp)
    elseif type(cmd) == "table" and cmd[1] and vim.fn.executable(cmd[1]) == 1 then
      vim.lsp.enable(lsp)
    end
  end
end
