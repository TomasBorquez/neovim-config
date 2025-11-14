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

        highlight Normal guibg=#191919
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
      vim.filetype.add({
        extension = {
          tmpl = "gotmpl",
          gohtml = "gotmpl",
          gotmpl = "gotmpl",

          glsl = "glsl",
          vert = "glsl",
          frag = "glsl",
        },
      })

      require('nvim-treesitter.configs').setup({
        modules = {},
        sync_install = false,
        auto_install = true,
        ignore_install = {},
        parser_install_dir = nil,
        ensure_installed = { "glsl", "gdscript", "godot_resource", "gdshader", "c", "cpp", "javascript", "typescript", "go", "gotmpl", "html" },
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
        defaults = {
          preview = {
            treesitter = false,
          }
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
    end
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

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "oil",
        callback = function()
          require("cmp").setup.buffer({ enabled = false })
        end,
      })
    end,
  },
  {
    'neovim/nvim-lspconfig',
    version = 'v2.5.0',
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
      "windwp/nvim-ts-autotag",
      { "folke/lazydev.nvim", ft = "lua", opts = {} },
    },
    config = function()
      require("mason").setup()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "clangd", "glsl_analyzer", "tsserver", "svelte", "biome", "gopls" },
        automatic_installation = {
          exclude = { "ruby_lsp" }
        },
      })

      vim.lsp.config('lua_ls', {
        capabilities = capabilities,
      })

      vim.lsp.config('clangd', {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=never",
          "--query-driver=**",
        },
        filetypes = { "c", "h" },
        capabilities = capabilities,
        init_options = {
          fallbackFlags = { "-std=c11" },
          compilationDatabasePath = "./build",
        },
      })

      vim.lsp.config('glsl_analyzer', {
        filetypes = { "glsl", "vert", "frag" },
        capabilities = capabilities,
      })

      vim.lsp.config('ts_ls', {
        cmd = { "typescript-language-server", "--stdio" },
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
        capabilities = capabilities,
      })

      vim.lsp.config('biome', {
        filetypes = { "css", "html", "json", "jsonc" },
        capabilities = capabilities,
      })

      vim.lsp.config('svelte', {
        filetypes = { "svelte" },
        capabilities = capabilities,
      })

      vim.lsp.config('gopls', {
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

      if IsWindows() then
        vim.lsp.config('gdscript', {
          cmd = vim.lsp.rpc.connect('127.0.0.1', 6005),
          capabilities = capabilities,
        })
        vim.lsp.enable('gdscript')
      end

      if IsLinux() then
        vim.lsp.config('ruby_lsp', {
          cmd = {
            vim.fn.expand("~/.local/share/mise/shims/bundle"),
            "exec",
            "ruby-lsp"
          },
          root_dir = vim.fs.root(0, { "Gemfile", ".git" }),
          capabilities = capabilities,
        })
        vim.lsp.enable('ruby_lsp')
      end

      vim.lsp.enable({ 'lua_ls', 'clangd', 'glsl_analyzer', 'ts_ls', 'biome', 'svelte', 'gopls' })

      -- [[ Clang Format ]]
      local mason_registry = require("mason-registry")
      if not mason_registry.is_installed("clang-format") then
        vim.cmd("MasonInstall clang-format")
      end

      --[[ Conform ]]
      require("conform").setup({
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
        format_on_save = {
          timeout_ms = 1000,
          lsp_fallback = true,
        },
      })

      --[[ Binds ]]
      vim.keymap.set('n', '<leader>m', function()
        vim.diagnostic.jump({ count = 1 })
      end)
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

      --[[ Autoclosing tags ]]
      require('nvim-ts-autotag').setup()

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
      -- WARNING: If on linux, keep blank or add custom one

      -- INFO: Config for MinGW64:
      -- shell = 'cmd.exe /k "set CHERE_INVOKING=1 && set MSYSTEM=MINGW64 && C:\\msys64\\usr\\bin\\bash.exe --login -i"',

      -- INFO: Config for Gitbash:
      -- shell = 'C:\\Users\\eveti\\scoop\\apps\\git\\current\\bin\\bash.exe',
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
  { -- TODO: Rewrite myself as a util
    "machakann/vim-highlightedyank",
    event = "VeryLazy",
    config = function()
      vim.g.highlightedyank_highlight_duration = 300
      vim.cmd([[ highlight HighlightedyankRegion guibg=#335533 guifg=NONE gui=NONE ctermbg=green ctermfg=NONE ]])
      vim.g.highlightedyank_highlight_group = "HighlightedyankRegion"
    end,
  },
  {
    "habamax/vim-godot",
    event = "VimEnter"
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false }
  },
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup()
    end
  },
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    config = function()
      require("Comment").setup()
    end,
  },
})
require('commands')
