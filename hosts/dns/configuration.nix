{ config, pkgs, ... }:
# can i just say that i hate this
let hosts = import ../.;
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
        localData' = { hostname, ip, ... }: localData hostname ip;
        ptrData = hostname: ip: ''"${ip} ${hostname}.voidlocal"'';
        ptrData' = { hostname, ip, ... }: ptrData hostname ip;

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
      };
      forward-zone = {
        name = ''"."'';
        forward-addr = [ "8.8.8.8" "9.9.9.9" ];
      };
    };
  };

}
