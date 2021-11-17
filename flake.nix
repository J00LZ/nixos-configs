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
      mkDeploy = profile: hostname: {
        hostname = hostname;
        fastConnection = true;
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.${system}.activate.nixos
            self.nixosConfigurations.${profile};
        };
      };

    in {

      nixosConfigurations.nginx = mkConfig { name = "nginx"; };
      nixosConfigurations.gitea = mkConfig { name = "gitea"; };
      nixosConfigurations.vaultwarden = mkConfig { name = "vaultwarden"; };
      nixosConfigurations.k3s = mkConfig {
        name = "k3s";
        lxc = false;
      };
      nixosConfigurations.minio = mkConfig { name = "minio"; };
      nixosConfigurations.registry = mkConfig { name = "registry"; };
      nixosConfigurations.postgresql = mkConfig { name = "postgresql"; };
      nixosConfigurations.grafana = mkConfig { name = "grafana"; };
      nixosConfigurations.dns = mkConfig { name = "dns"; };

      deploy.nodes.nginx = mkDeploy "nginx" "10.42.20.2";
      deploy.nodes.gitea = mkDeploy "gitea" "10.42.20.3";
      deploy.nodes.vaultwarden = mkDeploy "vaultwarden" "10.42.20.4";
      deploy.nodes.k3s = mkDeploy "k3s" "10.42.20.5";
      deploy.nodes.minio = mkDeploy "minio" "10.42.20.6";
      deploy.nodes.registry = mkDeploy "registry" "10.42.20.7";
      deploy.nodes.postgresql = mkDeploy "postgresql" "10.42.20.8";
      deploy.nodes.grafana = mkDeploy "grafana" "10.42.20.9";
      deploy.nodes.dns = mkDeploy "dns" "10.42.20.10";

      checks = builtins.mapAttrs
        (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

    };
}
