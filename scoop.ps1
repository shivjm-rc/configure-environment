Import-Module "./env.psm1"

SetMachineEnv -Name 'SCOOP' -Value 'C:\App\Scoop'
SetMachineEnv -Name 'SCOOPGLOBAL' -Value 'C:\App\ScoopApps'

if ((Get-Command scoop -ErrorAction SilentlyContinue) -eq $null) {
    Set-ExecutionPolicy RemoteSigned -scope Process
    iwr get.scoop.sh | iex
}
else {
    Write-Output "Scoop already installed, skipping…"
}

Write-Output "Installing Git to add buckets…"
scoop install git

Write-Output "Installing aria2 for faster downloads…"
scoop bucket add extras
scoop install aria2

$script:ScoopApps = (Get-Content "$Global:PackagesDirectory\\scoop")
Write-Output "Installing $($script:ScoopApps.Count) Scoop apps…"
scoop install @script:ScoopApps
scoop uninstall vcredist2019    # remove leftover installer
# TODO install TeraCopy

if ($LASTEXITCODE -ne 0) {
    exit 1
}
