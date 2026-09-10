FillTypeLoader = {}

local modDirectory = g_currentModDirectory
local modName = g_currentModName

if FillTypeManager.SEND_NUM_BITS < 9 then
    FillTypeManager.SEND_NUM_BITS = 9
end

function FillTypeLoader.loadFillTypesFromXML(xmlFile, missionInfo, baseDirectory)
    local fillTypesXML = loadXMLFile("fillTypes", modDirectory.."xmls/fillTypes.xml")
    g_fillTypeManager:loadFillTypes(fillTypesXML, modDirectory , false, modName)
end

FillTypeManager.loadMapData = Utils.appendedFunction(FillTypeManager.loadMapData, FillTypeLoader.loadFillTypesFromXML)