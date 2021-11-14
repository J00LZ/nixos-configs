{ config, pkgs, ... }:
let secrets = import ./secrets.nix;
in {
  imports = [
    # Import common config
    ../../common/generic-lxc.nix
    ../../common
  ];

  networking.hostName = "minio";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

  environment.systemPackages = with pkgs; [ ];

  environment.etc.minioSettings = {
    enable = true;
    text = secrets.content;
  };

  networking.firewall.allowedTCPPorts = [ 9000 9001 ];

  services.minio = {
    enable = true;
    rootCredentialsFile = "/etc/minioSettings";
  };

}
