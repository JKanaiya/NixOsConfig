{
  lib,
  pkgs,
  ...
}: {
  imports = [];

  programs.nvf = {
    enable = true;

    settings = {
      vim = {
        theme = {
          enable = true;
          name = "rose-pine";
          style = "main";
        };

        globals = {
          mapleader = " ";
          maplocalleader = " ";
        };

        binds.whichKey.enable = true;

        treesitter = {
          enable = true;
          highlight.enable = true;
          indent.enable = true;
          context.enable = true;
          autotagHtml = true;
        };

        snippets = {
          luasnip.enable = true;
        };

        diagnostics = {
          enable = true;
          config = {
            virtual_lines = {
              enable = true;
              current_line = true;
            };
          };
        };

        visuals = {
          nvim-cursorline.enable = true;
          # indent-blankline.enable = true;
        };

        terminal = {
          toggleterm = {
            enable = true;
            mappings.open = "<C-\\>";
            setupOpts.direction = "float";
          };
        };

        telescope = {
          enable = true;
          extensions = [
            {
              name = "ui-select";
              packages = [pkgs.vimPlugins.telescope-ui-select-nvim];
            }
          ];
        };

        utility = {
          sleuth.enable = true;
          oil-nvim = {
            enable = true;
            gitStatus.enable = true;
          };
        };

        keymaps = [
          {
            key = "\\\\";
            mode = "n";
            action = "<cmd>Oil<CR>";
          }
          {
            key = "<Esc>";
            mode = "n";
            action = "<cmd>nohlsearch<CR>";
          }
          # -- Keybinds to make split navigation easier.
          # --  Use CTRL+<hjkl> to switch between windows
          {
            mode = "n";
            key = "<C-h>";
            action = "<C-w><C-h>";
          }
          {
            mode = "n";
            key = "<C-l>";
            action = "<C-w><C-l>";
          }
          {
            mode = "n";
            key = "<C-j>";
            action = "<C-w><C-j>";
          }
          {
            mode = "n";
            key = "<C-k>";
            action = "<C-w><C-k>";
          }
        ];

        formatter = {
          conform-nvim.enable = true;
        };

        diagnostics.nvim-lint = {
          enable = true;
        };

        lsp = {
          enable = true;
          formatOnSave = true;
          servers = {
            typescript.cmd = lib.mkForce ["typescript-language-server"];
          };
        };

        options = {
          # wrap = true;
          smartindent = true;
          shiftwidth = 4;
          scrolloff = 10;
        };

        syntaxHighlighting = true;

        withNodeJs = true;

        statusline.lualine.enable = true;
        git.enable = true;
        autocomplete.nvim-cmp.enable = true;

        languages = {
          enableTreesitter = true;
          enableFormat = true;
          enableDAP = true;

          nix.enable = true;
          css.enable = true;
          bash.enable = true;
          # ts = {
          #   enable = true;
          #   # extensions = ["tsx" "typescript"];
          #   format = {
          #     enable = true;
          #   };
          # };
          python.enable = true;
        };

        mini = {
          clue.enable = true;
          comment.enable = true;
          # completion.enable = true;
          pairs.enable = true;
          surround.enable = true;
        };
      };
    };
  };
}
