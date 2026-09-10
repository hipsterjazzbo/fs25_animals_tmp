AnimalsLoader = {}

local modName = g_currentModName
local modDirectory = g_currentModDirectory
local animalXmls = {
    "xmls/animals/cow.xml",
    "xmls/animals/pig.xml",
    "xmls/animals/sheep.xml",
    "xmls/animals/horse.xml",
    "xmls/animals/chicken.xml",
	"xmls/animals/rabbit.xml"
}

function AnimalsLoader.loadAnimals(self, superFunc, xmlFile, baseDirectory)
    local mapEnvironment = self.customEnvironment
    self.customEnvironment = modName

    local supportedAnimalTypes = {}

    for _, value in ipairs(animalXmls) do
        local path = Utils.getFilename(value, modDirectory)
        local animalTypeXml = XMLFile.load("animals", path)

        for _, animalKey in animalTypeXml:iterator("animals.animal") do
            local typeName = animalTypeXml:getString(animalKey .."#type")
            table.insert(supportedAnimalTypes, typeName)
        end

        superFunc(self, animalTypeXml, modDirectory)
    end

    local animalsToRemove = {}
    for _, animalKey in xmlFile:iterator("animals.animal") do
        local typeName = xmlFile:getString(animalKey .."#type")
        if (table.find(supportedAnimalTypes, typeName)) then
            table.insert(animalsToRemove, animalKey)
        end
    end

    for _, animalPath in AnimalsLoader:rpairs(animalsToRemove) do
        xmlFile:removeProperty(animalPath)
    end

    self.customEnvironment = mapEnvironment
    return superFunc(self, xmlFile, baseDirectory)
end

AnimalSystem.loadAnimals = Utils.overwrittenFunction(AnimalSystem.loadAnimals, AnimalsLoader.loadAnimals)

function AnimalsLoader:rpairs(t)
	return function(t, i)
		i = i - 1
		if i ~= 0 then
			return i, t[i]
		end
	end, t, #t + 1
end

function AnimalsLoader.loadVisualData(self, superFunc, animalType, xmlFile, key, baseDirectory)
	local returnValue = superFunc(self, animalType, xmlFile, key, baseDirectory)

    local textureIndexes = {}

    xmlFile:iterate(key .. ".textureIndexes", function (_, textureIndexesKey)
        xmlFile:iterate(textureIndexesKey .. ".value", function (_, valueKey)
            local textureIndex = xmlFile:getInt(valueKey)
            table.insert(textureIndexes, textureIndex)
        end)
    end)

    if #textureIndexes > 0 then
        returnValue.textureIndexes = textureIndexes
    end

    return returnValue
end

AnimalSystem.loadVisualData = Utils.overwrittenFunction(AnimalSystem.loadVisualData, AnimalsLoader.loadVisualData)

function AnimalsLoader.loadSubType(self, superFunc, animalType, subType, xmlFile, subTypeKey, baseDirectory)
    local value = superFunc(self, animalType, subType, xmlFile, subTypeKey, baseDirectory)

    for _, visual in pairs(subType.visuals) do
        if visual.textureIndexes ~= nil then
            local visualAnimal = AnimalsLoader:deepcopy(visual.visualAnimal)
            local variations = {}

            for _, v in pairs(visual.textureIndexes) do
                table.insert(variations, visualAnimal.variations[v])
            end

            if #variations > 0 then
                visualAnimal.variations = variations
                visual.visualAnimal = visualAnimal
            end
        end
    end

    return value
end

AnimalSystem.loadSubType = Utils.overwrittenFunction(AnimalSystem.loadSubType, AnimalsLoader.loadSubType)

function AnimalsLoader:deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[AnimalsLoader:deepcopy(orig_key)] = AnimalsLoader:deepcopy(orig_value)
        end
        setmetatable(copy, AnimalsLoader:deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

function AnimalsLoader.updateVisuals(self, superFunc)
    superFunc(self)

    local animalIdToCluster = self.animalIdToCluster or {}

    for animalId, cluster in pairs(animalIdToCluster) do
        local subTypeIndex = cluster:getSubTypeIndex()
        local age = cluster:getAge()
        local visualData = self.animalSystem:getVisualByAge(subTypeIndex, age)
        local variations = visualData.visualAnimal.variations

        if #variations > 1 then
            -- JAVÍTÁS: math.random helyett az animalId alapján osztunk fix textúrát
            local variationIndex = (animalId % #variations) + 1
            local variation = variations[variationIndex]
            setAnimalTextureTile(self.husbandryId, animalId, variation.tileUIndex, variation.tileVIndex)
        else
            local variation = variations[1]
            setAnimalTextureTile(self.husbandryId, animalId, variation.tileUIndex, variation.tileVIndex)
        end

        local animalRootNode = getAnimalRootNode(self.husbandryId, animalId)
		local x, y, z, w = getAnimalShaderParameter(self.husbandryId, animalId, "atlasInvSizeAndOffsetUV")
		I3DUtil.setShaderParameterRec(animalRootNode, "atlasInvSizeAndOffsetUV", x, y, z, w)
    end
end

AnimalClusterHusbandry.updateVisuals = Utils.overwrittenFunction(AnimalClusterHusbandry.updateVisuals, AnimalsLoader.updateVisuals)