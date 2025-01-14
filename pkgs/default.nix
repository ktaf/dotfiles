{
  systems = ["x86_64-linux"];

  perSystem = {pkgs, ...}: {
    packages = {
      # instant repl with automatic flake loading
      repl = pkgs.callPackage ./repl {};

      catppuccin-plymouth = pkgs.callPackage ./catppuccin-plymouth {};

      gdb-frontend = pkgs.callPackage ./gdb-frontend {};

      howdy = pkgs.callPackage ./howdy {};

      linux-enable-ir-emitter = pkgs.callPackage ./linux-enable-ir-emitter {};

      waveform = pkgs.callPackage ./waveform {};
    };
  };
}
