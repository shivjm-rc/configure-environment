<#
.SYNOPSIS
 Sets up OpenSSH on Windows.

.DESCRIPTION
 Enables the OpenSSH server on Windows. Adapted from <https://iamroot.it/2021/07/01/powershell-enable-native-openssh-server-in-windows-2019-and-later/>.
#>
param(
    [Parameter(Mandatory = $True, Position = 1)]
    [string]$sshKey,
    [Parameter()]
    [string]$sshKeyFilePath = "$Env:ProgramData\ssh\administrators_authorized_keys",
    [Parameter()]
    [string]$opensshUrl = "https://github.com/PowerShell/Win32-OpenSSH/releases/download/v8.9.1.0p1-Beta/OpenSSH-Win64.zip"
)

Import-Module -Name "NetSecurity"

$ErrorActionPreference = "Stop"
 
# Setup windows update service to manual
$wuauserv = Get-Service 'wuauserv'
$wuauservStartType = $wuauserv.StartType
Set-Service wuauserv -StartupType Manual
 
# Install OpenSSH
$opensshPath = "$env:TEMP\openssh.zip"
$opensshDir = "$env:ProgramFiles\OpenSSH-Win64"
Invoke-WebRequest -Uri $opensshUrl -OutFile $opensshPath
Expand-Archive -Force -LiteralPath $opensshPath -DestinationPath $env:ProgramFiles
Push-Location $opensshDir
try {
    powershell.exe -ExecutionPolicy Bypass -File install-sshd.ps1
}
finally {
    Pop-Location
}

if (Get-NetFirewallRule -Name sshd) {
    Write-Output "Found matching rules, skipping creation…"
}
else {
    New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
}

# Configure SSH public key
Set-Content -Path $sshKeyFilePath -Value $sshKey
 
$adminsGroup = "S-1-5-32-544"
# set acl on administrators_authorized_keys
$admins = ([System.Security.Principal.SecurityIdentifier]$adminsGroup).Translate([System.Security.Principal.NTAccount]).Value
$acl = Get-Acl $sshKeyFilePath
$acl.SetAccessRuleProtection($true, $false)
$administratorsRule = New-Object system.security.accesscontrol.filesystemaccessrule($admins, "FullControl", "Allow")
$systemRule = New-Object system.security.accesscontrol.filesystemaccessrule("SYSTEM", "FullControl", "Allow")
$acl.SetAccessRule($administratorsRule)
$acl.SetAccessRule($systemRule)
$acl | Set-Acl
 
# Set service to automatic and start
Set-Service sshd -StartupType Automatic
Start-Service sshd
 
# Setup windows update service to original
Set-Service wuauserv -StartupType $wuauservStartType
 
# Configure PowerShell as the default shell
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "$Env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
 
# Restart the service
Restart-Service sshd
 
# Open firewall port 22
$FirewallParams = @{ 
    "DisplayName" = "OpenSSH SSH Server (sshd)"
    "Direction"   = "Inbound"
    "Action"      = "Allow"
    "Protocol"    = "TCP"
    "LocalPort"   = "22"
    "Program"     = "%SystemRoot%\system32\OpenSSH\sshd.exe"
}

New-NetFirewallRule @FirewallParams
