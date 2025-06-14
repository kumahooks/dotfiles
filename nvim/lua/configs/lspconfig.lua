local on_attach = require("nvchad.configs.lspconfig").on_attach
local capabilities = require("nvchad.configs.lspconfig").capabilities

local servers = {
	"ts_ls",
	"gopls",
	"rust_analyzer",
	"clangd",
	"pyright",
	"jsonls",
	"html",
	"cssls",
	"bashls",
	"yamlls",
	"htmx",
	"marksman",
	"asm_lsp",
	lua_ls = {
		settings = {
			Lua = {
				diagnostics = {
					globals = { "vim" },
				},
				workspace = {
					library = vim.api.nvim_get_runtime_file("", true),
					checkThirdParty = false,
				},
			},
		},
	},
}

for _, server in ipairs(servers) do
	local server_name = type(server) == "string" and server or server[1]
	local server_opts = type(server) == "string" and {} or server[2]

	if server_name == "tsserver" then
		server_opts.filetypes = {
			"javascript",
			"javascriptreact",
			"javascript.jsx",
			"typescript",
			"typescriptreact",
			"typescript.tsx",
		}
	end

	local lspconfig = require "lspconfig"

	lspconfig[server_name].setup {
		on_attach = on_attach,
		capabilities = capabilities,
		filetypes = server_opts.filetypes or lspconfig[server_name].filetypes,
	}
end
