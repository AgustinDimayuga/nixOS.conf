{ config, pkgs, zen-browser, helium, ... }:
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "agustin";
  home.homeDirectory = "/home/agustin";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.
  imports = [
    #Dracula
    ./homeconfigs/kitty.dracula.nix
    #Gruvbox
    #./homeconfigs/kitty.nix

    # zen-browser.homeModules.twilight
    ./homeconfigs/wofi.nix
    ./homeconfigs/zshrc.nix
    ./homeconfigs/obs.nix
    ./homeconfigs/browserapplications.nix
    zen-browser.homeModules.beta
    # Or: inputs.zen-browser.homeModules.twilight-official
  ];
  programs.zen-browser.enable = true;
  nixpkgs.config.allowUnfree = true;
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    adwaita-qt
    adwaita-qt6
    gruvbox-gtk-theme
    (helium.defaultPackage.${pkgs.system}) # <-- use this

    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello


    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/agustin/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    ##EDITOR = "nvim";
    HYPRSHOT_DIR = "${config.home.homeDirectory}/Pictures/Screenshots";
    # switch to gruvbox pkgs.gruvbox-dark-gtk if failure
    GTK_THEME = "Gruvbox-Dark";
    XCURSOR_THEME = "macOS";
    XCURSOR_SIZE = 20;
  };
  home.pointerCursor = {
    package = pkgs.apple-cursor;
    name = "macOS";
    size = 20;



  };

  # Auto-switch power profile based on AC status
  # systemd.user.services."power-profile-auto" = {
  #   Unit = {
  #     Description = "Auto switch power profile based on AC power";
  #     After = [ "default.target" ];
  #   };
  #   Service = {
  #     Type = "simple";
  #     Restart = "always";
  #     RestartSec = "10s";
  #     ExecStart = pkgs.writeShellScript "power-profile-auto" ''
  #       # Wait for power-profiles-daemon to be ready
  #       while ! ${pkgs.power-profiles-daemon}/bin/powerprofilesctl get &>/dev/null; do
  #         ${pkgs.coreutils}/bin/sleep 2
  #       done
  #
  #       # Now start the main loop
  #       while true; do
  #         if ${pkgs.acpi}/bin/acpi -a | ${pkgs.gnugrep}/bin/grep -q "on-line"; then
  #           ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance 2>/dev/null || true
  #         else
  #           ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver 2>/dev/null || true
  #         fi
  #         ${pkgs.coreutils}/bin/sleep 30
  #       done
  #     '';
  #   };
  #   Install = {
  #     WantedBy = [ "default.target" ];
  #   };
  # };
  programs.git = {
    enable = true;
    userName = "AgustinDimayuga";
    userEmail = "axocuadi@calpoly.edu";
  };

  dconf.enable = true;
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };

  };
  gtk = {
    enable = true;
    # switch to gruvbox pkgs.gruvbox-dark-gtk if failure
    theme.package = pkgs.gruvbox-gtk-theme;
    theme.name = "Gruvbox-Dark-hdpi";
    iconTheme.package = pkgs.gruvbox-gtk-theme;
    iconTheme.name = "Gruvbox-Dark";
  };
  qt = {
    enable = true;
  };
  programs.yazi.enable = true;
  programs.zathura.enable = true;

  home.file."/.config/hypr/hyprland.conf".source = hypr/hyprland.conf;
  home.file."/.config/hypr/hyprlock.conf".source = hypr/hyprlock.conf;
  home.file."/.config/hypr/hypridle.conf".source = hypr/hypridle.conf;
  home.file."/.config/waybar/config.jsonc".source = waybar/config.jsonc;

  home.file."/.config/qutebrowser/config.py".source = qutebrowser/config.py;
  home.file."/.config/yazi/yazi.toml".source = ./yazi/yazi.toml;
  home.file."/.config/yazi/keymap.toml".source = ./yazi/keymap.toml;
  home.file."/.config/hypr/hyprpaper.conf".source = hypr/hyprpaper.conf;

  #Turn on Gruvbox


  #home.file.".tmux.conf".source = tmux/.tmux.conf;
  #home.file.".config/rofi/gruvbox-material.rasi".source = ./rofi/gruvbox.rasi;
  #home.file."/.config/waybar/style.css".source = waybar/style.css;
  #home.file."/.config/zathura/zathurarc".source = ./zathura/zathurarc;
  #home.file."/.config/yazi/theme.toml".source = ./yazi/theme.toml;
  #home.file.".config/rofi/config.rasi".source = ./rofi/config.rasi;

  ## Dracula Theme
  home.file."/.config/waybar/style.css".source = waybar/style.dracula.css;
  home.file."/.config/yazi/theme.toml".source = ./yazi/theme.dracula.toml;
  home.file."/.config/zathura/zathurarc".source = ./zathura/zathurarc.dracula;
  home.file.".config/rofi/gruvbox-material.rasi".source = ./rofi/dracula.rasi;
  home.file.".config/rofi/config.rasi".source = ./rofi/config.dracula.rasi;
  home.file.".tmux.conf".source = ./tmux/.tmux.dracula.conf;
  programs.home-manager.enable = true;

}
