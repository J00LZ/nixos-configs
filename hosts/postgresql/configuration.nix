{ config, pkgs, ... }:
let
in {
  imports = [
    # Import common config
    ../../common/generic-lxc.nix
    ../../common
  ];

  networking.hostName = "postgresql";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

  environment.systemPackages = with pkgs; [ ];

  networking.firewall.allowedTCPPorts = [ 5432 ];

  services.postgresql = {
    enable = true;
    authentication = "host all all 10.42.0.0/16 trust";
    ensureDatabases = [ "prometheus" "grafana" ];
    ensureUsers = [
      {
        name = "prometheus";
        ensurePermissions = { "DATABASE \"prometheus\"" = "ALL PRIVILEGES"; };
      }
      {
        name = "grafana";
        ensurePermissions = { "DATABASE \"grafana\"" = "ALL PRIVILEGES"; };
      }
    ];
    enableTCPIP = true;
  };

}
