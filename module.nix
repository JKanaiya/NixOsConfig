inputs: {
  config,
  wlib,
options,
  lib,
  pkgs,
  ...
}: {
  imports = [wlib.wrapperModules.neovim];
  # choose a directory for your config.
  # this can be a string, for if you don't want nix to manage it right now.
  # but be careful, it also doesn't get frovisioned by nix if it isnt in the store.
  config.settings.config_directory = ./.;

  options.nvim-lib.neovimPlugins = lib.mkOption {
    readOnly = true;
    type = lib.types.attrsOf wlib.types.stringable;
    # Makes plugins autobuilt from our inputs available with
    # `config.nvim-lib.neovimPlugins.<name_without_prefix>`
    default = config.nvim-lib.pluginsFromPrefix "plugins-" inputs;
  };

  options.settings.colorscheme = lib.mkOption {
    type = lib.types.str;
    default = "onedark_dark";
  };

  config.specs.colorscheme = {
    lazy = true;
    data = builtins.getAttr config.settings.colorscheme (
      with pkgs.vimPlugins;
      {
        "onedark_dark" = onedarkpro-nvim;
        "onedark_vivid" = onedarkpro-nvim;
        "onedark" = onedarkpro-nvim;
        "onelight" = onedarkpro-nvim;
        "moonfly" = vim-moonfly-colors;
      }
    );
  };

  config.specs.lze = [
    # if defaults is fine, you can just provide the `.data` field
    config.nvim-lib.neovimPlugins.lze
    # but these can be specs too!
    {
      # these ones can't take lists though
      data = config.nvim-lib.neovimPlugins.lzextras;
      # things can target any spec that has a name.
      name = "lzextras";
      # now something else can be after = [ "lzextras" ]
      # the spec name is not the plugin name.
      # to override the plugin name, use `pname`
      # You could run something before your main init.lua like this
      # before = [ "INIT_MAIN" ];
      # You can include configuration and translated nix values here as well!
      # type = "lua"; # | "fnl" | "vim"
      # info = { };
      # config = ''
      #   local info, pname, lazy = ...
      # '';
    }
  ];

  # The makeWrapper options are available
  config.runtimePkgs = with pkgs; [
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
  config.settings.block_normal_config = true;
  # your config/plugin specifications
  # a set of plugins or specs, which can contain a list of plugins or specs if desired.
  config.specs.general = with pkgs.vimPlugins; [
    {
      # These can be specs too!
      data = snacks-nvim;
      # maybe you want to do something like this?

      # lazy = false | true;
      # type = "lua" | "fnl" | "vim";
      # info = { /* some opts from nix to the config */ };
      # config = ''
      #   local info, pname, lazy = ...
      #   -- run snacks bigfile or something
      # '';

      # before = [ "INIT_MAIN" ];
      # putting before = [ "INIT_MAIN" ] here will run this before the main init

      # things can target any spec that has a name.
      name = "snacks-spec";
      # now something else can be after = [ "snacks-spec" ]
      # the spec name is not the plugin name.
      # to override the plugin name, use `pname`
    }
    {
    data = config.nvim-lib.mkPlugin "99" inputs.ninety-nine;
    name = "99";
    before = ["INIT_MAIN"];
    }
    easy-dotnet-nvim
    onedark-nvim
    vim-godot
    oceanic-material
    todo-comments-nvim
    # nvim-dap-vscode-js
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
    blink-cmp
    lualine-nvim
    lualine-lsp-progress
    gitsigns-nvim
    which-key-nvim
    (config.nvim-lib.mkPlugin "99" inputs.ninety-nine)
    nvim-lint
    noice-nvim
    nui-nvim
    nvim-notify
    conform-nvim
    nvim-dap-ui
    nvim-dap-virtual-text
    # building a plugin from a source outside of nixpkgs
    (config.nvim-lib.mkPlugin "treesitter-textobjects" inputs.nvim-treesitter-textobjects)
    # treesitter + grammars
    nvim-treesitter.withAllGrammars
    # This is for if you only want some of the grammars
    (nvim-treesitter.withPlugins (
      plugins: with plugins; [
        nix
        lua
        kdl
      ]
    ))
  ];

  # config.runtimePkgs = config.specCollect (acc: v: acc ++ (v.runtimePkgs or [ ])) [ ];

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

  # you can name these whatever you want. These ones are named `general` and `lazy`
  # You can use the before and after fields to run them before or after other specs or spec of lists of specs
  config.specs.lazy = {
    # this `lazy = true` definition will transfer to specs in the contained DAL, if there is one.
    # This is because the definition of lazy in `config.specMods` checks `parentSpec.lazy or false`
    # the submodule type for `config.specMods` gets `parentSpec` as a `specialArg`.
    # you can define options like this too!
    lazy = true;
    # here we chose a DAL of plugins, but we can also pass a single plugin, or null
    # plugins are of type wlib.types.stringable
    data = with pkgs.vimPlugins; [
      lazydev-nvim
    ];
    # top level specs don't need to declare their dag name to be targetable.
    # so we can target general here, without adding name = "general" in the `general` spec above.
    # in fact, we didn't even need to give `general` a spec, its just a list!
    after = ["general"];
  };

  # These specMods are modules which modify your specs in config.specs
  # you can override defaults, or make your own options.
  config.specMods =
    {
      # When this module is ran in an inner list,
      # this will contain `config` of the parent spec
      parentSpec ? null,
      # and this will contain `options`
      # otherwise they will be `null`
      parentOpts ? null,
      parentName ? null,
      # and then config from this one, as normal
      config,
      # and the other module arguments.
      ...
    }:
    {
      # you could use this to change defaults for the specs
      config.collateGrammars = lib.mkDefault (parentSpec.collateGrammars or false);
      # config.autoconfig = lib.mkDefault (parentSpec.autoconfig or false);
      # config.runtimeDeps = lib.mkDefault (parentSpec.runtimeDeps or false);
      # config.pluginDeps = lib.mkDefault (parentSpec.pluginDeps or false);
      # or something more interesting like:
      # add a runtimePkgs field to the specs themselves
      options.runtimePkgs = options.runtimePkgs // {
        description = ''
          A runtimePkgs spec field to put packages on the PATH
          If the spec is disabled, this value will not be included in the resulting neovim derivation
        '';
      };
      # You could do this too
      # config.before = lib.mkDefault [ "INIT_MAIN" ];
    };
  # or, if you dont care about propagating parent values:
  # config.specMods.collateGrammars = lib.mkDefault true;

  # There are some default hosts!
  # python, ruby, and node are enabled by default
  # perl and neovide are not.

  # To add a wrapped $out/bin/${config.binName}-neovide to the resulting neovim derivation
  # config.hosts.neovide.nvim-host.enable = true;

  # If you want to install multiple neovim derivations via home.packages or environment.systemPackages
  # in order to prevent path collisions:

  # set this to true:
  # config.settings.dont_link = true;

  # and make sure these dont share values:
  # config.binName = "nvim";
  # config.settings.aliases = [ ];
}
