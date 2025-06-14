local options = {
	formatters_by_ft = {
		lua = { "stylua" },
		--javascript = { "prettier" },
		--typescript = { "prettierd", "--trailing-comma=none", "--use-tabs", "--tab-width=4" },
		--json = { "prettierd", "--trailing-comma=none", "--use-tabs", "--tab-width=4" },
		--html = { "prettierd", "--trailing-comma=none", "--use-tabs", "--tab-width=4" },
		--css = { "prettierd", "--trailing-comma=none", "--use-tabs", "--tab-width=4" },
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
