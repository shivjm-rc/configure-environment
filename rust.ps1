<#
.SYNOPSIS
 Installs Rust and Cargo packages.
#>
param(
    [Parameter(Mandatory=$True, Position=1)]
    [string]
    $packagesFile
)

$ErrorActionPreference = "Stop"

Import-Module ".\env.psm1"

$script:RustupUri = 'https://win.rustup.rs/x86_64'
$script:RustupInstallerPath = "$env:TEMP\\rustup-init.exe"
$script:RustupArgs = ("-y", "--default-toolchain", "nightly-x86_64-pc-windows-msvc", "-c", "rust-src", "-c", "rust-analyzer-preview", "-c", "rustfmt", "-c", "clippy")
$script:Packages = ConvertFrom-Json (Get-Content -Raw $packagesFile)

$env:RUSTFLAGS = "-C target-feature=+crt-static"

if ($null -eq (Get-Command rustup -ErrorAction SilentlyContinue)) {
    Write-Output "Installing rustup & Rust…"
    Invoke-WebRequest -Uri $script:RustupUri -OutFile $script:RustupInstallerPath
    Start-Process $script:RustupInstallerPath -ArgumentList $script:RustupArgs
}

Write-Output "Setting the default toolchain to MSVC instead of GNU…"
rustup set default-host x86_64-pc-windows-msvc

Write-Output "Installing stable Rust toolchain…"
rustup toolchain add stable-x86_64-pc-windows-msvc

Write-Output "Installing $($script:Packages.Count) packages via Cargo…"

foreach ($package in $script:Packages) {
    $name = $package.package
    $arguments = @($name)

    Write-Output "Installing $name via Cargo…"

    foreach ($member in ($package | Get-Member -MemberType NoteProperty)) {
        $key = $member.Name
        $val = $package.$key
        if ($key -eq "package") {
            continue
        }

        $arguments += "--$key"
        $arguments += $val
    }

    Write-Debug "Calling cargo install $arguments"
    cargo install @arguments
    
    if ($LastExitCode -ne 0) {
        throw "Failed to install $name"
    }
}
