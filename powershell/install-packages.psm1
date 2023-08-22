$types = @("scoop", "chocolatey", "cargo", "npm", "pipx", "go")

function Install-ThirdPartyPackage {
    param(
        [Parameter(Mandatory=$True)]
        $details
    )

        if ($details.ContainsKey("scoop")) { Install-ScoopApplication $details.scoop $details.version }
        elseif ($details.ContainsKey("chocolatey")) { Install-Chocolatey $details.chocolatey $details.version $details.parameters }
        elseif ($details.ContainsKey("cargo")) { Install-Cargo $details.cargo $details.version $details.features $details.git $details.branch }
        elseif ($details.ContainsKey("npm")) { Install-Npm $details.npm $details.version }
        elseif ($details.ContainsKey("pipx")) { Install-Pipx $details.pipx $details.version }
        elseif ($details.ContainsKey("go")) { Install-Go $details.go $details.version }
          elseif ($details.ContainsKey("vcpkg")) { Install-Vcpkg $details.vcpkg }
    else { throw "Don’t know how to install package: $($details.name)" }

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to install $($details.name)"
    }
}
Export-ModuleMember -Function Install-ThirdPartyPackage

Function Install-ScoopApplication($name, $version) {
    if ($null -eq $version) {
        scoop install $name
    } else {
        scoop install $name@$version
    }
}

Function Install-Chocolatey($name, $version, $parameters) {
    $params = @(,$name)
    if ($null -ne $version) {
        $params += "--version"
        $params += $version
    }

    $parametersArgs = @()
    if ($null -ne $parameters) {
        $parametersArgs = @("--package-parameters", $parameters)
    }

    choco upgrade -y @params @parametersArgs
}

Function Install-Cargo($name, $version, $features, $git, $branch) {
    $params = if ($null -ne $git) {
        @("--git", $git)
    } else {
        @("--version", $version)
    }

    if ($null -ne $branch) {
        $params += "--branch"
        $params += $branch
    }

    if ($null -ne $features) {
        $params += "--features"
        $params += ($features -join ",")
    }

    cargo install $name @params
}

Function Install-Npm($name, $version) {
    if ($null -ne (Get-Command fnm -ErrorAction SilentlyContinue)) {
        fnm use system
    }

    if ($null -ne $version) {
        npm install -g $name@$version
    } else {
        npm install -g $name
    }
}

Function Install-Pipx($name, $version) {
    if ($null -ne $version) {
        pipx install $name==$version
    } else {
        pipx install $name
    }
}

Function Install-Go($url, $version) {
    go install $url@$version
}

Function Install-Vcpkg($package) {
    vcpkg install $package
}
