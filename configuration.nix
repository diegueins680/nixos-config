# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  hsPackages = with pkgs.haskellPackages; [
    aeson
    cabal2nix
    cabal-install
    crypto-pubkey-types
    ghc
    ghcid
    hlint
    idris
    pandoc
    pointfree
    pointful
    purescript
    reflex
    RSA
    SHA2
    taffybar
    text-icu
    xmobar
    xmonad
    xmonad-extras
    yeganesh
    yi
  ];
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.loader.gummiboot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.kernelModules = [ "fbcon" ];

  boot.loader.grub.device = "/dev/sda";
  boot.cleanTmpDir = true;

  # This gets your audio output and input (mic) working
  boot.extraModprobeConfig = ''
    options libata.force=noncq
    options resume=/dev/sda5
    options snd_hda_intel index=0 model=intel-mac-auto id=PCH
    options snd_hda_intel index=1 model=intel-mac-auto id=HDMI
    options snd-hda-intel model=mbp101
    options hid_apple fnmode=2
  '';
  # because we are using the EFI mount for boot, which is small (tiny actually)
  # I switched these to false.
  boot.loader.generationsDir.enable = false;
  boot.loader.generationsDir.copyKernels = false;
  
  nix.binaryCaches = [ http://cache.nixos.org 
    http://hydra.nixos.org ];

  nix.trustedBinaryCaches = [ "https://ryantrinkle.com:5443" ];
  nix.binaryCachePublicKeys = [ "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI=" ];

  # Select internationalisation properties.
  i18n = {
  #   consoleFont = "lat9w-16";
    consoleKeyMap = "dvorak";
  #   defaultLocale = "en_US.UTF-8";
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    ardour
    arp-scan
    binutils
    chromium
    clojure
    csound
    cups
    dblatex
    deluge
    dmenu
    doxygen
    electrum
    emacs
    firefox
    gcc
    gimp
    #gnash
    gnupg
    gitFull
    gravit
    htop
    icu
    irssi
    jack_rack
    jack2Full
    libao
    libjack2
    libreoffice
    llvm
    mplayer
    mpg321
    ncurses
    networkmanagerapplet
    nix-repl
    qjackctl
    rxvt_unicode
    silver-searcher
    stellarium
    sooperlooper
    terminator
    thunderbird
    torbrowser
    thunderbird
    transmission
    vagrant
    wpa_supplicant_gui
    sudo
    wireshark
    wget
    xchat
    xclip
    xorg.xev
    xscreensaver
    yoshimi
    youtube-dl
    zam-plugins
  ] ++ hsPackages;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.ntp.enable = true;

  services.xserver = {
    enable = true;

    vaapiDrivers = [ pkgs.vaapiIntel ];

    desktopManager.default = "none";
    desktopManager.xterm.enable = false;
    displayManager = {
      desktopManagerHandlesLidAndPower = false;
      lightdm.enable = true;
    };

    windowManager.default = "xmonad"; 
    windowManager.xmonad.enable = true;                                                                               
    windowManager.xmonad.enableContribAndExtras = true;
    windowManager.xmonad.extraPackages = haskellPackages: [
      haskellPackages.taffybar                                                                                        
    ];

    xkbVariant = "dvorak";

    modules = [ pkgs.xf86_input_mtrack ];

    config =
      ''
        Section "InputClass"
          MatchIsTouchpad "on"
          Identifier      "Touchpads"
          Driver "mtrack"
          Option "Sensitivity" "0.55"
          Option "FingerHigh" "12"
          Option "FingerLow" "1"
          Option "IgnoreThumb" "true"
          Option "IgnorePalm" "true"
          Option "TapButton1" "1"
          Option "TapButton2" "3"
          Option "TapButton3" "2"
          Option "TapButton4" "0"
          Option "ClickFinger1" "1"
          Option "ClickFinger2" "3"
          Option "ClickFinger3" "0"
          Option "ButtonMoveEmulate" "false"
          Option "ButtonIntegrated" "true"
          Option "ClickTime" "25"
          Option "BottomEdge" "25"
          Option "ScrollUpButton" "5"
          Option "ScrollDownButton" "4"
          Option "ScrollLeftButton" "7"
          Option "ScrollRightButton" "6"
          Option "SwipeLeftButton" "8"
          Option "SwipeRightButton" "9"
          Option "SwipeUpButton" "0"
          Option "SwipeDownButton" "0"
          Option "ScrollDistance" "75"
        EndSection
      '';

    multitouch = {
      enable = false;
      invertScroll = true;
    };

    synaptics = {
      enable = false;
      horizontalScroll = true;
      minSpeed = "0.7";
      palmDetect = true;
      twoFingerScroll = true;
      additionalOptions = ''
        Option "VertScrollDelta"     "-111"
        Option "HorizScrollDelta"    "-111"
        Option "AreaBottomEdge"      "4000"
      '';
    };
  };

  users.mutableUsers = true;

  users.extraUsers.jet = {
    name = "jet";
    group = "users";
    uid = 1000;
    extraGroups = [ "wheel" "networkmanager" ];
    createHome = true;
    isNormalUser = true;
    home = "/home/jet";
    shell = "/run/current-system/sw/bin/zsh";
  };

  networking.hostName = "jet-nixos";
  networking.networkmanager.enable = true;
  services.upower.enable = true;

  services.nixosManual.showManual = true;

  services.btsync.deviceName = "jet-nixos";
  services.btsync.enable = true;
  services.btsync.enableWebUI = true;
  services.btsync.httpListenAddr = "127.0.0.1";

  services.redshift.enable = true;
  services.redshift.brightness.day = "0.8";
  services.redshift.brightness.night = "0.4";
  services.redshift.latitude = "0.0000";
  services.redshift.longitude = "0.0000";

  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";
  programs.ssh.agentTimeout = "12h";

  programs.zsh.enable = true;
}