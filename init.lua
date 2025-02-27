vim.g.mapleader = " "
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
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
			"saadparwaiz1/cmp_luasnip",
		},
	},
	{
		"stevearc/conform.nvim",
		opts = {},
	},
	"sindrets/diffview.nvim",
	"lewis6991/gitsigns.nvim",
	"neovim/nvim-lspconfig",
	{
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("lualine").setup({
				options = {
					theme = "ayu_mirage",
				},
			})
		end,
	},
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
	},
	{
		"williamboman/mason.nvim",
	},
	{
		"williamboman/mason-lspconfig.nvim",
	},
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.6",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"BurntSushi/ripgrep",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			"sharkdp/fd",
		},
	},
	{
		"nvim-tree/nvim-tree.lua",
		version = "*",
		lazy = false,
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"antosha417/nvim-lsp-file-operations",
		},
		config = function()
			require("nvim-tree").setup({})
		end,
	},
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
	},
})

require("gitsigns").setup()
require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = { "lua_ls", "rust_analyzer", "tsserver", "volar", "cssls", "pyright", "clangd", "html" },
})
require("conform").setup({
	formatters_by_ft = {
		javascript = { "prettier" },
		lua = { "stylua" },
		python = { "black" },
		rust = { "rustfmt" },
		typescript = { "prettier" },
		vue = { "prettier" },
		html = { "prettier" },
	},
})

-- CMP

local cmp = require("cmp")
cmp.setup({
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	window = {},
	mapping = cmp.mapping.preset.insert({
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
	}, {
		{ name = "buffer" },
	}),
})

-- LSP

local cmp_capabilities = require("cmp_nvim_lsp").default_capabilities()
local lspconfig = require("lspconfig")

lspconfig.rust_analyzer.setup({
	on_attach = function(client, bufnr)
		vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
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
				enable = true,
			},
		},
	},
	capabilities = cmp_capabilities,
})

local mason_registry = require("mason-registry")
local vue_lsp_path = mason_registry.get_package("vue-language-server"):get_install_path()
	.. "/node_modules/@vue/language-server"
--	.. "/node_modules/@vue/typescript-plugin"

lspconfig.tsserver.setup({
	init_options = {
		plugins = {
			{
				name = "@vue/typescript-plugin",
				location = vue_lsp_path,
				languages = { "vue" },
			},
		},
	},
	filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
	capabilities = cmp_capabilities,
})

lspconfig.volar.setup({
	capabilities = cmp_capabilities,
})

lspconfig.pyright.setup({
	capabilities = cmp_capabilities,
})

lspconfig.clangd.setup({
	capabilities = cmp_capabilities,
})

lspconfig.html.setup({
	capabilities = cmp_capabilities,
})
-- KEYMAPS

local telescope_builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", telescope_builtin.find_files, { desc = "open file with name" })
vim.keymap.set("n", "<leader>fg", telescope_builtin.live_grep, { desc = "search in files" })
vim.keymap.set("n", "<leader>ls", ":NvimTreeOpen<CR>")
vim.keymap.set("n", "<leader>lt", ":NvimTreeToggle<CR>")
vim.keymap.set("n", "<leader>lc", ":NvimTreeClose<CR>")
vim.keymap.set("n", "<leader>p", function()
	require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "formatter" })
vim.keymap.set("n", "<leader>ml", "<C-W>W")
vim.keymap.set("n", "<leader>mr", "<C-W>w")

-- COLORSCHEME

vim.cmd("colorscheme habamax")
