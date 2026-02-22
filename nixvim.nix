{pkgs, ...}: {
  programs.nixvim = {
    enable = true;

    globals = {
      mapleader = " ";
      maplocalleader = "\\";
      markdown_fenced_languages = ["rust" "rs=rust"];
    };

    options = {
      number = true;
      mouse = "a";
      showmode = false;
      breakindent = true;
      undofile = true;
      ignorecase = true;
      smartcase = true;
      signcolumn = "yes:1";
      updatetime = 125;
      timeoutlen = 300;
      splitright = true;
      splitbelow = true;
      inccommand = "split";
      cursorline = true;
      scrolloff = 10;
      laststatus = 3;
      fillchars = "eob: ";
      foldenable = true;
      foldlevel = 99;
      foldlevelstart = 99;
      cmdheight = 0;
    };

    keymaps = [
      {
        mode = "n";
        key = "<Esc>";
        action = "<Cmd>nohlsearch<CR>";
      }
      {
        mode = "n";
        key = "[b";
        action = "<Cmd>bprev<CR>";
      }
      {
        mode = "n";
        key = "]b";
        action = "<Cmd>bnext<CR>";
      }
      {
        mode = "n";
        key = "<leader>c";
        action = "<cmd>lua require('snacks').bufdelete()<CR>";
        options.desc = "Delete buffer";
      }
      {
        mode = "n";
        key = "<leader>/";
        action = "gcc";
        options = {
          remap = true;
          desc = "Toggle comment line";
        };
      }
      {
        mode = "v";
        key = "<leader>/";
        action = "gc";
        options = {
          remap = true;
          desc = "Toggle comment";
        };
      }
      {
        mode = "n";
        key = "<leader>q";
        action = "<Cmd>q<CR>";
      }
      {
        mode = "n";
        key = "<leader>Q";
        action = "<Cmd>qa!<CR>";
      }
      {
        mode = "v";
        key = "J";
        action = "5j";
      }
      {
        mode = "n";
        key = "<leader>w";
        action = "<Cmd>w<CR>";
      }
      {
        mode = "n";
        key = "j";
        action = "gj";
      }
      {
        mode = "n";
        key = "k";
        action = "gk";
      }
      {
        mode = "x";
        key = "j";
        action = "gj";
      }
      {
        mode = "x";
        key = "k";
        action = "gk";
      }
      {
        mode = "n";
        key = ";";
        action = ":";
      }
      {
        mode = "n";
        key = "<M-n>";
        action = "<cmd>lua require('snacks').terminal()<CR>";
        options.desc = "Toggle terminal";
      }
      {
        mode = "t";
        key = "<M-n>";
        action = "<cmd>lua require('snacks').terminal()<CR>";
        options.desc = "Toggle terminal";
      }
      {
        mode = "n";
        key = "<leader>th";
        action = "<cmd>lua require('snacks').terminal()<CR>";
        options.desc = "Toggle terminal";
      }
      {
        mode = "t";
        key = "<Esc><Esc>";
        action = "<C-\\><C-n>";
        options.desc = "Exit terminal mode";
      }
      {
        mode = "n";
        key = "<C-h>";
        action = "<C-w><C-h>";
        options.desc = "Move focus to the left window";
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<C-w><C-l>";
        options.desc = "Move focus to the right window";
      }
      {
        mode = "n";
        key = "<C-j>";
        action = "<C-w><C-j>";
        options.desc = "Move focus to the lower window";
      }
      {
        mode = "n";
        key = "<C-k>";
        action = "<C-w><C-k>";
        options.desc = "Move focus to the upper window";
      }
      {
        mode = "n";
        key = "<leader>ui";
        action = "<cmd>lua _G.hvim_set_indent_prompt()<CR>";
        options.desc = "Set indent";
      }
      {
        mode = ["n" "v"];
        key = "<leader>lf";
        action = "<cmd>lua require('conform').format({ async = true, lsp_fallback = true })<CR>";
        options.desc = "Format buffer";
      }
    ];

    extraPlugins = with pkgs.vimPlugins; [
      snacks-nvim
      noice-nvim
      nui-nvim
      flash-nvim
      persistence-nvim
      mini-nvim
      nvim-treesitter
      blink-cmp
      luasnip
      friendly-snippets
      rustaceanvim
      haskell-tools-nvim
      lean-nvim
      plenary-nvim
      gitsigns-nvim
      nvim-lint
      conform-nvim
      evergarden
    ];

    extraConfigLua = ''
      vim.cmd("syntax on")

      _G.hvim_set_indent_prompt = function()
        local input_avail, input = pcall(vim.fn.input, "Set indent value (>0 expandtab, <=0 noexpandtab): ")
        if input_avail then
          local indent = tonumber(input)
          if not indent or indent == 0 then
            return
          end
          vim.bo.expandtab = (indent > 0)
          indent = math.abs(indent)
          vim.bo.tabstop = indent
          vim.bo.softtabstop = indent
          vim.bo.shiftwidth = indent
        end
      end

      vim.g.clipboard = {
        name = "OSC 52",
        copy = {
          ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
          ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
        },
        paste = {
          ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
          ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
        },
      }

      vim.api.nvim_create_autocmd("TextYankPost", {
        desc = "Highlight when yanking (copying) text",
        group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
        callback = function()
          vim.highlight.on_yank()
        end,
      })

      vim.api.nvim_create_autocmd("VimLeave", {
        pattern = "*",
        callback = function()
          vim.o.guicursor = ""
          vim.fn.chansend(vim.v.stderr, "\x1b[ q]")
        end,
      })

      vim.api.nvim_create_autocmd("VimLeavePre", {
        desc = "Exit: Kill all background terminals automatically",
        group = vim.api.nvim_create_augroup("kill_terminals_on_exit", { clear = true }),
        callback = function()
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
              vim.api.nvim_buf_delete(buf, { force = true })
            end
          end
        end,
      })

      vim.diagnostic.config({
        virtual_lines = false,
        virtual_text = true,
        update_in_insert = true,
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = {
          numhl = {
            [vim.diagnostic.severity.ERROR] = "DiagnosticError",
            [vim.diagnostic.severity.WARN] = "DiagnosticWarn",
            [vim.diagnostic.severity.INFO] = "DiagnosticInfo",
            [vim.diagnostic.severity.HINT] = "DiagnosticHint",
          },
          text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.INFO] = "",
            [vim.diagnostic.severity.HINT] = "",
          },
        },
      })

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

          map("gd", vim.lsp.buf.definition, "goto definition")
          map("gr", vim.lsp.buf.references, "goto references")
          map("gD", vim.lsp.buf.declaration, "goto declaration")
          map("gi", vim.lsp.buf.implementation, "goto implementation")
          map("gh", vim.lsp.buf.typehierarchy, "goto type hierarchy")
          map("K", function() vim.lsp.buf.hover({ border = "rounded" }) end, "Hover")

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

      vim.lsp.config.basedpyright = {
        cmd = { "basedpyright-langserver", "--stdio" },
        root_markers = { "pyproject.toml", "requirements.txt" },
        filetypes = { "python" },
        settings = {
          basedpyright = {
            analysis = {
              autoSearchPaths = true,
              diagnosticMode = "openFilesOnly",
              useLibraryCodeForTypes = true,
            },
          },
        },
      }

      vim.lsp.config.bashls = {
        cmd = { "bash-language-server", "start" },
        settings = {
          bashIde = {
            globPattern = vim.env.GLOB_PATTERN or "*@(.sh|.inc|.bash|.command)",
          },
        },
        filetypes = { "bash", "sh" },
        single_file_support = true,
        root_markers = { ".git" },
      }

      vim.lsp.config.clangd = {
        cmd = { "clangd", "--background-index" },
        root_markers = { ".clangd", "compile_commands.json" },
        filetypes = { "c", "cpp" },
        single_file_support = true,
        capabilities = {
          offsetEncoding = "utf-8",
          textDocument = {
            completion = {
              editsNearCursor = true,
            },
            semanticTokens = {
              multilineTokenSupport = true,
            },
          },
        },
      }

      vim.lsp.config.cssls = {
        cmd = { "vscode-css-language-server", "--stdio" },
        filetypes = { "css", "scss", "less" },
        init_options = { provideFormatter = true },
        root_markers = { "package.json", ".git" },
        settings = {
          css = { validate = true },
          scss = { validate = true },
          less = { validate = true },
        },
      }

      vim.lsp.config.elmls = {
        cmd = { "elm-language-server" },
        filetypes = { "elm" },
        root_markers = { "elm.json" },
        init_options = {
          elmReviewDiagnostics = "off",
          skipInstallPackageConfirmation = false,
          disableElmLSDiagnostics = false,
          onlyUpdateDiagnosticsOnSave = false,
        },
        capabilities = {
          offsetEncoding = { "utf-8", "utf-16" },
        },
      }

      vim.lsp.config.html = {
        cmd = { "vscode-html-language-server", "--stdio" },
        filetypes = { "html", "templ" },
        root_markers = { "package.json", ".git" },
        settings = {},
        init_options = {
          provideFormatter = true,
          embeddedLanguages = { css = true, javascript = true },
          configurationSection = { "html", "css", "javascript" },
        },
      }

      vim.lsp.config.jsonls = {
        cmd = { "vscode-json-language-server", "--stdio" },
        filetypes = { "json", "jsonc" },
        init_options = {
          provideFormatter = true,
        },
        root_markers = { ".git" },
      }

      vim.lsp.config.luals = {
        cmd = { "lua-language-server" },
        root_markers = { ".git" },
        filetypes = { "lua" },
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = {
              checkThirdParty = false,
              library = vim.api.nvim_get_runtime_file("", true),
            },
          },
        },
      }

      vim.lsp.config.neocmake = {
        cmd = { "neocmakelsp", "--stdio" },
        filetypes = { "cmake" },
        root_markers = { ".git", "build", "cmake" },
        single_file_support = true,
      }

      vim.lsp.config.nil = {
        cmd = { "nil" },
        root_markers = { ".git", "flake.nix", "flake.lock" },
        filetypes = { "nix" },
        single_file_support = true,
      }

      vim.lsp.config.taplo = {
        cmd = { "taplo", "lsp", "stdio" },
        filetypes = { "toml" },
        root_markers = { ".taplo.toml", "taplo.toml", ".git" },
      }

      vim.lsp.config.yamlls = {
        cmd = { "yaml-language-server", "--stdio" },
        filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
        root_markers = { ".git" },
        settings = {
          redhat = { telemetry = { enabled = false } },
        },
      }

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

      local lsps = {
        "clangd",
        "basedpyright",
        "luals",
        "nil",
        "neocmake",
        "bashls",
        "elmls",
        "html",
        "jsonls",
        "taplo",
        "yamlls",
        "cssls",
      }

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

      local Snacks = require("snacks")
      vim.api.nvim_set_hl(0, "SnacksDashboardHeader", { link = "@string" })
      Snacks.setup({
        dashboard = {
          enabled = true,
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
        notifier = {
          enabled = true,
        },
        indent = {
          enabled = true,
          animate = {
            enabled = false,
          },
        },
        terminal = {
          enabled = true,
          win = {
            height = 10,
            position = "bottom",
            style = "minimal",
          },
        },
        explorer = {
          enabled = true,
          replace_netrw = true,
        },
        words = {
          enabled = true,
        },
      })

      vim.keymap.set("n", "<leader>f<space>", function()
        Snacks.picker.smart()
      end, { desc = "Smart find files" })
      vim.keymap.set("n", "<leader>fr", function()
        Snacks.picker.recent()
      end, { desc = "recent files" })
      vim.keymap.set("n", "<leader>ff", function()
        Snacks.picker.files()
      end, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fw", function()
        Snacks.picker.grep()
      end, { desc = "Grep files" })
      vim.keymap.set("n", "<leader>fi", function() Snacks.picker.icons() end, { desc = "Icons" })
      vim.keymap.set("n", "<leader>fk", function() Snacks.picker.keymaps() end, { desc = "Keymaps" })
      vim.keymap.set("n", "<leader>fu", function() Snacks.picker.undo() end, { desc = "Undo History" })
      vim.keymap.set("n", "<leader>fs", function() Snacks.picker.lsp_workspace_symbols() end, { desc = "LSP Symbols" })
      vim.keymap.set("n", "<leader>g", function()
        Snacks.lazygit()
      end, { desc = "Lazygit" })
      vim.keymap.set("n", "<leader>e", function()
        Snacks.explorer()
      end, { desc = "Explorer" })
      vim.keymap.set("n", "<leader>lD", function()
        Snacks.picker.diagnostics()
      end, { desc = "Diagnostics" })

      require("noice").setup({
        lsp = {
          signature = { enabled = false },
          hover = { enabled = false },
        },
        cmdline = {
          enabled = true,
          view = "cmdline_popup",
        },
        routes = {
          {
            filter = {
              event = "msg_show",
              kind = "",
              find = "written",
            },
            opts = { skip = true },
          },
        },
        notify = {
          enabled = false,
        },
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
          inc_rename = false,
          lsp_doc_border = false,
        },
      })

      require("flash").setup({})
      vim.keymap.set("n", "s", function() require("flash").jump() end, { desc = "Flash" })
      vim.keymap.set("x", "s", function() require("flash").jump() end, { desc = "Flash" })
      vim.keymap.set("o", "s", function() require("flash").jump() end, { desc = "Flash" })
      vim.keymap.set("n", "S", function() require("flash").treesitter() end, { desc = "Flash Treesitter" })
      vim.keymap.set("x", "S", function() require("flash").treesitter() end, { desc = "Flash Treesitter" })
      vim.keymap.set("o", "S", function() require("flash").treesitter() end, { desc = "Flash Treesitter" })
      vim.keymap.set("o", "r", function() require("flash").remote() end, { desc = "Remote Flash" })
      vim.keymap.set("o", "R", function() require("flash").treesitter_search() end, { desc = "Treesitter Search" })
      vim.keymap.set("x", "R", function() require("flash").treesitter_search() end, { desc = "Treesitter Search" })
      vim.keymap.set("c", "<c-s>", function() require("flash").toggle() end, { desc = "Toggle Flash Search" })

      require("persistence").setup({})

      require("mini.icons").setup()
      require("mini.statusline").setup({
        use_icons = true,
        content = {
          active = function()
            local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
            local git = MiniStatusline.section_git({ trunc_width = 40 })
            local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })

            local lsp_client = function()
              local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
              if #buf_clients == 0 then return "" end
              local names = {}
              for _, client in pairs(buf_clients) do
                table.insert(names, client.name)
              end
              return " " .. table.concat(names, ", ")
            end
            local lsp_str = lsp_client()

            local macro = function()
              if package.loaded["noice"] and require("noice").api.status.mode.has() then
                return require("noice").api.status.mode.get()
              end
              local recording_register = vim.fn.reg_recording()
              if recording_register == "" then return "" end
              return "⏺ @" .. recording_register
            end
            local macro_str = macro()

            return MiniStatusline.combine_groups({
              { hl = mode_hl, strings = { mode } },
              { hl = "MiniStatuslineDevinfo", strings = { git } },
              "%<",
              { hl = "MiniStatuslineFilename", strings = { "%=" } },
              { hl = "MiniStatuslineFilename", strings = { diagnostics } },
              "%=",
              { hl = "MiniStatuslineFileinfo", strings = { lsp_str } },
              { hl = mode_hl, strings = { macro_str } },
            })
          end,
        },
      })
      require("mini.tabline").setup()
      require("mini.pairs").setup()
      require("mini.surround").setup()

      local miniclue = require("mini.clue")
      miniclue.setup({
        triggers = {
          { mode = { "n", "x" }, keys = "<Leader>" },
          { mode = "n", keys = "[" },
          { mode = "n", keys = "]" },
          { mode = "i", keys = "<C-x>" },
          { mode = { "n", "x" }, keys = "g" },
          { mode = { "n", "x" }, keys = "'" },
          { mode = { "n", "x" }, keys = "`" },
          { mode = { "n", "x" }, keys = "\"" },
          { mode = { "i", "c" }, keys = "<C-r>" },
          { mode = "n", keys = "<C-w>" },
          { mode = { "n", "x" }, keys = "z" },
        },
        clues = {
          miniclue.gen_clues.square_brackets(),
          miniclue.gen_clues.builtin_completion(),
          miniclue.gen_clues.g(),
          miniclue.gen_clues.marks(),
          miniclue.gen_clues.registers(),
          miniclue.gen_clues.windows(),
          miniclue.gen_clues.z(),
        },
      })

      local TS = require("nvim-treesitter")
      TS.setup({})

      local group = vim.api.nvim_create_augroup("my_treesitter_main", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        callback = function(ev)
          local ft = ev.match
          local lang = vim.treesitter.language.get_lang(ft) or ft

          if not vim.treesitter.language.add(lang) then
            return
          end

          TS.install({ lang })
          pcall(vim.treesitter.start, ev.buf, lang)

          vim.api.nvim_buf_call(ev.buf, function()
            vim.opt_local.foldmethod = "expr"
            vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
          end)

          vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })

      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_vscode").lazy_load({
        paths = { vim.fn.stdpath("config") .. "/snippets" },
      })

      local function has_words_before()
        local line, col = (unpack or table.unpack)(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      require("blink.cmp").setup({
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
          ["<M-l>"] = { "snippet_forward", "fallback" },
          ["<M-h>"] = { "snippet_backward", "fallback" },
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
        snippets = { preset = "luasnip" },
        sources = {
          default = { "lsp", "path", "snippets", "buffer" },
        },
        fuzzy = { implementation = "prefer_rust_with_warning" },
      })

      vim.g.rustaceanvim = {
        tools = {},
        server = {
          default_settings = {
            ["rust-analyzer"] = {
              cargo = {
                extraEnv = { CARGO_PROFILE_RUST_ANALYZER_INHERITS = "dev" },
                extraArgs = { "--profile", "rust-analyzer" },
              },
              checkOnSave = true,
              check = {
                command = "clippy",
                allTargets = false,
                extraArgs = { "--no-deps" },
                allFeatures = true,
              },
            },
          },
        },
        dap = {},
      }

      require("lean").setup({
        mappings = true,
        infoview = {
          orientation = "vertical",
        },
      })

      require("gitsigns").setup({
        signs = {
          add = { text = "┃" },
          change = { text = "┃" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
          untracked = { text = "┆" },
        },
        current_line_blame = true,
        on_attach = function(bufnr)
          local gitsigns = require("gitsigns")

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          map("n", "]c", function()
            if vim.wo.diff then
              vim.cmd.normal({ "]c", bang = true })
            else
              gitsigns.nav_hunk("next")
            end
          end, { desc = "Jump to next git [c]hange" })

          map("n", "[c", function()
            if vim.wo.diff then
              vim.cmd.normal({ "[c", bang = true })
            else
              gitsigns.nav_hunk("prev")
            end
          end, { desc = "Jump to previous git [c]hange" })

          map("v", "<leader>hs", function()
            gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, { desc = "stage git hunk" })
          map("v", "<leader>hr", function()
            gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, { desc = "reset git hunk" })
          map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "git [s]tage hunk" })
          map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "git [r]eset hunk" })
          map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "git [S]tage buffer" })
          map("n", "<leader>hu", gitsigns.undo_stage_hunk, { desc = "git [u]ndo stage hunk" })
          map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "git [R]eset buffer" })
          map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "git [p]review hunk" })
          map("n", "<leader>hb", gitsigns.blame_line, { desc = "git [b]lame line" })
          map("n", "<leader>hd", gitsigns.diffthis, { desc = "git [d]iff against index" })
          map("n", "<leader>hD", function()
            gitsigns.diffthis("@")
          end, { desc = "git [D]iff against last commit" })
          map("n", "<leader>tb", gitsigns.toggle_current_line_blame, { desc = "[T]oggle git show [b]lame line" })
          map("n", "<leader>tD", gitsigns.toggle_deleted, { desc = "[T]oggle git show [D]eleted" })
        end,
      })

      local lint = require("lint")
      lint.linters_by_ft = {
        swift = { "swiftlint" },
        python = { "ruff" },
        haskell = { "hlint" },
      }

      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })

      require("conform").setup({
        notify_on_error = true,
        format_on_save = false,
        formatters_by_ft = {
          swift = { "swiftformat" },
          typst = { "typstyle" },
          json = { "biome" },
          html = { "biome" },
          css = { "biome" },
          markdown = { "biome" },
          haskell = { "ormolu" },
          ocaml = { "ocamlformat" },
          python = { "ruff" },
          nix = { "alejandra" },
          elm = { "elm_format" },
        },
      })

      require("evergarden").setup({
        theme = {
          variant = "winter",
          accent = "green",
        },
        editor = {
          transparent_background = false,
        },
        style = {
          types = {},
          keyword = {},
          search = { "reverse", "bold" },
          incsearch = { "reverse", "bold" },
        },
      })
      vim.cmd.colorscheme("evergarden")

      local function set_indent(width)
        vim.bo.expandtab = true
        vim.bo.tabstop = width
        vim.bo.softtabstop = width
        vim.bo.shiftwidth = width
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("indent-2", { clear = true }),
        pattern = { "c", "cpp", "cmake", "make", "json", "lua", "bs", "nix", "yaml", "java", "cabal" },
        callback = function()
          set_indent(2)
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("indent-rust", { clear = true }),
        pattern = "rust",
        callback = function()
          set_indent(4)
          local bufnr = vim.api.nvim_get_current_buf()
          vim.keymap.set("n", "<leader>a", function()
            vim.cmd.RustLsp("codeAction")
          end, { silent = true, buffer = bufnr })
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("indent-haskell", { clear = true }),
        pattern = "haskell",
        callback = function()
          set_indent(2)
          vim.cmd("TSEnable highlight")
          local ht = require("haskell-tools")
          local bufnr = vim.api.nvim_get_current_buf()
          local opts = { noremap = true, silent = true, buffer = bufnr }
          vim.keymap.set("n", "<space>ll", vim.lsp.codelens.run, opts)
          vim.keymap.set("n", "<space>le", ht.lsp.buf_eval_all, opts)
        end,
      })
    '';
  };

  xdg.configFile."nvim/snippets/package.json".text = ''
    {
      "name": "my-snippets",
      "contributes": {
        "snippets": [
          {
            "language": "rust",
            "path": "./rust.json"
          }
        ]
      }
    }
  '';

  xdg.configFile."nvim/snippets/rust.json".text = ''
    {
      "Rust CP Template": {
        "prefix": "cp",
        "body": [
          "#[allow(unused_imports)]",
          "use std::cmp::{max, min};",
          "use std::collections::{BTreeMap, BTreeSet, BinaryHeap, HashMap, HashSet, VecDeque};",
          "use std::io::{self, BufWriter, Write};",
          "use std::str::FromStr;",
          "",
          "struct Scanner<'a> {",
          "    iter: std::str::SplitAsciiWhitespace<'a>,",
          "}",
          "",
          "impl<'a> Scanner<'a> {",
          "    fn new(input: &'a str) -> Self {",
          "        Self {",
          "            iter: input.split_ascii_whitespace(),",
          "        }",
          "    }",
          "",
          "    fn next<T: FromStr>(&mut self) -> T {",
          "        self.iter.next().unwrap().parse().ok().unwrap()",
          "    }",
          "}",
          "",
          "fn main() {",
          "    let stdin = io::stdin();",
          "    let input = io::read_to_string(stdin).unwrap();",
          "    let mut sc = Scanner::new(&input);",
          "    let stdout = io::stdout();",
          "    let mut out = BufWriter::new(stdout.lock());",
          "",
          "    solve(&mut sc, &mut out);",
          "}",
          "",
          "fn solve(sc: &mut Scanner, out: &mut impl Write) {",
          "    $0",
          "}",
        ],
        "description": "Rust Competitive Programming Template (Fast IO)"
      },
      "Rust Interactive CP": {
        "prefix": "cpi",
        "body": [
          "#[allow(unused_imports)]",
          "use std::cmp::{max, min};",
          "use std::collections::{BTreeMap, BTreeSet, BinaryHeap, HashMap, HashSet, VecDeque};",
          "use std::io::{self, BufRead, BufWriter, Write, StdinLock};",
          "use std::str::FromStr;",
          "",
          "struct InteractiveScanner<R> {",
          "    reader: R,",
          "    queue: VecDeque<String>,",
          "}",
          "",
          "impl<R: BufRead> InteractiveScanner<R> {",
          "    fn new(reader: R) -> Self {",
          "        Self {",
          "            reader,",
          "            queue: VecDeque::new(),",
          "        }",
          "    }",
          "",
          "    fn next<T: FromStr>(&mut self) -> T {",
          "        while self.queue.is_empty() {",
          "            let mut line = String::new();",
          "            let bytes = self.reader.read_line(&mut line).expect(\"Failed to read line\");",
          "            if bytes == 0 { panic!(\"Unexpected EOF\"); }",
          "            for s in line.split_whitespace() {",
          "                self.queue.push_back(s.to_string());",
          "            }",
          "        }",
          "        self.queue.pop_front().unwrap().parse::<T>().ok().expect(\"Parse failed\")",
          "    }",
          "}",
          "",
          "fn main() {",
          "    let stdin = io::stdin();",
          "    let mut sc = InteractiveScanner::new(stdin.lock());",
          "",
          "    solve(&mut sc);",
          "}",
          "",
          "fn solve(sc: &mut InteractiveScanner<StdinLock>) {",
          "    $0",
          "}",
        ],
        "description": "Rust Interactive Problem Template"
      }
    }
  '';
}
