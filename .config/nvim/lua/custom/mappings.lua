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

-- Debugging
map("n", "<leader>do", "<cmd>lua require('dapui').toggle()<CR>", { desc = "debug toggle ui" })
map("n", "<leader>db", "<cmd>lua require('dap').toggle_breakpoint()<CR>", { desc = "debug toggle breakpoint" })
map("n", "<leader>dr", "<cmd>lua require('dap').continue()<CR>", { desc = "debug run/continue" })

-- Folds
map("n", "zR", require("ufo").openAllFolds)
map("n", "zM", require("ufo").closeAllFolds)

-- Adds semicolon in the end
map("n", "<C-l>", "A;<Esc>", { desc = "Jump out and add semicolon" })
map("i", "<C-l>", "<Esc>A;<Esc>", { desc = "Jump out and add semicolon" })
