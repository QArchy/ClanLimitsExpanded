param(
    [string]$BannerlordDir = $env:BANNERLORD_DIR
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$sourceModule = Join-Path $repoRoot "module\ClanLimitsExpanded"
$sourceXml = Join-Path $sourceModule "SubModule.xml"
$sourceSettings = Join-Path $sourceModule "ClanLimitsExpanded.Settings.xml"
$sourceClientDll = Join-Path $sourceModule "bin\Win64_Shipping_Client\ClanLimitsExpanded.dll"
$sourceEditorDll = Join-Path $sourceModule "bin\Win64_Shipping_wEditor\ClanLimitsExpanded.dll"

if ([string]::IsNullOrWhiteSpace($BannerlordDir)) {
    throw "BannerlordDir is required. Pass -BannerlordDir or set BANNERLORD_DIR."
}

if (-not (Test-Path -LiteralPath $sourceXml)) {
    throw "SubModule.xml not found: $sourceXml"
}

if (-not (Test-Path -LiteralPath $sourceSettings)) {
    throw "Settings file not found: $sourceSettings"
}

if (-not (Test-Path -LiteralPath $sourceClientDll)) {
    throw "Built client DLL not found: $sourceClientDll. Run scripts\build.ps1 first."
}

if (-not (Test-Path -LiteralPath $sourceEditorDll)) {
    throw "Built editor DLL not found: $sourceEditorDll. Run scripts\build.ps1 first."
}

$bannerlordPath = Resolve-Path $BannerlordDir
$targetModule = Join-Path $bannerlordPath "Modules\ClanLimitsExpanded"
$targetClientBin = Join-Path $targetModule "bin\Win64_Shipping_Client"
$targetEditorBin = Join-Path $targetModule "bin\Win64_Shipping_wEditor"

New-Item -ItemType Directory -Path $targetClientBin -Force | Out-Null
New-Item -ItemType Directory -Path $targetEditorBin -Force | Out-Null
Copy-Item -LiteralPath $sourceXml -Destination $targetModule -Force
Copy-Item -LiteralPath $sourceSettings -Destination $targetModule -Force
Copy-Item -LiteralPath $sourceClientDll -Destination $targetClientBin -Force
Copy-Item -LiteralPath $sourceEditorDll -Destination $targetEditorBin -Force

Get-ChildItem -LiteralPath $targetModule -Recurse
