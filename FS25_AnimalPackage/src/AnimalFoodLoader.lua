AnimalFoodLoader = {}

local modDirectory = g_currentModDirectory
local modName = g_currentModName

function AnimalFoodLoader.loadMapData(self, superFunc, xmlFile, missionInfo)
    -- 1. Futtatjuk az eredeti betöltést, hogy az alap játék adatai betöltődjenek
    local success = superFunc(self, xmlFile, missionInfo)
    if not success then
        return false
    end

    -- 2. Meghatározzuk a mi saját XML fájlunk elérési útját a modon belül
    local customXmlPath = Utils.getFilename("xmls/animalFood.xml", modDirectory)
    
    -- Ellenőrizzük, hogy létezik-e a fájl
    if fileExists(customXmlPath) then
        local customXml = XMLFile.load("customAnimalFood", customXmlPath, AnimalFoodSystem.xmlSchema)
        
        if customXml ~= nil then
            local mapEnvironment = self.customEnvironment
            self.customEnvironment = modName

            -- 3. Ráküldjük a betöltő függvényeket a mi XML-ünkre
            -- Ez hozzáadja az új állatokat (RABBIT), és felülírja azokat, amiket módosítottál
            self:loadAnimalFood(customXml)
            self:loadMixtures(customXml)
            self:loadRecipes(customXml)

            customXml:delete()
            self.customEnvironment = mapEnvironment
        end
    else
        Logging.warning("Az egyedi animalFood.xml nem található ezen az útvonalon: %s", customXmlPath)
    end
    
    return true
end

-- Felülírjuk az eredeti funkciót a miénkkel
AnimalFoodSystem.loadMapData = Utils.overwrittenFunction(AnimalFoodSystem.loadMapData, AnimalFoodLoader.loadMapData)