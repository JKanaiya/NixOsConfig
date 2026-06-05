local conform = require("conform")
conform.setup({
	formatters_by_ft = {
		-- NOTE: download some formatters in lspsAndRuntimeDeps
		-- and configure them here
		lua = { "stylua" },
		-- templ = { "templ" },
		-- Conform will run multiple formatters sequentially
		-- python = { "isort", "black" },
		-- Use a sub-list to run only the first available formatter
		nix = { "nixfmt" },
		python = { "ruff_organize_imports", "ruff_format" },
		javascript = { "prettierd", "prettier", stop_after_first = true },
		typescriptreact = { "prettierd", "prettier", stop_after_first = true },
		typescript = { "prettierd", "prettier", stop_after_first = true },
		css = { "prettierd", "prettier", stop_after_first = true },
		html = { "prettierd", "prettier", stop_after_first = true },
		prisma = { "prisma_fmt" },
	},
	-- Adding format-on-save logic here:
	format_on_save = {
		-- These options are passed to conform.format()
		timeout_ms = 500,
		lsp_fallback = true,
		lsp_format = "fallback",
	},
})
vim.keymap.set({ "n", "v" }, "<leader>FF", function()
	conform.format({
		lsp_fallback = true,
		async = false,
		timeout_ms = 1000,
	})
end, { desc = "[F]ormat [F]ile" })
