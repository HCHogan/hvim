return {
  cmd = { 'clangd', "--background-index" },
  root_markers = { '.clangd', 'compile_commands.json' },
  filetypes = { 'c', 'cpp' },
  single_file_support = true,
  capabilities = {
    offsetEncoding = 'utf-8',
    textDocument = {
      completion = {
        editsNearCursor = true,
      },
      semanticTokens = {
        multilineTokenSupport = true,
      },
    }
  },
}
