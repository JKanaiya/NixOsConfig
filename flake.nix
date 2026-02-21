{
  description = "My NixOS Flake Config";

  inputs = {
    # NixOS official package source, using the nixos-25.11 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    mnw.url = "github:Gerg-L/mnw";
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
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        # Import the previous configuration.nix we used,
        # so the old configuration file still takes effect
        ./configuration.nix
        ./noctalia.nix
        home-manager.nixosModules.home-manager
        {
          # home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {inherit inputs;};
          home-manager.users.jonathan = import ./home/home.nix;
          # home-manager.user.modules = [./home-manager/home.nix];

          # Optionally, use home-manager.extraSpecialArgs to pass
          # arguments to home.nix
        }
      ];
    };
  };
}
