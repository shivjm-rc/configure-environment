Import-Module './env.psm1'

Write-Output "Importing Python registry file with sudo…"
sudo reg import "$env:SCOOP\apps\python\current\install-pep-514.reg"

Write-Output "Installing pipx…"
python3 -m pip install --user pipx

Write-Output "Adding $script:PythonScriptsDirectory to ``PATH``…"
$script:PythonDirectory = (Get-ChildItem -path "$env:APPDATA\python") | Select-Object -first 1
$script:PythonScriptsDirectory = "$($script:PythonDirectory)\Scripts"
$script:ExistingPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
$script:NewPath = $script:ExistingPath + ";" + $script:PythonScriptsDirectory
SetMachineEnv -Name 'PATH' -Value $script:NewPath

Write-Output "Installing pipx packages…"
$script:PipxPackages = Get-Content ("$Global:PackagesDirectory\\pipx") | Join-String -Separator " "
pipx install @script:PipxPackages
