{
  config,
  lib,
  ...
}:
# networking configuration
{
  networking = {
    firewall = {
      trustedInterfaces = ["tailscale0"];
      # required to connect to Tailscale exit nodes
      checkReversePath = "loose";

      allowedUDPPorts = [
        # allow the Tailscale UDP port through the firewall
        config.services.tailscale.port
        5353
      ];

      allowedTCPPorts = [
        42355
      ];
    };

    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      wifi.powersave = true;
    };
  };

  services = {
    # network discovery, mDNS
    avahi = {
      enable = true;
      nssmdns = true;
      publish = {
        enable = true;
        domain = true;
        userServices = true;
      };
    };

    openssh = {
      enable = true;
      settings.UseDns = true;
    };

    # DNS resolver
    resolved.enable = true;

    # inter-machine VPN
    tailscale.enable = true;
  };

  # Don't wait for network startup
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
}
