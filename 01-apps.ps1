<#
 .Synopsis
  Install applications using Scoop & Chocolatey.
#>

$ErrorActionPreference = "Stop"

Import-Module './env.psm1'

SetMachineEnv -Name 'SCOOP' -Value 'C:\App\Scoop'
SetMachineEnv -Name 'SCOOPGLOBAL' -Value 'C:\App\ScoopApps'

if ((Get-Command scoop -ErrorAction SilentlyContinue) -eq $null) {
    Set-ExecutionPolicy RemoteSigned -scope Process
    iwr get.scoop.sh | iex
}
else {
    Write-Output "Scoop already installed, skipping…"
}

Write-Output "Installing Git to add buckets…"
scoop install git

Write-Output "Installing aria2 for faster downloads…"
scoop bucket add extras
scoop install aria2

$script:Apps = (Get-Content "$Global:PackagesDirectory\\scoop")
Write-Output "Installing $($script:Apps.Count) apps…"
scoop install @script:Apps
scoop uninstall vcredist2019    # remove leftover installer
# TODO install TeraCopy

if ($LASTEXITCODE -ne 0) {
    exit 1
}

Write-Output "Installing nerd fonts with sudo…"
scoop bucket add nerd-fonts
sudo scoop install -g DejaVuSansMono-NF meslo-nf

Write-Output "Installing Java…"
scoop bucket add java
scoop install openjdk11

if ($null -eq (Get-Command choco -ErrorAction SilentlyContinue)) {
    SetMachineEnv -Name ChocolateyInstall -Value 'C:\App\Chocolatey'
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}
