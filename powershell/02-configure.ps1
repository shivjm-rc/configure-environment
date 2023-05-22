<#
 .Synopsis
  Configures installed applications.

 .Description
  Configures installed applications using known settings and by copying existing data where appropriate.

 .Parameter AppsSource
  Existings `App` directory.

 .Parameter UserProfileSource
  Existing user profile directory.

 .Parameter MediaSource
  Existing `Media` directory.

 .Parameter AllTheIconsCommit
  Commit reference to use when downloading all-the-icons fonts.
#>

param(
    [Parameter(Mandatory = $True)]
    [String]$AppsSource,
    [Parameter(Mandatory = $True)]
    [String]$UserProfileSource,
    [Parameter(Mandatory = $True)]
    [String]$MediaSource,
    [Parameter(Mandatory = $False)]
    [String]$AllTheIconsCommit
)

$ErrorActionPreference = "Stop"

Import-Module './env.psm1'
Import-Module './fonts.psm1'

Write-Output "You must install Iosevka and Iosevka Aile manually."

. './python.ps1'

Write-Output "Copying .gitconfig…"
$script:GitConfigSource = $UserProfileSource + '\.gitconfig'
Copy-Item -Force -Path $script:GitConfigSource -Destination $env:USERPROFILE\.gitconfig -Recurse

Write-Output "Setting both ``GNUPG_HOME`` and ``GNUPGHOME``…"
$script:GpgHome = $MediaSource + '\My\GPG'
SetMachineEnv -Name "GNUPG_HOME" -Value $script:GpgHome
SetMachineEnv -Name "GNUPGHOME" -Value $script:GpgHome

Write-Output "Copying Emacs config…"
$script:EmacsDirectoriesToInclude = (Get-Content "../emacs-files-to-ignore")
$script:EmacsSourceDirectory = "$UserProfileSource\AppData\Roaming\.emacs.d"
$script:EmacsDestinationDirectory = "$env:APPDATA\.emacs.d"
New-Item -Path $script:EmacsDestinationDirectory -Force -ItemType Directory
Copy-Item -Path $script:EmacsSourceDirectory\* -Recurse -Include $script:EmacsDirectoriesToExclude -Destination $script:EmacsDestinationDirectory -Force

Write-Output "Installing all-the-icons fonts…"
$script:AllTheIconsCommit = ($AllTheIconsCommit -eq "" ? "master" : $AllTheIconsCommit)
$script:AllTheIconsUrl = "https://github.com/domtronn/all-the-icons.el/archive/$script:AllTheIconsCommit.zip"
Write-Output "Downloading $script:AllTheIconsUrl…"
Invoke-WebRequest -OutFile $env:TEMP\all-the-icons.zip -Uri $script:AllTheIconsUrl
Expand-Archive -Force -LiteralPath $env:TEMP\all-the-icons.zip -DestinationPath $env:TEMP\all-the-icons
try {
    $script:expr = "Install-Fonts `"$env:TEMP\all-the-icons\all-the-icons.el-$($script:AllTheIconsCommit)\fonts`""
    Start-Process pwsh -Verb runas -ArgumentList ('-c', $script:expr) -Wait -WindowStyle Hidden
}
finally {
    Remove-Item -Path $env:TEMP\all-the-icons* -Recurse -Force
}

Copy-Item -Path $AppsSource\Scoop\persist -Recurse -Force -Destination $env:SCOOP
Copy-Item -Path $AppsSource\ScoopApps\persist -Recurse -Force -Destination $env:SCOOP_GLOBAL

New-Item -Path "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" -Value "Invoke-Expression '. `"D:\Media\src\my\powershell\profile.ps1`"'" -Force

SetMachineEnv -Name "EXE4J_JAVA_HOME" -Value $env:JAVA_HOME

Copy-Item -Path $UserProfileSource\.ripgreprc
SetMachineEnv -Name "RIPGREP_CONFIG_PATH" -Value "$env:USERPROFILE\.ripgreprc"


# TODO: Add Git config, yt-dlp config
