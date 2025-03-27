-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.number = true
vim.opt.mouse = 'a'
vim.opt.showmode = false

vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 125

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
-- vim.opt.list = true
-- vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- views can only be fully collapsed with the global statusline
vim.opt.laststatus = 3

vim.o.fillchars = 'eob: '

vim.keymap.set('n', '[b', '<Cmd>tabprev<CR>')
vim.keymap.set('n', ']b', '<Cmd>tabnext<CR>')
vim.keymap.set('n', '<leader>b', '<Cmd>tabnew<CR>')
vim.keymap.set('n', '<leader>c', '<Cmd>tabclose<CR>')
vim.keymap.set('n', '<leader>q', '<Cmd>qa<CR>')
vim.keymap.set('n', '<leader>Q', '<Cmd>qa!<CR>')

vim.keymap.set('v', 'J', '5j')
vim.keymap.set('n', '<leader>w', '<cmd>w<CR>')
vim.keymap.set('n', 'j', 'gj')
vim.keymap.set('n', 'k', 'gk')
vim.keymap.set('x', 'j', 'gj')
vim.keymap.set('x', 'k', 'gk')

vim.keymap.set('n', ';', ':')

vim.keymap.set('n', '<M-n>', function() require('snacks').terminal() end, {desc = 'Toggle terminal'})
vim.keymap.set('t', '<M-n>', function() require('snacks').terminal() end, {desc = 'Toggle terminal'})
vim.keymap.set('n', '<leader>th', function() require('snacks').terminal() end, {desc = 'Toggle terminal'})
vim.keymap.set('n', '<leader>e', '<cmd>Neotree toggle<CR>', {desc = 'Toggle file tree'})

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('n', '<leader>ui', function()
  local input_avail, input = pcall(vim.fn.input, 'Set indent value (>0 expandtab, <=0 noexpandtab): ')
  if input_avail then
    local indent = tonumber(input)
    if not indent or indent == 0 then
      return
    end
    vim.bo.expandtab = (indent > 0) -- local to buffer
    indent = math.abs(indent)
    vim.bo.tabstop = indent         -- local to buffer
    vim.bo.softtabstop = indent     -- local to buffer
    vim.bo.shiftwidth = indent      -- local to buffer
  end
end)

