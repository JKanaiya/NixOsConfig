# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Africa/Nairobi";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.xserver.videoDrivers = ["nvidia"];
  hardware.graphics.enable = true;

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    prime = {
      sync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        settings = {
          main = {
            capslock = "overload(control, esc)";
            esc = "capslock";
          };
        };
      };
    };
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jonathan = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "jonathan";
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [
      #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  programs.zsh.enable = true;

  programs.steam = {
    enable = true;
    extraCompatPackages = [pkgs.proton-ge-bin];
  };

  programs.nvf = {
    enable = true;

    settings = {
      vim = {
        theme = {
          enable = true;
          name = "rose-pine";
          style = "main";
        };

        globals = {
          mapleader = " ";
          maplocalleader = " ";
        };

        binds.whichKey.enable = true;

        treesitter = {
          enable = true;
          highlight.enable = true;
          indent.enable = true;
          context.enable = true;
          autotagHtml = true;
        };

        snippets = {
          luasnip.enable = true;
        };

        diagnostics = {
          enable = true;
          config = {
            virtual_lines = {
              enable = true;
              current_line = true;
            };
          };
        };

        visuals = {
          nvim-cursorline.enable = true;
          # indent-blankline.enable = true;
        };

        terminal = {
          toggleterm = {
            enable = true;
            mappings.open = "<C-\\>";
            setupOpts.direction = "float";
          };
        };

        telescope = {
          enable = true;
          extensions = [
            {
              name = "ui-select";
              packages = [pkgs.vimPlugins.telescope-ui-select-nvim];
            }
          ];
        };

        utility = {
          sleuth.enable = true;
          oil-nvim = {
            enable = true;
            gitStatus.enable = true;
          };
        };

        keymaps = [
          {
            key = "\\\\";
            mode = "n";
            action = "<cmd>Oil<CR>";
          }
          {
            key = "<Esc>";
            mode = "n";
            action = "<cmd>nohlsearch<CR>";
          }
          # -- Keybinds to make split navigation easier.
          # --  Use CTRL+<hjkl> to switch between windows
          {
            mode = "n";
            key = "<C-h>";
            action = "<C-w><C-h>";
          }
          {
            mode = "n";
            key = "<C-l>";
            action = "<C-w><C-l>";
          }
          {
            mode = "n";
            key = "<C-j>";
            action = "<C-w><C-j>";
          }
          {
            mode = "n";
            key = "<C-k>";
            action = "<C-w><C-k>";
          }
        ];

        formatter = {
          conform-nvim.enable = true;
        };

        diagnostics.nvim-lint = {
          enable = true;
        };

        lsp = {
          enable = true;
          formatOnSave = true;
          servers = {
            typescript.cmd = lib.mkForce ["typescript-language-server"];
          };
        };

        options = {
          # wrap = true;
          smartindent = true;
          shiftwidth = 4;
          scrolloff = 10;
        };

        syntaxHighlighting = true;

        withNodeJs = true;

        statusline.lualine.enable = true;
        git.enable = true;
        autocomplete.nvim-cmp.enable = true;

        languages = {
          enableTreesitter = true;
          enableFormat = true;
          enableDAP = true;

          nix.enable = true;
          css.enable = true;
          bash.enable = true;
          # ts = {
          #   enable = true;
          #   # extensions = ["tsx" "typescript"];
          #   format = {
          #     enable = true;
          #   };
          # };
          python.enable = true;
        };

        mini = {
          clue.enable = true;
          comment.enable = true;
          # completion.enable = true;
          pairs.enable = true;
          surround.enable = true;
        };
      };
    };
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    btop
    lutris
    bat
    wget
    ghostty
    ripgrep
    tldr
    qbittorrent
    keyd
    curlie
    fd
    git
    everforest-cursors
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
