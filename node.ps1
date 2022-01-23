<#
.SYNOPSIS
 Installs multiple Node versions and npm packages.

.DESCRIPTION
 Uses fnm (which should have been installed via Cargo) to install all the required versions of Node and then installs the desired packages globally in the default version.
#>
Function Install-Node($fnmFile, $npmFile) {
    $versions = (Get-Content $fnmFile)
    foreach ($version in $versions) {
        fnm install $version
    }

    fnm use $versions[0]

    $packages = (Get-Content $npmFile)
    Write-Output "Installing $($packages.Count) npm packages…"
    npm i -g @packages
}
