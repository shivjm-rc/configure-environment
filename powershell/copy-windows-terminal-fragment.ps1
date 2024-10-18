[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [string]$directoryName = "configure-environment",
    [string]$fileName = "fragments.json"
)

$ErrorActionPreference = "Stop"

Import-Module ./env.psm1

$destination = "$($env:LOCALAPPDATA)/Microsoft/Windows Terminal/Fragments/$directoryName"

New-Item -Force $destination -Verbose:$Verbose -ItemType Directory

Copy-Item "$(Get-ScriptDirectory)/../applications/windows-terminal-fragments.json" $destination/$fileName -Verbose:$Verbose
