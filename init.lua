vim.g.mapleader = " "
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.number = true

-- PLUGINS

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct
vim.g.maplocalleader = "\\" -- Same for `maplocalleader`

require("lazy").setup({
  {
      "hrsh7th/nvim-cmp",
      dependencies = {
          "hrsh7th/cmp-nvim-lsp",
          "hrsh7th/cmp-buffer", 
          "hrsh7th/cmp-path",
          "hrsh7th/cmp-cmdline",
      }
  },
  "sindrets/diffview.nvim",
  "lewis6991/gitsigns.nvim",
  "neovim/nvim-lspconfig",
  {
      "nvim-lualine/lualine.nvim",
      dependencies = {
          "nvim-tree/nvim-web-devicons"
      },
      config = function()
          require("lualine").setup({
              options = {
                  theme = "ayu_dark"
              }
          })
      end
  },
  {
      'nvim-telescope/telescope.nvim',
      tag = '0.1.6',
      dependencies = {
          "nvim-lua/plenary.nvim",
          "BurntSushi/ripgrep",
          {"nvim-telescope/telescope-fzf-native.nvim", build = "make"},
          "sharkdp/fd"
      }
  },
  {
      "nvim-tree/nvim-tree.lua",
      version = "*",
      lazy = false,
      dependencies = {
          "nvim-tree/nvim-web-devicons"
      },
      config = function()
          require("nvim-tree").setup({})
      end
  },
  {"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"},
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 300
    end
  },
})

require("gitsigns").setup()

-- CMP

local cmp = require("cmp")
cmp.setup({
    snippet = {
        expand = function(args)
            vim.snippet.expand(args.body)
        end,
    },
    window = {},
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
})

-- LSP

local cmp_capabilities = require("cmp_nvim_lsp").default_capabilities()
local lspconfig = require("lspconfig")

lspconfig.rust_analyzer.setup({
    on_attach = function(client, bufnr)
        vim.lsp.inlay_hint_enable(true, {bufnr = bufnr})
    end,
    settings = {
        ["rust-analyzer"] = {
            imports = {
                granularity = {
                    group = "module",
                },
                prefix = "self",
            },
            cargo = {
                buildScripts = {
                    enable = true,
                },
            },
            procMacro = {
                enable = true
            },
        }
    },
    capabilities = cmp_capabilities,
})

local vue_lsp_path = "%AppData%/npm/node_modules/@vue/language-server"

lspconfig.tsserver.setup({
    init_options = {
        plugins = {
            {
                name = '@vue/typescript-plugin',
                location = vue_language_server_path,
                languages = { 'vue' },
            },
        },
    },
    filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
    capabilities = cmp_capabilities,
})

lspconfig.volar.setup({
    capabilities = cmp_capabilities,
})

-- TELESCOPE

local telescope_builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", telescope_builtin.find_files, {desc = "open file with name"})
vim.keymap.set("n", "<leader>fg", telescope_builtin.live_grep, {desc = "search in files"})
