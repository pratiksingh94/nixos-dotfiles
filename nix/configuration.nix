{ config, pkgs, lib, ... }:

# variables
let
  lanzaboote = import (builtins.fetchTarball "https://github.com/nix-community/lanzaboote/archive/refs/tags/v0.4.2.tar.gz");
  flake-compat = builtins.fetchTarball "https://github.com/edolstra/flake-compat/archive/master.tar.gz";
  hyprland = (import flake-compat {
    src = builtins.fetchTarball "https://github.com/hyprwm/Hyprland/archive/main.tar.gz";
  }).defaultNix;

in {
  imports =
    [
      ./hardware-configuration.nix
      lanzaboote.nixosModules.lanzaboote
    ];

  # NTFS Support
  boot.supportedFilesystems = [ "ntfs" ];

  # Bootloader
  # boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.enable = lib.mkForce false; # Lanzaboote replaces systemd-boot so force it off
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";  # location of sbctl generated keys
  };

  boot.loader.efi.canTouchEfiVariables = true;

  # GRUB
  #  boot.loader.grub.enable = true;
  #  boot.loader.grub.devices = [ "nodev" ];
  #  boot.loader.grub.efiSupport = true;
  #  boot.loader.grub.useOSProber = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_IN";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.displayManager = {
      sddm.enable = true;
      defaultSession = "hyprland";
  };

  # Hyprland
  programs.hyprland = {
    enable = true;
    package = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  # Waybar for Hyprland
  programs.waybar.enable = true;

  # Enable the GNOME Desktop Environment.
  #  services.xserver.displayManager.gdm.enable = true;
  #  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
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
  users.users.snehasish = {
    isNormalUser = true;
    description = "snehasish";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      brave
      discord
      spotify
    ];
  };

  # Install firefox.
  programs.firefox.enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    # secure boot
    sbctl

    # hyprland
    hyprland
    wofi
    xdg-utils
    xdg-desktop-portal-hyprland    

    # wallpaper
    swww

    # terminal
    kitty

    # utils
    git
    gh
    zsh
    nodejs_24
    vscode
    neovim
    fastfetch
    networkmanagerapplet
    btop
    
    # screen (snip + clip)
    grim # screenshot
    wf-recorder # clipping
    slurp # selected are snipping+clipping

    # clipboard
    wl-clipboard
    cliphist

    # c tooling
    gcc
    gdb
   
    # theming
    catppuccin-gtk
    catppuccin-cursors
    papirus-icon-theme
    nwg-look
  ];

  # fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-emoji
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

  system.stateVersion = "25.05";
}