require "nvchad.autocmds"

local autocmds = vim.api.nvim_create_augroup("CustomAutocmds", { clear = true })

-- Remove trailing whitespaces on save
vim.api.nvim_create_autocmd("BufWritePre", {
	group = autocmds,
	pattern = "*",
	command = "%s/\\s\\+$//e",
})

-- Add new line to the end on save
vim.api.nvim_create_autocmd("BufWritePre", {
	group = autocmds,
	pattern = "*",
	callback = function()
		local buf = vim.api.nvim_get_current_buf()

		local line_count = vim.api.nvim_buf_line_count(buf)

		if line_count > 0 then
			local last_line = vim.api.nvim_buf_get_lines(buf, line_count - 1, line_count, false)[1]

			if last_line ~= "" then
				vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "" })
			end
		end
	end,
})
