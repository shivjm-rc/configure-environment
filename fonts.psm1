$script:FontsRegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"

<#
 .Synopsis
  Globally installs all TrueType fonts under a folder.

 .Description
  Globally installs all TrueType fonts under a folder. Ignores anything that isn’t recognized as a TrueType font. Based on <https://4sysops.com/archives/install-fonts-with-a-powershell-script/>.

 .Parameter Folder
  Path to folder containing TrueType fonts.
#>
Function script:Install-Fonts {
    param(
        [Parameter(Mandatory = $True)]
        [string]$Folder
    )

    $objShell = New-Object -ComObject Shell.Application
    $objFolder = $objShell.namespace($Folder)
    Write-Output "objFolder: $objFolder"
    foreach ($font in $objFolder.items()) {
        $fileType = $objFolder.getDetailsOf($font, 2)
        $fontName = $objFolder.getDetailsOf($font, 0)

        if ($fileType -ne 'TrueType font file') {
            Write-Output "Skipping $fileType $fontName…"
            Continue
        }

        Write-Output "Copying $($fontName).ttf…"
        Copy-Item -Force $font.Path 'C:\Windows\Fonts'
        New-ItemProperty -Path $script:FontsRegistryPath -Name $fontName -Value "$($fontName).ttf" -PropertyType String -Force
    }
}

Export-ModuleMember -Function Install-Fonts
