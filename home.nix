{ config, pkgs, dotfiles, ... }:

{
  home.username = "nixos";
  home.homeDirectory = "/home/nixos";
  home.stateVersion = "26.05";

  # CLI packages
  home.packages = with pkgs; [
    # Core CLI utilities
    fd
    ripgrep
    bat
    eza
    fzf
    jq
    xh
    fastfetch
    tree-sitter
    duckdb
    poppler-utils
    chafa
    ffmpegthumbnailer

    # VCS
    jujutsu
    lazygit

    # Dev runtimes & toolchains
    uv
    python3
    bun
    nodejs_24
    rustup
    zig
    go
    awscli2
    kubectl
    pandoc
    gcc
    gnumake
    unzip

    # Media & processing
    ffmpeg-full
    imagemagick
    mpv

    # Container tools
    podman-compose
  ];

  # Git configuration
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Donci31";
        email = "82709410+Donci31@users.noreply.github.com";
      };
      init.defaultBranch = "main";
    };
    ignores = [
      "**/.claude/settings.local.json"
    ];
  };

  # Jujutsu configuration
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Donci31";
        email = "82709410+Donci31@users.noreply.github.com";
      };
      ui.editor = "nvim";
    };
  };

  # Neovim (LazyVim from GitHub dotfiles)
  xdg.configFile."nvim" = {
    source = "${dotfiles}/nvim";
    recursive = true;
    force = true;
  };

  # Bat
  programs.bat = {
    enable = true;
  };

  # Starship
  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
  };
  xdg.configFile."starship.toml".source = "${dotfiles}/starship/starship.toml";

  # Zoxide
  programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
  };

  # Carapace
  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
  };

  # Atuin
  programs.atuin = {
    enable = true;
    enableNushellIntegration = true;
  };

  # Nushell
  programs.nushell = {
    enable = true;
    configFile.source = "${dotfiles}/nushell/config.nu";
    envFile.source = "${dotfiles}/nushell/env.nu";
  };

  # Nushell helper scripts
  xdg.configFile."nushell/lazyglue.nu".source = "${dotfiles}/nushell/lazyglue.nu";
  xdg.configFile."nushell/aws_lib.nu".source = "${dotfiles}/nushell/aws_lib.nu";

  # Yazi & Dracula theme
  programs.yazi = {
    enable = true;
    enableNushellIntegration = false;
  };
  xdg.configFile."yazi/yazi.toml".source = "${dotfiles}/yazi/yazi.toml";
  xdg.configFile."yazi/keymap.toml".source = "${dotfiles}/yazi/keymap.toml";
  xdg.configFile."yazi/theme.toml".source = "${dotfiles}/yazi/theme.toml";
  xdg.configFile."yazi/flavors/dracula.yazi".source = ./flavors/dracula.yazi;

  # Pgcli
  xdg.configFile."pgcli/config".source = "${dotfiles}/pgcli/config";

  # Direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
