{pkgs ? import <nixpkgs> {}, ...}: let
  envname = "pio-arduino-fhs";
  # as a function to make sure the same pkgs is used as in targetPkgs
  mypython = pks: pks.python3.withPackages (ps: with ps; [platformio pylibftdi pyusb]);
  # "proxy" env, is this useful/necessary???
  # myEnv = pkgs.buildEnv {
  #   name = envname;
  #   paths = [ pkgs.zsh ];
  # };
in
  (pkgs.buildFHSUserEnv {
    name = envname;
    targetPkgs = pkgs: (with pkgs; [
      # picocom -fn -b115200 --imap lfcrlf /dev/ttyACM0
      picocom

      # for pio cli and vscode extension
      platformio-core
      (mypython pkgs)

      # for running openocd manually
      openocd

      # for running openocd via pio cli or vscode extension
      libusb1 # libusb-1.0.so.0
      hidapi # libhidapi-hidraw.so.0
      systemd # libudev.so.1

      # for platformio debugging in vscode
      # (ldd ~/.platformio/packages/toolchain-rp2040-earlephilhower/bin/arm-none-eabi-gdb)
      ncurses5 # libtinfo.so.5
      mpfr # libmpfr.so.6

      # pio run -e linux -t exec
      # pio run -e linux && stdbuf -o0 tr \\n \\r | .pio/build/linux/program
      gcc

      zsh
    ]);
    # NOTE:just use nix develop or do this in your .envrc to avoid a load loop:
    # https://github.com/direnv/direnv/issues/992#issuecomment-1744989487
    runScript = ''
      ${pkgs.zsh}/bin/zsh
    '';
  })
  .env
