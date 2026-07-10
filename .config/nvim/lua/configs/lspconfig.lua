local nvchad_lspconfig = require("nvchad.configs.lspconfig")
local on_attach = nvchad_lspconfig.on_attach
local on_init = nvchad_lspconfig.on_init
local capabilities = nvchad_lspconfig.capabilities

pcall(function()
	local semantic_token_highlights = require("base46").get_integration("semantic_tokens")

	for highlight_group, highlight_options in pairs(semantic_token_highlights) do
		vim.api.nvim_set_hl(0, highlight_group, highlight_options)
	end
end)

local servers = {
	"ts_ls",
	"gopls",
	"rust_analyzer",
	"clangd",
	"pyright",
	"jsonls",
	"cssls",
	"bashls",
	"yamlls",
	"marksman",
	"templ",
}

-- Apply capabilities and on_init to all servers (merges with NvChad's global config)
vim.lsp.config("*", {
	capabilities = capabilities,
	on_init = on_init,
})

-- Enable servers that use defaults
for _, server_name in ipairs(servers) do
	vim.lsp.enable(server_name)
end

-- Override lua_ls settings (merges with NvChad's lua_ls config)
vim.lsp.config("lua_ls", {
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

-- Override gopls: disable formatting (use gofumpt via conform), add settings
vim.lsp.config("gopls", {
	on_attach = function(client, bufnr)
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
		on_attach(client, bufnr)
	end,
	on_init = function() end,
	settings = {
		gopls = {
			analyses = {
				unusedparams = true,
				shadow = true,
			},
			completeUnimported = true,
			usePlaceholders = true,
			staticcheck = true,
			gofumpt = true,
		},
	},
})

-- Override eslint: format on save
local base_eslint_on_attach = vim.lsp.config.eslint.on_attach
vim.lsp.config("eslint", {
	on_attach = function(client, bufnr)
		if base_eslint_on_attach then
			base_eslint_on_attach(client, bufnr)
		end
		vim.api.nvim_create_autocmd("BufWritePre", {
			buffer = bufnr,
			command = "EslintFixAll",
		})
	end,
})

