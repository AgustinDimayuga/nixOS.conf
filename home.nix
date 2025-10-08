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
  nixpkgs.config.allowUnfree = true;
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
    XCURSOR_THEME = "macOS";
    XCURSOR_SIZE = 20;
  };
  home.pointerCursor = {
    package = pkgs.apple-cursor;
    name = "macOS";
    size = 20;



  };

  xdg.desktopEntries = {
    notion = {
      name = "Notion";
      genericName = "Workspace";
      comment = "Notion web app";
      exec = "firefox --new-window https://www.notion.so";
      terminal = false;
      categories = [ "Office" "Utility" ];
      icon = ./icons/notion.png;
    };

    outlook = {
      name = "Outlook";
      genericName = "Mail";
      comment = "Outlook web app";
      exec = "firefox --new-window outlook.office.com";
      terminal = false;
      categories = [ "Office" "Email" ];
      icon = ./icons/Outlook.png;
    };
    chatgpt = {
      name = "ChatGPT";
      genericName = "AI Assistant";
      comment = "ChatGPT web app";
      # swap 'chromium' for brave/google-chrome/ungoogled-chromium if you prefer
      exec = "chromium --new-window --app=https://chat.openai.com/ --class ChatGPT";
      terminal = false;
      categories = [ "Network" "Utility" ];
      icon = ./icons/chatGPT.png;
    };
    claude = {
      name = "Claude";
      genericName = "AI Assistant";
      comment = "Claude web app";
      exec = "chromium --new-window --app=https://claude.ai/ --class Claude";
      terminal = false;
      categories = [ "Network" "Utility" ];
      icon = ./icons/Claude.png;
    };
  };
  # Auto-switch power profile based on AC status
  systemd.user.services."power-profile-auto" = {
    Unit = {
      Description = "Auto switch power profile based on AC power";
      After = [ "default.target" ];
    };
    Service = {
      Type = "simple";
      Restart = "always";
      RestartSec = "10s";
      ExecStart = pkgs.writeShellScript "power-profile-auto" ''
        # Wait for power-profiles-daemon to be ready
        while ! ${pkgs.power-profiles-daemon}/bin/powerprofilesctl get &>/dev/null; do
          ${pkgs.coreutils}/bin/sleep 2
        done
    
        # Now start the main loop
        while true; do
          if ${pkgs.acpi}/bin/acpi -a | ${pkgs.gnugrep}/bin/grep -q "on-line"; then
            ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance 2>/dev/null || true
          else
            ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver 2>/dev/null || true
          fi
          ${pkgs.coreutils}/bin/sleep 30
        done
      '';
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
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

    # This writes ~/.config/wofi/config
    settings = {
      width = 500;
      height = 350;
      location = "center";
      show = "drun";
      prompt = "Search...";
      filter_rate = 100;
      allow_markup = true;
      no_actions = true;
      halign = "fill";
      orientation = "vertical";
      content_halign = "fill";
      insensitive = true;
      allow_images = true;
      image_size = 35;
      gtk_dark = true;
      dynamic_lines = true;
    };

    # This writes ~/.config/wofi/style.css
    style = ''
      * {
        font-family: "JetBrains Mono", monospace;
        font-size: 12pt;
        border-radius: @;
      }

      window {
        margin: 0;
        padding: 8px;
        border: 1px solid #928374;
        background-color: #282828; /* gruvbox bg0 */
      }

      #outer-box, #inner-box, #scroll {
        background-color: #282828;
        border: none;
        margin: 0;
        padding: 0;
      }

      #input {
        margin: 8px;
        padding: 8px 10px;
        border: none;
        color: #ebdbb2;          /* fg1 */
        background-color: #1d2021; /* bg0_h */
        box-shadow: none;
      }

      #img {
        margin-right: 8px;
      }

      #entry {
        margin: 4px 8px;
        padding: 8px 10px;
        border: none;
        background-color: transparent;
        color: #ebdbb2;
      }

      #entry:selected {
        background-color: #1d2021;
        color: #fbf1c7;          /* fg0 */
        outline: 1px solid #928374;
      }

      #text {
        margin: 0;
        color: inherit;
      }

      #prompt {
        color: #d79921;          /* yellow */
        margin-left: 8px;
        margin-bottom: 4px;
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
      name = "JetBrains Mono";
      size = 14;
    };
    settings = {
      background_opacity = 1;
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
  home.file."/.config/qutebrowser/config.py".source = qutebrowser/config.py;
  home.file."/.config/hypr/hyprpaper.conf".source = hypr/hyprpaper.conf;
  home.file."/.config/yazi/theme.toml".source = ./yazi/theme.toml;
  home.file."/.config/yazi/yazi.toml".source = ./yazi/yazi.toml;
  home.file."/.config/yazi/keymap.toml".source = ./yazi/keymap.toml;
  home.file."/.config/zathura/zathurarc".source = ./zathura/zathurarc;
  home.file.".config/rofi/config.rasi".source = ./rofi/config.rasi;
  home.file.".config/rofi/gruvbox-material.rasi".source = ./rofi/gruvbox.rasi;

  programs.home-manager.enable = true;

}
