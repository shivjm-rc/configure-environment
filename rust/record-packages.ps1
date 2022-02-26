<#
.SYNOPSIS
 Records latest versions of crates.io packages in the given file.
#>
param(
    [Parameter(Mandatory = $True, Position = 1)]
    [string]
    $filename
)

$headerMarker = "Package*"

$cargoUpdateOutput = (cargo install-update -l) -split "`n"

$pastHeader = $false

$packages = @{}

foreach ($line in $cargoUpdateOutput) {
    if (!$pastHeader) {
        if ($line -like $headerMarker) {
            $pastHeader = $true
        }

        continue
    }

    $parts = $line -split "\s+"

    if ($parts.Length -lt 4) {
        continue
    }

    $name = $parts[0]
    $version = $parts[1] -replace "v",""

    Write-Debug "Package: $name $version"

    $packages[$name] = $version
}

$existing = ConvertFrom-Json (Get-Content $filename -Raw)

$new = @()

foreach ($package in $existing) {
    $updated = $packages[$package.package]
    if ($null -ne $package.version -and $null -ne $updated) {
        $package.version = $updated
    } else {
        Write-Debug "Skipping non-versioned package $($package.package)"
    }

    $new += $package
}

Set-Content $filename (ConvertTo-Json $new)
prettier -w $filename
