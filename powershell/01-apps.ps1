<#
 .Synopsis
  Install applications.
#>

$ErrorActionPreference = "Stop"

Import-Module "./env.psm1"
Import-Module "./install-packages.psm1"

. "./scoop.ps1"

if ($null -eq (Get-Command choco -ErrorAction SilentlyContinue)) {
    SetMachineEnv -Name ChocolateyInstall -Value 'C:\App\Chocolatey'
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

if ($null -eq (Get-Module powershell-yaml)) {
    Install-Module powershell-yaml
}

$packagesToInstall = (ConvertFrom-Yaml (Get-Content -Raw (Join-Path $ConfigDirectory "../files/packages.yaml")))

$ErrorActionPreference = "Stop"
foreach ($package in $packagesToInstall) {
    Write-Output "Installing $($package.name)…"
    Install-ThirdPartyPackage $package
}
