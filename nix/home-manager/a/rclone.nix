{ pkgs, targetDir ? "%h/mnt/%i", configFile ? "%h/.config/rclone/rclone.conf"
, ... }: {
  systemd.user.services = {
    "rclone@" = {
      Unit = {
        Description = "Main Google Drive mount";
        After = "network-online.target";
        Wants = "network-online.target";
      };

      Service = {
        Type = "notify";
        # https://discourse.nixos.org/t/fusermount-systemd-service-in-home-manager/5157/4
        Environment =
          [ "PATH=/run/wrappers/bin/:$PATH" "RCLONE_CONFIG=${configFile}" ];
        RestartSec = "5s";
        ExecStartPre = "/run/current-system/sw/bin/mkdir -p ${targetDir}";
        ExecStart =
          "${pkgs.rclone}/bin/rclone mount --config ${configFile} %i: ${targetDir} --vfs-cache-mode full --log-file %h/tmp/rclone-%i.log --allow-other --umask 022";
        Restart = "on-failure";
        ExecStop = "/bin/fusermount -u ${targetDir}";
      };

      Install = { WantedBy = [ "default.target" ]; };
    };
  };
}
