{
  description = "My NixOS Flake Config";

  inputs = {
    nixpkgs.url = "github:nixOS/nixpkgs/26.05";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    # mnw.url = "github:Gerg-L/mnw";
    wrappers.url = "github:BirdeeHub/nix-wrapper-modules";
    wrappers.inputs.nixpkgs.follows = "nixpkgs";
    nvim-treesitter-textobjects = {
      url = "github:nvim-treesitter/nvim-treesitter-textobjects/main";
      flake = false;
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  inputs.plugins-lze = {
    url = "github:BirdeeHub/lze";
    flake = false;
  };
  inputs.ninety-nine = {
    url = "github:ThePrimeagen/99";
    flake = false;
  };
  # These 2 are already in nixpkgs, however this ensures you always fetch the most up to date version!
  inputs.plugins-lzextras = {
    url = "github:BirdeeHub/lzextras";
    flake = false;
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    wrappers,
    ...
  } @ inputs: let
    forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.platforms.all;
    module = nixpkgs.lib.modules.importApply ./module.nix inputs;
    wrapper = wrappers.lib.evalModule module;
  in {
    overlays = {
      default = final: prev: {neovim = wrapper.config.wrap {pkgs = final;};};
      neovim = self.overlays.default;
    };
    wrapperModules = {
      default = module;
      neovim = self.wrapperModules.default;
    };
    wrappedModules = {
      default = wrapper.config;
      neovim = self.wrappedModules.default;
    };
    packages = forAllSystems (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        default = wrapper.config.wrap {inherit pkgs;};
        neovim = self.packages.${system}.default;
      }
    );
    nixosModules = {
       default = self.nixosModules.neovim;
       neovim = wrappers.lib.getInstallModule {
         name = "neovim";
        value = module;
      };
    };
    wrappers.neovim.enable = true;
          nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        # Import the previous configuration.nix we used,
        # so the old configuration file still takes effect
        ./configuration.nix
        ./noctalia.nix
        home-manager.nixosModules.home-manager
        inputs.self.nixosModules.neovim
        {
          # home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {inherit inputs;};
          home-manager.users.jonathan = import ./home/home.nix;
          wrappers.neovim.enable = true;
          # home-manager.user.modules = [./home-manager/home.nix];

          # Optionally, use home-manager.extraSpecialArgs to pass
          # arguments to home.nix
        }
      ];
    };
  };
}
