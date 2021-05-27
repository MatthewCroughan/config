{ pkgs, ... }:
  let p = pkgs; in
  { environment =
      { systemPackages = with pkgs;
          [ alacritty
            brave
            gimp
            git
            graphviz
            imagemagick
            ix
            jq
            ncdu
            neofetch
            neovim
            nix-du
            ntfs3g
            parted
            pavucontrol
            spectacle
            tmate
            trash-cli
            unzip
            xclip
            w3m
          ];

        variables.EDITOR = "nvim";
      };

    fonts.fonts = [ (p.nerdfonts.override {fonts = [ "Cousine" ]; }) ];

    hardware =
      { keyboard.zsa.enable = true;
        pulseaudio.enable = true;
      };

    networking =
      { firewall.enable = false;
        networkmanager.enable = true;
        # wireless.enable = true; # Enables wireless support via wpa_supplicant.

        # The global useDHCP flag is deprecated, therefore explicitly set to false here.
        # Per-interface useDHCP will be mandatory in the future, so this generated config
        # replicates the default behaviour.
        useDHCP = false;
      };

    nix =
      { extraOptions = "experimental-features = nix-command flakes";
        package = p.nixUnstable;

        registry =
          { nixpkgs =
              { from =
                  { id = "nixpkgs";
                    type = "indirect";
                  };

                to =
                  { owner = "NixOS";
                    repo = "nixpkgs";
                    ref = "nixpkgs-unstable";
                    type = "github";
                  };
              };

            utils =
              { from =
                  { id = "utils";
                    type = "indirect";
                  };

                to =
                  { owner = "ursi";
                    repo = "flake-utils";
                    type = "github";
                  };
              };
          };

        trustedUsers = [ "mason" "root" ];
      };

    programs =
      { bash.shellAliases =
          { nix-use = "nix-env -if nix.nix";
            nix-remove = "nix-env -e nix";
            nixbuild = "nix build -f .";

            nixrepl =
              let
                file = p.writeText "" "{ p }: { l = p.lib; inherit p; } // builtins";
              in
              ''nix repl --arg p '(builtins.getFlake "${./.}").inputs.nixpkgs.legacyPackages.x86_64-linux' ${file}'';

            nixshell = "nix develop -f shell.nix";
            fui = "nix flake lock --update-input ";
          };

        nm-applet.enable = true;
      };

    services =
      { picom =
          { enable = true;
            vSync = true;
          };

        xserver =
          { enable = true;

            # Disable mouse acceleration
            libinput =
              { enable = true;

                mouse =
                  { accelProfile = "flat";
                    accelSpeed = "0";
                  };
              };

            windowManager.i3.enable = true;
          };
      };

    sound.enable = true;

    ssbm =
      { cache.enable = true;

        gcc =
          { oc-kmod.enable = true;
            rules.enable = true;
          };
      };

    time.timeZone = "America/Toronto";

    users =
      { mutableUsers = false;

        users =
          { mason =
              { createHome = true;
                description = "Mason Mackaman";
                extraGroups = [ "networkmanager" "plugdev" "wheel" ];
                icons.cursor = p.icons.breeze.cursors.breeze;
                isNormalUser = true;
                git = import ./git.nix "${p.neovim}/bin/nvim";

                packages = with pkgs;
                  let
                    communication =
                      [ discord
                        mattermost-desktop
                        signal-desktop
                        zulip
                      ];
                  in
                  [ gnome3.nautilus # for seeing images
                    qemu
                    (writeShellScriptBin
                       "snowball"
                       "bash <( curl https://gitlab.com/fresheyeball/snowball/-/raw/master/generator.sh )"
                    )
                    slippi-netplay
                    wally-cli
                  ]
                  ++ communication
                  ++ flake-packages;

                password = "";
              };

            root =
              { extraGroups = [ "root" ];
                password = "";
              };
          };
      };
  }
