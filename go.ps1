<#
.SYNOPSIS
 Installs Go packages.

.DESCRIPTION
 Globally installs the Go packages listed in the file.
#>
Function Install-GoPackages($file) {
    $packages = (Get-Content $file)
    Write-Output "Installing $($packages.Count) Go packages…"

    foreach ($package in $packages) {
        go install $package
    }
}
