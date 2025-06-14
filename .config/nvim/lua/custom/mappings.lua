require "nvchad.mappings"

local map = vim.keymap.set

-- Remaps ; to : to quickly enter command mode
map("n", ";", ":", { desc = "CMD enter command mode" })

-- Exit insert with "jk"
map("i", "jk", "<ESC>")

-- Remaps Ctrl+S to save files
map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
