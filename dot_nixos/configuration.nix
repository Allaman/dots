{ self }:
{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Enable experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "thinkpad"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # https://discourse.nixos.org/t/udiskie-no-longer-runs/23768
  services.udisks2.enable = true;
  environment.etc."inputrc" = {
    text = pkgs.lib.mkDefault( pkgs.lib.mkAfter ''
        #  alternate mappings for "page up" and "page down" to search the history
        "\e[5~": history-search-backward
        "\e[6~": history-search-forward
        '');
  };

  # https://nixos.wiki/wiki/I3#i3blocks
  environment.pathsToLink = [ "/libexec" ];
  # Enable the X11 windowing system.
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/x11/xserver.nix
  services.xserver = {
    enable = true;
    desktopManager.xterm.enable = false;
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        i3status # gives you the default i3 status bar
        i3lock #default i3 screen locker
        i3blocks #if you are planning on using i3blocks over i3status
        i3lock-fancy # screen locking with blur effect
      ];
    };
    # Configure keymap in X11
    xkb = {
      layout = "de";
      variant = "nodeadkeys";
    };
    # length of time in milliseconds that a key must be depressed before autorepeat starts
    autoRepeatDelay = 200;
    # length of time in milliseconds that should elapse between autorepeat-generated keystrokes
    autoRepeatInterval = 20;
  };

  services.displayManager.defaultSession = "none+i3";
  services.gnome.gnome-keyring.enable = true;

  services.keyd = {
    enable = true;
    keyboards = {
      # https://manpages.opensuse.org/Tumbleweed/keyd/keyd.1.en.html
      internal = {
        settings = {
          main = {
            # Tapping caps is ESC
            # Holding caps with hjkl act as arrow keys
            capslock = "overload(arrows, esc)";
            # Left alt acts as ctrl in certain key combos
            # Mimic the behaviour of my macOS config (karabiner)
            leftalt = "layer(alt)";
          };
          arrows = {
            h = "left";
            j = "down";
            k = "up";
            l = "right";
            c = "A-c"; # fzf cd-folder-widget
            "." = "A-."; # last argument
          };
          "alt:A" = {
            c = "C-insert";
            v = "S-insert";
            t = "C-t";
            w = "C-w";
            d = "C-d";
          };
        };
      };
    };
  };

  # Configure console keymap
  console.keyMap = "de-latin1-nodeadkeys";

  # Enable CUPS to print documents.
  services.printing.enable = false;

  # Enable TLP
  services.tlp.enable = true;

  # Enable bluetooth(ctl)
  hardware.bluetooth.enable = true;
  # Bluetooth GUI if bluetoothctl is not sufficient
  #hardware.bluetooth.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  programs.zsh.enable = true;
  # Apparently, those are defaults and overwrite my "~/.shell/aliases"
  # so I need to disable them here
  environment.shellAliases = {
    ls = null;
    ll = null;
  };
  programs.neovim = {
    enable = true;
  };

  # https://github.com/NixOS/nixpkgs/issues/273611
  nixpkgs.config.permittedInsecurePackages =
    pkgs.lib.optional (pkgs.obsidian.version == "1.5.3") "electron-25.9.0";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.michael = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Michael";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
	  alacritty # terminal application
    acpi # battery interfae
    arandr # simple app to configure displays
    brightnessctl # for manipulating screen brightness
    coreutils # GNU Core utils
    curl
    dunst # Notification handling
    file
    gcc
    git
    gnumake
    htop
    icu.dev # dependecy for marksman
    libnotify # notification library
    lm_sensors # get system temperature
    zlib # dependecy for marksman
    networkmanagerapplet # tray icon
    pasystray # pulseaudio tray icon
    pinentry-curses # GnuPG’s interface to passphrase input
    pulseaudio # for audio controlls
    sysstat # A collection of performance monitoring tools for Linux (mpstat is required for i3blocks)
    tree # file and folders as tree
    udisks # query/manipulate storage devices
    unzip
    wget
    xorg.xhost # give permission to access X-server from a container
    zip
  ];

  fonts = {
      packages = with pkgs; [
        (nerdfonts.override { fonts = [ "Meslo" "FiraCode" ]; })
      ];
      fontconfig = {
        enable = true;
        antialias = true;
        hinting.enable = true;
        defaultFonts = {
  	      monospace = [ "Meslo LG M Regular Nerd Font Complete Mono" ];
  	      serif = [ "Noto Serif" "Source Han Serif" ];
  	      sansSerif = [ "Noto Sans" "Source Han Sans" ];
        };
      };
  };

  # NOTE: Moving this to home-manager does break something
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    settings = {
      default-cache-ttl = 21600;
      default-cache-ttl-ssh = 21600;
      max-cache-ttl = 21600;
      max-cache-ttl-ssh = 21600;
    };
  };
  virtualisation = {
    podman = {
      enable = true;
      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings = {
        dns_enabled = true;
      };
    };
  };

  # List services that you want to enable:

  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/syncthing.nix
# TODO: move to home-manager when proper config options are available https://github.com/nix-community/home-manager/issues/4049
  services = {
    syncthing = {
      enable = true;
      user = "michael";
      configDir = "/home/michael/.config/syncthing";
      overrideDevices = true;     # overrides any devices added or deleted through the WebUI
      overrideFolders = true;     # overrides any folders added or deleted through the WebUI
      settings = {
        globalAnnounceEnabled = false;
        devices = {
        # https://docs.syncthing.net/users/faq.html#should-i-keep-my-device-ids-secret
        "unraid" = { id = "42GWJCT-VAONXMN-UNQVPRX-MVX6VHC-CSFKYFI-7MJX7QT-7VPK7SV-XJUFHAG"; addresses = [ "tcp://192.168.178.62:22222" ]; };
        };
        folders = {
          "secrets" = {                  # Label of the folder
            id = "lkumh-nvc74";          # ID of the folder
            path = "~/.secrets/";        # Which folder to add to Syncthing
            devices = [ "unraid" ];      # Which devices to share the folder with
            type = "receiveonly";        # One of "sendreceive" "sendonly" "receiveonly" "receiveencrypted"
            ignorePerms = false;         # Whether to ignore permission changes
          };
          "workspace" = {                # Label of the folder
            id = "domaq-kl2sg";          # ID of the folder
            path = "~/workspace/";       # Which folder to add to Syncthing
            devices = [ "unraid" ];      # Which devices to share the folder with
            type = "sendreceive";        # One of "sendreceive" "sendonly" "receiveonly" "receiveencrypted"
            ignorePerms = false;         # Whether to ignore permission changes
          };
        };
      };
    };
  };

  # Enable garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # The firewall is enabled by default
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
