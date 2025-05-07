vim.diagnostic.config {
  virtual_lines = false,
  virtual_text = true,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = vim.diagnostic.severity.ERROR },
  signs = true,
}

for _, sev in ipairs({ "Error", "Warn", "Info", "Hint" }) do
  local sign_name = "DiagnosticSign" .. sev
  vim.fn.sign_define(sign_name, {
    text   = "",
    texthl = "",
    numhl  = "Diagnostic" .. sev,
  })
end
