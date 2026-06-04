require("nvchad.mappings")

local map = vim.keymap.set

-- Remaps ; to : to quickly enter command mode
map("n", ";", ":", { desc = "CMD enter command mode" })

-- Exit insert with "jk"
map("i", "jk", "<ESC>")

-- Remaps Ctrl+S to save files
map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Opens Telescope fuzzy finder for searching keymaps
map("n", "<leader>tk", ":Telescope keymaps<CR>", { desc = "Serch keymaps" })

-- Closes Terminal (Alt+Q)
map("t", "<A-q>", "<cmd> :q <CR>", { desc = "Exit terminal" })

-- Open floating terminal (Alt+i)
map({ "n", "t" }, "<A-i>", function()
	require("nvchad.term").toggle({ pos = "float", id = "floatTerm" })
end, { desc = "terminal toggle floating term" })

-- Diagnostics of current line
map("n", "<leader>df", function()
	vim.diagnostic.open_float({ border = "rounded" })
end, { desc = "Floating diagnostic" })

-- Git Blame
map("n", "<leader>gb", function()
	require("gitsigns").blame_line({ full = true })
end, { desc = "git blame" })

-- Debugging (x64dbg/OllyDbg style)
local dap = require("dap")
map("n", "<leader>do", "<cmd>lua require('dapui').toggle()<CR>", { desc = "Toggle UI" })
map("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
map("n", "<leader>dr", dap.continue, { desc = "Run / Continue" })
map("n", "<leader>d?", function()
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
		" Debug Shortcuts (x64dbg/OllyDbg style)",
		" ──────────────────────────────────────",
		"  F2         Toggle breakpoint",
		"  F7         Step into",
		"  F8         Step over",
		"  F9         Run / Continue",
		"  Shift+F9   Stop",
		"  Ctrl+F2    Restart",
		"  Ctrl+F9    Run to cursor",
		"",
		"  <leader>db  Toggle breakpoint",
		"  <leader>dr  Run / Continue",
		"  <leader>do  Toggle DAP UI",
		"",
		" Press q to close",
	})
	vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
	vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { silent = true })
	local w = math.min(vim.o.columns, 42)
	local h = 13
	local row = (vim.o.lines - h) / 2 - 1
	local col = (vim.o.columns - w) / 2
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = w,
		height = h,
		row = math.floor(row),
		col = math.floor(col),
		border = "rounded",
		style = "minimal",
	})
	vim.api.nvim_set_option_value("winhl", "Normal:NormalFloat", { win = win })
end, { desc = "Show debug shortcuts" })
map("n", "<F2>", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
map("n", "<F7>", dap.step_into, { desc = "Step into" })
map("n", "<F8>", dap.step_over, { desc = "Step over" })
map("n", "<F9>", dap.continue, { desc = "Run / Continue" })
map("n", "<C-F9>", dap.run_to_cursor, { desc = "Run to cursor" })
map("n", "<C-F2>", function()
	dap.close()
	vim.defer_fn(function()
		dap.continue()
	end, 200)
end, { desc = "Restart" })
map("n", "<S-F9>", dap.close, { desc = "Stop" })

-- Folds
map("n", "zR", require("ufo").openAllFolds)
map("n", "zM", require("ufo").closeAllFolds)
