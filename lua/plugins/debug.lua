return {
	"nvim-dap",
	keys = {
		{ "<F5>", mode = "n" },
		{ "<F1>", mode = "n" },
		{ "<F2>", mode = "n" },
		{ "<F3>", mode = "n" },
		{ "<leader>b", mode = "n" },
		{ "<leader>B", mode = "n" },
		{ "<F7>", mode = "n" },
	},
	after = function(_)
		local dap = require("dap")
		local dapui = require("dapui")

		-- Basic debugging keymaps, feel free to change to your liking!
		vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
		vim.keymap.set("n", "<F1>", dap.step_into, { desc = "Debug: Step Into" })
		vim.keymap.set("n", "<F2>", dap.step_over, { desc = "Debug: Step Over" })
		vim.keymap.set("n", "<F3>", dap.step_out, { desc = "Debug: Step Out" })
		vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
		vim.keymap.set("n", "<leader>B", function()
			dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
		end, { desc = "Debug: Set Breakpoint" })

		-- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
		vim.keymap.set("n", "<F7>", dapui.toggle, { desc = "Debug: See last session result." })

		dap.listeners.after.event_initialized["dapui_config"] = dapui.open
		dap.listeners.before.event_terminated["dapui_config"] = dapui.close
		dap.listeners.before.event_exited["dapui_config"] = dapui.close

		-- Dap UI setup
		-- For more information, see |:help nvim-dap-ui|
		dapui.setup({
			icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
			controls = {
				icons = {
					pause = "⏸",
					play = "▶",
					step_into = "⏎",
					step_over = "⏭",
					step_out = "⏮",
					step_back = "b",
					run_last = "▶▶",
					terminate = "⏹",
					disconnect = "⏏",
				},
			},
		})

		require("nvim-dap-virtual-text").setup({
			enabled = true,
			enabled_commands = true,
			highlight_changed_variables = true,
			highlight_new_as_changed = false,
			show_stop_reason = true,
			commented = false,
			only_first_definition = true,
			all_references = false,
			clear_on_continue = false,
			display_callback = function(variable, buf, stackframe, node, options)
				if options.virt_text_pos == "inline" then
					return " = " .. variable.value
				else
					return variable.name .. " = " .. variable.value
				end
			end,
			virt_text_pos = vim.fn.has("nvim-0.10") == 1 and "inline" or "eol",

			-- experimental features:
			all_frames = false,
			virt_lines = false,
			virt_text_win_col = nil,
		})
		require("dap-vscode-js").setup({
			-- node_path = "node", -- Path of node executable. Defaults to $NODE_PATH, and then "node"
			-- debugger_path = tostring(os.getenv("VSCODE_JS_DEBUG_PATH")), -- Path to vscode-js-debug installation.

			-- debugger_cmd = { tostring(os.getenv("VSCODE_JS_DEBUG_PATH")) }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
			adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" }, -- which adapters to register in nvim-dap
			-- log_file_path = "(stdpath cache)/dap_vscode_js.log" -- Path for file logging
			-- log_file_level = false -- Logging level for output to file. Set to false to disable file logging.
			-- log_console_level = vim.log.levels.ERROR -- Logging level for output to console. Set to false to disable console output.
		})

		for _, language in ipairs({ "typescript", "javascript", "typescriptreact" }) do
			dap.configurations[language] = {
				{
					name = "Launch",
					type = "pwa-node",
					request = "launch",
					program = "${file}",
					cwd = vim.fn.getcwd(),
					-- cwd = "${workspaceFolder}",
					sourceMaps = true,
					protocol = "inspector",
					console = "integratedTerminal",
				},
				{
					name = "Attach to process",
					type = "pwa-node",
					request = "attach",
					processId = require("dap.utils").pick_process,
				},
				{
					type = "pwa-chrome",
					request = "launch",
					name = 'Start Chrome with "localhost"',
					url = "http://localhost:3000",
					webRoot = "${workspaceFolder}",
					userDataDir = "${workspaceFolder}/.vscode/vscode-chrome-debug-userdatadir",
				},
			}
		end
	end,
}
