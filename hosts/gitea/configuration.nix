{ config, pkgs, ... }:
let
  secrets = import ./secrets.nix;
in {
  imports = [
    # Import common config
    ../../common/generic-lxc.nix
    ../../common
  ];

  networking.hostName = "gitea";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

  environment.systemPackages = with pkgs; [
    gnupg
  ];

  networking.firewall.enable = false;
  networking.firewall.allowedTCPPorts = [ 3000 ];
  services.openssh.permitRootLogin = "no";
  services.openssh.passwordAuthentication = false;

  environment.etc.giteaPass = {
    enable = true;
    text = "x";
  };

  services.gitea = {
    enable = true;
    ssh = {
      clonePort = 4321;
    };
    lfs.enable = true;
    appName = "Voidcorp Gitea";
    domain = "git.voidcorp.nl";
    rootUrl = "https://git.voidcorp.nl/";
    database = secrets.database;
    # TODO: Figure out how to do this
    # dump = {
    #   enable = true;
    #   interval = "weekly";
    #   backupDir = "/mnt/storage/backup/gitea";
    # };
    cookieSecure = true;
    disableRegistration = true;
  };
}
