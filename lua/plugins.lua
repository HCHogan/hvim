local function has_words_before()
  local line, col = (unpack or table.unpack)(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local icons = require('icons')

return {
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
        sources = {
          explorer = {
            layout = {
              layout = {
                width = 30,
              },
            },
          },
        },
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
      words = {
        enabled = true,
      },
    },
    keys = {
      {
        "<leader>f<space>",
        function()
          require("snacks").picker.smart()
        end,
        desc = "Smart find files",
      },
      {
        "<leader>ff",
        function()
          require("snacks").picker.files()
        end,
        desc = "Find files",
      },
      {
        "<leader>fw",
        function()
          require("snacks").picker.grep()
        end,
        desc = "Grep files",
      },
      {
        "<leader>g",
        function()
          require("snacks").lazygit()
        end,
        desc = "Lazygit",
      },
      {
        "<leader>e",
        function()
          require("snacks").explorer()
        end,
        desc = "Explorer",
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    event = "BufReadPost",
    opts = {
      auto_install = true,
      highlight = {
        enable = true,
      },
    },
  },
  {
    "saghen/blink.cmp",
    event = "BufReadPost",
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
            if has_words_before() or vim.api.nvim_get_mode().mode == "c" then
              return cmp.show()
            end
          end,
          "fallback",
        },
        ["<S-Tab>"] = {
          "select_prev",
          "snippet_backward",
          function(cmp)
            if vim.api.nvim_get_mode().mode == "c" then
              return cmp.show()
            end
          end,
          "fallback",
        },
      },
      completion = {
        list = { selection = { preselect = false, auto_insert = true } },
        menu = {
          auto_show = function(ctx)
            return ctx.mode ~= "cmdline"
          end,
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
        nerd_font_variant = "mono",
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },

      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
  },
  {
    'mrcjkb/haskell-tools.nvim',
    version = '^5', -- Recommended
    lazy = false,   -- This plugin is already lazy
    init = function()
      vim.g.haskell_tools = {
        hls = {
          settings = {
            plugin = {
              ['cabal-fmt'] = {
                globalOn = false,
              }
            }
          }
        }
      }
    end
  },
  {

    'lewis6991/gitsigns.nvim',
    event = 'VeryLazy',
    opts = {
      signs = {
        add = { text = icons.GitSign },
        change = { text = icons.GitSign },
        delete = { text = icons.GitSign },
        topdelete = { text = icons.GitSign },
        changedelete = { text = icons.GitSign },
        untracked = { text = icons.GitSign },
      },
      current_line_blame = true,
      on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gitsigns.nav_hunk 'next'
          end
        end, { desc = 'Jump to next git [c]hange' })

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gitsigns.nav_hunk 'prev'
          end
        end, { desc = 'Jump to previous git [c]hange' })

        -- Actions
        -- visual mode
        map('v', '<leader>hs', function()
          gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'stage git hunk' })
        map('v', '<leader>hr', function()
          gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'reset git hunk' })
        -- normal mode
        map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git [s]tage hunk' })
        map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk' })
        map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer' })
        map('n', '<leader>hu', gitsigns.undo_stage_hunk, { desc = 'git [u]ndo stage hunk' })
        map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'git [R]eset buffer' })
        map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'git [p]review hunk' })
        map('n', '<leader>hb', gitsigns.blame_line, { desc = 'git [b]lame line' })
        map('n', '<leader>hd', gitsigns.diffthis, { desc = 'git [d]iff against index' })
        map('n', '<leader>hD', function()
          gitsigns.diffthis '@'
        end, { desc = 'git [D]iff against last commit' })
        -- Toggles
        map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle git show [b]lame line' })
        map('n', '<leader>tD', gitsigns.toggle_deleted, { desc = '[T]oggle git show [D]eleted' })
      end,
    },
  },
  {
    "nvimdev/guard.nvim",
    dependencies = {
      "nvimdev/guard-collection",
    },
    event = "BufReadPost",
    opts = {},
    config = function()
      local ft = require("guard.filetype")

      if vim.fn.executable("hlint") == 1 then
        ft("haskell"):lint("hlint")
      end

      if vim.fn.executable("stylua") == 1 then
        ft("lua"):fmt("stylua")
      end

      if vim.fn.executable("clang-tidy") == 1 then
        ft("c"):lint("clang-tidy")
        ft("cpp"):lint("clang-tidy")
      end

      if vim.fn.executable("alejandra") == 1 then
        ft("nix"):fmt("alejandra")
      end

      vim.g.guard_config = {
        fmt_on_save = false,
        save_on_fmt = false,
        lsp_as_default_formatter = true,
      }
    end,
  },
  {
    'jesseleite/nvim-noirbuddy',
    enabled = true,
    dependencies = {
      { 'tjdevries/colorbuddy.nvim' }
    },
    lazy = false,
    priority = 1000,
    config = function()
      require('noirbuddy').setup {
        styles = {
          italic = true,
          bold = true,
          underline = false,
          undercurl = false,
        },
        preset = 'northern-lights',
      }
      local colorbuddy = require('colorbuddy')
      local Color = colorbuddy.Color
      local colors = colorbuddy.colors
      local Group = colorbuddy.Group
      local groups = colorbuddy.groups
      local styles = colorbuddy.styles
      Color.new('lightgreen', '#d7eecc')

      Group.new('MiniTablineCurrent', colors.background, colors.primary)
      Group.new('MiniTablineModifiedCurrent', colors.background, colors.primary)

      Group.new('@type', colors.primary, colors.background)
      Group.new('@keyword', colors.noir_2, _, styles.bold)
      Group.new('@comment', _, _, styles.italic)
      Group.new('LspCodeLens', colors.noir_7, _)

      Group.new('WinSeparator', colors.noir_7, colors.background)

      Group.new('BlinkCmpDocSeparator', colors.primary, _)

      Group.new('SnacksPickerInputBorder', colors.primary, _)
      Group.new('SnacksPickerBoxTitle', colors.primary, _)
      Group.new('SnacksPickerDir', colors.noir_7, _)
      Group.new('SnacksInputBorder', colors.noir_7, _)
      Group.new('SnacksInputTitle', colors.primary, _)
      Group.new('SnacksInputIcon', colors.primary, _)
      Group.new('SnacksPickerMatch', colors.noir_1, _, styles.bold)
    end
  },
}
