param(
    [Parameter(Mandatory = $True, Position = 1)]
    [string]$rustBuildDirectory,
    [Parameter(Mandatory = $True, Position = 2)]
    [string]$triggerTime,
    [Parameter(Mandatory = $False)]
    [int]$limitInDays = 30
)

$trigger = New-ScheduledTaskTrigger -Daily -At $triggerTime
$action = New-ScheduledTaskAction -Execute 'pwsh' -Argument "-c 'Push-Location $rustBuildDirectory && cargo sweep --hidden --recursive --time $limitInDays *>&1 > $rustBuildDirectory/sweep.log'"
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType "S4U" -RunLevel Highest

New-Item $rustBuildDirectory -ItemType Directory
New-Item $rustBuildDirectory\target -ItemType Directory
Push-Location $rustBuildDirectory
cargo init
Remove-Item -Recurse src

Register-ScheduledTask -TaskName "Clean-Rust" -Action $action -Trigger $trigger -Principal $principal
