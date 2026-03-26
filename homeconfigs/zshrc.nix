{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    initContent = ''
      bindkey -v
      export EDITOR=nvim
      fastfetch
      export PATH="$HOME/.emacs.d/bin:$PATH"
    '';
  };
}
