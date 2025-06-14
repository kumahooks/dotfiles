return {
	{
		"stevearc/conform.nvim",
		event = "BufWritePre", -- Format on save
		opts = require "custom.configs.conform",
	},

	{
		"neovim/nvim-lspconfig",
		config = function()
			require("nvchad.configs.lspconfig").defaults()
			require "custom.configs.lspconfig"
		end,
	},

	{
		"mason-org/mason.nvim",
		opts = {
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
			ensure_installed = {
				-- LSPs
				"typescript-language-server",
				"asm-lsp",
				"bash-language-server",
				"clangd",
				"css-lsp",
				"gopls",
				"html-lsp",
				"json-lsp",
				"lua-language-server",
				"marksman",
				"pyright",
				"rust-analyzer",
				"yaml-language-server",

				-- Formatters
				"black",
				"clang-format",
				"prettier",
				"prettierd",
				"stylua",
			},
		},
	},
}
