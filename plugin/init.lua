-- require("plugin.ai")
-- require("plugin.completion")
-- require("plugin.debug")
-- require("plugin.format")
-- require("plugin.general_ui")
-- require("plugin.gitsigns")
-- require("plugin.lint")
-- require("plugin.lsp")
-- require("plugin.noice")
-- require("plugin.snacks")
-- require("plugin.treesitter")

return {
	{ import = "plugin.treesitter" },
	{ import = "plugin.snacks" },
	{ import = "plugin.ai" },
	{ import = "plugin.completion" },
	{ import = "plugin.format" },
	{ import = "plugin.debug" },
	{ import = "plugin.general_ui" },
	{ import = "plugin.gitsigns" },
	{ import = "plugin.lint" },
	{ import = "plugin.lsp" },
	{ import = "plugin.noice" },
}
