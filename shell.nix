with import ./nix/pkgs.nix {
    config = {
      packageOverrides = pkgs: {
        dmd = pkgs.callPackage ./nix/dmd {};
        ldc = pkgs.callPackage ./nix/ldc {};
      };
    };
  };

stdenv.mkDerivation rec {
  name = "treerender-d-env";
  env = buildEnv { name = name; paths = buildInputs; };

  LD_LIBRARY_PATH="/run/opengl-driver/lib:/run/opengl-driver-32/lib:${libGL}/lib";
  buildInputs = [
    dmd
    ldc
    dub
    SDL2
    SDL2_mixer
    SDL2_image
    SDL2_ttf
    valgrind
    kdeApplications.kcachegrind
    pkg-config
    libGL
    renderdoc
  ];
}
