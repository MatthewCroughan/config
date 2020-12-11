{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
  };

  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/disk/by-id/ata-WDC_WD10EZEX-08M2NA0_WD-WCC3FE0JTJMX";
  };

  networking = {
    firewall.enable = false;
    networkmanager.enable = true;
    # wireless.enable = true; # Enables wireless support via wpa_supplicant.

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;
    interfaces.eno1.useDHCP = true;
  };

  fonts.fonts = with pkgs; [ (nerdfonts.override {fonts = [ "Cousine" ]; }) ];

  environment = {
    systemPackages = with pkgs; [
      brave
      git
      (neovim.override { withNodeJs = true; })
      ntfs3g
      parted
      pavucontrol
      spectacle
      trash-cli
      unzip
      xclip
      xfce.xfce4-terminal
      w3m
    ];

    variables = { EDITOR = "nvim"; };
  };

  programs.nm-applet.enable = true;
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  services = {
    picom = {
      backend = "glx";
      enable = true;
      vSync = true;
    };

    udev.extraRules = ''
      # Teensy rules for the Ergodox EZ
      ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
      ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", MODE:="0666"
      KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", MODE:="0666"

      #GameCube Controller Adapter
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="0337", TAG+="uaccess"

      #Mayflash DolphinBar
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="0306", TAG+="uaccess"
    '';

    xserver = {
      enable = true;

      # Disable mouse acceleration
      libinput = {
        enable = true;
        accelProfile = "flat";
        accelSpeed = "0";
      };

      windowManager.i3.enable = true;
    };
  };

  users = {
    mutableUsers = false;

    users = {
      mason = {
        createHome = true;
        description = "Mason Mackaman";
        extraGroups = [ "networkmanager" "wheel" ];
        isNormalUser = true;

        packages = with pkgs;
          let
            communication = [
              discord
              mattermost-desktop
              signal-desktop
              zulip
            ];

            editor =
              let
                elm = with elmPackages; [
                  elm-language-server
                  elm-format
                ];

                node = with nodePackages; [
                  purty
                  purescript-language-server
                ];
              in
                elm ++ node;
          in
            [
              gnome3.nautilus # for seeing images
              go-sct
              nodePackages.node2nix
              wally-cli
            ]
              ++ communication
              ++ editor
              ++ flakePackages;

        password = "";
      };

      root = {
        extraGroups = [ "root" ];
        password = "";
      };
    };
  };

  nixpkgs = rec {
    # pkgs = import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/<commit>.tar.gz") { inherit config; };
    config.allowUnfree = true;
  };


  system = {
    autoUpgrade.enable = true;

    # don't change - man configuration.nix
    stateVersion = "20.03";
  };
}
