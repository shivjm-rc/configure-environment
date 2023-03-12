Import-Module "./env.psm1"

SetMachineEnv -Name 'SCOOP' -Value 'C:\App\Scoop'
SetMachineEnv -Name 'SCOOPGLOBAL' -Value 'C:\App\ScoopApps'

if ($null -eq (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy RemoteSigned -scope Process
    Invoke-WebRequest get.scoop.sh | Invoke-Expression
} else {
    Write-Verbose "Scoop already installed, skipping…"
}

if ($null -eq (scoop list aria2 6>$null | select-string aria2)) {
    scoop install aria2
    scoop config aria2-warning-enabled false
}

# $script:ScoopApps = (Get-Content "$Global:PackagesDirectory\\scoop")
# Write-Output "Installing $($script:ScoopApps.Count) Scoop apps…"
# scoop install @script:ScoopApps
# scoop uninstall vcredist2019    # remove leftover installer
# # TODO install TeraCopy

# if ($LASTEXITCODE -ne 0) {
#     exit 1
# }
