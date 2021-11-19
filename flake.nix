{
  description = "Memes";

  inputs.deploy-rs.url = "github:serokell/deploy-rs";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, deploy-rs }@inputs:
    let
      system = "x86_64-linux";
      mkConfig = { name, lxc ? true }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = (if lxc then
            [ "${nixpkgs}/nixos/modules/virtualisation/lxc-container.nix" ]
          else
          # this is probably the ugliest fix ever, but it
          # makes both nix/deploy.rs and the formatter work so it's fine
            [ ]) ++ [ "${./.}/hosts/${name}/configuration.nix" ];
          specialArgs = { inputs = inputs; };
        };
      mkDeploy = profile: {
        hostname = "${profile}.voidlocal";
        fastConnection = true;
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.${system}.activate.nixos
            self.nixosConfigurations.${profile};
        };
      };
      hosts' = import ./common/hosts.nix;
      nixHosts = (builtins.filter ({ nix ? true, ... }: nix) hosts');

      hostToConfig = z@{ hostname, nixname ? hostname, lxc ? true, ... }:
        a:
        a // {
          ${nixname} = mkConfig {
            name = nixname;
            lxc = lxc;
          };
        };

      hostToDeploy = z@{ hostname, nixname ? hostname, lxc ? true, ... }:
        a:
        a // {
          ${nixname} = mkDeploy nixname;
        };

      configs = nixpkgs.lib.fold hostToConfig { } nixHosts;
      nodes = nixpkgs.lib.fold hostToDeploy { } nixHosts;
    in {

      nixosConfigurations = configs;

      deploy.nodes = nodes;

      checks = builtins.mapAttrs
        (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

    };
}
