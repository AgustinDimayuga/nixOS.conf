{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    initContent = ''
      bindkey -v
      export EDITOR=nvim
      fastfetch
    '';
  };
}
