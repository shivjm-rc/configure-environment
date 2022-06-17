<#
.SYNOPSIS
 Installs Go packages.

.DESCRIPTION
 Globally installs the Go packages listed in the file.
#>
param(
    [Parameter(Mandatory = $True, Position = 1)]
    [string]
    $file)

$script:packages = (Get-Content $file)
Write-Output "Installing $($script:packages.Count) Go packages…"

foreach ($package in $script:packages) {
    go install $package
}
