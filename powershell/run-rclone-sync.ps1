<#
.SYNOPSIS
 Runs `rclone sync` and saves compressed logfile.
#>
param(
    [Parameter(Mandatory = $True, Position = 1)]
    [string]
    $rcloneRemote,
    [Parameter(Mandatory = $True, Position = 2)]
    [string]
    $destination,
    [Parameter(Mandatory = $True, Position = 3)]
    [string]
    $logsDirectory,
    [Parameter(Mandatory = $False)]
    [int]
    $maximumLogFiles = 10
)

$ErrorActionPreference = "Stop"

# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/tee-object
$consoleDevice = if ($IsWindows) {
    '\\.\CON'
}
else {
    '/dev/tty'
}

$timestamp = (Get-PlainDate)
$logFile = "$logsDirectory/$rcloneRemote-$timestamp.log.zstd"

rclone sync -v -M --fast-list "$($rcloneRemote):/" $destination 2>&1 | Tee-Object -FilePath $consoleDevice | zstd -6 -o $logFile

CheckLastExitCode

if ($maximumLogFiles -eq 0) {
    exit 0
}

# https://stackoverflow.com/a/8810966/8492116
Get-ChildItem $logsDirectory | Where-Object { -not $_.PsIsContainer -and ($_.BaseName -like "$rcloneRemote-*.log") } | Sort-Object CreationTime -Desc | Select-Object -Skip $maximumLogFiles | Remove-Item -Force
