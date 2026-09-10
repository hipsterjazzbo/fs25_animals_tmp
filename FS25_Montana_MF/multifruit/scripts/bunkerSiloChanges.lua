-- all the bunkerSilo related changes for MaizePlus
-- fillTypes, inputs and outputs are loaded via maizePlus_bunkerSilo.xml now

-- by modelleicher (Farming Agency)


bunkerSiloChanges = {}
addModEventListener(bunkerSiloChanges);

bunkerSiloChanges.modDirectory = g_currentModDirectory

-- add XML Schema
g_xmlManager:addCreateSchemaFunction(function ()
	bunkerSiloChanges.xmlSchema = XMLSchema.new("bunkerSilo")
end)

-- register XML Schema and load data from maizePlus_bunkerSilo.xml
function bunkerSiloChanges:loadMap(n)

    local schema = bunkerSiloChanges.xmlSchema
	local basePath = "bunkerSilo"

    schema:register(XMLValueType.INT, basePath .. "#fillLevelSwitchingLimit", "Max fillLevel where switching is allowed", 4000)
    schema:register(XMLValueType.STRING, basePath .. ".bunkerSiloType(?)#attachTo", "Base Filltype BunkerSilo has to have for this to attach to", "chaff")
    schema:register(XMLValueType.STRING, basePath .. ".bunkerSiloType(?)#inputFillType", "Input Filltype of SiloType", nil, true)  
    schema:register(XMLValueType.STRING, basePath .. ".bunkerSiloType(?)#outputFillType", "Output Filltype of SiloType", nil, true)  
    schema:register(XMLValueType.STRING, basePath .. ".bunkerSiloType(?).acceptedFillTypes#beforeSwitchLimit", "Accepted FillTypes before switching Limit is reached", nil, true)  
    schema:register(XMLValueType.STRING, basePath .. ".bunkerSiloType(?).acceptedFillTypes#afterSwitchLimit", "Accepted FillTypes after switching Limit is reached and Input is locked", nil, true)  
    schema:register(XMLValueType.STRING, basePath .. ".bunkerSiloType(?).additionalSettings#noCompaction", "This FillType does not need compaction", nil, false)  
    schema:register(XMLValueType.STRING, basePath .. ".bunkerSiloType(?).additionalSettings#noFermenting", "This FillType does not need fermenting", nil, false)  

    local xml = XMLFile.load("bunkerSiloXMLFile", bunkerSiloChanges.modDirectory.."multifruit/scripts/bunkerSiloConverters.xml", bunkerSiloChanges.xmlSchema)
    local basePath = "bunkerSilo"

    bunkerSiloChanges.fillLevelSwitchingLimit = xml:getValue(basePath.."#fillLevelSwitchingLimit")

    bunkerSiloChanges.bunkerSiloTypes = {}
	
	bunkerSiloChanges.beforeSwitchLimitToBunkerSiloType = {}

    local i = 0
    while true do
        local bunkerSiloType = {}
        local typePath = basePath..".bunkerSiloType("..i..")"

        local attachTo = xml:getValue(typePath.."#attachTo")
        if attachTo == nil then
            break
        end
        bunkerSiloType.attachTo = string.upper(attachTo)
        bunkerSiloType.inputFillType = string.upper(xml:getValue(typePath.."#inputFillType"))
        bunkerSiloType.outputFillType = string.upper(xml:getValue(typePath.."#outputFillType"))

        local beforeSwitchLimit = string.upper(xml:getValue(typePath..".acceptedFillTypes#beforeSwitchLimit"))
        local afterSwitchLimit = string.upper(xml:getValue(typePath..".acceptedFillTypes#afterSwitchLimit"))

        bunkerSiloType.acceptedFillTypes = {}
        bunkerSiloType.acceptedFillTypes.beforeSwitchLimit = beforeSwitchLimit:split(" ")
        bunkerSiloType.acceptedFillTypes.afterSwitchLimit = afterSwitchLimit:split(" ")
		
		-- reference table for accepted filLTypes before switch limit 
		for _, fillTypeName in pairs(bunkerSiloType.acceptedFillTypes.beforeSwitchLimit) do
			bunkerSiloChanges.beforeSwitchLimitToBunkerSiloType[g_fillTypeManager:getFillTypeIndexByName(fillTypeName)] = bunkerSiloType
		end

        bunkerSiloType.noFermenting = xml:getValue(typePath..".additionalSettings#noFermenting")
        bunkerSiloType.noCompaction = xml:getValue(typePath..".additionalSettings#noCompaction")

        bunkerSiloChanges.bunkerSiloTypes[i+1] = bunkerSiloType

        i = i+1
    end

