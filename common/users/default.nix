{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ fzf git htop rsync ripgrep zoxide ];
  programs.neovim.enable = true;
  programs.neovim.viAlias = true;

  users.defaultUserShell = pkgs.fish;

  users.extraUsers.jdejeu = {
    isNormalUser = true;
    home = "/home/jdejeu";
    description = "Julius";
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAJBY9eQlR/JRnjVC2wKWQ+o02wDlGUlSgN/4e3i6ans"
    ];
  };

  # Configure the root account
  users.extraUsers.root = {
    # Allow my SSH keys for logging in as root.
    openssh.authorizedKeys.keys =
      config.users.users.jdejeu.openssh.authorizedKeys.keys;
    # Also use zsh for root
    shell = pkgs.fish;
  };
}
