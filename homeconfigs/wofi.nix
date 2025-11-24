{ pkgs, ... }:

{
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
}
