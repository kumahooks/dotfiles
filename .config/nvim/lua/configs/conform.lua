local options = {
	formatters_by_ft = {
		lua = { "stylua" },
		go = { "gofumpt", "goimports-reviser", "golines" },
	},

	formatters = {
		-- Golang
		["goimports-reviser"] = {
			prepend_args = { "-rm-unused" },
		},
		golines = {
			prepend_args = { "--max-len=120" },
		},

		-- Lua
		stylua = {
			prepend_args = {
				"--column-width",
				"120",
				"--line-endings",
				"Unix",
				"--indent-type",
				"Tabs",
				"--indent-width",
				"4",
				"--quote-style",
				"AutoPreferDouble",
			},
		},

		-- Python
		black = {
			prepend_args = {
				"--fast",
				"--line-length",
				"120",
			},
		},
		isort = {
			prepend_args = {
				"--profile",
				"black",
			},
		},
	},

	format_on_save = {
		timeout_ms = 500,
		lsp_fallback = true,
	},
}

return options
