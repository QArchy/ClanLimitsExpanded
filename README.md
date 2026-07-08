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

With default settings and vanilla Bannerlord 1.4.5 values before perks and before other mods:

| Clan tier | Extra parties | Companions | Workshops |
|---:|---:|---:|---:|
| 0 | +0 | 15 | 5 |
| 1 | +3 | 20 | 10 |
| 2 | +6 | 25 | 15 |
| 3 | +9 | 30 | 20 |
| 4 | +12 | 35 | 25 |
| 5 | +15 | 40 | 30 |
| 6 | +18 | 45 | 35 |

Companion limits are multiplied after Bannerlord calculates the existing result, so leadership/charm perks and compatible mods are included first.

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
