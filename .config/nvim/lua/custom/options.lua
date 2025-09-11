require("nvchad.options")

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt
local g = vim.g
local o = vim.o

-- Disables nvim auto format on save
g.autoformat = false

-- Adds new line on save
opt.fixendofline = true

-- Disables conceal level
opt.conceallevel = 0

-- Creates two vertical columns
vim.opt.colorcolumn = "80,120"

-- Performance stuff
g.lazyredraw = true
opt.updatetime = 50

-- Indentation
o.tabstop = 4
o.expandtab = false
o.shiftwidth = 4

-- Line Number
opt.relativenumber = true
opt.number = true

-- Enable line wrapping
opt.wrap = true

-- Highlight the line where the cursor is
opt.cursorline = true

-- Enable mouse support in all modes
opt.mouse:append("a")

-- Use system clipboard for copy/paste
opt.clipboard:append("unnamedplus")

-- Default split behavior: open splits below/right
opt.splitright = true
opt.splitbelow = true

-- Case-insensitive search unless uppercase is used
opt.ignorecase = true
opt.smartcase = true

-- Enable true color support
opt.termguicolors = true
-- Always show the sign column to avoid shifting text
opt.signcolumn = "yes"

-- Disable mode display (e.g., "-- INSERT --")
opt.showmode = false

-- Automatically reload files changed outside of Neovim
opt.autoread = true
vim.bo.autoread = true

-- Disable backup/swap/write-backup files
opt.backup = false
opt.writebackup = false
opt.swapfile = false

-- Set file encoding detection order
opt.fileencodings = "utf-8,gbk,gb18030,gb2312,ucs-bom,cp936,big5,euc-jp,euc-kr"

-- Disable automatic comment continuation on new lines
vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	callback = function()
		opt.formatoptions:remove({ "c", "r", "o" })
	end,
})

-- Allow the cursor to move into virtual (nonexistent) space in block visual mode
o.virtualedit = "block"

-- UI characters (used to style the interface visually)
vim.opt.fillchars = {
	diff = "╱",
	eob = " ", -- Hide ~ at end of buffer
	stl = " ",
	stlnc = " ",
	wbr = " ",
	horiz = "─",
	horizup = "┴",
	horizdown = "┬",
	vert = "│",
	vertleft = "┤",
	vertright = "├",
	verthoriz = "┼",
}

-- Set transparency levels for floating windows and popup menus
o.winblend = 0
o.pumblend = 0
o.pumheight = 15 -- Limit popup menu height

-- Statusline and command-line UI
o.showmode = false
o.showcmd = false
o.cmdheight = 0 -- Hide command line unless needed
o.laststatus = 3 -- Global statusline
o.ruler = false
o.signcolumn = "yes"
o.shortmess = "fimnxsTAIcF" -- Compact messages

-- Set transparency levels for floating windows and popup menus
o.winblend = 0
o.pumblend = 0
o.pumheight = 15 -- Limit popup menu height

-- Statusline and command-line UI
o.showmode = false
o.showcmd = false
o.cmdheight = 0 -- Hide command line unless needed
o.laststatus = 3 -- Global statusline
o.ruler = false
o.signcolumn = "yes"
o.shortmess = "fimnxsTAIcF" -- Compact messages

-- Persistent undo, backup, and view directories
opt.undofile = true
opt.undodir = vim.fn.expand("$HOME/.cache/nvim/undo")
opt.backupdir = vim.fn.expand("$HOME/.cache/nvim/backup")
opt.viewdir = vim.fn.expand("$HOME/.cache/nvim/view")

-- LSP logging level
vim.lsp.set_log_level("info")

-- Command and key mapping timeout settings
o.timeout = true
o.ttimeoutlen = 50
o.timeoutlen = 100

-- Shell providers - disable unused ones
g.loaded_python3_provider = 0
g.loaded_ruby_provider = 0
g.loaded_node_provider = 0
g.loaded_perl_provider = 0

-- Enable smooth scrolling if supported
opt.smoothscroll = true

-- Folding settings
o.foldlevel = 99 -- Keep all folds open by default
o.foldtext = "v:lua.require'lazyvim.util'.ui.foldtext()" -- Custom fold text display

-- Disable recommended Markdown indentation style
vim.g.markdown_recommended_style = 0

-- Folds configuration
vim.o.foldcolumn = "1" -- '0' is not bad
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true
