<#
 .Synopsis
  Install applications using Scoop & Chocolatey.
#>

$ErrorActionPreference = "Stop"

Import-Module "./env.psm1"

. "./scoop.ps1"

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

$script:ChocoApps = (Get-Content "$Global:PackagesDirectory\\scoop")
Write-Output "Installing $($script:ChocoApps.Count) Chocolatey apps…"
choco install -y @script:ChocoApps

Import-Module ".\rust.psm1"
Initialize-Rust

Import-Module ".\node.psm1"
Install-Node "$Global:PackagesDirectory\\fnm" "$Global:PackagesDirectory\\npm"
