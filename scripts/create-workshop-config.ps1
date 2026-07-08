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

These are [b]model-level limit calculations[/b] from the installed Bannerlord 1.4.5 files, before perks, UI checks, purchase/build requirements, and other mods. They show the cap returned by the game's limit models, not a guarantee that every action is immediately available on day one.

[code]
Game file:
bin/Win64_Shipping_Client/TaleWorlds.CampaignSystem.dll

Game formulas:
DefaultClanTierModel.GetPartyLimitForTier:
  non-minor clans: 1 party at tiers 0-2, 2 at tiers 3-4, 3 at tier 5+

DefaultClanTierModel.GetCompanionLimitFromTier:
  clan tier + 3

DefaultWorkshopModel.GetMaxWorkshopCountForClanTier:
  clan tier + 1

Mod formulas with default settings:
Parties    = existing party limit + clan tier * 3
Companions = existing companion limit * 5
Workshops  = existing workshop limit * 5
[/code]

[code]
Clan Tier | Parties, vanilla -> mod | Companions        | Workshops
----------|--------------------------|-------------------|----------
0         | 1 -> 1                   | (0 + 3) * 5 = 15 | (0 + 1) * 5 = 5
1         | 1 -> 4                   | (1 + 3) * 5 = 20 | (1 + 1) * 5 = 10
2         | 1 -> 7                   | (2 + 3) * 5 = 25 | (2 + 1) * 5 = 15
3         | 2 -> 11                  | (3 + 3) * 5 = 30 | (3 + 1) * 5 = 20
4         | 2 -> 14                  | (4 + 3) * 5 = 35 | (4 + 1) * 5 = 25
5         | 3 -> 18                  | (5 + 3) * 5 = 40 | (5 + 1) * 5 = 30
6         | 3 -> 21                  | (6 + 3) * 5 = 45 | (6 + 1) * 5 = 35
[/code]

Companion limits are multiplied after the game calculates the base value, so leadership/charm perks and compatible mods are included before this mod applies its multiplier.

Workshop numbers are also model-level caps. The game or another mod may still apply separate requirements around buying, owning, building, or accessing workshops.

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
$lines.Add("      <Tag Value=""v1.4.5""/>")
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
