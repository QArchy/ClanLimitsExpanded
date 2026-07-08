param(
    [switch]$Zip
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$sourceModule = Join-Path $repoRoot "module\ClanLimitsExpanded"
$sourceXml = Join-Path $sourceModule "SubModule.xml"
$sourceSettings = Join-Path $sourceModule "ClanLimitsExpanded.Settings.xml"
$sourceDll = Join-Path $sourceModule "bin\Win64_Shipping_Client\ClanLimitsExpanded.dll"
$distRoot = Join-Path $repoRoot "dist"
$packageRoot = Join-Path $distRoot "ClanLimitsExpanded"
$packageBin = Join-Path $packageRoot "bin\Win64_Shipping_Client"

if (-not (Test-Path -LiteralPath $sourceDll)) {
    throw "Built DLL not found: $sourceDll. Run scripts\build.ps1 first."
}

if (-not (Test-Path -LiteralPath $sourceSettings)) {
    throw "Settings file not found: $sourceSettings"
}

$resolvedRepo = [System.IO.Path]::GetFullPath($repoRoot)
$resolvedPackage = [System.IO.Path]::GetFullPath($packageRoot)
if (-not $resolvedPackage.StartsWith($resolvedRepo, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to package outside repository: $resolvedPackage"
}

if (Test-Path -LiteralPath $packageRoot) {
    Remove-Item -LiteralPath $packageRoot -Recurse -Force
}

New-Item -ItemType Directory -Path $packageBin | Out-Null
Copy-Item -LiteralPath $sourceXml -Destination $packageRoot
Copy-Item -LiteralPath $sourceSettings -Destination $packageRoot
Copy-Item -LiteralPath $sourceDll -Destination $packageBin

if ($Zip) {
    $zipPath = Join-Path $distRoot "ClanLimitsExpanded-v2.0.0.zip"
    if (Test-Path -LiteralPath $zipPath) {
        Remove-Item -LiteralPath $zipPath -Force
    }
    Compress-Archive -Path $packageRoot -DestinationPath $zipPath
    Get-Item -LiteralPath $zipPath
} else {
    Get-ChildItem -LiteralPath $packageRoot -Recurse
}
