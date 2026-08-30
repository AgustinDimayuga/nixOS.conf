# home/screensaver.nix
{ config, pkgs, lib, ... }:

let
  mkScript = name: text:
    pkgs.writeShellScriptBin name ''
      set -euo pipefail
      ${text}
    '';

  omarchyScreensaver = mkScript "omarchy-screensaver" ''
    SCREENSAVER_TEXT="$HOME/.config/omarchy/branding/screensaver.txt"

    screensaver_in_focus() {
      hyprctl activewindow -j \
        | jq -e '.class == "org.omarchy.screensaver"' >/dev/null 2>&1
    }

    exit_screensaver() {
      hyprctl keyword cursor:invisible false >/dev/null 2>&1 || true
      pkill -x tte 2>/dev/null || true
      exit 0
    }

    trap exit_screensaver SIGINT SIGTERM SIGHUP SIGQUIT EXIT

    printf '\033]11;rgb:00/00/00\007'

    hyprctl keyword cursor:invisible true >/dev/null 2>&1 || true

    # Give Hyprland/terminal a moment to actually focus the screensaver window.
    for _ in $(seq 1 20); do
      screensaver_in_focus && break
      sleep 0.05
    done

    tty="$(tty 2>/dev/null || true)"

    while true; do
      tte -i "$SCREENSAVER_TEXT" \
        --frame-rate 120 \
        --canvas-width 0 \
        --canvas-height 0 \
        --reuse-canvas \
        --anchor-canvas c \
        --anchor-text c \
        --random-effect \
        --no-eol \
        --no-restore-cursor &

      tte_pid="$!"

      while kill -0 "$tte_pid" 2>/dev/null; do
        if read -n1 -t 1 || ! screensaver_in_focus; then
          exit_screensaver
        fi
      done
    done
  '';

  launchScreensaver = mkScript "omarchy-launch-screensaver" ''
    if ! command -v tte >/dev/null 2>&1; then
      notify-send "tte not installed"
      exit 1
    fi

    pgrep -f org.omarchy.screensaver >/dev/null 2>&1 && exit 0

    TOGGLE_FILE="$HOME/.local/share/omarchy/screensaver-off"

    if [[ -f "$TOGGLE_FILE" ]] && [[ "''${1:-}" != "force" ]]; then
      exit 0
    fi

    command -v walker >/dev/null 2>&1 && walker -q || true

    focused="$(
      hyprctl monitors -j \
        | jq -r '.[] | select(.focused) | .name'
    )"

    pick_terminal() {
      for term in kitty ghostty alacritty foot; do
        if command -v "$term" >/dev/null 2>&1; then
          echo "$term"
          return
        fi
      done

      echo "none"
    }

    terminal="$(pick_terminal)"

    for monitor in $(
      hyprctl monitors -j \
        | jq -r '.[].name'
    ); do
      hyprctl dispatch focusmonitor "$monitor" >/dev/null 2>&1 || true

      case "$terminal" in
        kitty)
          hyprctl dispatch exec -- \
            kitty \
              --class org.omarchy.screensaver \
              --override font_size=18 \
              --override window_padding_width=0 \
              --override confirm_os_window_close=0 \
              -e omarchy-screensaver
          ;;

        ghostty)
          hyprctl dispatch exec -- \
            ghostty \
              --class=org.omarchy.screensaver \
              --font-size=18 \
              -e omarchy-screensaver
          ;;

        alacritty)
          hyprctl dispatch exec -- \
            alacritty \
              --class=org.omarchy.screensaver \
              -e omarchy-screensaver
          ;;

        foot)
          hyprctl dispatch exec -- \
            foot \
              --app-id org.omarchy.screensaver \
              -e omarchy-screensaver
          ;;

        *)
          notify-send \
            "No supported terminal found" \
            "Install kitty, ghostty, alacritty, or foot"
          exit 1
          ;;
      esac
    done

    hyprctl dispatch focusmonitor "$focused" >/dev/null 2>&1 || true
  '';

  toggleScreensaver = mkScript "omarchy-toggle-screensaver" ''
    TOGGLE_FILE="$HOME/.local/share/omarchy/screensaver-off"

    mkdir -p "$(dirname "$TOGGLE_FILE")"

    if [[ -f "$TOGGLE_FILE" ]]; then
      rm "$TOGGLE_FILE"
      notify-send -u low "󱄄   Screensaver enabled"
    else
      touch "$TOGGLE_FILE"
      notify-send -u low "󱄄   Screensaver disabled"
    fi
  '';

  brandingScreensaver = mkScript "omarchy-branding-screensaver" ''
    SCREEN_FILE="$HOME/.config/omarchy/branding/screensaver.txt"

    mkdir -p "$(dirname "$SCREEN_FILE")"

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
        echo "usage:"
        echo "  omarchy-branding-screensaver edit"
        echo "  omarchy-branding-screensaver reset"
        exit 1
        ;;
    esac
  '';
  omarchyBrightnessDisplay = mkScript "omarchy-brightness-display" ''
    step="''${1:-+5%}"

    if [[ "$step" == "off" ]]; then
      hyprctl dispatch dpms off >/dev/null 2>&1
      exit 0
    elif [[ "$step" == "on" ]]; then
      hyprctl dispatch dpms on >/dev/null 2>&1
      exit 0
    fi

    runtime_dir="''${XDG_RUNTIME_DIR:-/tmp}"
    exec 9>"$runtime_dir/omarchy-brightness-display.lock"
    flock -n 9 || exit 0

    device="$(ls -1 /sys/class/backlight 2>/dev/null | head -n1)"

    for candidate in amdgpu_bl* intel_backlight acpi_video*; do
      if [[ -e /sys/class/backlight/$candidate ]]; then
        device="$candidate"
        break
      fi
    done

    if [[ -z "''${device:-}" ]]; then
      notify-send "No backlight device found"
      exit 1
    fi

    current="$(brightnessctl -d "$device" -m | cut -d',' -f4 | tr -d '%')"

    if [[ "$step" == "+5%" ]]; then
      if (( current < 5 )); then
        (( target = current + 1 ))
      else
        (( target = current + 5 ))
      fi
      (( target > 100 )) && target=100
      step="$target%"
    elif [[ "$step" == "5%-" ]]; then
      if (( current <= 5 )); then
        (( target = current - 1 ))
      else
        (( target = current - 5 ))
      fi
      (( target < 1 )) && target=1
      step="$target%"
    fi

    brightnessctl -d "$device" set "$step" >/dev/null

    if command -v omarchy-swayosd-brightness >/dev/null 2>&1; then
      omarchy-swayosd-brightness "$(brightnessctl -d "$device" -m | cut -d',' -f4 | tr -d '%')"
    fi
  '';

  omarchySystemLock = mkScript "omarchy-system-lock" ''
    if ! pidof hyprlock >/dev/null; then
      (
        hyprlock
        command -v omarchy-system-wake >/dev/null 2>&1 && omarchy-system-wake
      ) &
    fi

    hyprctl switchxkblayout all 0 >/dev/null 2>&1 || true

    if pgrep -x "1password" >/dev/null 2>&1; then
      1password --lock &
    fi

    pkill -f org.omarchy.screensaver 2>/dev/null || true

    if [[ "''${OMARCHY_LOCK_ONLY:-false}" != "true" ]]; then
      (
        sleep 3
        pidof hyprlock >/dev/null || exit 0

        command -v omarchy-brightness-keyboard >/dev/null 2>&1 &&
          omarchy-brightness-keyboard off

        omarchy-brightness-display off
      ) &
    fi
  '';
  omarchySystemWake = mkScript "omarchy-system-wake" ''
    omarchy-brightness-display on

    if command -v omarchy-brightness-keyboard >/dev/null 2>&1; then
      omarchy-brightness-keyboard restore
    fi
  '';

in
{
  home.packages = with pkgs; [
    omarchyScreensaver
    launchScreensaver
    toggleScreensaver
    brandingScreensaver
    omarchyBrightnessDisplay
    omarchySystemLock
    omarchySystemWake

    jq
    libnotify
    brightnessctl
    util-linux
    hyprlock
  ];

  xdg.configFile."omarchy/branding/screensaver.txt" = {
    source = ./screensaver.txt;
    force = false;
  };
}
