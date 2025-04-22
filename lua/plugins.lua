local function has_words_before()
  local line, col = (unpack or table.unpack)(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

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
  -- {
  --   "catppuccin/nvim",
  --   name = "catppuccin",
  --   config = function()
  --     require('catppuccin').setup {
  --       term_colors = true,
  --       integrations = {
  --         treesitter = true,
  --         snacks = {
  --           enabled = true,
  --         },
  --         blink_cmp = true,
  --         mini = {
  --           enabled = true,
  --         }
  --       },
  --     }
  --     vim.cmd "colorscheme catppuccin"
  --   end
  -- }
  -- {
  --   "echasnovski/mini.base16",
  --   opts = {
  --     use_cterm = true,
  --     palette = {
  --       base00 = "#14161B", -- Background modded
  --       base01 = "#202227", -- LineNr (bg)
  --       base02 = "#444b71", -- LineNr (fg)
  --       base03 = "#818596", -- StatusLine (bg)
  --
  --       base04 = "#E0E2EA", -- Foreground modded
  --       base05 = "#E0E2EA", -- Normal text (same as foreground) modded
  --
  --       base06 = "#d2d4de", -- Light foreground (optional)
  --       base07 = "#ffffff", -- White (optional highlight)
  --
  --       -- Adjusted representative colors
  --       base08 = "#8eaad0", -- soft blue (替代原本红色)
  --
  --       base09 = "#89B8C2", -- soft purple (替代橙色)
  --       base0A = "#b4be82", -- yellow-green
  --       base0B = "#B3F6C0", -- cyan modded
  --       base0C = "#95c4ce", -- lighter cyan variant
  --
  --       base0D = "#89B8C2", -- purple
  --       base0E = "#A6DBFF", -- soft blue
  --       base0F = "#C4C6CD", -- fallback dark accent
  --     },
  --   }
  -- },
  {
    "neanias/everforest-nvim",
    version = false,
    lazy = false,
    priority = 1000, -- make sure to load this before all the other start plugins
    -- Optional; default configuration will be used if setup isn't called.
    config = function()
      require("everforest").setup({
        background = "hard",
        -- Your config here
      })
      vim.cmd("colorscheme everforest")
    end,
  }
}
