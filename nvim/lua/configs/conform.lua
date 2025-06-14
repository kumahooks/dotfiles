local options = {
	formatters_by_ft = {
		lua = { "stylua" },
		javascript = { "prettierd", "--trailing-comma=none" },
		typescript = { "prettierd", "--trailing-comma=none" },
		json = { "prettierd", "--trailing-comma=none" },
		html = { "prettierd", "--trailing-comma=none" },
		css = { "prettierd", "--trailing-comma=none" },
		go = { "gofmt" },
		rust = { "rustfmt" },
		c = { "clang_format" },
		cpp = { "clang_format" },
		python = { "black" },
	},

	format_on_save = {
		timeout_ms = 500,
		lsp_fallback = true,
	},
}

return options
