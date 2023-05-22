<#
 .Synopsis
  Install applications.
#>

$ErrorActionPreference = "Stop"

Import-Module "./env.psm1"

. "./scoop.ps1"

if ($null -eq (Get-Command choco -ErrorAction SilentlyContinue)) {
    SetMachineEnv -Name ChocolateyInstall -Value 'C:\App\Chocolatey'
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

. ".\rust.ps1" "$Global:PackagesDirectory\\cargo.json"

Import-Module ".\node.psm1"
Install-Node "$Global:PackagesDirectory\\fnm" "$Global:PackagesDirectory\\npm"

Import-Module ".\go.psm1"
Install-GoPackages "$Global:PackagesDirectory\\go"
