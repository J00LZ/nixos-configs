{ config, pkgs, ... }:
let

in {
  imports = [
    # Import common config
    ../../common/generic-lxc.nix
    ../../common
  ];

  networking.hostName = "dns";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

  environment.systemPackages = with pkgs; [ dig ];

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  services.unbound = {
    enable = true;
    settings = {
      server = let
        localData = hostname: ip: ''"${hostname}.voidlocal. A ${ip}"'';
        localData' = { hostname, ip }: localData hostname ip;
        ptrData = hostname: ip: ''"${ip} ${hostname}.voidlocal"'';
        ptrData' = { hostname, ip }: ptrData hostname ip;

        hosts = [
          {
            hostname = "localhost";
            ip = "127.0.0.1";
          }
          {
            hostname = "pfsense";
            ip = "10.42.0.1";
          }
          {
            hostname = "pve";
            ip = "10.42.1.1";
          }
          {
            hostname = "idrac";
            ip = "10.42.1.2";
          }
          {
            hostname = "pve-storage";
            ip = "10.42.1.4";
          }
          {
            hostname = "arch-base";
            ip = "10.42.2.1";
          }
          {
            hostname = "gitlab-host";
            ip = "10.42.2.2";
          }
          {
            hostname = "storage-host";
            ip = "10.42.2.4";
          }
          {
            hostname = "cdn-host";
            ip = "10.42.2.6";
          }
          {
            hostname = "arch-torrent";
            ip = "10.42.2.7";
          }
          {
            hostname = "postgres";
            ip = "10.42.2.19";
          }
          {
            hostname = "thelounge";
            ip = "10.42.2.21";
          }
          {
            hostname = "unifi";
            ip = "10.42.2.27";
          }
          {
            hostname = "ssh-host";
            ip = "10.42.2.28";
          }
          {
            hostname = "k8s-1";
            ip = "10.42.3.1";
          }
          {
            hostname = "k8s-2";
            ip = "10.42.3.2";
          }
          {
            hostname = "k8s-3";
            ip = "10.42.3.3";
          }
          {
            hostname = "nginx";
            ip = "10.42.20.2";
          }
          {
            hostname = "gitea";
            ip = "10.42.20.3";
          }
          {
            hostname = "vaultwarden";
            ip = "10.42.20.4";
          }
          {
            hostname = "k3s-1";
            ip = "10.42.20.5";
          }
          {
            hostname = "minio";
            ip = "10.42.20.6";
          }
          {
            hostname = "registry";
            ip = "10.42.20.7";
          }
          {
            hostname = "postgresql";
            ip = "10.42.20.8";
          }
          {
            hostname = "grafana";
            ip = "10.42.20.9";
          }
          {
            hostname = "dns";
            ip = "10.42.20.10";
          }
        ];

      in {
        use-syslog = "yes";
        module-config = ''"validator iterator"'';
        interface-automatic = "yes";
        interface = [ "0.0.0.0" "::0" ];

        local-zone = ''"voidlocal." transparent'';
        local-data = map localData' hosts;
        local-data-ptr = map ptrData' hosts;
        access-control = [
          "127.0.0.1/32 allow_snoop"
          "::1 allow_snoop"
          "10.42.0.0/16 allow"
          "127.0.0.0/8 allow"
          "192.168.2.0/24 allow"
          "::1/128 allow"
        ];
        private-address = [
          "127.0.0.0/8"
          "10.0.0.0/8"
          "::ffff:a00:0/104"
          "172.16.0.0/12"
          "::ffff:ac10:0/108"
          "169.254.0.0/16"
          "::ffff:a9fe:0/112"
          "192.168.0.0/16"
          "::ffff:c0a8:0/112"
          "fd00::/8"
          "fe80::/10"
        ];
        # addLocal "10.42.0.1" "pfsense";
      };
      forward-zone = {
        name = ''"."'';
        forward-addr = [ "8.8.8.8" "9.9.9.9" ];
      };
    };
  };

}
