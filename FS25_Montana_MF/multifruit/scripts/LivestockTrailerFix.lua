-- ============================================================================
-- === LivestockTrailerFix.Lua
-- === Mod my [LSMT] Modding Team 
-- === LS25 /FS25
-- === Script by [LSMT] BaTt3RiE @ 2025
-- === Ver 1.0.0.0
-- ============================================================================

LivestockTrailerFix = {}

function LivestockTrailerFix.initSpecialization()
    g_storeManager:addSpecType("numAnimalsChicken", "shopListAttributeIconChicken", 
        LivestockTrailer.loadSpecValueNumberAnimalsChicken, 
        LivestockTrailer.getSpecValueNumberAnimalsChicken, StoreSpecies.VEHICLE)
end

function LivestockTrailer.loadSpecValueNumberAnimalsChicken(xmlFile, customEnvironment, baseDir)
    return LivestockTrailer.loadSpecValueNumberAnimals(xmlFile, customEnvironment, baseDir, "chicken")
end

function LivestockTrailer.getSpecValueNumberAnimalsChicken(storeItem, realItem)
    return LivestockTrailer.getSpecValueNumberAnimals(storeItem, realItem, "numAnimalsChicken")
end

LivestockTrailer.initSpecialization = Utils.prependedFunction(
    LivestockTrailer.initSpecialization, 
    LivestockTrailerFix.initSpecialization
)

print("LivestockTrailerFix: Script loaded")