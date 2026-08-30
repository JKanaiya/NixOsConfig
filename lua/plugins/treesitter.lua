-- vim.g.no_plugin_maps must be set before ftplugins run, so it stays top-level,
-- not inside an `after` callback.
vim.g.no_plugin_maps = true
-- vim.g.no_python_maps = true
-- vim.g.no_ruby_maps = true
-- vim.g.no_rust_maps = true
-- vim.g.no_go_maps = true

return {
	{
		"nvim-treesitter",
		event = "FileType",
		after = function(_)
			---@param buf integer
			---@param language string
			local function treesitter_try_attach(buf, language)
				if not vim.treesitter.language.add(language) then
					return false
				end
				vim.treesitter.start(buf, language)
				vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
				vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				return true
			end

			local installable_parsers = require("nvim-treesitter").get_available()

			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					local buf, filetype = args.buf, args.match
					local language = vim.treesitter.language.get_lang(filetype)
					if not language then
						return
					end
					if not treesitter_try_attach(buf, language) then
						if vim.tbl_contains(installable_parsers, language) then
							require("nvim-treesitter").install(language):await(function()
								treesitter_try_attach(buf, language)
							end)
						end
					end
				end,
			})
		end,
	},

	{
		"nvim-treesitter-textobjects",
		keys = {
			{ "am", mode = { "x", "o" } },
			{ "im", mode = { "x", "o" } },
			{ "ac", mode = { "x", "o" } },
			{ "ic", mode = { "x", "o" } },
			{ "as", mode = { "x", "o" } },
		},
		after = function(_)
			require("nvim-treesitter-textobjects").setup({
				select = {
					lookahead = true,
					selection_modes = {
						["@parameter.outer"] = "v",
						["@function.outer"] = "V",
						-- ['@class.outer'] = '<c-v>',
					},
					include_surrounding_whitespace = false,
				},
			})

			vim.keymap.set({ "x", "o" }, "am", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "im", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "ac", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "ic", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "as", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@local.scope", "locals")
			end)
		end,
	},
}
