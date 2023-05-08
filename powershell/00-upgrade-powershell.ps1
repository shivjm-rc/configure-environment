<#
.Synopsis
 Prepares the PowerShell environment.

.Description
 Prepares the PowerShell environment. Requires elevated privileges.
#>

param()

$ErrorActionPreference = "Stop"

if ($PSVersionTable.PSVersion -lt ((Invoke-RestMethod 'https://raw.githubusercontent.com/PowerShell/PowerShell/master/tools/metadata.json').ReleaseTag -replace '^v')) {
    Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) } -UseMSI -Quiet"
}
