{
  description = "My NixOS Flake Config";

  inputs = {
    # NixOS official package source, using the nixos-25.11 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    nixvim.url = "github:nix-community/nixvim";
    Neve.url = "github:redyf/Neve";
    nvf.url = "github:notashelf/nvf";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nvf,
    ...
  } @ inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        # Import the previous configuration.nix we used,
        # so the old configuration file still takes effect
        ./configuration.nix
        nvf.nixosModules.default
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
# {
#   description = "NixOS configuration";
#
#   inputs = {
#     nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
#     home-manager.url = "github:nix-community/home-manager";
#     home-manager.inputs.nixpkgs.follows = "nixpkgs";
#   };
#
#   outputs =
#     { nixpkgs, home-manager, ... }:
#     {
#       nixosConfigurations = {
#         hostname = nixpkgs.lib.nixosSystem {
#           system = "x86_64-linux";
#           modules = [
#             ./configuration.nix
#             home-manager.nixosModules.home-manager
#             {
#               home-manager.useGlobalPkgs = true;
#               home-manager.useUserPackages = true;
#               home-manager.users.jdoe = ./home.nix;
#
#               # Optionally, use home-manager.extraSpecialArgs to pass
#               # arguments to home.nix
#             }
#           ];
#         };
#       };
#     };
# }

