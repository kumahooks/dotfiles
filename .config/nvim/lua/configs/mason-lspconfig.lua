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
	"lua_ls",
	"templ",
	"eslint",
}

require("mason-lspconfig").setup({
	ensure_installed = servers,
	automatic_installation = false,
})