end


function bunkerSiloChanges.bunkerSiloLoad(self, superFunc, components, xmlFile, key, i3dMappings)
    local returnValue = superFunc(self, components, xmlFile, key, i3dMappings)

        local isMaizePlusSilo = false -- per default we don't touch the silo, only if the right fillType exists in the silo already

        self.bunkerSiloTypes = bunkerSiloChanges.bunkerSiloTypes

        -- run through all our siloTypes in our XML
        for i = 1, #self.bunkerSiloTypes do
            local bunkerSiloType = self.bunkerSiloTypes[i]

            -- our fillType matches a bunkerSiloType we attach to
            if self.acceptedFillTypes[g_fillTypeManager:getFillTypeIndexByName(bunkerSiloType.attachTo)] then 
		
                isMaizePlusSilo = true

                -- add accepted FillTypes (the ones that are accepted prior to the switchingLimit reaching, e.g. those that are used to determine what it switches to)
                local acceptedFillTypes = bunkerSiloType.acceptedFillTypes
				
                for a = 1, #acceptedFillTypes.beforeSwitchLimit do
                    self.acceptedFillTypes[g_fillTypeManager:getFillTypeIndexByName(acceptedFillTypes.beforeSwitchLimit[a])] = true      
                end
            end
        end
        if isMaizePlusSilo then
            -- update the converting fillType areas to convert the new acceptedFillTypes too 
            g_densityMapHeightManager:setConvertingFillTypeAreas(self.bunkerSiloArea, self.acceptedFillTypes, self.inputFillType)	

            -- add maizePlus specific variables 
            self.fillLevelSwitchingLimit = bunkerSiloChanges.fillLevelSwitchingLimit
            self.allowFillLevelSwitching = true

            -- backup compaction distance
            self.distanceToCompactedFillLevelBackup = self.distanceToCompactedFillLevel

            -- backup acceptedFillTypes 
            self.acceptedFillTypesBackup = {}
            for index, _ in pairs (self.acceptedFillTypes) do
                self.acceptedFillTypesBackup[index] = true
            end           
        end

    return returnValue
end
BunkerSilo.load = Utils.overwrittenFunction(BunkerSilo.load, bunkerSiloChanges.bunkerSiloLoad)

function bunkerSiloChanges.registerSavegameXMLPaths(schema, basePath)
	schema:register(XMLValueType.STRING, basePath .. "#inputFillType", "Current Input FillType", "chaff")
    schema:register(XMLValueType.STRING, basePath .. "#outputFillType", "Current Output FillType", "silage")   
end
BunkerSilo.registerSavegameXMLPaths = Utils.appendedFunction(BunkerSilo.registerSavegameXMLPaths, bunkerSiloChanges.registerSavegameXMLPaths)


function bunkerSiloChanges.saveToXMLFile(self, xmlFile, key, usedModNames)
	if self.fillLevelSwitchingLimit ~= nil then
        xmlFile:setValue(key .. "#inputFillType", g_fillTypeManager:getFillTypeByIndex(self.inputFillType).name)
        xmlFile:setValue(key .. "#outputFillType", g_fillTypeManager:getFillTypeByIndex(self.outputFillType).name)
	end
end
BunkerSilo.saveToXMLFile = Utils.appendedFunction(BunkerSilo.saveToXMLFile, bunkerSiloChanges.saveToXMLFile)

