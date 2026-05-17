# home/screensaver.nix
# Drop this into your Home Manager imports list.
# Requires: hyprland, jq, one of (alacritty | ghostty | foot | kitty),
#           and tte available in your PATH (see flake.nix for how to add it).

{ config, pkgs, lib, ... }:

let
  # ── helper: write a bash script to the store and put it on PATH ─────────────
  mkScript = name: text:
    pkgs.writeShellScriptBin name ''
      set -euo pipefail
      ${text}
    '';

  # ── the four scripts ─────────────────────────────────────────────────────────

  # omarchy-screensaver  — inner loop, runs inside the terminal window
  screensaverBin = mkScript "omarchy-screensaver" ''
    SCREENSAVER_TXT="''${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/branding/screensaver.txt"

    screensaver_in_focus() {
      hyprctl activewindow -j | ${pkgs.jq}/bin/jq -e '.class == "org.omarchy.screensaver"' >/dev/null 2>&1
    }

    exit_screensaver() {
      hyprctl eval 'hl.config({ cursor = { invisible = false } })' &>/dev/null \
        || hyprctl keyword cursor:invisible false &>/dev/null \
        || true
      pkill -x tte 2>/dev/null || true
      pkill -f org.omarchy.screensaver 2>/dev/null || true
      exit 0
    }

    trap exit_screensaver SIGINT SIGTERM SIGHUP SIGQUIT

    # Black background
    printf '\033]11;rgb:00/00/00\007'
    hyprctl eval 'hl.config({ cursor = { invisible = true } })' &>/dev/null \
      || hyprctl keyword cursor:invisible true &>/dev/null

    tty=$(tty 2>/dev/null)

    while true; do
      tte -i "$SCREENSAVER_TXT" \
        --frame-rate 120 --canvas-width 0 --canvas-height 0 \
        --reuse-canvas --anchor-canvas c --anchor-text c \
        --random-effect --no-eol --no-restore-cursor &

      while pgrep -t "''${tty#/dev/}" -x tte >/dev/null; do
        if read -n1 -t 1 || ! screensaver_in_focus; then
          exit_screensaver
        fi
      done
    done
  '';

  # omarchy-launch-screensaver  — spawns a fullscreen terminal on every monitor
  launchScreensaverBin = mkScript "omarchy-launch-screensaver" ''
    if ! command -v tte &>/dev/null; then
      echo "tte not found — install terminaltexteffects" >&2
      exit 1
    fi

    # Don't double-spawn
    pgrep -f org.omarchy.screensaver && exit 0

    # Respect the toggle (unless force-started)
    TOGGLE_FILE="''${XDG_DATA_HOME:-$HOME/.local/share}/omarchy/screensaver-off"
    if [[ -f "$TOGGLE_FILE" ]] && [[ "''${1:-}" != "force" ]]; then
      exit 1
    fi

    focused=$(hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | select(.focused) | .name')

    hypr_focus_monitor() {
      hyprctl dispatch "hl.dsp.focus({ monitor = \"$1\" })" >/dev/null 2>&1 \
        || hyprctl dispatch focusmonitor "$1" >/dev/null
    }

    hypr_exec() {
      local cmd="$1"
      hyprctl dispatch "hl.dsp.exec_cmd([[$cmd]])" >/dev/null 2>&1 \
        || hyprctl dispatch exec -- bash -lc "$cmd" >/dev/null
    }

    # Detect the default terminal (prefer what's installed)
    pick_terminal() {
      for t in alacritty ghostty foot kitty; do
        command -v "$t" &>/dev/null && { echo "$t"; return; }
      done
      echo "none"
    }
    terminal=$(pick_terminal)

    for m in $(hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | .name'); do
      hypr_focus_monitor "$m"
      case "$terminal" in
        alacritty)
          ALACRITTY_CFG="''${XDG_DATA_HOME:-$HOME/.local/share}/omarchy/alacritty/screensaver.toml"
          hypr_exec "alacritty --class=org.omarchy.screensaver --config-file $ALACRITTY_CFG -e omarchy-screensaver"
          ;;
        ghostty)
          hypr_exec "ghostty --class=org.omarchy.screensaver --font-size=18 -e omarchy-screensaver"
          ;;
        foot)
          hypr_exec "foot --app-id=org.omarchy.screensaver -e omarchy-screensaver"
          ;;
        kitty)
          hypr_exec "kitty --class=org.omarchy.screensaver --override font_size=18 --override window_padding_width=0 -e omarchy-screensaver"
          ;;
        *)
          ${pkgs.libnotify}/bin/notify-send -u low "✋ Screensaver only runs in Alacritty, Foot, Ghostty, or Kitty"
          ;;
      esac
    done

    hypr_focus_monitor "$focused"
  '';

  # omarchy-toggle-screensaver  — enable / disable the screensaver
  toggleScreensaverBin = mkScript "omarchy-toggle-screensaver" ''
    TOGGLE_FILE="''${XDG_DATA_HOME:-$HOME/.local/share}/omarchy/screensaver-off"
    mkdir -p "$(dirname "$TOGGLE_FILE")"

    if [[ -f "$TOGGLE_FILE" ]]; then
      rm "$TOGGLE_FILE"
      ${pkgs.libnotify}/bin/notify-send -u low "󱄄   Screensaver enabled"
    else
      touch "$TOGGLE_FILE"
      ${pkgs.libnotify}/bin/notify-send -u low "󱄄   Screensaver disabled"
    fi
  '';

  # omarchy-branding-screensaver  — change what's shown (image → ASCII, or plain text)
  brandingScreensaverBin = mkScript "omarchy-branding-screensaver" ''
    SCREENSAVER_TXT="''${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/branding/screensaver.txt"
    SOURCE_DIR="''${XDG_PICTURES_DIR:-$HOME/Pictures}"

    usage() {
      echo "Usage: omarchy-branding-screensaver <image|text|reset>" >&2
      exit 1
    }

    case "''${1:-}" in
      image)
        # Requires: imagemagick (for convert) or jp2a for PNG→ASCII
        # Pick a file with a fuzzy finder — adapt to whatever you have (fzf shown here)
        image=$(find "$SOURCE_DIR" -maxdepth 3 \( -name '*.png' -o -name '*.svg' \) \
          | ${pkgs.fzf}/bin/fzf --prompt "Pick png/svg: ")
        if [[ -n "$image" ]]; then
          # jp2a converts PNG → ASCII; for SVG first rasterise with inkscape/convert
          ${pkgs.jp2a}/bin/jp2a --width=80 "$image" > "$SCREENSAVER_TXT" \
            && omarchy-launch-screensaver force >/dev/null 2>&1
        fi
        ;;
      text)
        # Open in $EDITOR (or fallback to nano)
        "''${EDITOR:-nano}" "$SCREENSAVER_TXT" \
          && omarchy-launch-screensaver force >/dev/null 2>&1
        ;;
      reset)
        cp ${./screensaver.txt} "$SCREENSAVER_TXT" \
          && omarchy-launch-screensaver force >/dev/null 2>&1
        ;;
      *)
        usage
        ;;
    esac
  '';

