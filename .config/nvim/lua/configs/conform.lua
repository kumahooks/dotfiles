local options = {
	formatters_by_ft = {
		lua = { "stylua" },
		go = { "goimports-reviser", "gofumpt", "golines" },
		c = { "clang-format" },
		cpp = { "clang-format" },
		zig = { "zigfmt" },
	},

	formatters = {
		-- C/C++
		["clang-format"] = {
			prepend_args = {
				"--style={BasedOnStyle: LLVM, UseTab: Always, IndentWidth: 4, TabWidth: 4, PointerAlignment: Left, BreakBeforeBraces: Custom, BraceWrapping: {AfterFunction: true}, ColumnLimit: 0}",
			},
		},

		-- Golang
		["goimports-reviser"] = {},
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
		lsp_format = "fallback",
	},
}

return options
