return {
	-- NvimTree
	{
		"nvim-tree/nvim-tree.lua",
		opts = function()
			return require("configs.nvimtree")
		end,
	},

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("configs.treesitter")
		end,
	},

	-- LSP
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("nvchad.configs.lspconfig").defaults()
			require("configs.lspconfig")
		end,
	},
	{
		"mason-org/mason-lspconfig.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-lspconfig" },
		config = function()
			require("configs.mason-lspconfig")
		end,
	},

	-- LuaSnip: drop TextChangedI from update events. NvChad enables
	-- "TextChanged,TextChangedI" and LuaSnip's pos_begin_end_raw crashes on a
	-- stale extmark while typing. See L3MON4D3/LuaSnip#1224.
	{
		"L3MON4D3/LuaSnip",
		opts = function(_, opts)
			opts.updateevents = "TextChanged,InsertLeave"
			return opts
		end,
	},

	-- Lint
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("configs.lint")
		end,
	},
	{
		"rshkarin/mason-nvim-lint",
		event = "VeryLazy",
		dependencies = { "nvim-lint" },
		config = function()
			require("configs.mason-lint")
		end,
	},

	-- Formatter
	{
		"stevearc/conform.nvim",
		event = "BufWritePre",
		opts = require("configs.conform"),
	},
	{
		"zapling/mason-conform.nvim",
		event = "VeryLazy",
		dependencies = { "conform.nvim" },
		config = function()
			require("configs.mason-conform")
		end,
	},
}
