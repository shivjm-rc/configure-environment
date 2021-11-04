Import-Module ".\env.psm1"

$script:RustupUri = 'https://win.rustup.rs/x86_64'
$script:RustupInstallerPath = "$env:TEMP\\rustup-init.exe"
$script:RustupArgs = ("-y", "--default-toolchain", "nightly-x86_64-pc-windows-msvc", "-c", "rust-src", "-c", "rust-analyzer-preview", "-c", "rustfmt", "-c", "clippy")
$script:Packages = ConvertFrom-Json (Get-Content -Raw "$Global:PackagesDirectory\\cargo.json")

$env:RUSTFLAGS = "-C target-feature=+crt-static"

Function Initialize-Rust() {
    if ($null -eq (Get-Command rustup -ErrorAction SilentlyContinue)) {
        Write-Output "Installing rustup & Rust…"
        Invoke-WebRequest -Uri $script:RustupUri -OutFile $script:RustupInstallerPath
        Start-Process $script:RustupInstallerPath -ArgumentList $script:RustupArgs
    }

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
    }
}