vim.cmd [[inoremap ( ()<Left>]]
vim.cmd [[inoremap () ()]]

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- fix cursor in windows terminal
vim.api.nvim_create_autocmd("VimLeave", {
  pattern = "*",
  callback = function()
    vim.o.guicursor = ""
    vim.fn.chansend(vim.v.stderr, "\x1b[ q]")
  end,
})

local function has_words_before()
  local line, col = (unpack or table.unpack)(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match '%s' == nil
end

local function get_kind_icon(CTX)
  local lspkind = require("lspkind")
  if CTX.item.source_name == "LSP" then
    local icon = lspkind.symbolic(CTX.kind, { mode = "symbol" })
    if icon then CTX.kind_icon = icon end
  end
  return { text = CTX.kind_icon .. CTX.icon_gap, highlight = CTX.kind_hl }
end

require("lazy").setup({
  spec = {
    {
      "rebelot/kanagawa.nvim",
      config = function()
        require('kanagawa').setup {
          compile = true,
          theme = 'dragon',
        }
        vim.cmd("colorscheme kanagawa-dragon")
      end
    },
    {
      "folke/snacks.nvim",
      lazy = false,
      ---@type snacks.Config
      opts = {
        dashboard = {
          enabled = true,
          ---@format disable-next
      preset = {
        header = [[
⣇⣿⠘⣿⣿⣿⡿⡿⣟⣟⢟⢟⢝⠵⡝⣿⡿⢂⣼⣿⣷⣌⠩⡫⡻⣝⠹⢿⣿⣷
⡆⣿⣆⠱⣝⡵⣝⢅⠙⣿⢕⢕⢕⢕⢝⣥⢒⠅⣿⣿⣿⡿⣳⣌⠪⡪⣡⢑⢝⣇
⡆⣿⣿⣦⠹⣳⣳⣕⢅⠈⢗⢕⢕⢕⢕⢕⢈⢆⠟⠋⠉⠁⠉⠉⠁⠈⠼⢐⢕⢽
⡗⢰⣶⣶⣦⣝⢝⢕⢕⠅⡆⢕⢕⢕⢕⢕⣴⠏⣠⡶⠛⡉⡉⡛⢶⣦⡀⠐⣕⢕
⡝⡄⢻⢟⣿⣿⣷⣕⣕⣅⣿⣔⣕⣵⣵⣿⣿⢠⣿⢠⣮⡈⣌⠨⠅⠹⣷⡀⢱⢕
⡝⡵⠟⠈⢀⣀⣀⡀⠉⢿⣿⣿⣿⣿⣿⣿⣿⣼⣿⢈⡋⠴⢿⡟⣡⡇⣿⡇⡀⢕
⡝⠁⣠⣾⠟⡉⡉⡉⠻⣦⣻⣿⣿⣿⣿⣿⣿⣿⣿⣧⠸⣿⣦⣥⣿⡇⡿⣰⢗⢄
⠁⢰⣿⡏⣴⣌⠈⣌⠡⠈⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣬⣉⣉⣁⣄⢖⢕⢕⢕
⡀⢻⣿⡇⢙⠁⠴⢿⡟⣡⡆⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣵⣵⣿
⡻⣄⣻⣿⣌⠘⢿⣷⣥⣿⠇⣿⣿⣿⣿⣿⣿⠛⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣷⢄⠻⣿⣟⠿⠦⠍⠉⣡⣾⣿⣿⣿⣿⣿⣿⢸⣿⣦⠙⣿⣿⣿⣿⣿⣿⣿⣿⠟
⡕⡑⣑⣈⣻⢗⢟⢞⢝⣻⣿⣿⣿⣿⣿⣿⣿⠸⣿⠿⠃⣿⣿⣿⣿⣿⣿⡿⠁⣠
⡝⡵⡈⢟⢕⢕⢕⢕⣵⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣶⣿⣿⣿⣿⣿⠿⠋⣀⣈⠙
⡝⡵⡕⡀⠑⠳⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⢉⡠⡲⡫⡪⡪⡣]],
      },
        },
        image = {
          enabled = true,
        },
        picker = {
          enabled = true,
          ui_select = true,
        },
        input = {
          enabled = true,
        },
        lazygit = {
          enabled = true,
        },
        indent = {
          enabled = true,
        },
        terminal = {
          enabled = true,
          win = {
            height = 10,
            position = "bottom",
            style = "minimal",
          },
        },
        ---@class snacks.explorer.Config
        explorer = {
          enabled = true,
          replace_netrw = true,
        },
      },
      keys = {
        { "<leader>f<space>", function() require('snacks').picker.smart() end, desc = "Smart find files" },
        { "<leader>ff",       function() require('snacks').picker.files() end, desc = "Find files" },
        { "<leader>fw",       function() require('snacks').picker.grep() end,  desc = "Grep files" },
        { "<leader>g",        function() require('snacks').lazygit() end,      desc = "Lazygit" },
        { "<leader>e",        function() require('snacks').explorer() end,     desc = "Explorer" },
      }
    },
    {
      "nvim-treesitter/nvim-treesitter",
      event = "VeryLazy",
      opts = {
        auto_install = true,
      },
    },
    {
      "saghen/blink.cmp",
      event = "InsertEnter",
      version = "*",
      opts = {
        keymap = {
          ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
          ["<Up>"] = { "select_prev", "fallback" },
          ["<Down>"] = { "select_next", "fallback" },
          ["<C-N>"] = { "select_next", "show" },
          ["<C-P>"] = { "select_prev", "show" },
          ["<C-J>"] = { "select_next", "fallback" },
          ["<C-K>"] = { "select_prev", "fallback" },
          ["<C-U>"] = { "scroll_documentation_up", "fallback" },
          ["<C-D>"] = { "scroll_documentation_down", "fallback" },
          ["<C-e>"] = { "hide", "fallback" },
          ["<CR>"] = { "accept", "fallback" },
          ["<Tab>"] = {
            "select_next",
            "snippet_forward",
            function(cmp)
              if has_words_before() or vim.api.nvim_get_mode().mode == "c" then return cmp.show() end
            end,
            "fallback",
          },
          ["<S-Tab>"] = {
            "select_prev",
            "snippet_backward",
            function(cmp)
              if vim.api.nvim_get_mode().mode == "c" then return cmp.show() end
            end,
            "fallback",
          },
        },
        completion = {
          list = { selection = { preselect = false, auto_insert = true } },
          menu = {
            auto_show = function(ctx) return ctx.mode ~= "cmdline" end,
            border = "rounded",
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
            draw = {
              treesitter = { "lsp" },
            },
          },
          accept = {
            auto_brackets = { enabled = true },
          },
          documentation = {
            auto_show = true,
            auto_show_delay_ms = 0,
            window = {
              border = "rounded",
              winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
            },
          },
        },
        signature = {
          window = {
            border = "rounded",
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
          },
        },

        appearance = {
          use_nvim_cmp_as_default = true,
          nerd_font_variant = 'mono'
        },
        sources = {
          default = { 'lsp', 'path', 'snippets', 'buffer', },
        },

        fuzzy = { implementation = "prefer_rust_with_warning" }
      }
    },
  },
  ui = {
    backdrop = 70,
    border = "rounded",
  },
  checker = { enabled = true },
})
