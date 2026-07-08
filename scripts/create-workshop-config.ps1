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
[h1]Clan Limits Expanded[/h1]

Configurable clan-limit expansion for Mount & Blade II: Bannerlord 1.4.5.

The mod keeps the game's existing values, including changes from compatible mods loaded before it, and then applies a small Harmony postfix bonus.

[h2]What It Changes[/h2]

[list]
[*][b]Clan party limit:[/b] existing limit + clan tier * configurable value
[*][b]Companion limit:[/b] existing limit * configurable value
[*][b]Workshop limit:[/b] existing limit * configurable value
[*][b]Applies to AI:[/b] party and companion limit changes apply to player and AI clans
[*][b]No save data:[/b] the mod does not add custom save-game records
[/list]

[h2]Default Settings[/h2]

[code]
PartyTierBonusPerTier = 3
CompanionLimitMultiplier = 5
WorkshopLimitMultiplier = 5
[/code]

Edit [b]ClanLimitsExpanded.Settings.xml[/b] in the module folder and restart the game to apply changes.

[h2]Examples With Default Settings[/h2]

These examples use the vanilla Bannerlord 1.4.5 formulas before perks and before other mods.

[code]
Clan Tier | Extra Parties | Companions | Workshops
----------|---------------|------------|----------
0         | +0            | 15         | 5
1         | +3            | 20         | 10
2         | +6            | 25         | 15
3         | +9            | 30         | 20
4         | +12           | 35         | 25
5         | +15           | 40         | 30
6         | +18           | 45         | 35
[/code]

Companion limits are multiplied after the game calculates the base value, so leadership/charm perks and compatible mods are included before this mod applies its multiplier.

[h2]Can I Add It Mid-Campaign?[/h2]

Yes. The mod only changes runtime limit calculations. It does not add campaign behaviors, settlements, troops, items, heroes, or custom save data.

Recommended:
[list]
[*]Enable it, load your save, and continue playing.
[*]Change settings only while the game is closed, then restart.
[*]Before disabling the mod, reduce parties/companions/workshops back under vanilla limits where possible.
[/list]

If you remove it while your save is above vanilla limits, the game may force restrictions or behave awkwardly because the extra capacity is gone.

[h2]Compatibility[/h2]

[list]
[*]Requires [b]Bannerlord.Harmony[/b].
[*]Designed for [b]Bannerlord 1.4.5[/b].
[*]No MCM, ButterLib, or UIExtenderEx dependency.
[*]May conflict with mods that replace DefaultClanTierModel or DefaultWorkshopModel.
[*]May conflict with mods that overwrite these limit methods after this mod.
[/list]

[h2]Load Order[/h2]

Put this mod after the official modules and after Bannerlord.Harmony:

[code]
Bannerlord.Harmony
Native
SandBoxCore
Sandbox
CustomBattle
StoryMode
ClanLimitsExpanded
[/code]

[h2]Source[/h2]

Git repository: QArchy / ClanLimitsExpanded
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
