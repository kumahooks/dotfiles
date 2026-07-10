local languages = {
	"bash",
	"c",
	"cmake",
	"cpp",
	"fish",
	"go",
	"gomod",
	"gosum",
	"gotmpl",
	"gowork",
	"lua",
	"luadoc",
	"make",
	"markdown",
	"printf",
	"python",
	"toml",
	"vim",
	"vimdoc",
	"yaml",
}

vim.api.nvim_create_autocmd("FileType", {
	pattern = languages,
	callback = function()
		vim.treesitter.start()
	end,
})
