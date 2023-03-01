{ lib, stdenv, fetchFromGitHub, fetchpatch, bison, flex, fontconfig, freetype
, gperf, icu, openssl, libjpeg, libpng, perl, python2, ruby, sqlite, qtwebkit
, qmake, qtbase, darwin, writeScriptBin, cups, makeWrapper, cmake }:

let
  fakeClang = writeScriptBin "clang" ''
    #!${stdenv.shell}
    if [[ "$@" == *.c ]]; then
      exec "${stdenv.cc}/bin/clang" "$@"
    else
      exec "${stdenv.cc}/bin/clang++" "$@"
    fi
  '';

in stdenv.mkDerivation {
  pname = "phantomjs";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "ariya";
    repo = "phantomjs";
    rev = "0a0b0facb16acfbabb7804822ecaf4f4b9dce3d2";
    sha256 = "sha256-xLCqi9l6AIdFXMuwcZcKB8pZ1hmUK9KQTAm0jzZKBEQ=";
  };

  nativeBuildInputs = [ cmake qmake makeWrapper ];
  buildInputs = [
    bison
    flex
    fontconfig
    freetype
    gperf
    icu
    openssl
    libjpeg
    libpng
    perl
    python2
    ruby
    sqlite
    qtwebkit
    qtbase
  ] ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
    AGL
    ApplicationServices
    AppKit
    Cocoa
    OpenGL
    darwin.libobjc
    fakeClang
    cups
  ]);

  __impureHostDeps = lib.optional stdenv.isDarwin "/usr/lib/libicucore.dylib";

  dontWrapQtApps = true;

  installPhase = ''
    mkdir -p $out/share/doc/phantomjs
    cp -a bin $out
  '' + lib.optionalString stdenv.isDarwin ''
    install_name_tool -change \
        ${darwin.CF}/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation \
        /System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation \
      -change \
        ${darwin.configd}/Library/Frameworks/SystemConfiguration.framework/SystemConfiguration \
        /System/Library/Frameworks/SystemConfiguration.framework/Versions/A/SystemConfiguration \
    $out/bin/phantomjs
  '' + ''
    wrapProgram $out/bin/phantomjs \
    --set QT_QPA_PLATFORM offscreen \
    --prefix PATH : ${lib.makeBinPath [ qtbase ]}
  '';

  meta = with lib; {
    description = "Headless WebKit with JavaScript API";
    longDescription = ''
      PhantomJS2 is a headless WebKit with JavaScript API.
      It has fast and native support for various web standards:
      DOM handling, CSS selector, JSON, Canvas, and SVG.

      PhantomJS is an optimal solution for:
      - Headless Website Testing
      - Screen Capture
      - Page Automation
      - Network Monitoring
    '';

    homepage = "https://phantomjs.org/";
    license = licenses.bsd3;

    maintainers = [ maintainers.aflatter ];
    platforms = platforms.darwin ++ platforms.linux;
  };
}
