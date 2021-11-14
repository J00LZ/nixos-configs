{
  description = "Memes";

  inputs.deploy-rs.url = "github:serokell/deploy-rs";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, deploy-rs }: {

    nixosConfigurations.nginx = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        "${nixpkgs}/nixos/modules/virtualisation/lxc-container.nix"
        ./hosts/nginx/configuration.nix
      ];
    };

    nixosConfigurations.gitea = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        "${nixpkgs}/nixos/modules/virtualisation/lxc-container.nix"
        ./hosts/gitea/configuration.nix
      ];
    };

    nixosConfigurations.vaultwarden = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        "${nixpkgs}/nixos/modules/virtualisation/lxc-container.nix"
        ./hosts/vaultwarden/configuration.nix
      ];
    };

    nixosConfigurations.k3s = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./hosts/k3s/configuration.nix ];
    };

    nixosConfigurations.minio = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        "${nixpkgs}/nixos/modules/virtualisation/lxc-container.nix"
        ./hosts/minio/configuration.nix
      ];
    };

    nixosConfigurations.registry = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        "${nixpkgs}/nixos/modules/virtualisation/lxc-container.nix"
        ./hosts/registry/configuration.nix
      ];
    };

    deploy.nodes.nginx = {
      hostname = "10.42.20.2";
      fastConnection = true;
      profiles.system = {
        user = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos
          self.nixosConfigurations.nginx;
      };
    };

    deploy.nodes.gitea = {
      hostname = "10.42.20.3";
      fastConnection = true;
      profiles.system = {
        user = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos
          self.nixosConfigurations.gitea;
      };
    };

    deploy.nodes.vaultwarden = {
      hostname = "10.42.20.4";
      fastConnection = true;
      profiles.system = {
        user = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos
          self.nixosConfigurations.vaultwarden;
      };
    };

    deploy.nodes.k3s = {
      hostname = "10.42.20.5";
      fastConnection = true;
      profiles.system = {
        user = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos
          self.nixosConfigurations.k3s;
      };
    };

    deploy.nodes.minio = {
      hostname = "10.42.20.6";
      fastConnection = true;
      profiles.system = {
        user = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos
          self.nixosConfigurations.minio;
      };
    };

    deploy.nodes.registry = {
      hostname = "10.42.20.7";
      fastConnection = true;
      profiles.system = {
        user = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos
          self.nixosConfigurations.registry;
      };
    };

    checks =
      builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy)
      deploy-rs.lib;

  };
}
