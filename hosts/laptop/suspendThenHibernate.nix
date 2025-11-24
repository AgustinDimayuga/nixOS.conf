{ lib, pkgs, ... }:
{
  ##################################
  #      Suspend Then Hibernate   #
  # ################################
  networking.hostName = "laptop";
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
    HibernateDelaySec=30min
  '';
  # Make sure systemd-logind has control
  services.logind = {
    lidSwitch = "suspend-then-hibernate";
    lidSwitchExternalPower = "suspend-then-hibernate";
    lidSwitchDocked = "suspend-then-hibernate";
    extraConfig = ''
      LidSwitchIgnoreInhibited=yes
      HandleLidSwitch=suspend-then-hibernate
    '';
  };

  # Disable acpid completely (Hyprland can interfere with it)
  services.acpid.enable = false;

  # generally good to have on
  powerManagement.enable = true;
}
