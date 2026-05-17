# home/screensaver.nix
#
# Simple Omarchy-style TTE screensaver for Hyprland.
#
# Add to your Home Manager imports:
#   imports = [ ./home/screensaver.nix ];
#
# Requirements:
#   - Hyprland
#   - hypridle
#   - jq
#   - terminaltexteffects (tte)
#   - one terminal:
#       kitty / foot / ghostty / alacritty
#
# Recommended Hyprland rules:
#
# windowrulev2 = fullscreen, class:^(org\.omarchy\.screensaver)$
# windowrulev2 = float, class:^(org\.omarchy\.screensaver)$
# windowrulev2 = noborder, class:^(org\.omarchy\.screensaver)$
# windowrulev2 = noanim, class:^(org\.omarchy\.screensaver)$
# windowrulev2 = noblur, class:^(org\.omarchy\.screensaver)$
# windowrulev2 = noshadow, class:^(org\.omarchy\.screensaver)$
# windowrulev2 = pin, class:^(org\.omarchy\.screensaver)$
#
# Example hypridle:
#
# listener {
#   timeout = 300
#   on-timeout = omarchy-launch-screensaver
#   on-resume = pkill -f org.omarchy.screensaver
# }

{ config, pkgs, lib, ... }:

let
  mkScript = name: text:
    pkgs.writeShellScriptBin name ''
      set -euo pipefail
      ${text}
    '';

  #
  # Main screensaver process
  #
  omarchyScreensaver = mkScript "omarchy-screensaver" ''

  SCREENSAVER_TEXT="$HOME/.config/omarchy/branding/screensaver.txt"

  screensaver_in_focus() {
    hyprctl activewindow -j \
      | jq -e '.class == "org.omarchy.screensaver"' >/dev/null 2>&1
  }

  cleanup() {
    hyprctl keyword cursor:invisible false >/dev/null 2>&1 || true
    pkill -x tte 2>/dev/null || true
  }
  trap cleanup EXIT INT TERM

  printf '\033]11;rgb:00/00/00\007'
  hyprctl keyword cursor:invisible true >/dev/null 2>&1 || true

# run ONE tte instance
  tte \
    -i "$SCREENSAVER_TEXT" \
    --frame-rate 60 \
    --canvas-width 0 \
    --canvas-height 0 \
    --reuse-canvas \
    --anchor-canvas c \
    --anchor-text c \
    --random-effect \
    --no-eol \
    --no-restore-cursor
    '';

  #
  # Launch fullscreen terminal on every monitor
  #
  launchScreensaver = mkScript "omarchy-launch-screensaver" ''
    if ! command -v tte >/dev/null 2>&1; then
      notify-send "tte not installed"
      exit 1
    fi

    # Prevent double launch
    pgrep -f org.omarchy.screensaver >/dev/null && exit 0

    TOGGLE_FILE="$HOME/.local/share/omarchy/screensaver-off"

    if [[ -f "$TOGGLE_FILE" ]] && [[ "''${1:-}" != "force" ]]; then
      exit 0
    fi

    pick_terminal() {
      for term in kitty foot ghostty alacritty; do
        if command -v "$term" >/dev/null 2>&1; then
          echo "$term"
          return
        fi
      done

      echo "none"
    }

    TERMINAL="$(pick_terminal)"

    focus_monitor() {
      hyprctl dispatch focusmonitor "$1" >/dev/null 2>&1 || true
    }

    exec_on_monitor() {
      hyprctl dispatch exec "$1" >/dev/null 2>&1 || true
    }

    CURRENT_MONITOR="$(
      hyprctl monitors -j \
        | ${pkgs.jq}/bin/jq -r '.[] | select(.focused) | .name'
    )"

    for MONITOR in $(
      hyprctl monitors -j \
        | ${pkgs.jq}/bin/jq -r '.[].name'
    ); do

      focus_monitor "$MONITOR"

      case "$TERMINAL" in
        kitty)
          exec_on_monitor \
            "kitty \
              --class org.omarchy.screensaver \
              --override background_opacity=1.0 \
              --override font_size=18 \
              --override confirm_os_window_close=0 \
              -e omarchy-screensaver"
          ;;

        foot)
          exec_on_monitor \
            "foot \
              --app-id org.omarchy.screensaver \
              -e omarchy-screensaver"
          ;;

        ghostty)
          exec_on_monitor \
            "ghostty \
              --class org.omarchy.screensaver \
              --font-size=18 \
              -e omarchy-screensaver"
          ;;

        alacritty)
          exec_on_monitor \
            "alacritty \
              --class org.omarchy.screensaver \
              -e omarchy-screensaver"
          ;;

        *)
          notify-send \
            "No supported terminal found" \
            "Install kitty, foot, ghostty, or alacritty"

          exit 1
          ;;
      esac
    done

    focus_monitor "$CURRENT_MONITOR"
  '';

  #
  # Toggle enable/disable
  #
  toggleScreensaver = mkScript "omarchy-toggle-screensaver" ''
    TOGGLE_FILE="$HOME/.local/share/omarchy/screensaver-off"

    mkdir -p "$(dirname "$TOGGLE_FILE")"

    if [[ -f "$TOGGLE_FILE" ]]; then
      rm "$TOGGLE_FILE"

      ${pkgs.libnotify}/bin/notify-send \
        -u low \
        "󱄄   Screensaver enabled"
    else
      touch "$TOGGLE_FILE"

      ${pkgs.libnotify}/bin/notify-send \
        -u low \
        "󱄄   Screensaver disabled"
    fi
  '';

  #
  # Edit/reset branding text
  #
  brandingScreensaver = mkScript "omarchy-branding-screensaver" ''
    SCREEN_FILE="$HOME/.config/omarchy/branding/screensaver.txt"

    usage() {
      echo "usage:"
      echo "  omarchy-branding-screensaver edit"
      echo "  omarchy-branding-screensaver reset"
      exit 1
    }

    case "''${1:-}" in
      edit)
        "''${EDITOR:-nano}" "$SCREEN_FILE"

        omarchy-launch-screensaver force >/dev/null 2>&1 || true
        ;;

      reset)
        cp ${./screensaver.txt} "$SCREEN_FILE"

        omarchy-launch-screensaver force >/dev/null 2>&1 || true
        ;;

      *)
        usage
        ;;
    esac
  '';

in
{
  home.packages = with pkgs; [
    omarchyScreensaver
    launchScreensaver
    toggleScreensaver
    brandingScreensaver

    jq
    libnotify
  ];

  #
  # Default text file
  #
  xdg.configFile."omarchy/branding/screensaver.txt" = {
    source = ./screensaver.txt;
    force = false;
  };
}
