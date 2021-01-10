{ stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "nuklear";
  version = "4.06.2";

  src = fetchFromGitHub {
    owner = "Immediate-Mode-UI";
    repo = "Nuklear";
    rev = "4a749821c46865e9592fe1437638d89f1b3409da";
    sha256 = "1y01kqzrfdnpj8fpzfp4c1k8knfs0ipgn7jv5d5iflg9lfmjdi10";
  };
  nativeBuildInputs = [ cmake ];
  buildInputs = [ ];

  postUnpack = ''
    ls source
    cp ${./CMakeLists.txt} source/CMakeLists.txt
    cp ${./nuklear.c} source/nuklear.c
  '';
  postInstall = ''
    ln -s $out/lib/libnuklear.so $out/lib/nuklear.so
  '';

  meta = with stdenv.lib; {
    description = "This is a minimal-state, immediate-mode graphical user interface toolkit written in ANSI C and licensed under public domain. ";
    longDescription = ''
      This is a minimal-state, immediate-mode graphical user interface toolkit written in ANSI C and licensed under public domain. It was designed as a simple embeddable user interface for application and does not have any dependencies, a default render backend or OS window/input handling but instead provides a highly modular, library-based approach, with simple input state for input and draw commands describing primitive shapes as output. So instead of providing a layered library that tries to abstract over a number of platform and render backends, it focuses only on the actual UI.
    '';
    homepage = "https://github.com/Immediate-Mode-UI/Nuklear";
    changelog = "https://github.com/Immediate-Mode-UI/Nuklear/CHANGELOG.md";
    license = licenses.publicDomain;
    maintainers = [ "jhc@dismail.de" ];
    platforms = platforms.all;
  };
}
