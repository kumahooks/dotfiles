require("nvchad.autocmds")

local autocmds = vim.api.nvim_create_augroup("CustomAutocmds", { clear = true })

-- Remap gf in Go buffers to resolve the import under the cursor and open
-- nvim-tree at that directory.
vim.api.nvim_create_autocmd("FileType", {
	group = autocmds,
	pattern = "go",
	callback = function()
		local function go_gf()
			local cfile = vim.fn.expand("<cfile>")
			if cfile == "" then
				return
			end

			-- Walk upward to find go.mod and parse the module name
			local buffer_dir = vim.fn.expand("%:p:h")
			local go_mod_path = vim.fn.findfile("go.mod", buffer_dir .. ";")
			if go_mod_path == "" then
				vim.notify("[go:gf] no go.mod found upward from buffer", vim.log.levels.WARN)
				return
			end

			local module_root = vim.fn.fnamemodify(go_mod_path, ":p:h")
			local modname
			for line in io.lines(go_mod_path) do
				local match = line:match("^%s*module%s+(%S+)")
				if match then
					match = match:match('^"(.+)"$') or match
					modname = match
					break
				end
			end

			if not modname then
				vim.notify("[go:gf] could not parse module name from go.mod", vim.log.levels.WARN)
				return
			end

			-- Strip the module prefix from the import path
			local relative = cfile:gsub("^" .. modname:gsub("[%.%-]", "%%%0") .. "/", "")
			if relative == cfile then
				vim.notify("[go:gf] not a local import: " .. cfile, vim.log.levels.WARN)
				return
			end

			local target = module_root .. "/" .. relative
			local ok, api = pcall(require, "nvim-tree.api")
			if not ok then
				vim.notify("[go:gf] nvim-tree not available", vim.log.levels.ERROR)
				return
			end

			api.tree.find_file({ buf = target, open = true, focus = true })
		end

		vim.keymap.set("n", "gf", go_gf, { buffer = true, desc = "Open import in nvim-tree" })
	end,
})

-- Remove trailing whitespaces on save
vim.api.nvim_create_autocmd("BufWritePre", {
	group = autocmds,
	pattern = "*",
	command = "%s/\\s\\+$//e",
})

-- Add new line to the end on save
vim.api.nvim_create_autocmd("BufWritePost", {
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
