local cmp = require("cmp")

local options = require("nvchad.configs.cmp")

options.sources = {
	{ name = "nvim_lsp" },
	{ name = "buffer" },
	{ name = "path" },
	{ name = "nvim_lua" },
}

options.mapping["<C-q>"] = cmp.mapping.close()
options.mapping["<C-e>"] = cmp.mapping.close()
options.mapping["<C-Space>"] = cmp.mapping.complete()
options.mapping["<CR>"] = cmp.mapping.confirm({
	behavior = cmp.ConfirmBehavior.Insert,
	select = true,
})

options.mapping["<Tab>"] = cmp.mapping(function(fallback)
	if cmp.visible() then
		cmp.select_next_item()
	else
		fallback()
	end
end, {
	"i",
	"s",
})

options.mapping["<S-Tab>"] = cmp.mapping(function(fallback)
	if cmp.visible() then
		cmp.select_prev_item()
	else
		fallback()
	end
end, {
	"i",
	"s",
})

return options
