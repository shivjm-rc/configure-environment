<#
.SYNOPSIS
 Records latest versions of crates.io packages in the given file.
#>
param(
    [Parameter(Mandatory = $True, Position = 1)]
    [string]
    $filename
)

$ErrorActionPreference = "Stop"

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

# `ConvertFrom-Yaml` doesn’t preserve order, whereas
# `ConvertFrom-Json` does.
$rawJson = (yq -o json . $filename | Out-String)
$existing = ConvertFrom-Json $rawJson -AsHashtable

$new = @()

foreach ($package in $existing) {
    $name = $package.cargo
    if ($null -eq $name) {
        $new += $package
        continue
    }

    $updated = $packages[$name]

    if ($null -ne $package.version -and $null -ne $updated -and !($null -ne $updated.platform -and "windows" -notin $updated.platform)) {
        $package.version = $updated
    } else {
        Write-Debug "Skipping non-versioned package $($package.package)"
    }

    $new += $package
}

Set-Content $filename (ConvertTo-Json $new | yq -P .)
prettier -w $filename
