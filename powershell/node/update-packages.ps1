<#
.SYNOPSIS
 Updates package versions in the given file (skipping Git repositories).
#>
param(
    [Parameter(Mandatory = $True, Position = 1)]
    [string]
    $filename
)

$script:separator = @"
@
"@.Trim()

Function script:Get-Newest($line) {
    $parts = $line.Trim() -split $script:separator
    $name = $parts[0]

    $version = (npm show $name version)

    return "$name@$version"
}

Function script:Is-Package($line) {
    return $line -like "*@*"
}

$script:lines = (Get-Content $filename)

foreach ($line in $script:lines) {
    if (Is-Package($line)) {
        Write-Debug "Package found: $line"
        Write-Output (script:Get-Newest $line)
    } else {
        Write-Debug "No package: $line"
        Write-Output $line
    }
}
