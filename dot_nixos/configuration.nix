# and in the NixOS manual (accessible by running ‘nixos-help’).

# Fix lua-language-server and stylua
# patchelf --set-interpreter $(patchelf --print-interpreter `which find`) $HOME/.local/share/nvim/mason/packages/lua-language-server/libexec/bin/lua-language-server
# patchelf --set-interpreter $(patchelf --print-interpreter `which find`) /home/michael/.local/share/nvim/mason/packages/stylua/stylua
# libz.so.1 and glibc++6 not found in this case in this case
# patchelf --set-rpath "$(nix eval nixpkgs#zlib.outPath --raw)/lib:$(nix eval nixpkgs#stdenv.cc.cc.lib.outPath --raw)/lib" .local/share/nvim/mason/bin/marksman


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

  # https://nixos.wiki/wiki/I3#i3blocks
  environment.pathsToLink = [ "/libexec" ];
  # Enable the X11 windowing system.
  services.xserver = {
      enable = true;
      desktopManager.xterm.enable = false;
      windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu #application launcher most people use
        i3status # gives you the default i3 status bar
        i3lock #default i3 screen locker
        i3blocks #if you are planning on using i3blocks over i3status
	      i3lock-fancy # screen locking with blur effect
     ];
    };
    displayManager.defaultSession = "none+i3";
    # Configure keymap in X11
    layout = "de";
    xkbVariant = "nodeadkeys";
    # Set caps lock to escape
    xkbOptions = "caps:escape";
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
  programs.neovim = {
    enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.michael = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Michael";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
	    flameshot # Screenshots
	    keepassxc # password manager
	    xautolock # automatic screen locking
      #java
      age # key management
      cargo
      chezmoi # dotfile management
      distrobox # Linux distribution as Podman/Docker
      fd # finder alternative
      firefox # best browser
      gitui # Git TUI
      go
      lf # TUI file manager
      nodejs
      ripgrep # grep alternative
      rustc
      tectonic # LaTex compiler
      tig # GIT TUI
      tmux # Terminal multiplexer
      trash-cli # trash bin
      xclip # clipboard tool
      zoxide # Quickly jump to know folders
    ];
  };

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
	  alacritty # terminal application
    acpi # battery interfae
    arandr # simple app to configure displays
    brightnessctl # for manipulating screen brightness
    curl
    gcc
    git
    gnumake
    htop
    icu.dev # dependecy for marksman
    libnotify # notification library
    libz # dependecy for marksman
    networkmanagerapplet # tray icon
    pulseaudio # for audio controlls
    udisks # query/manipulate storage devices
    unzip
    wget
    xorg.xhost # give permission to access X-server from a container
    zip
  ];

  fonts = {
      fonts = with pkgs; [
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

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
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
  services = {
    syncthing = {
      enable = true;
      user = "michael";
      configDir = "/home/michael/.config/syncthing";
      overrideDevices = true;     # overrides any devices added or deleted through the WebUI
      overrideFolders = true;     # overrides any folders added or deleted through the WebUI
      extraOptions = {
        globalAnnounceEnabled = false;
      };
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
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
