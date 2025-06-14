return {
	{
		"stevearc/conform.nvim",
		event = "BufWritePre", -- Format on save
		opts = require "configs.conform",
	},

	{
		"neovim/nvim-lspconfig",
		config = function()
			require("nvchad.configs.lspconfig").defaults()
			require "configs.lspconfig"
		end,
	},
}
