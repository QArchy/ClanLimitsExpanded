param(
    [string]$OutputPath,
    [string]$ItemId,
    [ValidateSet("Public", "FriendsOnly", "Private")]
    [string]$Visibility = "Private",
    [string]$ImagePath,
    [string]$ChangeNotes = "Initial release."
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$moduleFolder = Join-Path $repoRoot "dist\ClanLimitsExpanded"
$moduleXml = Join-Path $moduleFolder "SubModule.xml"

if (-not (Test-Path -LiteralPath $moduleXml)) {
    throw "Workshop package not found: $moduleXml. Run scripts\package-workshop.ps1 first."
}

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $workshopDir = Join-Path $repoRoot "workshop"
    New-Item -ItemType Directory -Path $workshopDir -Force | Out-Null
    $fileName = if ([string]::IsNullOrWhiteSpace($ItemId)) { "WorkshopCreate.xml" } else { "WorkshopUpdate.xml" }
    $OutputPath = Join-Path $workshopDir $fileName
}

$description = @"
Configurable clan limit expansion for Mount & Blade II: Bannerlord 1.4.5.

Features:
- Party limit: existing limit + clan tier * configurable value
- Companion limit: existing limit * configurable value
- Workshop limit: existing limit * configurable value
- Party and companion changes apply to player and AI clans
- No save-game data
- Requires Bannerlord.Harmony

Default settings:
PartyTierBonusPerTier = 3
CompanionLimitMultiplier = 5
WorkshopLimitMultiplier = 5

Edit ClanLimitsExpanded.Settings.xml and restart the game to apply changes.
"@

function Convert-ToXmlAttributeValue {
    param([string]$Value)
    return [System.Security.SecurityElement]::Escape($Value)
}

$escapedModuleFolder = Convert-ToXmlAttributeValue ([System.IO.Path]::GetFullPath($moduleFolder))
$escapedDescription = Convert-ToXmlAttributeValue $description
$escapedChangeNotes = Convert-ToXmlAttributeValue $ChangeNotes
$escapedVisibility = Convert-ToXmlAttributeValue $Visibility

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("<Tasks>")

if ([string]::IsNullOrWhiteSpace($ItemId)) {
    $lines.Add("  <CreateItem/>")
} else {
    $escapedItemId = Convert-ToXmlAttributeValue $ItemId
    $lines.Add("  <GetItem>")
    $lines.Add("    <ItemId Value=""$escapedItemId""/>")
    $lines.Add("  </GetItem>")
}

$lines.Add("  <UpdateItem>")
$lines.Add("    <ModuleFolder Value=""$escapedModuleFolder""/>")
$lines.Add("    <ItemDescription Value=""$escapedDescription""/>")
$lines.Add("    <Tags>")
$lines.Add("      <Tag Value=""Singleplayer""/>")
$lines.Add("      <Tag Value=""Gameplay""/>")
$lines.Add("      <Tag Value=""Utility""/>")
$lines.Add("    </Tags>")

if (-not [string]::IsNullOrWhiteSpace($ImagePath)) {
    $resolvedImagePath = Resolve-Path $ImagePath
    $escapedImagePath = Convert-ToXmlAttributeValue ([System.IO.Path]::GetFullPath($resolvedImagePath))
    $lines.Add("    <Image Value=""$escapedImagePath""/>")
}

$lines.Add("    <ChangeNotes Value=""$escapedChangeNotes""/>")
$lines.Add("    <Visibility Value=""$escapedVisibility""/>")
$lines.Add("  </UpdateItem>")
$lines.Add("</Tasks>")

$outputDirectory = Split-Path -Parent $OutputPath
if (-not [string]::IsNullOrWhiteSpace($outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
}

Set-Content -LiteralPath $OutputPath -Value $lines -Encoding UTF8
Get-Item -LiteralPath $OutputPath
