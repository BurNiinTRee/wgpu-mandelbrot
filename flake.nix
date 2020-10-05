{
  description = "A very basic flake";

  inputs.import-cargo.url = "github:edolstra/import-cargo";

  outputs = { self, nixpkgs, import-cargo }:
    let
      build = release:

        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          importCargo = import-cargo.builders.importCargo;
          desktopFile = pkgs.makeDesktopItem {
            name = "wgpu-mandelbrot";
            exec = "@out@/bin/wgpu-mandelbrot";
            comment = "A simple mandelbrot renderer using wgpu";
            desktopName = "Mandelbrot";
            categories = "Game;";
          };
          libPath = pkgs.lib.makeLibraryPath [
            pkgs.libxkbcommon
            pkgs.vulkan-loader
            pkgs.wayland
          ];
          cargo-import = (importCargo {
            lockFile = ./Cargo.lock;
            inherit pkgs;
          });
        in pkgs.stdenv.mkDerivation {
          name = "wgpu-mandelbrot";
          src = self;

          dontUseCmakeConfigure = true;

          nativeBuildInputs = [
            cargo-import.cargoHome

            pkgs.rustc
            pkgs.cargo
            pkgs.pkgconfig
          ];
          buildInputs = [
            pkgs.makeWrapper
            pkgs.xorg.libX11
            pkgs.xorg.libXrandr
            pkgs.xorg.libXi
            pkgs.xorg.libXcursor
            pkgs.mesa
            pkgs.vulkan-loader
          ];
          buildPhase = ''
            cargo build --offline ${if release then "--release" else ""}
          '';
          installPhase = ''
            install -Dm775 ./target/${
              if release then "release" else "debug"
            }/wgpu-mandelbrot $out/bin/wgpu-mandelbrot

            wrapProgram $out/bin/wgpu-mandelbrot --suffix LD_LIBRARY_PATH : "${libPath}"

            mkdir -p $out/share/applications
            substituteAll ${desktopFile}/share/applications/wgpu-mandelbrot.desktop \
              $out/share/applications/wgpu-mandelbrot.dekstop
          '';

          shellHook = ''
            export CARGO_HOME=${cargo-import.vendorDir}/vendor
            export LD_LIBRARY_PATH="${libPath}";
          '';
          SHADERC_LIB_DIR = "${pkgs.shaderc.static}/lib";
        };
    in {

      packages.x86_64-linux = {
        debug = build false;
        release = build true;
      };

      defaultPackage.x86_64-linux = self.packages.x86_64-linux.release;
    };
}
