local blink_capabilities = require('blink.cmp').get_lsp_capabilities()

local my_capabilities = {
  offsetEncoding = 'utf-8',
  textDocument = {
    completion = {
      editsNearCursor = true,
    },
    semanticTokens = {
      multilineTokenSupport = true,
    },
  }
}


local function tableMerge(t1, t2)
  for k, v in pairs(t2) do
    if type(v) == "table" then
      if type(t1[k] or false) == "table" then
        tableMerge(t1[k] or {}, t2[k] or {})
      else
        t1[k] = v
      end
    else
      t1[k] = v
    end
  end
  return t1
end

local config = {
  cmd = { 'clangd', "--background-index" },
  root_markers = { '.clangd', 'compile_commands.json' },
  filetypes = { 'c', 'cpp' },
  single_file_support = true,
  capabilities = tableMerge(blink_capabilities, my_capabilities),
}

return config
