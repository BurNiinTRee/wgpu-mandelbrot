let pkgs = import <nixpkgs> {};
in
pkgs.mkShell {
  name = "wgpu";
  buildInputs = with pkgs; [
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXi
    xorg.libX11
    mesa
    vulkan-loader
  ];
  nativeBuildInputs = with pkgs; [
    cargo
    cmake
    pkgconfig
    python3
  ];
  SHADERC_LIB_DIR = "${pkgs.shaderc.static}/lib";
  LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ pkgs.libxkbcommon pkgs.vulkan-loader pkgs.wayland ];
}
