vim.o.showtabline = 2

function _G.SpawnBufferLine()
  -- local s = ' neovim | '
  local s = ' '

  local last_buf = vim.fn.bufnr('$')
  local bufferNums = {}
  for i = 1, last_buf do
    if vim.fn.buflisted(i) == 1 then
      table.insert(bufferNums, i)
    end
  end

  local current_buf = vim.api.nvim_get_current_buf()
  for _, i in ipairs(bufferNums) do
    if i == current_buf then
      s = s .. '%#TabLineSel#'
    else
      s = s .. '%#TabLine#'
    end
    s = s .. i .. ' '
    local name = vim.fn.bufname(i)
    if name == '' then
      s = s .. '[NEW]'
    end
    if vim.fn.getbufvar(i, "&modifiable") == 1 then
      s = s .. vim.fn.fnamemodify(name, ':t')
      if vim.fn.getbufvar(i, "&modified") == 1 then
        s = s .. ' [+] | '
      else
        s = s .. ' | '
      end
    else
      s = s .. vim.fn.fnamemodify(name, ':t') .. ' [RO] | '
    end
  end

  s = s .. '%#TabLineFill#%T'
  s = s .. '%='

  local last_tab = vim.fn.tabpagenr('$')
  local current_tab = vim.fn.tabpagenr()
  for i = 1, last_tab do
    if i == current_tab then
      s = s .. '%#TabLineSel#'
    else
      s = s .. '%#TabLine#'
    end
    s = s .. '%' .. i .. 'T ' .. i
  end

  s = s .. '%#TabLineFill#%T'

  if last_tab > 1 then
    s = s .. '%999X X'
  end

  return s
end

vim.o.tabline = "%!v:lua.SpawnBufferLine()"
