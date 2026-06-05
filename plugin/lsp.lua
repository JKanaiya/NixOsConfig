-- NOTE: lsp setup via lspconfig

local servers = {}

-- most don't need much configuration
servers.gopls = {}
servers.ts_ls = {}

servers["prisma-language-server"] = {
	cmd = { "prisma-language-server", "--stdio" },
	filetypes = { "prisma" },
	settings = {
		prisma = {
			enableDiagnostics = true,
		},
	},
}

-- Python: Fast Type Checking (ty)
servers.ty = {
	settings = {
		ty = {
			diagnosticMode = "workspace", -- or 'openFilesOnly' for better performance
			inlayHints = {
				variableTypes = true,
				callArgumentNames = true,
			},
			completions = {
				autoImport = true,
			},
		},
	},
}

-- Python: Linting & Formatting (Ruff)
servers.ruff = {
	-- Ruff works perfectly alongside ty
}

-- but you can provide some if you want to!
servers.lua_ls = {
	settings = {
		Lua = {
			formatters = {
				ignoreComments = true,
			},
			signatureHelp = { enabled = true },
			diagnostics = {
				globals = { "vim" },
				disable = { "missing-fields" },
			},
		},
	},
}
-- nixd requires some configuration.
-- for additional configuration options, refer to:
-- https://github.com/nix-community/nixd/blob/main/nixd/docs/configuration.md
servers.nixd = {
	settings = {
		nixd = {
			nixpkgs = {
				expr = [[import <nixpkgs> {}]],
			},
			options = {},
			formatting = {
				command = { "nixfmt" },
			},
			diagnostic = {
				suppress = {
					"sema-escaping-with",
				},
			},
		},
	},
}

vim.lsp.config("*", {
	-- capabilities = capabilities,
	on_attach = function(_, bufnr)
		-- we create a function that lets us more easily define mappings specific
		-- for LSP related items. It sets the mode, buffer and description for us each time.
		local nmap = function(keys, func, desc)
			if desc then
				desc = "LSP: " .. desc
			end
			vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
		end

		nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
		nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
		nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
		nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
		nmap("gr", function()
			Snacks.picker.lsp_references()
		end, "[G]oto [R]eferences")
		nmap("gI", function()
			Snacks.picker.lsp_implementations()
		end, "[G]oto [I]mplementation")
		nmap("<leader>ds", function()
			Snacks.picker.lsp_symbols()
		end, "[D]ocument [S]ymbols")
		nmap("<leader>ws", function()
			Snacks.picker.lsp_workspace_symbols()
		end, "[W]orkspace [S]ymbols")

		-- See `:help K` for why this keymap
		nmap("K", vim.lsp.buf.hover, "Hover Documentation")
		nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

		-- Lesser used LSP functionality
		nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
		nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
		nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
		nmap("<leader>wl", function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, "[W]orkspace [L]ist Folders")

		-- Create a command `:Format` local to the LSP buffer
		vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
			vim.lsp.buf.format()
		end, { desc = "Format current buffer with LSP" })
	end,
})

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.diagnostic.config({
	-- Show the error message at the end of the line
	virtual_text = {
		spacing = 4,
		prefix = "●", -- Or '■', '▎', 'x'
		source = "if_many", -- Only show source (e.g., "lua_ls") if there are multiple
	},
	-- Show icons in the gutter (sign column)
	signs = true,
	-- Underline the actual code that has the error
	underline = true,
	-- Don't update diagnostics while you are typing (better performance)
	update_in_insert = false,
	-- Sort diagnostics by severity (errors first)
	severity_sort = true,
	-- Customize the floating window (the one that pops up on hover)
	float = {
		focused = false,
		style = "minimal",
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
	},
})

-- set up the servers to be loaded on the appropriate filetypes!
for server_name, cfg in pairs(servers) do
	vim.lsp.config(server_name, cfg)
	vim.lsp.enable(server_name)
end
