using System;
using System.Globalization;
using System.IO;
using System.Reflection;
using System.Xml.Linq;
using HarmonyLib;
using TaleWorlds.CampaignSystem;
using TaleWorlds.CampaignSystem.GameComponents;
using TaleWorlds.MountAndBlade;

namespace ClanLimitsExpanded
{
    public sealed class SubModule : MBSubModuleBase
    {
        private const string HarmonyId = "archy.bannerlord.clan-limits-expanded";

        private Harmony _harmony;

        protected override void OnSubModuleLoad()
        {
            base.OnSubModuleLoad();

            ModSettings.Load(Assembly.GetExecutingAssembly());

            _harmony = new Harmony(HarmonyId);
            _harmony.PatchAll(Assembly.GetExecutingAssembly());
        }
    }

    internal static class ModSettings
    {
        private const int DefaultPartyTierBonusPerTier = 3;
        private const int DefaultCompanionLimitMultiplier = 5;
        private const int DefaultWorkshopLimitMultiplier = 5;
        private const int MaxConfiguredValue = 100;
        private const string SettingsFileName = "ClanLimitsExpanded.Settings.xml";

        internal static int PartyTierBonusPerTier { get; private set; } = DefaultPartyTierBonusPerTier;
        internal static int CompanionLimitMultiplier { get; private set; } = DefaultCompanionLimitMultiplier;
        internal static int WorkshopLimitMultiplier { get; private set; } = DefaultWorkshopLimitMultiplier;

        internal static void Load(Assembly assembly)
        {
            PartyTierBonusPerTier = DefaultPartyTierBonusPerTier;
            CompanionLimitMultiplier = DefaultCompanionLimitMultiplier;
            WorkshopLimitMultiplier = DefaultWorkshopLimitMultiplier;

            string settingsPath = GetSettingsPath(assembly);
            if (string.IsNullOrEmpty(settingsPath) || !File.Exists(settingsPath))
                return;

            XDocument document;
            try
            {
                document = XDocument.Load(settingsPath);
            }
            catch (IOException)
            {
                return;
            }
            catch (UnauthorizedAccessException)
            {
                return;
            }
            catch (System.Xml.XmlException)
            {
                return;
            }

            XElement root = document.Root;
            if (root == null)
                return;

            PartyTierBonusPerTier = ReadInt(root, nameof(PartyTierBonusPerTier), DefaultPartyTierBonusPerTier);
            CompanionLimitMultiplier = ReadInt(root, nameof(CompanionLimitMultiplier), DefaultCompanionLimitMultiplier);
            WorkshopLimitMultiplier = ReadInt(root, nameof(WorkshopLimitMultiplier), DefaultWorkshopLimitMultiplier);
        }

        private static string GetSettingsPath(Assembly assembly)
        {
            string assemblyPath = assembly.Location;
            if (string.IsNullOrEmpty(assemblyPath))
                return null;

            DirectoryInfo directory = Directory.GetParent(assemblyPath);
            DirectoryInfo moduleRoot = directory != null && directory.Parent != null
                ? directory.Parent.Parent
                : null;

            return moduleRoot == null
                ? null
                : Path.Combine(moduleRoot.FullName, SettingsFileName);
        }

        private static int ReadInt(XElement root, string name, int defaultValue)
        {
            XElement element = root.Element(name);
            string rawValue = element == null
                ? null
                : (string)element.Attribute("value") ?? element.Value;

            int value;
            if (!int.TryParse(rawValue, NumberStyles.Integer, CultureInfo.InvariantCulture, out value))
                return defaultValue;

            if (value < 0)
                return 0;

            return Math.Min(value, MaxConfiguredValue);
        }
    }

    [HarmonyPatch(
        typeof(DefaultClanTierModel),
        nameof(DefaultClanTierModel.GetPartyLimitForTier),
        new Type[] { typeof(Clan), typeof(int) })]
    internal static class PartyLimitPatch
    {
        [HarmonyPostfix]
        [HarmonyPriority(Priority.Last)]
        private static void Postfix(Clan clan, int clanTierToCheck, ref int __result)
        {
            if (clan == null)
                return;

            int tier = Math.Max(0, clanTierToCheck);
            __result += tier * ModSettings.PartyTierBonusPerTier;
        }
    }

    [HarmonyPatch(
        typeof(DefaultClanTierModel),
        nameof(DefaultClanTierModel.GetCompanionLimit),
        new Type[] { typeof(Clan) })]
    internal static class CompanionLimitPatch
    {
        [HarmonyPostfix]
        [HarmonyPriority(Priority.Last)]
        private static void Postfix(Clan clan, ref int __result)
        {
            if (clan == null)
                return;

            __result *= ModSettings.CompanionLimitMultiplier;
        }
    }

    [HarmonyPatch(
        typeof(DefaultWorkshopModel),
        nameof(DefaultWorkshopModel.GetMaxWorkshopCountForClanTier),
        new Type[] { typeof(int) })]
    internal static class WorkshopLimitForTierPatch
    {
        [HarmonyPostfix]
        [HarmonyPriority(Priority.Last)]
        private static void Postfix(ref int __result)
        {
            __result *= ModSettings.WorkshopLimitMultiplier;
        }
    }
}
