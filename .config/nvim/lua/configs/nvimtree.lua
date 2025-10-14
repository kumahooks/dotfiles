local options = {
	view = {
		adaptive_size = true,
	},
	actions = {
		open_file = {
			window_picker = {
				enable = false,
			},
		},
	},
	update_focused_file = {
		enable = true,
		update_root = false,
	},
}

return options
