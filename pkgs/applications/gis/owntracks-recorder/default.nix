{ lib
, stdenv
, fetchFromGitHub
, gnumake
, libconfig
, lmdb
, mosquitto
, curl
, pkg-config
, owntracks-recorder
}:

stdenv.mkDerivation rec {
  pname = "owntracks-recorder";
  version = "0.8.6";

  src = fetchFromGitHub {
    owner = "owntracks";
    repo = "recorder";
    rev = "fd3f4631f16da09706eb1cde84a65322a24c31cb";
    sha256 = "t9fOgNVRVdbJMgXUDhc7az6ccnkZL7abI8RxVgpFwGE=";
  };

  doCheck = true;

  buildInputs = [
    pkg-config
    libconfig
    lmdb
    mosquitto
    curl
  ];

  nativeBuildInputs = [
    gnumake
  ];

  postConfigure = ''
    cp config.mk.in config.mk

    # Todo check build warning
    substituteInPlace config.mk --replace "# CFLAGS += -I/usr/local/include" "CFLAGS += -w"
    
    sed "s@STORAGEDEFAULT.*@STORAGEDEFAULT = /var/lib/owntracks-recorder@g" -i config.mk    
    sed "s@DOCROOT.*@DOCROOT = /var/www@g" -i config.mk    
    sed "s@/usr/local@@g" -i config.mk
    
    # Adds a CONFIGFILE_BUILD flag that specifies the config file location in the nix
    # store parameter so the software retrieves config from the nix store
    sed -r 's@CONFIGFILE = (.+)@CONFIGFILE_BUILD = $(out)\1\nCONFIGFILE = \1@g' -i config.mk

    # Change the build flag to the CONFIGFILE_BUILD flag
    sed 's@\"$(CONFIGFILE)@\"$(CONFIGFILE_BUILD)@g' -i Makefile
  '';

  installFlags = [
    "DESTDIR=$(out)"
  ];

  meta = with lib; {
    description = "Lightweight program for storing and accessing location data published via MQTT (or HTTP) by the OwnTracks apps.";
    longDescription = ''
      The OwnTracks Recorder is a lightweight program for storing and accessing location data 
      published via MQTT (or HTTP) by the OwnTracks apps. It is a compiled program which is easy 
      to install and operate even on low-end hardware, and it doesn't require an external 
      database.
    '';
    homepage = "https://owntracks.org/";
    changelog = "https://github.com/owntracks/recorder/blob/master/Changelog";
    license = licenses.gpl2Plus;
    #maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
