{ config, pkgs, ... }:
let secrets = import ./secrets.nix;
in {
  imports = [
    # Import common config
    ../../common/generic-lxc.nix
    ../../common
  ];

  networking.hostName = "grafana";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

  environment.systemPackages = with pkgs; [ ];

  environment.etc.adminPass = {
    enable = true;
    text = secrets.passwd;
  };

  environment.etc.signKey = {
    enable = true;
    text = secrets.secretKey;
  };
  
  networking.firewall.allowedTCPPorts = [ 3000 ];

  services.grafana = {
    enable = true;
    protocol = "http";
    domain = "grafana.voidcorp.nl";
    rootUrl = "https://grafana.voidcorp.nl/";
    addr = "0.0.0.0";
    port = 3000;
    database = {
      type = "postgres";
      host = "postgresql.voidlocal";
      user = "grafana";
      passwordFile = "/etc/adminPass";
    };
    security = {
      adminUser = secrets.adminUser;
      adminPasswordFile = "/etc/adminPass";
      secretKeyFile = "/etc/signKey";
    };
    analytics.reporting.enable = false;
  };

}
