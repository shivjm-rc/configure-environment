<#
.SYNOPSIS
 Installs multiple Node versions and npm packages.

.DESCRIPTION
 Uses fnm (which should have been installed via Cargo) to install all the required versions of Node and then installs the desired packages globally in the default version.
#>
param(
    [Parameter(Mandatory = $True, Position = 1)]
    [string]
    $fnmFile,
    [Parameter(Mandatory = $True, Position = 2)]
    [string]
    $npmFile) 

$script:versions = (Get-Content $fnmFile)
foreach ($version in $script:versions) {
    fnm install $version
}

fnm use $script:versions[0]

$script:packages = (Get-Content $npmFile)
Write-Output "Installing $($script:packages.Count) npm packages…"
npm i -g @script:packages
