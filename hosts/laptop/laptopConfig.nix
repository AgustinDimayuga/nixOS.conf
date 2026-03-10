{ config, lib, pkgs, ... }:
{
  ##################################
  #      Suspend Then Hibernate   #
  # ################################
  boot.initrd.systemd.enable = true;

  swapDevices = [
    { device = "/swapfile"; }
  ];
  boot.resumeDevice = "/dev/disk/by-uuid/747845f1-0ef0-4885-9a84-7f6a041f92f5";

  boot.kernelParams = [
    "resume=/dev/disk/by-uuid/747845f1-0ef0-4885-9a84-7f6a041f92f5"
    "resume_offset=198744064"
    "mem_sleep_default=s2idle"
  ];
  # suspend-then-hibernate after 30 minutes (tweak as you like)
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=1min
  '';
  # Make sure systemd-logind has control
  services.logind = {
    settings = {
      Login = {
        LidSwitchIgnoreInhibited = "yes";
        HandleLidSwitch = "suspend-then-hibernate";
        HandleLidSwitchExternalPower = "suspend-then-hibernate";
        HandleLidSwitchDocked = "suspend-then-hibernate";
        lidSwitch = "suspend-then-hibernate";
        lidSwitchExternalPower = "suspend-then-hibernate";
        lidSwitchDocked = "suspend-then-hibernate";

      };
    };
  };

  # Disable acpid completely (Hyprland can interfere with it)
  services.acpid.enable = false;

  # generally good to have on
  powerManagement.enable = true;


  ## powermpowerManagement
  services.auto-cpufreq.enable = true;
  services.tlp.enable = false; ## disable if removing auto-freq
  services.power-profiles-daemon.enable = false; ## enable if removing auto-freq
  ## Touchpad
  services.libinput = {
    enable = true;
    touchpad = {
      tapping = true;
      naturalScrolling = true;
      disableWhileTyping = true;
    };
  };
}
