inputs: { config, wlib, lib, pkgs, options,... }:
{
  imports = [ wlib.wrapperModules.neovim ];

  options.nvim-lib.neovimPlugins = lib.mkOption {
    readOnly = true;
    type = lib.types.attrsOf wlib.types.stringable;
    # Makes plugins autobuilt from our inputs available with
    # `config.nvim-lib.neovimPlugins.<name_without_prefix>`
    default = config.nvim-lib.pluginsFromPrefix "plugins-" inputs;
  };

  config.settings.config_directory = ./.;
  config.settings.block_normal_config = true;

  # Keep your existing extra packages (these are always available)
  config.extraPackages = with pkgs; [
    lazygit
    ty
    ruff
    lua-language-server
    tree-sitter
    stylua
    nixd
    alejandra
    vscode-js-debug
    gccgo13
    gcc
    gnumake
    nil
  ];

  # Add lze and lzextras as non‑lazy specs
  config.specs.lze = [
    config.nvim-lib.neovimPlugins.lze
    {
      data = config.nvim-lib.neovimPlugins.lzextras;
      name = "lzextras";
    }
  ];

  # Main general spec – all other plugins, lazy by default
  config.specs.general = {
    lazy = true;
    data = with pkgs.vimPlugins; [
      
    {
    data = config.nvim-lib.mkPlugin "99" inputs.ninety-nine;
    name = "99";
    before = ["INIT_MAIN"];
    }
      # Your existing plugins
      snacks-nvim
      easy-dotnet-nvim
      onedark-nvim
      vim-godot
      oceanic-material
      todo-comments-nvim
      nvim-dap-vscode-js
      gruvbox-material
      vim-sleuth
      mini-ai
      mini-files
      mini-surround
      mini-snippets
      friendly-snippets
      mini-icons
      mini-pairs
      nvim-lspconfig
      vim-startuptime
      lazydev-nvim
      blink-cmp
      lualine-nvim
      lualine-lsp-progress
      gitsigns-nvim

    (config.nvim-lib.mkPlugin "99" inputs.ninety-nine)
      which-key-nvim
      nvim-lint
      noice-nvim
      nui-nvim
      nvim-notify
      conform-nvim
      nvim-dap-ui
      nvim-dap-virtual-text
      # Missing plugins you want to add
      blink-compat
      cmp-cmdline
      colorful-menu-nvim
      fidget-nvim
      nvim-surround
      mason-nvim
      # Treesitter textobjects (your custom input)
      (config.nvim-lib.mkPlugin "treesitter-textobjects" inputs.nvim-treesitter-textobjects)
      # Treesitter with all grammars (you can also use the smaller `withPlugins` if you prefer)
      nvim-treesitter.withAllGrammars
      # Optional: keep a smaller set of grammars if you want faster builds
      # (nvim-treesitter.withPlugins (plugins: with plugins; [ nix lua kdl ]))
    ];
    # Optional: move some runtime dependencies here instead of extraPackages
    # runtimePkgs = with pkgs; [ ];
  };

  # If you want separate specs for language‑specific packages (like the desired setup), you can add them, e.g.:
  # config.specs.lua = { lazy = true; data = [ lazydev-nvim ]; };
  # config.specs.nix = { lazy = true; data = [ ]; };

  config.specMods = { parentSpec, ... }: {
    config.collateGrammars = lib.mkDefault (parentSpec.collateGrammars or true);
  };

  # Inform our lua of which top level specs are enabled
  options.settings.cats = lib.mkOption {
    readOnly = true;
    type = lib.types.attrsOf lib.types.bool;
    default = builtins.mapAttrs (_: v: v.enable) config.specs;
  };
  # build plugins from inputs set
  options.nvim-lib.pluginsFromPrefix = lib.mkOption {
    type = lib.types.raw;
    readOnly = true;
    default =
      prefix: inputs:
      lib.pipe inputs [
        builtins.attrNames
        (builtins.filter (s: lib.hasPrefix prefix s))
        (map (
          input:
          let
            name = lib.removePrefix prefix input;
          in
          {
            inherit name;
            value = config.nvim-lib.mkPlugin name inputs.${input};
          }
        ))
        builtins.listToAttrs
      ];
  };
}
