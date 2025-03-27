-- personal statusline
local fn, api = vim.fn, vim.api
local laststatus =
    string.format("%%#%s#%s%%%%* ", "StatusLine", string.rep(" ", vim.o.columns - 1))
local function get_lsp_diagnostic_count(diag_type)
  local result = vim.diagnostic.get(0, { severity = diag_type })
  return result and #result or 0
end
local is_formatting = false

local function statusline(data)
  local ft = vim.bo.ft

  local s = { val = "" }
  function s:append(text, hl)
    self.val = self.val .. string.format("%%#%s#%s %%* ", hl or "StatusLine", text)
  end

  s:append("")
  -- tab info
  local tabs = api.nvim_list_tabpages()
  if #tabs > 1 then
    s:append(1 + vim.fn.index(tabs, api.nvim_get_current_tabpage()) .. ":" .. #tabs)
  end

  -- search info
  ---@diagnostic disable-next-line: undefined-field
  if vim.v.hlsearch == 1 then
    local ok, search = pcall(fn.searchcount)
    if ok and search.total and search.total > 0 then
      local current = search.current
      s:append(current == 0 and "" or current .. "/" .. search.total, "Function")
    end
  end

  -- Macro recording status
  if fn.reg_recording() ~= "" then
    s:append(" REC: " .. fn.reg_recording(), "Macro")
  end

  -- Lsp diagnostic
  local error_count = get_lsp_diagnostic_count(vim.diagnostic.severity.ERROR)
  if error_count ~= 0 then
    s:append(" " .. error_count, "DiagnosticError")
  end
  local warning_count = get_lsp_diagnostic_count(vim.diagnostic.severity.WARN)
  if warning_count ~= 0 then
    s:append(" " .. warning_count, "DiagnosticWarn")
  end
  if warning_count and error_count and warning_count == 0 and error_count == 0 then
    local info_count = get_lsp_diagnostic_count(vim.diagnostic.severity.INFO)
    if info_count ~= 0 then
      s:append(" " .. info_count, "DiagnosticInfo")
    end
    local hint_count = get_lsp_diagnostic_count(vim.diagnostic.severity.HINT)
    if hint_count ~= 0 then
      s:append(" " .. hint_count, "DiagnosticHint")
    end
  end

  -- prevents info from disappearing when opening some util buffers
  if fn.fnamemodify(api.nvim_buf_get_name(0), ":t") == "" then
    return laststatus
  end

  s:append("%=")
  -- Code intelligence info
  local lsp = {}
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  vim.tbl_map(function(client)
    table.insert(lsp, client.name)
  end, clients)
  if vim.tbl_isempty(lsp) then
    local ok, parser = pcall(vim.treesitter.get_parser)
    if ok and parser then
      ---@diagnostic disable-next-line: undefined-field
      s:append(parser:lang(), "Directory")
    end
  else
    s:append("[" .. table.concat(lsp, ",") .. "]", "Keyword")
  end

  -- Guard info
  local ok, au = pcall(
    api.nvim_get_autocmds,
    { group = "Guard", event = "BufWritePre", buffer = 0 }
  )
  if ok and #au ~= 0 and require("guard.filetype")[ft].formatter then
    if data then
      if data.status == "pending" then
        is_formatting = true
      elseif data.status == "done" then
        is_formatting = false
      end
    end
    s:append(is_formatting and "" or "", "Comment")
  end

  laststatus = s.val
  return s.val
end

local events = {
  "BufEnter",
  "BufWrite",
  "TabEnter",
  "TabNewEntered",
  "TabClosed",
  "LspAttach",
  "LspDetach",
  "CursorHold",
  "CursorMoved",
  "DiagnosticChanged",
  "RecordingEnter",
  "RecordingLeave",
  "CmdlineEnter",
  "CmdlineLeave",
  "User GuardFmt",
}
local stl_group = api.nvim_create_augroup("StatusLine", {})
vim.o.laststatus = 3
for _, ev in ipairs(events) do
  local tmp = ev
  local pattern
  if ev:find("User") then
    pattern = vim.split(ev, "%s")[2]
    tmp = "User"
  end
  api.nvim_create_autocmd(tmp, {
    pattern = pattern,
    group = stl_group,
    callback = function(opts)
      vim.schedule(function()
        vim.opt.stl = statusline(opts.data)
      end)
    end,
  })
end
