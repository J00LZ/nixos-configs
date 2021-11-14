{ config, pkgs, ... }:
let
  proxy = url: {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = url;
      proxyWebsockets = true;
    };
  };
  k8s_proxy = proxy "https://k8s-1.voidlocal:443/";
in {
  imports = [
    # Import common config
    ../../common/generic-lxc.nix
    ../../common
  ];

  networking.hostName = "nginx";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

  environment.systemPackages = with pkgs; [ ];

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."voidcorp.nl" = k8s_proxy;
    virtualHosts."harbor.voidcorp.nl" = k8s_proxy;
    virtualHosts."cdn.voidcorp.nl" = proxy "http://10.42.2.6:80/";

    virtualHosts."git.voidcorp.nl" = proxy "http://gitea.voidlocal:3000/";

    virtualHosts."galerievanslagmaat.nl" = proxy "http://10.42.0.124:5667/";

    virtualHosts."vaultwarden.voidcorp.nl" = proxy "http://10.42.20.4:8000/";

    virtualHosts."s3.voidcorp.nl" = proxy "http://10.42.20.6:9000/";
    virtualHosts."explore.s3.voidcorp.nl" = proxy "http://10.42.20.6:9001/";
    virtualHosts."registry.voidcorp.nl" = proxy "http://10.42.20.7:5000/";
  };

  security.acme.email = "acme@voidcorp.nl";
  security.acme.acceptTerms = true;
}
