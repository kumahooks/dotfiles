local lspconfig = package.loaded["lspconfig"]

local ignore_install = {
	"stylelint_lsp",
}
local extra_packages = {
	"stylelint-language-server",
}
local all_servers = {}

local function table_contains(table, value)
	for _, table_value in ipairs(table) do
		if table_value == value then
			return true
		end
	end

	return false
end

for _, server in ipairs(lspconfig.servers) do
	if not table_contains(ignore_install, server) then
		table.insert(all_servers, server)
	end
end

require("mason-lspconfig").setup({
	ensure_installed = all_servers,
	automatic_installation = false,
})

local mason_registry = require("mason-registry")

for _, package_name in ipairs(extra_packages) do
	local mason_package = mason_registry.get_package(package_name)

	if not mason_package:is_installed() and not mason_package:is_installing() then
		mason_package:install()
	end
end