function bunkerSiloChanges.loadFromXMLFile(self, superFunc, xmlFile, key)
	local returnValue = superFunc(self, xmlFile, key)

	if self.fillLevelSwitchingLimit ~= nil then		
		local inputFillType =  xmlFile:getValue(key .. "#inputFillType")
		local outputFillType = xmlFile:getValue(key .. "#outputFillType")

		local fillLevel = xmlFile:getValue(key .. "#fillLevel")
		
		if inputFillType ~= nil and inputFillType ~= "" and outputFillType ~= nil and outputFillType ~= "" then
			self.inputFillType = g_fillTypeManager:getFillTypeIndexByName(inputFillType)
			self.outputFillType = g_fillTypeManager:getFillTypeIndexByName(outputFillType)

			-- reset convertingFillTypeAreas 
			g_densityMapHeightManager:removeConvertingFillTypeAreas(self.bunkerSiloArea)
			g_densityMapHeightManager:setConvertingFillTypeAreas(self.bunkerSiloArea, self.acceptedFillTypes, self.inputFillType)

		end
	end
	
	return returnValue
end	
BunkerSilo.loadFromXMLFile = Utils.overwrittenFunction(BunkerSilo.loadFromXMLFile, bunkerSiloChanges.loadFromXMLFile)


function bunkerSiloChanges.readStream(self, streamId, connection, objectID)
	if connection:getIsServer() then
		if self.fillLevelSwitchingLimit ~= nil then
		
			local inputFillType = streamReadUIntN(streamId, FillTypeManager.SEND_NUM_BITS)
			local outputFillType = streamReadUIntN(streamId, FillTypeManager.SEND_NUM_BITS)

			if inputFillType ~= nil and outputFillType ~= nil then
				self.inputFillType = inputFillType
				self.outputFillType = outputFillType

				g_densityMapHeightManager:removeConvertingFillTypeAreas(self.bunkerSiloArea)
				g_densityMapHeightManager:setConvertingFillTypeAreas(self.bunkerSiloArea, self.acceptedFillTypes, self.inputFillType)
			end
		end
    end
end
BunkerSilo.readStream = Utils.appendedFunction(BunkerSilo.readStream, bunkerSiloChanges.readStream)

function bunkerSiloChanges.writeStream(self, streamId, connection)
    if not connection:getIsServer() then
		if self.fillLevelSwitchingLimit ~= nil then
			streamWriteUIntN(streamId, self.inputFillType, FillTypeManager.SEND_NUM_BITS)
			streamWriteUIntN(streamId, self.outputFillType, FillTypeManager.SEND_NUM_BITS)	
		end
    end
end
BunkerSilo.writeStream = Utils.appendedFunction(BunkerSilo.writeStream, bunkerSiloChanges.writeStream)


function bunkerSiloChanges.updateTick(self, dt)

    if self.fillLevelSwitchingLimit ~= nil then

		-- we reached the switching limit threshold, disable switching, reset acceptedFillTypes, update convertingArea 
		if self.allowFillLevelSwitching and self.fillLevel > self.fillLevelSwitchingLimit then 

            -- reset allowFillLevelSwitching
			self.allowFillLevelSwitching = false
			
			-- reset acceptedFillTypes 
			self.acceptedFillTypes = {}	

            -- inputFillType is always accepted FillType
            self.acceptedFillTypes[self.inputFillType] = true
            -- cycle through our bunkerSiloTypes and find matching
            for i = 1, #self.bunkerSiloTypes do
                local bunkerSiloType = self.bunkerSiloTypes[i]

                -- if we find matching type just add the acceptedFillTypes afterSwitchLimit to acceptedFillTypes
                if self.inputFillType == g_fillTypeManager:getFillTypeIndexByName(bunkerSiloType.inputFillType) then
                    local acceptedFillTypes = bunkerSiloType.acceptedFillTypes
                    for a = 1, #acceptedFillTypes.afterSwitchLimit do
                        self.acceptedFillTypes[g_fillTypeManager:getFillTypeIndexByName(acceptedFillTypes.afterSwitchLimit[a])] = true
                    end  
                    
                    -- also add additional settings of no compaction and no fermentation
                    self.distanceToCompactedFillLevel = self.distanceToCompactedFillLevelBackup
                    if bunkerSiloType.noCompaction then
                        self.distanceToCompactedFillLevel = 1000000000000000000000000
                    end
                    self.noFermenting = nil
                    if bunkerSiloType.noFermenting then
                        self.noFermenting = true
                    end
     
                end
            end
            
			-- reset convertingFillTypeAreas 
			g_densityMapHeightManager:removeConvertingFillTypeAreas(self.bunkerSiloArea)
			g_densityMapHeightManager:setConvertingFillTypeAreas(self.bunkerSiloArea, self.acceptedFillTypes, self.inputFillType)
			
            
        end

        -- no fermenting silo, set to fermented immediately once closed
        if self.allowFillLevelSwitching == false then

            if self.noFermenting then
                if self.state == BunkerSilo.STATE_CLOSED and self.isServer then
                    self.fermentingPercent = 1
                    self:raiseDirtyFlags(self.bunkerSiloDirtyFlag)
                    self:setState(BunkerSilo.STATE_FERMENTED, true)
                end
            end
        end
 
        -- reset allowFillLevelSwitching if silo is below switching limit and in fill-mode or empty 
		if self.allowFillLevelSwitching == false and (self.fillLevel < 4000 and self.state == BunkerSilo.STATE_FILL or self.fillLevel == 0) then 
			self.allowFillLevelSwitching = true
			
			self.acceptedFillTypes = self.acceptedFillTypesBackup	
		end

    end

