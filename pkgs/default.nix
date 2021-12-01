{ inputs }:

final: prev: {
  clightd = prev.clightd.overrideAttrs (o: { src = inputs.clightd; });

  legendary-gl = prev.legendary-gl.overrideAttrs (o: rec {
    version = "0.20.9";
    src = prev.fetchFromGitHub {
      owner = "derrod";
      repo = "legendary";
      rev = version;
      sha256 = "sha256-22IxUAIMZxe3VhOE5460MTT0t+UWRtsNdPbakQ7dv8Y=";
    };
  });

  orchis-theme = prev.callPackage ./orchis-theme { };

  picom = prev.picom.overrideAttrs (old: {
    version = "unstable-2021-08-04";
    src = inputs.picom;
  });

  spotify-adblock = prev.callPackage ./spotify-adblock/wrapper.nix {
    spotify-adblocker = prev.callPackage ./spotify-adblock { };
  };

  technic-launcher = prev.callPackage ./technic.nix { };

  xwayland = prev.xwayland.overrideAttrs ({ patches ? [ ], ... }: {
    preConfigure = ''
      patch -p1 < ${./xwayland.patch}
    '';
  });
}
