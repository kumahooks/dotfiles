local options = {
	formatters_by_ft = {
		lua = { "stylua" },
		--javascript = { "prettier" },
		--typescript = { "prettierd" },
		json = { "prettierd" },
		html = { "prettierd" },
		css = { "prettierd" },
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

	formatters = {
		prettierd = {
			prepend_args = { "--tab-width", "4", "--use-tabs", "true" },
		},
	},
}

return options
