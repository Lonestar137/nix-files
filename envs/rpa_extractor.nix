# Usage: nix-shell ./rpa_extractor.nix
# Source: https://nixos.wiki/wiki/DotNET
# RPA Extract: https://github.com/Kaskadee/rpaextract
# ./rpaextract -f ./archive.rpa -x

with import <nixpkgs> {};

let rpaextract = stdenv.mkDerivation rec {
  pname = "rpaextract";
  version = "1.4.1";
  src = fetchzip {
    url = "https://github.com/Kaskadee/rpaextract/releases/download/v${version}/rpaextract-v${version}-linux-x64.zip";
    sha256 = "sha256-tpuQGGiTZLFODDO4sw+NaHPP4dxLOfKdpbqpUgj+Zz4=";
    stripRoot = false;
  };

  # nativeBuildInputs = [ unzip ];

  # unpackPhase = ''
  #   mkdir -p $out/bin
  #   unzip $src/v${version}/rpaextract-v${version}-linux-x64.zip
  # '';

  installPhase = ''
    mkdir -p $out/bin

    # NOTE: This should be a cp, since we should assume that /nix/store might 
    # not be on the same drive, but there is some issue w/ copy and move not
    # copying the whole exe file... so whatever.
    ln -s $src/rpaextract $out/bin/
    chmod +x $out/bin/rpaextract

    # NOTE: 'install' is a better version of cp for installing files.
    # chmod +x ./rpaextract
    # install -D ./rpaextract $out/bin/rpaextract
    # cp --archive ./rpaextract $out/bin
  '';

  meta = with lib; {
    description = "An application for extracting contents from Ren'py archives";
    homepage = "https://github.com/Kaskadee/rpaextract";
    license = licenses.eupl12;
    platforms = [ "x86_64-linux" ];
  };
};
in
mkShell {
  name = "dotnet-env";
  packages = [
    (with dotnetCorePackages; combinePackages [
      # sdk_6_0
      # sdk_7_0
      sdk_8_0
    ])
    rpaextract
    powershell
  ];

  DOTNET_ROOT = "${dotnetCorePackages.sdk_8_0}";
}
