{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    naersk = {
      url = "github:nmattia/naersk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, fenix, utils, naersk }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
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
        build = (naersk.lib.${system}.override {
          inherit (fenix.packages.${system}.minimal) cargo rustc;
        }).buildPackage {
          name = "wgpu-mandelbrot";
          version = "0.1.0";
          src = self;
          nativeBuildInputs = [
            pkgs.makeWrapper
            pkgs.pkgconfig
          ];
          buildInputs = [
            pkgs.xorg.libX11
            pkgs.xorg.libXrandr
            pkgs.xorg.libXi
            pkgs.xorg.libXcursor
            pkgs.mesa
            pkgs.vulkan-loader
          ];
          SHADERC_LIB_DIR = pkgs.shaderc.static + "/lib";
          overrideMain = old: old // {
            postInstall = ''
              wrapProgram $out/bin/wgpu-mandelbrot --suffix LD_LIBRARY_PATH : "${libPath}"

              mkdir -p $out/share/applications
              substituteAll ${desktopFile}/share/applications/wgpu-mandelbrot.desktop \
                $out/share/applications/wgpu-mandelbrot.desktop
            '';
          };
        };

      in
      {
        packages.wgpu-mandelbrot = build;
        defaultPackage = self.packages.${system}.wgpu-mandelbrot;
        devShell = pkgs.mkShell {
          inputsFrom = [ self.defaultPackage.${system} ];
          buildInputs = [ pkgs.crate2nix ];
        };
      }
    );
}