end
BunkerSilo.updateTick = Utils.appendedFunction(BunkerSilo.updateTick, bunkerSiloChanges.updateTick)


function bunkerSiloChanges.interactionTriggerCallback(self, triggerId, otherId, onEnter, onLeave, onStay, otherShapeId)

    if self.fillLevelSwitchingLimit ~= nil then
		if onEnter then
			local vehicle = g_currentMission.nodeToObject[otherShapeId]

			if vehicle ~= nil and vehicle.spec_fillUnit ~= nil  then

                for fillUnitIndex, fillUnit in pairs(vehicle.spec_fillUnit.fillUnits) do
                    
                    -- if the bunkerSilo fill Level is below our set limit and we have something in the fillUnit continue 
                    if self.allowFillLevelSwitching and fillUnit.fillLevel > 0 then
                        local oldInputFillType = self.inputFillType
                        local newInputFillType = self.inputFillType
                        local newOutputFillType = self.outputFillType
                        
                        -- find if fillUnit is filled with something the bunkerSilo accepts
                        for fillType, _ in pairs(self.acceptedFillTypes) do
							if fillUnit.fillType == fillType then 
							    -- if fillType matches, find input and output according to bunkerSiloTypes reference
								local bunkerSiloType = bunkerSiloChanges.beforeSwitchLimitToBunkerSiloType[fillType]
								if bunkerSiloType ~= nil then
									newInputFillType = g_fillTypeManager:getFillTypeIndexByName(bunkerSiloType.inputFillType)
									newOutputFillType = g_fillTypeManager:getFillTypeIndexByName(bunkerSiloType.outputFillType)   
								end
							end
						end
						
                        -- finally set the new fillTypes 
                        if newInputFillType ~= self.inputFillType then
                            g_densityMapHeightManager:removeConvertingFillTypeAreas(self.bunkerSiloArea)
                            g_densityMapHeightManager:setConvertingFillTypeAreas(self.bunkerSiloArea, self.acceptedFillTypes, newInputFillType)
                            self.inputFillType = newInputFillType
                            self.outputFillType = newOutputFillType
                            local area = self.bunkerSiloArea
                            local offsetFront = self:getBunkerAreaOffset(true, 0, self.inputFillType)
                            local offsetBack = self:getBunkerAreaOffset(false, 0, self.inputFillType)
                            local changed = DensityMapHeightUtil.changeFillTypeAtArea(area.sx, area.sz, area.wx, area.wz, area.hx, area.hz, oldInputFillType, newInputFillType)
                        end
                    end
                end
            end
        end
    end
end
BunkerSilo.interactionTriggerCallback = Utils.appendedFunction(BunkerSilo.interactionTriggerCallback, bunkerSiloChanges.interactionTriggerCallback)

