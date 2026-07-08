param(
    [string]$BannerlordDir = $env:BANNERLORD_DIR,
    [switch]$IncludePdb
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$projectPath = Join-Path $repoRoot "src\ClanLimitsExpanded\ClanLimitsExpanded.csproj"
$moduleBin = Join-Path $repoRoot "module\ClanLimitsExpanded\bin\Win64_Shipping_Client"
$buildBin = Join-Path $repoRoot "src\ClanLimitsExpanded\bin\Release\net472"

if ([string]::IsNullOrWhiteSpace($BannerlordDir)) {
    throw "BannerlordDir is required. Pass -BannerlordDir or set BANNERLORD_DIR."
}

$bannerlordPath = Resolve-Path $BannerlordDir
$gameBin = Join-Path $bannerlordPath "bin\Win64_Shipping_Client"
$requiredDlls = @(
    "TaleWorlds.CampaignSystem.dll",
    "TaleWorlds.Core.dll",
    "TaleWorlds.MountAndBlade.dll",
    "TaleWorlds.ObjectSystem.dll"
)

foreach ($dll in $requiredDlls) {
    $path = Join-Path $gameBin $dll
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Required Bannerlord DLL not found: $path"
    }
}

dotnet build $projectPath -c Release -p:BannerlordDir="$bannerlordPath"
if ($LASTEXITCODE -ne 0) {
    throw "dotnet build failed with exit code $LASTEXITCODE"
}

if (Test-Path -LiteralPath $moduleBin) {
    Remove-Item -LiteralPath $moduleBin -Recurse -Force
}
New-Item -ItemType Directory -Path $moduleBin | Out-Null

$dllOut = Join-Path $buildBin "ClanLimitsExpanded.dll"
if (-not (Test-Path -LiteralPath $dllOut)) {
    throw "Build output DLL not found: $dllOut"
}

Copy-Item -LiteralPath $dllOut -Destination $moduleBin

if ($IncludePdb) {
    $pdbOut = Join-Path $buildBin "ClanLimitsExpanded.pdb"
    if (Test-Path -LiteralPath $pdbOut) {
        Copy-Item -LiteralPath $pdbOut -Destination $moduleBin
    }
}

Get-ChildItem -LiteralPath $moduleBin
