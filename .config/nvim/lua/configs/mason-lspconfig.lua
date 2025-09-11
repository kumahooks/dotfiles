local lspconfig = package.loaded["lspconfig"]

local ignore_install = {}
local all_servers = {}

local function table_contains(table, value)
	for _, v in ipairs(table) do
		if v == value then
			return true
		end
	end

	return false
end

for _, s in ipairs(lspconfig.servers) do
	if not table_contains(ignore_install, s) then
		table.insert(all_servers, s)
	end
end

require("mason-lspconfig").setup({
	ensure_installed = all_servers,
	automatic_installation = false,
})
