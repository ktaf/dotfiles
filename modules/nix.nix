{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  environment.systemPackages = [
    # we need git for flakes
    pkgs.git
    # cool helper for rebuild
    inputs.nh.packages.${pkgs.system}.default
  ];
  environment.variables.FLAKE = "/home/mihai/Documents/code/dotfiles";

  nix = {
    # extra builders to offload work onto
    # don't set a machine as a builder to itself (throws warnings)
    buildMachines = lib.filter (x: x.hostName != config.networking.hostName) [
      {
        system = "aarch64-linux";
        sshUser = "root";
        sshKey = "/etc/ssh/ssh_host_ed25519_key";
        maxJobs = 4;
        hostName = "arm-server";
        supportedFeatures = ["nixos-test" "benchmark" "kvm" "big-parallel"];
      }
    ];
    distributedBuilds = true;

    # auto garbage collect
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    # pin the registry to avoid downloading and evaling a new nixpkgs version every time
    registry = lib.mapAttrs (_: v: {flake = v;}) inputs;

    # set the path for channels compat
    nixPath = lib.mapAttrsToList (key: _: "${key}=flake:${key}") config.nix.registry;

    settings = {
      auto-optimise-store = true;
      builders-use-substitutes = true;
      experimental-features = ["nix-command" "flakes"];
      flake-registry = "/etc/nix/registry.json";

      # for direnv GC roots
      keep-derivations = true;
      keep-outputs = true;

      substituters = [
        "https://nix-community.cachix.org"
        "https://helix.cachix.org"
        "https://fufexan.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
        "fufexan.cachix.org-1:LwCDjCJNJQf5XD2BV+yamQIMZfcKWR9ISIFy5curUsY="
      ];

      trusted-users = ["root" "@wheel"];
    };
  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      (
        _: prev: {
          steam = prev.steam.override {
            extraPkgs = pkgs:
              with pkgs; [
                keyutils
                libkrb5
                libpng
                libpulseaudio
                libvorbis
                stdenv.cc.cc.lib
                xorg.libXcursor
                xorg.libXi
                xorg.libXinerama
                xorg.libXScrnSaver
              ];
            extraProfile = "export GDK_SCALE=2";
          };

          greetd =
            prev.greetd
            // {
              regreet = prev.greetd.regreet.overrideAttrs (oldAttrs: rec {
                version = "0.1.1-patched";
                src = prev.fetchFromGitHub {
                  owner = "rharish101";
                  repo = "ReGreet";
                  rev = "61d871a0ee5c74230dfef8100d0c9bc75b309203";
                  hash = "sha256-PkQTubSm/FN3FXs9vBB3FI4dXbQhv/7fS1rXkVsTAAs=";
                };
                cargoDeps = oldAttrs.cargoDeps.overrideAttrs (_: {
                  inherit src;
                  outputHash = "sha256-dR6veXCGVMr5TbCvP0EqyQKTG2XM65VHF9U2nRWyzfA=";
                });

                # temp fix until https://github.com/NixOS/nixpkgs/pull/249384 is merged
                nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [prev.wrapGAppsHook];
                buildInputs = oldAttrs.buildInputs ++ [prev.librsvg];

                # temp fix until https://github.com/rharish101/ReGreet/issues/32 is solved
                patches = [../pkgs/regreet.patch];
              });
            };

          # temp fix until https://github.com/NixOS/nixpkgs/pull/249382 is merged
          gtklock = prev.gtklock.overrideAttrs (old: {
            nativeBuildInputs = old.nativeBuildInputs ++ [prev.wrapGAppsHook];
            buildInputs = old.buildInputs ++ [prev.librsvg];
          });
        }
      )
    ];
  };
}
