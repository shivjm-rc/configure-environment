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

$buckets = @(
    @{ "name" = "extras" },
    @{ "name" = "nerd-fonts" },
    @{ "name" = "java" },
    @{ "name" = "nonportable"},
    @{ "name" = "smallstep"; "repo" = "https://github.com/smallstep/scoop-bucket.git" }
)

foreach ($bucket in $buckets) {
    if ($bucket.ContainsKey("repo")) {
        scoop bucket add $bucket.name $bucket.repo
    } else {
        scoop bucket add $bucket.name
    }

    if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne 2) {
        throw "Failed to add bucket $($bucket.name)"
    }
}
