# This overrides behavior in <https://github.com/LnL7/nix-darwin/blob/ba9b3173b0f642ada42b78fb9dfc37ca82266f6c/modules/security/pam.nix>
{ config, lib, ... }: {
  config = lib.mkIf config.security.pam.enableSudoTouchIdAuth {
    # This is the example given in `/etc/pam.d/sudo_local.template`.
    # This file is sourced by `/etc/pam.d/sudo`, and will not be overwritten after Darwin upgrades.
    environment.etc."pam.d/sudo_local".text = ''
      auth       sufficient     pam_tid.so
    '';
    # Disable the activation script text from the nix-darwin module.
    # Such complexity is unnecessary.
    system.activationScripts.pam.text = lib.mkForce "";
  };
}
