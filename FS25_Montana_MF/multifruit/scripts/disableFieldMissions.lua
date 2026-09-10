-- VidhosticeSDK
--
-- This script disables missions for crops listed in modDesc.xml
--
-- modDesc.xml
--    <disableFieldMissions>
--        <disabledCrop l10n="here type any text for debugging">CARROT</disabledCrop>
--        <disabledCrop>PARSNIP</disabledCrop>
--        <disabledCrop>BEETROOT</disabledCrop>
--        <disabledCrop>COTTON</disabledCrop>
--        <disabledCrop>SUGARCANE</disabledCrop>
--        <disabledCrop>POTATO</disabledCrop>
--        <disabledCrop>SUGARBEET</disabledCrop>
--        <disabledCrop>GREENBEAN</disabledCrop>
--        <disabledCrop>PEA</disabledCrop>
--        <disabledCrop>SPINACH</disabledCrop>
--    </disableFieldMissions>
--
-- free for all, enjoy :-)

disableFieldMissions = {
    printDebug = false,
    disabledCrops = {}
}
disableFieldMissions.currentModName = g_currentModName
disableFieldMissions.currentModDirectory = g_currentModDirectory
disableFieldMissions.modDesc = g_currentModDirectory .. "modDesc.xml"


function disableFieldMissions:loadMap(savegame)
    local xmlFile = XMLFile.load("modDesc", disableFieldMissions.modDesc)
    if xmlFile:hasProperty("modDesc.disableFieldMissions.disabledCrop(0)") then
        for _, item in xmlFile:iterator("modDesc.disableFieldMissions.disabledCrop") do
            local crop = xmlFile:getString(item)
            local l10nCrop = xmlFile:getString(item .. "#l10n")
            if disableFieldMissions.printDebug  then
                if string.isNilOrWhitespace(l10nCrop) then
                    Logging.info("Debug: modDesc.disableFieldMissions.disabledCrop: %q", crop)
                else
                    Logging.info("Debug: modDesc.disableFieldMissions.disabledCrop: %q - %q", crop, l10nCrop)
                end
            end
            if string.isNilOrWhitespace(crop) then
                Logging.warning("disableFieldMissions has empty disabledCrop at %q", item)
            elseif not table.addElement(disableFieldMissions.disabledCrops, crop) then
                Logging.warning("disableFieldMissions has duplicate disabledCrop %q at %q", crop, item)
            end
        end
    end
    xmlFile:delete()

    for name, fruitType in pairs(g_fruitTypeManager.nameToFruitType) do
        for _, cropName in ipairs(disableFieldMissions.disabledCrops) do
            if name == cropName then
                fruitType.useForFieldMissions = false
                Logging.info("disableFieldMissions: %q > useForFieldJob = false", name)
                break
            end
        end
    end
end


addModEventListener(disableFieldMissions)
Logging.info("disableFieldMissions - loaded")
