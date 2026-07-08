# CODEX_INSTRUCTIONS.md

## Current Mod

Project name:

```text
Clan Limits Expanded
```

Technical identifiers:

```text
Module ID: ClanLimitsExpanded
Assembly name: ClanLimitsExpanded
Root namespace: ClanLimitsExpanded
Submodule class: ClanLimitsExpanded.SubModule
Harmony ID: archy.bannerlord.clan-limits-expanded
Settings file: ClanLimitsExpanded.Settings.xml
```

Target game:

```text
Mount & Blade II: Bannerlord 1.4.5
Windows x64
.NET Framework 4.7.2
Steam install
```

The mod must stay small and use the shared `Bannerlord.Harmony` module. Do not copy `0Harmony.dll` or `TaleWorlds.*.dll` into the mod package.

## Behavior

The mod changes clan limits with Harmony postfixes and keeps existing values from vanilla and earlier-running mods.

Current formulas:

```text
party limit = existing party limit + clan tier * PartyTierBonusPerTier
companion limit = existing companion limit * CompanionLimitMultiplier
workshop limit = existing workshop limit * WorkshopLimitMultiplier
```

Default settings:

```xml
<PartyTierBonusPerTier value="3"/>
<CompanionLimitMultiplier value="5"/>
<WorkshopLimitMultiplier value="5"/>
```

Settings are read from:

```text
<BannerlordDir>\Modules\ClanLimitsExpanded\ClanLimitsExpanded.Settings.xml
```

Settings are applied on game start. Values below `0` are treated as `0`; values above `100` are capped at `100`.

## Harmony Patch Points

Use postfix patches with:

```text
[HarmonyPostfix]
[HarmonyPriority(Priority.Last)]
```

Patch points:

```text
DefaultClanTierModel.GetPartyLimitForTier(Clan clan, int clanTierToCheck)
DefaultClanTierModel.GetCompanionLimit(Clan clan)
DefaultWorkshopModel.GetMaxWorkshopCountForClanTier(int tier)
```

Do not patch `DefaultWorkshopModel.MaximumWorkshopsPlayerCanHave` separately: in Bannerlord 1.4.5 it calls `GetMaxWorkshopCountForClanTier`, so patching both would multiply the same value twice.

## Scope

Current party and companion changes apply to player and AI clans. Workshop limits use the vanilla workshop model and affect callers of that model.

The mod should not:

- add save-game data;
- modify original game DLLs;
- include MCM, ButterLib, or UIExtenderEx dependencies;
- add UI unless explicitly requested;
- use a transpiler when a postfix is enough;
- use `int.MaxValue` for limits.

## Repository Layout

```text
ClanLimitsExpanded/
├── CODEX_INSTRUCTIONS.md
├── README.md
├── .gitignore
├── src/
│   └── ClanLimitsExpanded/
│       ├── ClanLimitsExpanded.csproj
│       └── SubModule.cs
├── module/
│   └── ClanLimitsExpanded/
│       ├── SubModule.xml
│       ├── ClanLimitsExpanded.Settings.xml
│       └── bin/
│           ├── Win64_Shipping_Client/
│           └── Win64_Shipping_wEditor/
└── scripts/
    ├── build.ps1
    ├── install-local.ps1
    └── package-workshop.ps1
```

## Build And Install

Expected local game path in this workspace:

```text
C:\Program Files (x86)\Steam\steamapps\common\Mount & Blade II Bannerlord
```

Build:

```powershell
.\scripts\build.ps1 -BannerlordDir "C:\Program Files (x86)\Steam\steamapps\common\Mount & Blade II Bannerlord"
```

Install locally:

```powershell
.\scripts\install-local.ps1 -BannerlordDir "C:\Program Files (x86)\Steam\steamapps\common\Mount & Blade II Bannerlord"
```

Package:

```powershell
.\scripts\package-workshop.ps1
```

Use `-Zip` to create:

```text
dist\ClanLimitsExpanded-v2.0.0.zip
```

## Verification

After C# or project edits:

1. Run `scripts\build.ps1`.
2. Confirm `0` errors and `0` warnings.
3. Run `scripts\install-local.ps1` if the user wants the game install updated.
4. Run `scripts\package-workshop.ps1` if package output should stay current.
5. Validate edited XML files with PowerShell `[xml]`.

Do not claim the game was tested unless Bannerlord was actually launched.
