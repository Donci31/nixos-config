{ config, lib, pkgs, ... }:

{
  # WSL Integration
  wsl.enable = true;
  wsl.defaultUser = "nixos";

  # Set timezone to match Windows host (Central Europe Standard Time)
  time.timeZone = "Europe/Budapest";

  # Nix configuration
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "nixos" ];
  };

  # Podman containerization (with docker CLI alias)
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # Set Nushell as default shell
  environment.shells = [ pkgs.nushell pkgs.bash ];
  users.users.nixos = {
    isNormalUser = true;
    shell = pkgs.nushell;
    extraGroups = [ "wheel" ];
  };

  # Base system packages
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
  ];

  # Neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  system.stateVersion = "26.05";
}
