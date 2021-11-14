{ config, pkgs, lib, ... }:
let secrets = import ./secrets.nix;
in {
  imports = [ ../../common ../../common/generic-lxc.nix ];

  # the registry port and metrics port
  networking.firewall.allowedTCPPorts = [ config.services.dockerRegistry.port ];

  environment.etc.htpasswd = {
    enable = true;
    text = secrets.htpasswd;
  };

  services.dockerRegistry = {
    enable = true;
    enableDelete = true;
    enableGarbageCollect = true;
    listenAddress = "0.0.0.0";
    storagePath = null; # We want to store in s3
    garbageCollectDates = "weekly";

    extraConfig = {
      # S3 Storages
      storage.s3 = {
        accesskey = secrets.access;
        secretkey = secrets.secret;
        regionendpoint = "https://s3.voidcorp.nl";
        bucket = "docker";
        region = "us-east-1"; # Fake but needed
      };
      auth.htpasswd = {
        realm = "Voidcorp Registry";
        path = "/etc/htpasswd";
      };
    };
  };
}
