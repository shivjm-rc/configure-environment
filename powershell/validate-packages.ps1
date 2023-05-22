param(
    [Parameter(Mandatory=$True, Position=0)]
    [string]
    $packagesYaml,
    [Parameter(Mandatory=$True, Position=1)]
    [string]
    $schema,
    [Parameter(Mandatory=$False)]
    [string]
    $yqPath = "yq"
)

$ErrorActionPreference = "Stop"

Test-Json (yq -o json $packagesYaml) -SchemaFile $schema


