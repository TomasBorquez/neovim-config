local current_dir = vim.fn.getcwd()
local wsl_root = "/mnt/c/WINDOWS/system32"
local win_root = "C:\\Program Files\\Neovide"

if current_dir == wsl_root or current_dir == win_root then
  vim.cmd("cd " .. vim.fn.expand("~"))
end

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
    "neovim/nvim-lspconfig",
    version = "v2.5.0",
    event = { "BufReadPre", "BufNewFile" },
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
    },
    config = function()
      require("mason").setup()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "clangd", "glsl_analyzer", "tsserver", "svelte", "biome", "gopls", "rust_analyzer" },
      })

      local mason_registry = require("mason-registry")
      if not mason_registry.is_installed("clang-format") then
        vim.cmd("MasonInstall clang-format")
      end

      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
      })

      vim.lsp.config("clangd", {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=never",
          "--query-driver=**",
        },
        filetypes = { "c", "h" },
        capabilities = capabilities,
        init_options = { compilationDatabasePath = "./build" },
      })

      vim.lsp.config("glsl_analyzer", {
        filetypes = { "glsl", "vert", "frag" },
        capabilities = capabilities,
      })

      vim.lsp.config("ts_ls", {
        cmd = { "typescript-language-server", "--stdio" },
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
        capabilities = capabilities,
      })

      vim.lsp.config("biome", {
        filetypes = { "css", "html", "json", "jsonc" },
        capabilities = capabilities,
      })

      vim.lsp.config("svelte", {
        filetypes = { "svelte" },
        capabilities = capabilities,
      })

      vim.lsp.config("gopls", {
        capabilities = capabilities,
        filetypes = { "go", "gomod", "gowork", "gotmpl" },
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
            staticcheck = true,
            gofumpt = true,
          },
        },
      })

      vim.lsp.config("rust_analyzer", {
        capabilities = capabilities,
        settings = {
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
            },
            check = {
              command = "clippy",
            }
          },
        },
      })

      vim.lsp.enable({ "lua_ls", "clangd", "glsl_analyzer", "ts_ls", "biome", "svelte", "gopls", "rust_analyzer" })

      --[[ Conform ]]
      local conform = require("conform")
      conform.setup({
        formatters_by_ft = {
          -- C/CPP
          c = { "clang_format" },
          cpp = { "clang_format" },
          h = { "clang_format" },
          hpp = { "clang_format" },
          glsl = { "clang_format" },

          -- JavaScript
          javascript = { "biome" },
          javascriptreact = { "biome" },
          typescript = { "biome" },
          typescriptreact = { "biome" },
          svelte = { "biome" },
        },
      })

      vim.keymap.set("n", "<C-f>", function()
        local line = vim.fn.line(".")
        conform.format({
          lsp_fallback = true,
          async = true,
          range = { start = { line, 0 }, ["end"] = { line, 0 } },
        })
      end)

      local key = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
      vim.keymap.set("v", "<C-f>", function()
        conform.format({ lsp_fallback = true, async = true })
        vim.api.nvim_feedkeys(key, "n", false) -- presses escape
      end)

      vim.keymap.set("n", "<leader>m", function()
        vim.diagnostic.jump({ count = 1 })
      end)

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then
            return
          end

          local opts = { buffer = args.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gh", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<C-.>", vim.lsp.buf.code_action, opts)
        end,
      })

      --[[ LuaSnip ]]
      local ls = require("luasnip")
      ls.config.set_config({
        history = true,
        update_events = "TextChanged,TextChangedI",
        enable_autosnippets = true,
      })

      --[[ CMP ]]
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
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = "luasnip" },
          { name = "nvim_lua" },
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      -- INFO: Config for Gitbash:
      -- shell = "C:\\Users\\eveti\\scoop\\apps\\git\\current\\bin\\bash.exe",
      direction = "float",
      close_on_exit = true,
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

      local harpoon = require("harpoon")
      local function close_harpoon_menu()
        if harpoon.ui.win_id and vim.api.nvim_win_is_valid(harpoon.ui.win_id) then
          harpoon.ui:close_menu()
        end
      end

      local current_term = nil
      local function switch_terminal(target_term)
        return function()
          close_harpoon_menu()

          if current_term == target_term then
            vim.cmd("q")
            current_term = nil
            return
          end

          if target_term == 0 then
            vim.cmd("q!")
            current_term = nil
            return
          end

          if current_term ~= nil then
            vim.cmd("q")
          end

          local term_cmd = target_term .. "ToggleTerm"
          vim.cmd(string.format("%s dir=%s", term_cmd, Cwd()))
          current_term = target_term
        end
      end

      vim.keymap.set("n", "<C-1>", switch_terminal(1))
      vim.keymap.set("n", "<C-2>", switch_terminal(2))
      vim.keymap.set("n", "<C-3>", switch_terminal(3))

      function _G.set_terminal_keymaps()
        vim.keymap.set("t", "<C-d>", "<Nop>")
        vim.keymap.set("t", "<C-S-v>", [[<C-\><C-n>"+pa]])
        vim.keymap.set("t", "<C-S-d>", switch_terminal(0))
        vim.keymap.set("t", "<C-1>", switch_terminal(1))
        vim.keymap.set("t", "<C-2>", switch_terminal(2))
        vim.keymap.set("t", "<C-3>", switch_terminal(3))
        vim.keymap.set("t", "<esc>", [[<C-\><C-n>]])
      end

      opts.on_open = set_terminal_keymaps
      toggleterm.setup(opts)
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" }
    },
    config = function()
      local telescope_builtin = require("telescope.builtin")
      vim.keymap.set("n", "<Leader>f", function()
        telescope_builtin.find_files({ cwd = GetRootDir() })
      end)
      vim.keymap.set("n", "<Leader>g", function()
        telescope_builtin.live_grep({ cwd = GetRootDir() })
      end)

      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          preview = {
            treesitter = false,
          },
          file_ignore_patterns = { "^.git/", "node_modules" },
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          }
        }
      })

      telescope.load_extension('fzf')
    end
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      vim.filetype.add({
        extension = {
          glsl = "glsl",
          vert = "glsl",
          frag = "glsl",
        },
      })

      require("nvim-treesitter.configs").setup({
        modules = {},
        sync_install = false,
        auto_install = true,
        ignore_install = {},
        parser_install_dir = nil,
        ensure_installed = { "glsl", "gdscript", "godot_resource", "gdshader", "c", "cpp", "javascript", "typescript", "go", "html" },
        highlight = {
          enable = true,
        },
        incremental_selection = {
          enable = true,
        },
        indent = {
          enable = false,
        },
      })
    end,
  },
  {
    "stevearc/oil.nvim",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("oil").setup({
        view_options = {
          show_hidden = true,
          is_always_hidden = function(name)
            return vim.endswith(name, ".uid")
          end,
        },
        use_default_keymaps = false,
        keymaps = {
          ["<CR>"] = "actions.select",
          ["<leader>p"] = "actions.preview",
          ["<leader>r"] = "actions.refresh",
        },
      })

      local cmp = require("cmp")
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "oil",
        callback = function()
          cmp.setup.buffer({ enabled = false })
        end,
      })
    end,
  },
  {
    "sainnhe/gruvbox-material",
    priority = 1000,
    config = function()
      vim.g.gruvbox_material_better_performance = 1
      vim.g.gruvbox_material_disable_italic_comment = 1
      vim.cmd.colorscheme("gruvbox-material")

      local fg = vim.api.nvim_get_hl(0, { name = "Normal" }).fg

      local highlights = {
        FloatShadow = {},
        MatchParen = { bg = "#504945", sp = "NONE" },
        Normal = { bg = "#191919", fg = fg },
        StatusLine = { bg = "#0D0D0D", fg = fg },
        TelescopeNormal = { bg = "#0F0F0F", fg = fg },
        TelescopeBorder = { bg = "#0F0F0F", fg = fg },
        Pmenu = { bg = "#0D0D0D", fg = fg },
        NormalFloat = { bg = "#0D0D0D", fg = fg },
        CursorLine = { bg = "#0D0D0D" },
        FloatBorder = { bg = "#0B0B0B", fg = fg },
      }

      for group, opts in pairs(highlights) do
        vim.api.nvim_set_hl(0, group, opts)
      end
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
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        keymaps = {
          normal = "s",
          visual = "s",
          normal_cur = "ss",
          delete = "ds",
          change = "cs",
        },
      })
    end
  },
  {
    "rmagatti/auto-session",
    lazy = false,
    config = function()
      require("auto-session").setup({
        auto_restore_last_session = true,
      })
    end
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false }
  },
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    ft = { "html", "javascript", "javascriptreact", "typescript", "typescriptreact", "svelte", "vue", "xml" },
  },
  { "numToStr/Comment.nvim", event = "VeryLazy" },
  { "folke/lazydev.nvim", ft = "lua", opts = {} },
})
require("commands")
