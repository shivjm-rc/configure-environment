# Run rclone as a service using an existing configuration file, as it
# isn’t possible to split the rclone configuration into a common
# section defined by this service and a private section for each host.
{ pkgs
, targetDir ? "%h/mnt/%i"
, configFile ? "%h/.config/rclone/rclone.conf"
, logFile ? "%h/.log/rclone-%i"
, ...
}: {
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
        ExecStartPre = "/bin/mkdir -p ${targetDir}";
        ExecStart =
          "${pkgs.rclone}/bin/rclone mount --config ${configFile} %i: ${targetDir} --vfs-cache-mode full --log-file ${logFile}.log --allow-other --umask 022";
        Restart = "on-failure";
        ExecStop = "/bin/fusermount -u ${targetDir}";
        StandardOutput = "append:${logFile}-out.log";
        StandardError = "append:${logFile}-err.log";
      };

      Install = { WantedBy = [ "default.target" ]; };
    };
  };
}
