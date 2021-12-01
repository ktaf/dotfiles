# home server configuration
{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./services.nix
  ];

  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sda";
  };

  # used by tailscale for exit node
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  networking.hostName = "homesv";

  services = {
    # don't suspend when lid is closed
    logind.lidSwitch = "ignore";

    # keep journal
    journald.extraConfig = lib.mkForce "";
  };

  system.stateVersion = lib.mkForce "21.05";
}
