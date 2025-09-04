{ config, pkgs, zen-browser, ... }:
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
    # zen-browser.homeModules.twilight
    zen-browser.homeModules.beta
    # Or: inputs.zen-browser.homeModules.twilight-official
  ];
  programs.zen-browser.enable = true;
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    adwaita-qt
    adwaita-qt6
    gruvbox-gtk-theme

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
  };
  programs.zsh = {
    enable = true;
    initContent = ''
      bindkey -v
      export EDITOR=nvim
    '';
  };
  programs.git = {
    enable = true;
    userName = "AgustinDimayuga";
    userEmail = "axocuadi@calpoly.edu";

  };
  programs.wofi = {
    enable = true;
    style = ''
      * 
      window {
        margin: 0px;
        border: 1px solid #928374;
        background-color: #282828;
        }

        #input {
        margin: 5px;
        border: none;
        color: #ebdbb2;
        background-color: #1d2021;
        }

        #inner-box {
        margin: 5px;
        border: none;
        background-color: #282828;
        }

        #outer-box {
        margin: 5px;
        border: none;
        background-color: #282828;
        }

        #scroll {
        margin: 0px;
        border: none;
        }

        #text {
        margin: 5px;
        border: none;
        color: #ebdbb2;
        }

        #entry:selected {
        background-color: #1d2021;
        }
    '';



  };
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
    ];
  };
  programs.kitty = {
    enable = true;
    font = {
      name = "Hack Nerd Font";
      size = 14;
    };
    settings = {
      background_opacity = 0.9;
      sync_to_monitor = true;
      cursor = "#928374";
      cursor_text_color = "background";
      url_color = "#83a598";
      visual_bell_color = "#8ec07c";
      bell_border_color = "#8ec07c";
      active_border_color = "#d3869b";
      inactive_border_color = "#665c54";
      foreground = "#ebdbb2";
      background = "#282828";
      selection_foreground = "#928374";
      selection_background = "#ebdbb2";
      active_tab_foreground = "#fbf1c7";
      active_tab_background = "#665c54";
      inactive_tab_foreground = "#a89984";
      inactive_tab_background = "#3c3836";
      # black
      color0 = "#665c54";
      color8 = "#7c6f64";
      # red 
      color1 = "#cc241d";
      color9 = "#fb4934";
      # green
      color2 = "#98971a";
      color10 = "#b8bb26";
      # yeloow
      color3 = "#d79921";
      color11 = "#fabd2f";
      # blue
      color4 = "#458588";
      color12 = "#83a598";
      #purple
      color5 = "#b16286";
      color13 = "#d3869b";
      #aqua
      color6 = "#689d6a";
      color14 = "#8ec07c";
      #White
      color7 = "#a89984";
      color15 = "#bdae93";

    };


    keybindings = {
      "ctrl+c" = "copy_or_interrupt";
      "ctrl+v" = "paste_from_clipboard";


    };

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

  #Turn on Dark Theme 
  home.file."/.config/hypr/hyprland.conf".source = hypr/hyprland.conf;
  home.file.".tmux.conf".source = tmux/.tmux.conf;
  home.file."/.config/waybar/config.jsonc".source = waybar/config.jsonc;
  home.file."/.config/waybar/style.css".source = waybar/style.css;
  programs.home-manager.enable = true;
  home.file."/.config/qutebrowser/config.py".source = qutebrowser/config.py;
  home.file."/.config/hypr/hyprpaper.conf".source = hypr/hyprpaper.conf;
  home.file."/.config/yazi/theme.toml".source = ./yazi/theme.toml;
  home.file."/.config/yazi/yazi.toml".source = ./yazi/yazi.toml;
  home.file."/.config/yazi/keymap.toml".source = ./yazi/keymap.toml;
  home.file."/.config/zathura/zathurarc".source = ./zathura/zathurarc;

}
