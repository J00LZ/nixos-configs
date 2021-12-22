{ config, pkgs, lib, ... }:
let secrets = import ./secrets.nix;
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # Import common config
    ../../common/generic-vm.nix
    ../../common
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  networking.hostName = "wireguard";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

  environment.systemPackages = with pkgs; [ wireguard ];

  environment.noXlibs = lib.mkForce false;

  networking.firewall.allowedTCPPorts = [ ];

  networking.nat.enable = true;
  networking.nat.externalInterface = "ens18";
  networking.nat.internalInterfaces = [ "wg0" ];

  networking.firewall.allowedUDPPorts = [ 51820 ];

  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.42.69.1/24" ];
      listenPort = 51820;
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.42.69.0/24 -o ens18 -j MASQUERADE
      '';

      # This undoes the above command
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.42.69.0/24 -o ens18 -j MASQUERADE
      '';

      privateKey = secrets.serverPrivate;
      peers = [
        {
          publicKey = secrets.laptopPublic;
          allowedIPs = [ "10.42.69.2/32" ];
        }
        {
          publicKey = secrets.phonePublic;
          allowedIPs = [ "10.42.69.3/32" ];
        }
      ];
    };
  };

}
