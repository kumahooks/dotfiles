local filetypes = {
	"bash",
	"c",
	"cmake",
	"cpp",
	"css",
	"fish",
	"go",
	"gomod",
	"gosum",
	"gotmpl",
	"gowork",
	"javascript",
	"javascriptreact",
	"json",
	"lua",
	"luadoc",
	"make",
	"markdown",
	"printf",
	"python",
	"rust",
	"templ",
	"toml",
	"typescript",
	"typescriptreact",
	"vim",
	"vimdoc",
	"yaml",
}

local treesitter_install_path = vim.fn.stdpath("data") .. "/site"
local treesitter_runtime_path = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/runtime"

require("nvim-treesitter").setup({
	install_dir = treesitter_install_path,
})

if vim.uv.fs_stat(treesitter_runtime_path) then
	vim.opt.runtimepath:prepend(treesitter_runtime_path)
end

pcall(function()
	dofile(vim.g.base46_cache .. "syntax")
	dofile(vim.g.base46_cache .. "treesitter")
end)

vim.treesitter.language.register("javascript", "javascriptreact")
vim.treesitter.language.register("tsx", "typescriptreact")

vim.api.nvim_create_autocmd("FileType", {
	pattern = filetypes,
	callback = function(event)
		pcall(vim.treesitter.start, event.buf)
	end,
})
