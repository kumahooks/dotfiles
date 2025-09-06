return {}

--[[
return {
	{
		"mfussenegger/nvim-dap",
		keys = {
			{
				"<leader>db",
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "DAP: Toggle Breakpoint",
			},
			{
				"<leader>dr",
				function()
					require("dap").continue()
				end,
				desc = "DAP: Run/Continue",
			},
			{
				"<leader>do",
				function()
					require("dap").step_over()
				end,
				desc = "DAP: Step Over",
			},
			{
				"<leader>di",
				function()
					require("dap").step_into()
				end,
				desc = "DAP: Step Into",
			},
			{
				"<leader>du",
				function()
					require("dap").step_out()
				end,
				desc = "DAP: Step Out",
			},
			{
				"<leader>d B",
				function()
					require("dap").set_breakpoint(vim.fn.input "Breakpoint condition: ")
				end,
				desc = "DAP: Set Conditional Breakpoint",
			},
		},
		dependencies = {
			{
				"rcarriga/nvim-dap-ui",
				dependencies = { "nvim-neotest/nvim-nio" },
				keys = {
					{
						"<leader>de",
						function()
							require("dapui").toggle()
						end,
						desc = "DAP: Toggle UI",
					},
					{
						"<leader>dK",
						function()
							require("dapui").eval()
						end,
						desc = "DAP: Evaluate",
						mode = { "n", "v" },
					},
				},
				config = function()
					local dapui = require "dapui"
					dapui.setup()

					local dap = require "dap"
					dap.listeners.after.event_initialized["dapui_config"] = function()
						dapui.open()
					end

					dap.listeners.before.event_terminated["dapui_config"] = function()
						dapui.close()
					end

					dap.listeners.before.event_exited["dapui_config"] = function()
						dapui.close()
					end
				end,
			},

			{
				"theHamsta/nvim-dap-virtual-text",
				opts = {},
			},

			{
				"jay-babu/mason-nvim-dap.nvim",
				opts = {},
			},

			{
				"mxsdev/nvim-dap-vscode-js",
				dependencies = {
					{
						"microsoft/vscode-js-debug",
						build = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
					},
					{ "nvim-lua/plenary.nvim" },
				},
			},
		},
		config = function()
			local dap = require "dap"
			local vscode_js = require "dap-vscode-js"

			vscode_js.setup {
				debugger_path = vim.fn.stdpath "data" .. "/lazy/vscode-js-debug",
				adapters = { "pwa-node", "node-terminal", "pwa-chrome", "pwa-extensionHost" },
			}

			for _, language in ipairs {
				"typescript",
				"javascript",
				"typescriptreact",
				"javascriptreact",
				"vue",
				"angular",
			} do
				dap.configurations[language] = {
					{
						type = "pwa-node",
						request = "launch",
						name = "Launch file",
						program = "${file}",
						cwd = vim.fn.getcwd(),
					},
					{
						type = "pwa-node",
						request = "attach",
						name = "Attach to process",
						processId = require("dap.utils").pick_process,
						cwd = vim.fn.getcwd(),
					},
					{
						type = "pwa-chrome",
						request = "launch",
						name = "Launch & Debug Chrome",
						url = function()
							local co = coroutine.running()

							return coroutine.create(function()
								vim.ui.input({
									prompt = "Enter URL: ",
									default = "http://localhost:3000",
								}, function(url)
									if url == nil or url == "" then
										return
									else
										coroutine.resume(co, url)
									end
								end)
							end)
						end,
						webRoot = vim.fn.getcwd(),
						userDataDir = false,
					},
					{
						type = "pwa-chrome",
						request = "attach",
						name = "Attach & Debug Chrome",
						url = function()
							local co = coroutine.running()

							return coroutine.create(function()
								vim.ui.input({
									prompt = "Enter URL: ",
									default = "http://localhost:3000",
								}, function(url)
									if url == nil or url == "" then
										return
									else
										coroutine.resume(co, url)
									end
								end)
							end)
						end,
						webRoot = vim.fn.getcwd(),
						userDataDir = false,
					},
				}
			end
		end,
	},
}
]]
