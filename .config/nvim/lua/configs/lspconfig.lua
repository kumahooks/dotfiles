local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

local lspconfig = require("lspconfig")

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
	"marksman",
	"asm_lsp",
	"lua_ls",
}

lspconfig.servers = servers

for _, server in ipairs(servers) do
	local server_name = type(server) == "string" and server or server[1]
	local server_opts = type(server) == "string" and {} or server[2]

	if server_name == "ts_ls" then
		server_opts.filetypes = {
			"javascript",
			"javascriptreact",
			"javascript.jsx",
			"typescript",
			"typescriptreact",
			"typescript.tsx",
		}
	end

	lspconfig[server_name].setup({
		on_attach = on_attach,
		on_init = on_init,
		capabilities = capabilities,
		filetypes = server_opts.filetypes or lspconfig[server_name].filetypes,
	})
end

lspconfig.lua_ls.setup({
	on_attach = on_attach,
	on_init = on_init,
	capabilities = capabilities,

	settings = {
		Lua = {
			diagnostics = {
				enable = false,
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
			},
		},
	},
})

lspconfig.gopls.setup({
	on_attach = function(client, bufnr) -- Disables gopls format as we use gofumpt
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
		on_attach(client, bufnr)
	end,
	on_init = on_init,
	capabilities = capabilities,

	cmd = { "gopls" },
	filetypes = { "go", "gomod", "gotmpl", "gowork" },
	root_dir = lspconfig.util.root_pattern("go.work", "go.mod", ".git"),

	settings = {
		gopls = {
			analyses = {
				unusedparams = true,
				shadow = true,
			},
			completeUnimported = true,
			usePlaceholders = true,
			staticcheck = true,
		},
	},
})

lspconfig.eslint.setup({
	on_attach = function(_, bufnr)
		vim.api.nvim_create_autocmd("BufWritePre", {
			buffer = bufnr,
			command = "EslintFixAll",
		})
	end,
})

lspconfig.stylelint_lsp.setup({
	filetypes = { "css", "scss" },
	root_dir = lspconfig.util.root_pattern("package.json", ".git"),
	settings = {
		stylelintplus = {},
	},
	on_attach = function(_, buffer)
		vim.api.nvim_create_autocmd("BufWritePre", {
			buffer = buffer,
			callback = function()
				vim.lsp.buf.format()
			end,
		})
	end,
})
