local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

---@diagnostic disable-next-line: undefined-field
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("config")
require("keymaps")
require("utils")
require("lazy").setup({
  {
    "sainnhe/gruvbox-material",
    priority = 1000,
    config = function()
      vim.g.gruvbox_material_better_performance = 1
      vim.g.gruvbox_material_disable_italic_comment = 1
      vim.cmd.colorscheme("gruvbox-material")

      vim.cmd([[
        highlight FloatShadow gui=NONE
        highlight MatchParen guibg=#504945 gui=NONE guisp=NONE

        highlight Normal guibg=#121212
        highlight StatusLine guibg=#0D0D0D

        highlight TelescopeNormal guibg=#0F0F0F
        highlight TelescopeBorder guibg=#0F0F0F

        highlight Pmenu guibg=#0D0D0D
        highlight NormalFloat guibg=#0D0D0D
        highlight CursorLine guibg=#0D0D0D

        highlight FloatBorder guibg=#0B0B0B
      ]])
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require('nvim-treesitter.configs').setup({
        modules = {},
        sync_install = false,
        auto_install = false,
        ignore_install = {},
        parser_install_dir = nil,
        ensure_installed = { "glsl" },
        highlight = {
          enable = true,
        },
        indent = {
          enable = true,
        },
        incremental_selection = {
          enable = true,
        },
      })
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-telescope/telescope-fzf-native.nvim", build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release" }
    },
    config = function()
      local telescope_builtin = require("telescope.builtin")

      vim.keymap.set('n', '<Leader>f', function()
        telescope_builtin.find_files({ cwd = GetTelescopeDir() })
      end)
      vim.keymap.set('n', '<Leader>g', function()
        telescope_builtin.live_grep({ cwd = GetTelescopeDir() })
      end)

      require('telescope').setup({
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          }
        }
      })
    end
  },
  {
    "stevearc/oil.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("oil").setup({
        view_options = {
          show_hidden = true,
        },
        use_default_keymaps = false,
        keymaps = {
          ["<CR>"] = "actions.select",
          ["<leader>p"] = "actions.preview",
          ["<leader>r"] = "actions.refresh",
        },
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "oil",
        callback = function()
          require("cmp").setup.buffer({ enabled = false })
        end,
      })
    end,
  },
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    config = function()
      require("Comment").setup()
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "stevearc/conform.nvim",
      {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
          library = {
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      },
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "clangd", "glsl_analyzer" },
        automatic_installation = true,
      })

      local mason_registry = require("mason-registry")
      if not mason_registry.is_installed("clang-format") then
        vim.cmd("MasonInstall clang-format")
      end

      -- NOTE: Lua LSP
      local lspconfig = require("lspconfig")
      lspconfig.lua_ls.setup({})

      -- NOTE: Clangd LSP
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      lspconfig.clangd.setup({
        capabilities = capabilities,
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--clang-tidy-checks=readability-*,modernize-*,-modernize-use-trailing-return-type",
          "--fallback-style=file",
          "--header-insertion=never",
          "--compile-commands-dir=.",
          "--query-driver=**",
        },
        filetypes = { "c", "h" },
        init_options = {
          fallbackFlags = { "-std=c11", "-D_POSIX_C_SOURCE=200809L", "-D_GNU_SOURCE", "-x", "c" },
          compilationDatabasePath = ".",
        }
      })

      require("conform").setup({
        formatters_by_ft = {
          c = { "clang_format" },
          h = { "clang_format" },
          glsl = { "clang_format" },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })

      -- NOTE: GLSL Analyzer
      lspconfig.glsl_analyzer.setup({
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
        filetypes = { "glsl", "vert", "frag", "geom" },
      })

      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = { "*.glsl", "*.vert", "*.frag", "*.geom" },
        callback = function()
          vim.bo.filetype = "glsl"
        end,
      })

      -- NOTE: Binds
      vim.keymap.set('n', '<leader>m', vim.diagnostic.goto_next)
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then return end

          local opts = { buffer = args.buf }
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'gh', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, opts)
          vim.keymap.set('n', '<C-.>', vim.lsp.buf.code_action, opts)
        end,
      })

      -- NOTE: LuaSnip
      local ls = require("luasnip")

      ls.config.set_config({
        history = true,
        update_events = "TextChanged,TextChangedI",
        enable_autosnippets = true,
      })

      -- NOTE: CMP
      local cmp = require("cmp")
      cmp.setup({
        performance = {
          debounce = 60,
          throttle = 30,
          async_budget = 1,
          fetching_timeout = 500,
          confirm_resolve_timeout = 80,
          max_view_entries = 10,
        },
        snippet = {
          expand = function(args)
            ls.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if ls.expand_or_jumpable() then
              ls.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if ls.jumpable(-1) then
              ls.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'luasnip' },
          { name = 'nvim_lua' },
          { name = 'nvim_lsp' },
          { name = 'buffer' },
          { name = 'path' },
        }),
      })
    end,
  },
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      direction = "float",
      close_on_exit = true,
      shell = 'cmd.exe /k "set CHERE_INVOKING=1 && set MSYSTEM=MINGW64 && C:\\msys64\\usr\\bin\\bash.exe --login -i"',
      float_opts = {
        border = "curved",
        winblend = 0,
        highlights = {
          border = "Normal",
          background = "Normal",
        },
      },
    },
    event = "VeryLazy",
    config = function(_, opts)
      local toggleterm = require("toggleterm")
      toggleterm.setup(opts)

      vim.keymap.set("n", "<C-`>", function()
        vim.cmd(string.format('ToggleTerm dir=%s', Cwd()))
      end, { desc = "Open terminal in current directory" })

      function _G.set_terminal_keymaps()
        local keymap_opts = { noremap = true }
        vim.api.nvim_buf_set_keymap(0, 't', '<C-d>', [[<cmd>q!<CR>]], keymap_opts)
        vim.api.nvim_buf_set_keymap(0, 't', '<C-`>', [[<cmd>q<CR>]], keymap_opts)
        vim.api.nvim_buf_set_keymap(0, 't', '<Esc>', [[<C-\><C-n>]], keymap_opts)
        vim.api.nvim_buf_set_keymap(0, 't', '<C-v>', [[<C-\><C-n>"+pa]], keymap_opts)
      end

      vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
    end,
  },
  {
    "windwp/nvim-autopairs",
    config = function() require("nvim-autopairs").setup() end
  },
  {
    "mhinz/vim-startify",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.startify_custom_header = CreateCowsay()

      vim.g.startify_lists = {
        { type = 'sessions', header = { '  Sessions' } },
        { type = 'files',    header = { '  Recent Files' } },
      }

      vim.g.startify_session_autoload = 1
      vim.g.startify_session_delete_buffers = 1
      vim.g.startify_change_to_vcs_root = 1
      vim.g.startify_fortune_use_unicode = 1
      vim.g.startify_session_persistence = 1

      vim.api.nvim_create_autocmd({ "FileType" }, {
        pattern = "startify",
        callback = function()
          vim.api.nvim_buf_set_keymap(0, 'n', 'p', '<cmd>Programming<CR>', { noremap = true, silent = true })
          vim.api.nvim_buf_set_keymap(0, 'n', 'c', '<cmd>SLoad config<CR>', { noremap = true, silent = true })
        end
      })
    end,
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()

      vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
      vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

      vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end)
      vim.keymap.set("n", "<C-t>", function() harpoon:list():select(2) end)
      vim.keymap.set("n", "<C-n>", function() harpoon:list():select(3) end)
      vim.keymap.set("n", "<C-s>", function() harpoon:list():select(4) end)
    end,
  },
  {
    "machakann/vim-highlightedyank",
    event = "VeryLazy",
    config = function()
      vim.g.highlightedyank_highlight_duration = 300
      vim.cmd([[ highlight HighlightedyankRegion guibg=#335533 guifg=NONE gui=NONE ctermbg=green ctermfg=NONE ]])
      vim.g.highlightedyank_highlight_group = "HighlightedyankRegion"
    end,
  },
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        keymaps = {
          normal = "s",
          normal_cur = "ss",
          normal_line = "S",
          normal_cur_line = "SS",
          visual = "s",
          visual_line = "S",
          delete = "ds",
          change = "cs",
        },
      })
    end
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      signs = false,
    }
  },
  { 'wakatime/vim-wakatime', lazy = false },
  {
    "mfussenegger/nvim-dap",
    event = "VeryLazy",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "jay-babu/mason-nvim-dap.nvim",
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      local mason_dap = require("mason-nvim-dap")
      local dap = require("dap")
      local ui = require("dapui")
      local dap_virtual_text = require("nvim-dap-virtual-text")

      -- Dap Virtual Text
      dap_virtual_text.setup()

      mason_dap.setup({
        ensure_installed = { "cppdbg" },
        automatic_installation = true,
        handlers = {
          function(config)
            require("mason-nvim-dap").default_setup(config)
          end,
        },
      })

      -- Configurations
      dap.configurations = {
        c = {
          {
            name = "Launch file",
            type = "cppdbg",
            request = "launch",
            program = function()
              return GetTelescopeDir() .. "/build/main.exe"
            end,
            cwd = "${workspaceFolder}",
            stopAtEntry = true,
            MIMode = "gdb",
            miDebuggerPath = "gdb",
            setupCommands = {
              {
                description = "Enable pretty-printing for gdb",
                text = "-enable-pretty-printing",
                ignoreFailures = true
              }
            }
          },
          {
            name = "Launch file (custom path)",
            type = "cppdbg",
            request = "launch",
            program = function()
              return vim.fn.input("Path to executable: ", Cwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopAtEntry = true,
            MIMode = "gdb",
            miDebuggerPath = "gdb",
            setupCommands = {
              {
                description = "Enable pretty-printing for gdb",
                text = "-enable-pretty-printing",
                ignoreFailures = true
              }
            }
          }
        },
      }

      -- Disable launch.json
      local vscode = require('dap.ext.vscode')
      vscode._load_json = function() return {} end

      -- Dap UI
      ui.setup({
        icons = {
          expanded = "▾",
          collapsed = "▸",
          current_frame = "▸"
        },
        mappings = {
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        element_mappings = {},
        expand_lines = true,
        force_buffers = true,
        layouts = {
          {
            elements = {
              { id = "scopes",      size = 0.425 },
              { id = "stacks",      size = 0.425 },
              { id = "breakpoints", size = 0.15 },
            },
            size = 40,
            position = "left",
          },
        },
        floating = {
          max_height = nil,
          max_width = nil,
          border = "single",
          mappings = {
            close = { "q", "<Esc>" },
          },
        },
        controls = {
          enabled = false, -- This disables the controls panel
          element = "repl",
          icons = {
            pause = "⏸",
            play = ">",
            step_into = "⏎",
            step_over = "⏭",
            step_out = "⏮",
            step_back = "b",
            run_last = "▶▶",
            terminate = "⏹",
            disconnect = "⏏",
          },
        },
        render = {
          max_type_length = nil,
          max_value_lines = 100,
          indent = 1,
        },
      })

      vim.fn.sign_define('DapBreakpoint', {
        text = 'B',
        texthl = 'DapBreakpoint',
        linehl = '',
        numhl = ''
      })

      vim.fn.sign_define('DapStopped', {
        text = '>',
        texthl = 'DapStopped',
        linehl = 'DapStoppedLine',
        numhl = ''
      })

      vim.cmd [[
        highlight DapBreakpoint guifg=#e06c75 ctermfg=203
        highlight DapBreakpointCondition guifg=#e06c75 ctermfg=203
        highlight DapStopped guifg=#98c379 ctermfg=114
        highlight DapStoppedLine guibg=#2d3748 ctermbg=238
      ]]

      dap.listeners.before.attach.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        ui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        ui.close()
      end
      dap.listeners.after.disconnect.dapui_config = function()
        ui.close()
      end

      -- Keymaps
      vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint)

      vim.keymap.set("n", "<leader>dr", function()
        dap.toggle_breakpoint()
        dap.continue()
      end)

      vim.keymap.set("n", "<leader>dn", dap.continue)
      vim.keymap.set("n", "<leader>di", dap.step_into)
      vim.keymap.set("n", "<leader>do", dap.step_over)
      vim.keymap.set("n", "<leader>du", dap.step_out)

      vim.keymap.set("n", "<leader>dq", function()
        dap.terminate()
        ui.close()
        dap.close()
      end)
    end,
  },
})
require('commands')
