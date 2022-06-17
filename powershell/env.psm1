# stolen from Scoop:
# https://github.com/lukesampson/scoop/blob/092005046454d94d141d5c68fdbdb4c4a1229ae9/lib/core.ps1#L117-L121
<#
 .Synopsis
  Checks whether the current user is an administrator.

 .Outputs
  System.Boolean. IsAdmin returns `$True` if the current user is an administrator, `$False` otherwise.
#>
function Script:IsAdmin {
    $admin = [security.principal.windowsbuiltinrole]::administrator
    $id = [security.principal.windowsidentity]::getcurrent()
    ([security.principal.windowsprincipal]($id)).isinrole($admin)
}

Export-ModuleMember -Function IsAdmin

<#
 .Synopsis
  Sets an environment variable at the machine level.

 .Description
  Sets an environment variable at the machine level. Does nothing if the environment variable is already set to `$Value`. Attempts to acquire elevated privileges if necessary.

 .Parameter Name
  Specifies the name of the variable.

 .Parameter Value
  Specifies the value of the variable.

 .Example

  PS> SetMachineEnv -Name FOO -Value bar

  PS> $env:FOO
  bar
#>
Function Script:SetMachineEnv {
    param(
        [Parameter(Mandatory = $True)]
        [string]$Name,
        [Parameter(Mandatory = $True)]
        [string]$Value
    )

    if ((Get-Item -Path "Env:\\$Name" -ErrorAction SilentlyContinue).Value -eq $Value) {
        Write-Output "Environment variable $Name already set, skipping…"
        return
    }

    $expr = "[Environment]::SetEnvironmentVariable('$Name', '$Value', 'Machine')"

    if (IsAdmin) {
        Write-Output "Setting system environment variable $Name…"
        Invoke-Expression $expr
    } else {
        Write-Output "Setting system environment variable $Name in elevated process…"
        Start-Process pwsh -Verb runas -ArgumentList ('-c', $expr) -Wait -WindowStyle Hidden
    }

    Set-Item -Path "Env:\\$Name" -Value $Value
}

Export-ModuleMember -Function SetMachineEnv

# https://leftlobed.wordpress.com/2008/06/04/getting-the-current-script-directory-in-powershell/
<#
 .Synopsis
  Gets the parent directory of the script being executed.

 .Outputs
  String. The parent directory of the script being executed.
#>
function Get-ScriptDirectory {
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value
    Split-Path $Invocation.MyCommand.Path
}

$Global:ConfigDirectory = (Get-ScriptDirectory)
$Global:PackagesDirectory = "$Global:ConfigDirectory\\package-lists"
