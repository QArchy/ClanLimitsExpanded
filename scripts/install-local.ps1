param(
    [string]$BannerlordDir = $env:BANNERLORD_DIR
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$sourceModule = Join-Path $repoRoot "module\ClanLimitsExpanded"
$sourceXml = Join-Path $sourceModule "SubModule.xml"
$sourceSettings = Join-Path $sourceModule "ClanLimitsExpanded.Settings.xml"
$sourceDll = Join-Path $sourceModule "bin\Win64_Shipping_Client\ClanLimitsExpanded.dll"

if ([string]::IsNullOrWhiteSpace($BannerlordDir)) {
    throw "BannerlordDir is required. Pass -BannerlordDir or set BANNERLORD_DIR."
}

if (-not (Test-Path -LiteralPath $sourceXml)) {
    throw "SubModule.xml not found: $sourceXml"
}

if (-not (Test-Path -LiteralPath $sourceSettings)) {
    throw "Settings file not found: $sourceSettings"
}

if (-not (Test-Path -LiteralPath $sourceDll)) {
    throw "Built DLL not found: $sourceDll. Run scripts\build.ps1 first."
}

$bannerlordPath = Resolve-Path $BannerlordDir
$targetModule = Join-Path $bannerlordPath "Modules\ClanLimitsExpanded"
$targetBin = Join-Path $targetModule "bin\Win64_Shipping_Client"

New-Item -ItemType Directory -Path $targetBin -Force | Out-Null
Copy-Item -LiteralPath $sourceXml -Destination $targetModule -Force
Copy-Item -LiteralPath $sourceSettings -Destination $targetModule -Force
Copy-Item -LiteralPath $sourceDll -Destination $targetBin -Force

Get-ChildItem -LiteralPath $targetModule -Recurse
