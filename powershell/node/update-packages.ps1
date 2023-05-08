<#
.SYNOPSIS
 Updates npm package versions in the given file (skipping Git repositories).
#>
param(
    [Parameter(Mandatory = $True, Position = 1)]
    [string]
    $filename
)

$json = (yq -o json . $filename | Out-String)
$packages = (ConvertFrom-Json $json -AsHashtable)

$new = @()

foreach ($package in $packages) {
    $name = $package.npm

    if ($null -eq $name) {
        $new += $package
        continue
    }

    if ($null -ne $package.version) {
        $package.version = (npm show $name version)
    } else {
        Write-Debug "Skipping non-versioned package $($package.package)"
    }

    $new += $package
}

Set-Content $filename (ConvertTo-Json $new | yq -P .)
prettier -w $filename
