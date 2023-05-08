$types = @("scoop", "chocolatey", "cargo", "npm", "pipx", "go")

function Install-ThirdPartyPackage {
    param(
        [Parameter(Mandatory=$True)]
        $details
    )

    switch ($details.type) {
        "scoop_bucket" { Install-ScoopBucket $details.scoop $details.repo }
        "scoop" { Install-ScoopApplication $details.scoop $details.version }
        "chocolatey" { Install-Chocolatey $details.chocolatey $details.version }
        "cargo" { Install-Cargo $details.cargo $details.version $details.features $details.git $details.branch }
        "npm" { Install-Npm $details.npm $details.version }
        "pipx" { Install-Pipx $details.pipx $details.version }
        "go" { Install-Go $details.go $details.version }
    }
}
Export-ModuleMember -Function Install-ThirdPartyPackage

function Install-ScoopBucket($name, $repository) {
    $params = @(,$name)
    if ($null -ne $repository) {
        $params += $repository
    }

    scoop bucket add @params
}

Function Install-ScoopApplication($name, $version) {
    if ($null -eq $version) {
        scoop install $name
    } else {
        scoop install $name@$version
    }
}

Function Install-Chocolatey($name, $version) {
    $params = @(,$name)
    if ($null -ne $version) {
        $params += "--version"
        $params += $version
    }

    choco upgrade @params
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
