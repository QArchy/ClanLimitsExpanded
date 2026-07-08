# Clan Limits Expanded

Small singleplayer mod for Mount & Blade II: Bannerlord 1.4.5.

Steam Workshop:

```text
https://steamcommunity.com/sharedfiles/filedetails/?id=3760490973
```

Workshop preview image:

```text
assets/workshop-preview.jpg
```

Final party, companion, and workshop limits:

```text
existing party limit + clan tier * PartyTierBonusPerTier
existing companion limit * CompanionLimitMultiplier
existing workshop limit * WorkshopLimitMultiplier
```

The mod uses Harmony postfixes on `DefaultClanTierModel.GetPartyLimitForTier`, `DefaultClanTierModel.GetCompanionLimit`, and `DefaultWorkshopModel` workshop limit methods. Party and companion changes apply to player and AI clans; workshop limits use the vanilla workshop model.

Default settings:

```xml
<PartyTierBonusPerTier value="3"/>
<CompanionLimitMultiplier value="5"/>
<WorkshopLimitMultiplier value="5"/>
```

Edit `ClanLimitsExpanded.Settings.xml` in the module folder and restart the game to apply changes. Values below `0` are treated as `0`; values above `100` are capped at `100`.

## Examples

These are model-level limit calculations from the installed Bannerlord 1.4.5 files, before perks, UI checks, purchase/build requirements, and other mods. They show the cap returned by the game's limit models, not a guarantee that every action is immediately available on day one.

Game source references:

```text
bin/Win64_Shipping_Client/TaleWorlds.CampaignSystem.dll

DefaultClanTierModel.GetPartyLimitForTier:
  non-minor clans: 1 party at tiers 0-2, 2 at tiers 3-4, 3 at tier 5+

DefaultClanTierModel.GetCompanionLimitFromTier:
  clan tier + 3

DefaultWorkshopModel.GetMaxWorkshopCountForClanTier:
  clan tier + 1
```

Mod formulas with default settings:

```text
Parties    = existing party limit + clan tier * 3
Companions = existing companion limit * 5
Workshops  = existing workshop limit * 5
```

| Clan tier | Parties, vanilla -> mod | Companions | Workshops |
|---:|---:|---:|---:|
| 0 | 1 -> 1 | `(0 + 3) * 5 = 15` | `(0 + 1) * 5 = 5` |
| 1 | 1 -> 4 | `(1 + 3) * 5 = 20` | `(1 + 1) * 5 = 10` |
| 2 | 1 -> 7 | `(2 + 3) * 5 = 25` | `(2 + 1) * 5 = 15` |
| 3 | 2 -> 11 | `(3 + 3) * 5 = 30` | `(3 + 1) * 5 = 20` |
| 4 | 2 -> 14 | `(4 + 3) * 5 = 35` | `(4 + 1) * 5 = 25` |
| 5 | 3 -> 18 | `(5 + 3) * 5 = 40` | `(5 + 1) * 5 = 30` |
| 6 | 3 -> 21 | `(6 + 3) * 5 = 45` | `(6 + 1) * 5 = 35` |

Companion limits are multiplied after Bannerlord calculates the existing result, so leadership/charm perks and compatible mods are included first.

Workshop numbers are model-level caps. The game or another mod may still apply separate requirements around buying, owning, building, or accessing workshops.

## Save Compatibility

The mod can be added in the middle of an existing campaign. It changes runtime limit calculations only and does not add custom save-game data.

Before disabling the mod, reduce parties/companions/workshops back under vanilla limits where possible. If a save remains above vanilla limits after removal, the game may force restrictions or behave awkwardly because the extra capacity is gone.

## Requirements

- Mount & Blade II: Bannerlord 1.4.5
- Bannerlord.Harmony
- Windows x64
- .NET Framework 4.7.2 reference assemblies for building

## Source

Git repository: `QArchy / ClanLimitsExpanded`

## Build

```powershell
.\scripts\build.ps1 -BannerlordDir "D:\SteamLibrary\steamapps\common\Mount & Blade II Bannerlord"
```

The build copies only `ClanLimitsExpanded.dll` to:

```text
module/ClanLimitsExpanded/bin/Win64_Shipping_Client/
module/ClanLimitsExpanded/bin/Win64_Shipping_wEditor/
```

It does not copy `0Harmony.dll` or `TaleWorlds.*.dll`.

## Install Locally

```powershell
.\scripts\install-local.ps1 -BannerlordDir "D:\SteamLibrary\steamapps\common\Mount & Blade II Bannerlord"
```

Expected game module layout:

```text
Mount & Blade II Bannerlord/
└── Modules/
    └── ClanLimitsExpanded/
        ├── SubModule.xml
        ├── ClanLimitsExpanded.Settings.xml
        └── bin/
            ├── Win64_Shipping_Client/
                └── ClanLimitsExpanded.dll
            └── Win64_Shipping_wEditor/
                └── ClanLimitsExpanded.dll
```

## Workshop Package

```powershell
.\scripts\package-workshop.ps1
```

Use `-Zip` to also create `dist/ClanLimitsExpanded-v2.0.0.zip`.

Create a Steam Workshop uploader config:

```powershell
.\scripts\create-workshop-config.ps1
```

For later updates, pass the existing Workshop item id:

```powershell
.\scripts\create-workshop-config.ps1 -ItemId "3760490973"
```

## Notes

- Singleplayer only.
- Adds no save-game data.
- Reads user settings from `ClanLimitsExpanded.Settings.xml`.
- Changes player and AI clan party/companion limits.
- Multiplies workshop limits by the configured value, default `5`.
- Does not change individual party size.
- May conflict with mods that replace `DefaultClanTierModel` or overwrite `GetPartyLimitForTier` after this mod.
- May conflict with mods that overwrite `GetCompanionLimit` after this mod.
- May conflict with mods that replace `DefaultWorkshopModel` or overwrite its workshop limit methods after this mod.
