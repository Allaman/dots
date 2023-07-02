# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

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
    xkbOptions = "caps:escape";
  };

  # Configure console keymap
  console.keyMap = "de-latin1-nodeadkeys";

  # Enable CUPS to print documents.
  services.printing.enable = false;

  # Enable bluetooth
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
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for nowJ)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.michael = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Michael";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      	firefox # best browser
	alacritty # terminal application
	xautolock # automatic screen locking
	flameshot # Screenshots
	keepassxc # password manager
        distrobox # Linux distribution as Podman/Docker
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
	acpi
	arandr
	brightnessctl
	curl
	gcc
	git
	gnumake
	htop
	networkmanagerapplet
	pulseaudio
	unzip
	wget
	xorg.xhost
	zip
  ];

  programs.zsh.enable = true;
  programs.neovim = {
    enable = true;
  };


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

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
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
      devices = {
        "unraid" = { id = "42GWJCT-VAONXMN-UNQVPRX-MVX6VHC-CSFKYFI-7MJX7QT-7VPK7SV-XJUFHAG"; addresses = [ "tcp://192.168.178.62:22222" ]; };
      };
      folders = {
        "secrets" = {        # Label of the folder
	  id = "lkumh-nvc74"; # ID of the folder
          path = "~/.secrets/";    # Which folder to add to Syncthing
          devices = [ "unraid" ];      # Which devices to share the folder with
	  type = "receiveonly"; # One of "sendreceive" "sendonly" "receiveonly" "receiveencrypted"
	  ignorePerms = false;
        };
        "workspace" = {        # Label of the folder
	  id = "domaq-kl2sg"; # ID of the folder
          path = "~/workspace/";    # Which folder to add to Syncthing
          devices = [ "unraid" ];      # Which devices to share the folder with
	  type = "sendreceive"; # One of "sendreceive" "sendonly" "receiveonly" "receiveencrypted"
	  ignorePerms = false;
        };
      };
    };
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
