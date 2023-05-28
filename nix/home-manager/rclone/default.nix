{ pkgs, sops-nix, targetDir ? "/home/a/gdrive", ... }: {
  sops-nix.secrets.rclone-gdrive-client-id = {};
  sops-nix.secrets.rclone-gdrive-client-secret = {};
  sops-nix.templates.rclone-gdrive-config = generators.toINI {
    "gdrive" = {
      type = "drive";
      client_id = sops-nix.placeholder.rclone-gdrive-client-id;
      client_secret = sops-nix.placeholder.rclone-gdrive-client-secret;
      scope = "drive";
      
    };
  };

  systemd.user.services = {
    "rclone-gdrive" = {
      Unit = {
        Description = "Main Google Drive mount";
        After = "network-online.target";
        AssertPathIsDirectory = targetDir;
      };

      Service = {
        Type = "notify";
        Environment = [ "PATH=${pkgs.fuse}/bin:/run/wrappers/bin/:$PATH" "RCLONE_CONFIG=/home/a/.config/rclone.conf" ];
        KillMode = "None";
        RestartSec = "5s";
        ExecStart = "${pkgs.rclone}/bin/rclone mount XXX:/ ${targetDir} --vfs-cache-mode full";
        Restart = "on-failure";
        ExecStop = "/bin/fusermount -u ${targetDir}";
      };
    };
  };
}
