{
  description = "Memes";

  inputs.deploy-rs.url = "github:serokell/deploy-rs";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, deploy-rs }@inputs:
    let
      # Add default system
      system = "x86_64-linux";

      # Make a config
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

      # create a deployment
      mkDeploy = profile: {
        hostname = "${profile}.voidlocal";
        fastConnection = true;
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.${system}.activate.nixos
            self.nixosConfigurations.${profile};
        };
      };

      # art starts here :D
      hosts' = import ./common/hosts.nix;

      # we only want nix hosts for this part, not all of the defined ones...
      nixHosts = (builtins.filter ({ nix ? true, ... }: nix) hosts');

      # Convert a host from hosts.nix to something nixosConfigurations understands
      hostToConfig = z@{ hostname, nixname ? hostname, lxc ? true, ... }:
        a:
        a // {
          ${nixname} = mkConfig {
            name = nixname;
            lxc = lxc;
          };
        };

      # Same as above, but for the nodes part of deploy.
      hostToDeploy = z@{ hostname, nixname ? hostname, lxc ? true, ... }:
        a:
        a // {
          ${nixname} = mkDeploy nixname;
        };

      # And actually make the two sets.
      configs = nixpkgs.lib.fold hostToConfig { } nixHosts;
      nodes = nixpkgs.lib.fold hostToDeploy { } nixHosts;
    in {

      nixosConfigurations = configs;

      deploy.nodes = nodes;

      checks = builtins.mapAttrs
        (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

    };
}
