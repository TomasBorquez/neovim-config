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
      vim.g.gruvbox_material_background = "medium"
      vim.g.gruvbox_material_ui_contrast = "high"
      vim.g.gruvbox_material_better_performance = 1
      vim.g.gruvbox_material_disable_italic_comment = 1
      vim.cmd.colorscheme("gruvbox-material")

      vim.cmd([[
        highlight MatchParen guibg=#504945 gui=NONE guisp=NONE
        highlight Normal guibg=#0A0A0A
        highlight NormalFloat guibg=#060606
        highlight StatusLine guibg=#070707
        highlight CursorLine guibg=#080808
        highlight FloatBorder guibg=#060606
        highlight FloatShadow gui=NONE guibg=#060606
        highlight Pmenu guibg=#060606
        highlight TelescopeNormal guibg=#060606
        highlight TelescopeBorder guibg=#060606
      ]])
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate"
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope_builtin = require("telescope.builtin")

      vim.keymap.set('n', '<C-p>', function()
        telescope_builtin.find_files({ cwd = GetBufferDir() })
      end)
      vim.keymap.set('n', '<C-S-f>', function()
        telescope_builtin.live_grep({ cwd = GetBufferDir() })
      end)
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
        ensure_installed = { "lua_ls", "clangd" },
        automatic_installation = true,
      })

      local mason_registry = require("mason-registry")
      if not mason_registry.is_installed("clang-format") then
        vim.cmd("MasonInstall clang-format")
      end

      local lspconfig = require("lspconfig")
      lspconfig.lua_ls.setup({})

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
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })

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

      local cmp = require("cmp")
      local ls = require("luasnip")

      ls.config.set_config({
        history = true,
        update_events = "TextChanged,TextChangedI",
        enable_autosnippets = true,
      })

      cmp.setup({
        snippet = {
          expand = function(args)
            ls.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif ls.expand_or_jumpable() then
              ls.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif ls.jumpable(-1) then
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
      shell = "cmd.exe /c \"\"C:\\Program Files\\Git\\bin\\bash.exe\" --login -i\"",
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

      function _G.set_terminal_keymaps()
        opts = { noremap = true }
        vim.api.nvim_buf_set_keymap(0, 't', '<C-`>', [[<cmd>q<CR>]], opts)
        vim.api.nvim_buf_set_keymap(0, 't', '<Esc>', [[<C-\><C-n>]], opts)
        vim.api.nvim_buf_set_keymap(0, 't', '<C-v>', [[<C-\><C-n>"+pa]], opts)
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
    lazy = false,    -- Load at startup
    priority = 1000, -- High priority to load early
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
})
require('commands')