in {
  # ── expose all four scripts on PATH ─────────────────────────────────────────
  home.packages = [
    screensaverBin
    launchScreensaverBin
    toggleScreensaverBin
    brandingScreensaverBin

    # Runtime deps (add your preferred terminal separately)
    pkgs.jq
    pkgs.libnotify
    pkgs.fzf
    pkgs.jp2a   # PNG → ASCII for the branding script
  ];

  # ── seed the screensaver text on first install ───────────────────────────────
  xdg.configFile."omarchy/branding/screensaver.txt" = {
    source = ./screensaver.txt;   # see screensaver.txt in this folder
    force  = false;               # don't overwrite if the user has customised it
  };

  # ── Alacritty screensaver profile (optional, only if you use Alacritty) ─────
  xdg.dataFile."omarchy/alacritty/screensaver.toml".text = ''
    [colors.primary]
    background = "0x000000"

    [colors.cursor]
    cursor = "0x000000"

    [font]
    size = 18.0

    [window]
    opacity = 1.0
  '';

  # ── Hyprland window rules: make the screensaver truly fullscreen ─────────────
  # Add these to your hyprland config (wayland.windowManager.hyprland.settings)
  # They are shown here as comments so you can paste them in the right place.
  #
  #   windowrulev2 = fullscreen, class:^(org\.omarchy\.screensaver)$
  #   windowrulev2 = noborder, class:^(org\.omarchy\.screensaver)$
  #   windowrulev2 = noblur, class:^(org\.omarchy\.screensaver)$
  #   windowrulev2 = noshadow, class:^(org\.omarchy\.screensaver)$
  #   windowrulev2 = float, class:^(org\.omarchy\.screensaver)$
  #
  # To trigger on idle, add to your hyprland config:
  #   exec-once = hypridle
  # And in your hypridle config (~/.config/hypr/hypridle.conf):
  #   listener {
  #     timeout  = 300           # 5 min of idle
  #     on-timeout = omarchy-launch-screensaver
  #     on-resume  = pkill -f org.omarchy.screensaver
  #   }
}
