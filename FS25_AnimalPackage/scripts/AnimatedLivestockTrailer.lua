AnimatedLivestockTrailer = {}

AnimatedLivestockTrailer.MOD_NAME = g_currentModName
AnimatedLivestockTrailer.SPEC_NAME = string.format("spec_%s.animatedLivestockTrailer", g_currentModName)
AnimatedLivestockTrailer.DEFAULT_TRACK = 0
AnimatedLivestockTrailer.MAX_ANIMATION_TRACKS = 2
AnimatedLivestockTrailer.animalConfigCache = {}
AnimatedLivestockTrailer.animalAssetsSchema = nil
AnimatedLivestockTrailer.locomotionSchema = nil
AnimatedLivestockTrailer.animationSchema = nil
AnimatedLivestockTrailer.dealerTrailerPatched = false
AnimatedLivestockTrailer.livestockTrailerOnLoadPatched = false
AnimatedLivestockTrailer.shopAnimalSpecsPatched = false
AnimatedLivestockTrailer.statisticsAnimalSpecsPatched = false
AnimatedLivestockTrailer.SHOP_ANIMAL_ICON_PREFIX = "$animatedLivestockTrailerAnimalIcon:"
AnimatedLivestockTrailer.GROUND_RAYCAST_COLLISION_MASK = CollisionFlag ~= nil and CollisionFlag.STATIC_OBJECT + CollisionFlag.BUILDING + CollisionFlag.ROAD + CollisionFlag.GROUND_TIP_BLOCKING + CollisionFlag.ANIMAL_POSITIONING or 0
AnimatedLivestockTrailer.SHOP_STATIC_ANIMAL_ICON_PROFILES = {
    shopListAttributeIconCow = true,
    shopListAttributeIconPig = true,
    shopListAttributeIconSheep = true,
    shopListAttributeIconHorse = true,
    shopListAttributeIconChicken = true
}
AnimatedLivestockTrailer.CLIP_FALLBACKS = {
    idle = {"idle1Source", "idleSource", "idle01Source", "idleBabySource"},
    walk = {"walkFwdLSource", "walkFwdSource", "walkFwdLBabySource", "walkFwdBabySource", "trotFwdLSource", "trotFwdSource", "trotFwdLBabySource", "trotFwdBabySource", "trotFwdBabyLSource"},
    run = {"runFwdLSource", "runFwdSource", "runFwdLBabySource", "runFwdBabySource", "trotFwdLSource", "trotFwdSource", "trotFwdLBabySource", "trotFwdBabySource", "trotFwdBabyLSource", "walkFwdLSource", "walkFwdSource", "walkFwdLBabySource", "walkFwdBabySource"}
}

function AnimatedLivestockTrailer.resolveFilename(filename, baseDirectory)
    if filename == nil or filename == "" then
        return nil
    end

    return Utils.getFilename(filename, baseDirectory)
end

function AnimatedLivestockTrailer.addConfigAlias(configs, filename, baseDirectory, config)
    local resolvedFilename = AnimatedLivestockTrailer.resolveFilename(filename, baseDirectory)

    if resolvedFilename ~= nil then
        configs[resolvedFilename] = config
    end
end

function AnimatedLivestockTrailer.patchAnimalScreenDealerTrailer()
    if AnimatedLivestockTrailer.dealerTrailerPatched or AnimalScreenDealerTrailer == nil then
        return
    end

    AnimatedLivestockTrailer.dealerTrailerPatched = true

    local oldGetSourcePrice = AnimalScreenDealerTrailer.getSourcePrice
    AnimalScreenDealerTrailer.getSourcePrice = function(controller, animalTypeIndex, itemIndex, numItems)
        if controller.sourceItems == nil or controller.sourceItems[animalTypeIndex] == nil or controller.sourceItems[animalTypeIndex][itemIndex] == nil then
            return false, 0, 0, 0
        end

        return oldGetSourcePrice(controller, animalTypeIndex, itemIndex, numItems)
    end

    local oldGetSourceMaxNumAnimals = AnimalScreenDealerTrailer.getSourceMaxNumAnimals
    AnimalScreenDealerTrailer.getSourceMaxNumAnimals = function(controller, animalTypeIndex, itemIndex)
        if controller.sourceItems == nil or controller.sourceItems[animalTypeIndex] == nil or controller.sourceItems[animalTypeIndex][itemIndex] == nil then
            return 0
        end

        return oldGetSourceMaxNumAnimals(controller, animalTypeIndex, itemIndex)
    end

    local oldGetApplySourceConfirmationText = AnimalScreenDealerTrailer.getApplySourceConfirmationText
    AnimalScreenDealerTrailer.getApplySourceConfirmationText = function(controller, animalTypeIndex, itemIndex, numItems)
        if controller.sourceItems == nil or controller.sourceItems[animalTypeIndex] == nil or controller.sourceItems[animalTypeIndex][itemIndex] == nil then
            return ""
        end

        return oldGetApplySourceConfirmationText(controller, animalTypeIndex, itemIndex, numItems)
    end

    local oldApplySource = AnimalScreenDealerTrailer.applySource
    AnimalScreenDealerTrailer.applySource = function(controller, animalTypeIndex, itemIndex, numItems)
        if controller.sourceItems == nil or controller.sourceItems[animalTypeIndex] == nil or controller.sourceItems[animalTypeIndex][itemIndex] == nil then
            return
        end

        local item = controller.sourceItems[animalTypeIndex][itemIndex]
        if item ~= nil and AnimatedLivestockTrailer.getCanLoadAnimalAge(controller.trailer, item:getAge()) == false then
            AnimatedLivestockTrailer.showAgeUnsupportedWarning(controller.trailer, controller.errorCallback)
            return false
        end

        return oldApplySource(controller, animalTypeIndex, itemIndex, numItems)
    end

    if AnimalScreenTrailerFarm ~= nil and AnimalScreenTrailerFarm.applyTarget ~= nil then
        local oldApplyTarget = AnimalScreenTrailerFarm.applyTarget
        AnimalScreenTrailerFarm.applyTarget = function(controller, animalTypeIndex, itemIndex, numItems)
            local item = controller.targetItems ~= nil and controller.targetItems[itemIndex] or nil
            local cluster = item ~= nil and controller.husbandry ~= nil and controller.husbandry:getClusterById(item:getClusterId()) or nil

            if AnimatedLivestockTrailer.getCanLoadAnimalCluster(controller.trailer, cluster) == false then
                AnimatedLivestockTrailer.showAgeUnsupportedWarning(controller.trailer, controller.errorCallback)
                return false
            end

            return oldApplyTarget(controller, animalTypeIndex, itemIndex, numItems)
        end
    end

    if AnimalScreenTrailer ~= nil and AnimalScreenTrailer.applySource ~= nil then
        local oldApplyTrailerSource = AnimalScreenTrailer.applySource
        AnimalScreenTrailer.applySource = function(controller, animalTypeIndex, itemIndex, numItems)
            local item = controller.sourceItems ~= nil and controller.sourceItems[animalTypeIndex] ~= nil and controller.sourceItems[animalTypeIndex][itemIndex] or nil
            local cluster = item ~= nil and item:getCluster() or nil

            if AnimatedLivestockTrailer.getCanLoadAnimalCluster(controller.trailer, cluster) == false then
                AnimatedLivestockTrailer.showAgeUnsupportedWarning(controller.trailer, controller.errorCallback)
                return false
            end

            return oldApplyTrailerSource(controller, animalTypeIndex, itemIndex, numItems)
        end
    end
end

function AnimatedLivestockTrailer.patchLivestockTrailerOnLoad()
    if AnimatedLivestockTrailer.livestockTrailerOnLoadPatched or LivestockTrailer == nil or LivestockTrailer.onLoad == nil then
        return
    end

    AnimatedLivestockTrailer.livestockTrailerOnLoadPatched = true

    local oldOnLoad = LivestockTrailer.onLoad
    LivestockTrailer.onLoad = function(vehicle, savegame)
        if vehicle.xmlFile ~= nil and vehicle.xmlFile:hasProperty("vehicle.animatedLivestockTrailer") and vehicle.xmlFile:getValue("vehicle.animatedLivestockTrailer#filterMissingAnimalTypes", true) then
            return AnimatedLivestockTrailer.loadFilteredLivestockTrailer(vehicle, savegame)
        end

        return oldOnLoad(vehicle, savegame)
    end
end

function AnimatedLivestockTrailer.loadFilteredLivestockTrailer(vehicle, savegame)
    local spec = vehicle.spec_livestockTrailer
    spec.animalPlaces = {}
    spec.animalTypeIndexToPlaces = {}

    local animalSystem = g_currentMission ~= nil and g_currentMission.animalSystem or nil
    local index = 0

    while true do
        local key = string.format("vehicle.livestockTrailer.animal(%d)", index)
        if not vehicle.xmlFile:hasProperty(key) then
            break
        end

        local typeName = vehicle.xmlFile:getValue(key .. "#type")
        local typeIndex = animalSystem ~= nil and animalSystem:getTypeIndexByName(typeName) or nil

        if typeIndex ~= nil then
            local place = {
                numUsed = 0,
                animalTypeIndex = typeIndex,
                slots = {}
            }

            local parentNode = vehicle.xmlFile:getValue(key .. "#node", nil, vehicle.components, vehicle.i3dMappings)
            local numSlots = math.abs(vehicle.xmlFile:getValue(key .. "#numSlots", 0))

            if parentNode == nil then
                Logging.xmlWarning(vehicle.xmlFile, "Missing animal slot node for '%s'", key)
            else
                local numChildren = getNumOfChildren(parentNode)
                if numChildren < numSlots then
                    Logging.xmlWarning(vehicle.xmlFile, "numSlots is greater than available children for '%s'", key)
                    numSlots = numChildren
                end

                for slotIndex = 0, numSlots - 1 do
                    table.insert(place.slots, {
                        linkNode = getChildAt(parentNode, slotIndex),
                        loadedMesh = nil,
                        place = place
                    })
                end

                table.insert(spec.animalPlaces, place)
                spec.animalTypeIndexToPlaces[place.animalTypeIndex] = place
            end
        end

        index = index + 1
    end

    local triggerNode = vehicle.xmlFile:getValue("vehicle.livestockTrailer.loadTrigger#node", nil, vehicle.components, vehicle.i3dMappings)
    if triggerNode ~= nil then
        addTrigger(triggerNode, "onAnimalLoadTriggerCallback", vehicle)
        spec.triggerNode = triggerNode
    end

    spec.rideablesInTrigger = {}
    spec.spawnPlaces = {}
    vehicle.xmlFile:iterate("vehicle.livestockTrailer.spawnPlaces.spawnPlace", function(_, key)
        local node = vehicle.xmlFile:getValue(key .. "#node", nil, vehicle.components, vehicle.i3dMappings)
        local width = vehicle.xmlFile:getValue(key .. "#width", 5)

        if node ~= nil then
            table.insert(spec.spawnPlaces, {
                node = node,
                width = width
            })
        end
    end)

    if #spec.spawnPlaces > 0 or spec.triggerNode ~= nil then
        spec.activatable = LivestockTrailerActivatable.new(vehicle)
        if g_currentMission ~= nil then
            g_currentMission.activatableObjectsSystem:addActivatable(spec.activatable)
        end
    end

    spec.clusterSystem = AnimalClusterSystem.new(vehicle.isServer, vehicle)
    g_messageCenter:subscribe(AnimalClusterUpdateEvent, vehicle.updatedClusters, vehicle)
    spec.loadingTrigger = nil
    spec.animalScreenController = nil

    if g_currentMission ~= nil then
        g_currentMission.husbandrySystem:addLivestockTrailer(vehicle)
    end
end

function AnimatedLivestockTrailer.patchShopAnimalSpecs()
    AnimatedLivestockTrailer.patchStatisticsAnimalSpecs()

    if AnimatedLivestockTrailer.shopAnimalSpecsPatched then
        return
    end

    if ShopController ~= nil and ShopController.makeDisplayItem ~= nil then
        local oldMakeDisplayItem = ShopController.makeDisplayItem
        ShopController.makeDisplayItem = function(controller, storeItem, realItem, configurations, saleItem, ignoreInAppPurchase)
            local displayItem = oldMakeDisplayItem(controller, storeItem, realItem, configurations, saleItem, ignoreInAppPurchase)
            AnimatedLivestockTrailer.applyShopAnimalSlotAttributes(displayItem)

            return displayItem
        end
    end

    if ShopItemsFrame == nil or ShopItemsFrame.assignItemTextData == nil then
        return
    end

    ShopItemsFrame.assignItemTextData = function(frame, displayItem)
        if Platform.isMobile and frame.attrVehicleValue ~= nil then
            local storeItem = displayItem.storeItem
            frame.attrVehicleValue:setText(frame:getStoreItemDisplayPrice(storeItem))
            frame.attrVehicleValue:setVisible(not storeItem.isInAppPurchase)
            frame.attrVehicleValueIcon:setVisible(not storeItem.isInAppPurchase)
        end

        for index, value in pairs(displayItem.attributeValues) do
            local cell = frame:dequeueDetailsCell(ShopItemsFrame.CELL_NAME_DETAIL)
            local icon = cell:getDescendantByName("icon")
            local text = cell:getDescendantByName("text")
            local profile = displayItem.attributeIconProfiles[index]

            if profile ~= nil and profile ~= "" then
                text:setText(value)

                local fillTypeIconFilename = AnimatedLivestockTrailer.getShopAnimalIconFilename(profile)
                if fillTypeIconFilename ~= nil then
                    AnimatedLivestockTrailer.applyShopFillTypeIcon(icon, fillTypeIconFilename, ShopItemsFrame.PROFILE.ICON_FRUIT_TYPE)
                    AnimatedLivestockTrailer.resizeShopAnimalTextCell(cell, icon, text)
                else
                    icon:applyProfile(profile)
                end
            end

            cell:setSize(icon.absSize[1] + icon.margin[1] + text.absSize[1], nil)
        end
    end

    AnimatedLivestockTrailer.shopAnimalSpecsPatched = true
end

function AnimatedLivestockTrailer.patchStatisticsAnimalSpecs()
    if AnimatedLivestockTrailer.statisticsAnimalSpecsPatched then
        return
    end

    if InGameMenuStatisticsFrame == nil or InGameMenuStatisticsFrame.assignItemTextData == nil then
        return
    end

    InGameMenuStatisticsFrame.assignItemTextData = function(frame, displayItem)
        if Platform.isMobile and frame.attrVehicleValue ~= nil then
            local storeItem = displayItem.storeItem
            frame.attrVehicleValue:setText(frame:getStoreItemDisplayPrice(storeItem))
            frame.attrVehicleValue:setVisible(not storeItem.isInAppPurchase)
            frame.attrVehicleValueIcon:setVisible(not storeItem.isInAppPurchase)
        end

        for index, value in pairs(displayItem.attributeValues) do
            local cell = frame:dequeueDetailsCell(InGameMenuStatisticsFrame.CELL_NAME_DETAIL)
            local icon = cell:getDescendantByName("icon")
            local text = cell:getDescendantByName("text")
            local profile = displayItem.attributeIconProfiles[index]

            if profile ~= nil and profile ~= "" then
                text:setText(value)

                local fillTypeIconFilename = AnimatedLivestockTrailer.getShopAnimalIconFilename(profile)
                if fillTypeIconFilename ~= nil then
                    AnimatedLivestockTrailer.applyShopFillTypeIcon(icon, fillTypeIconFilename, InGameMenuStatisticsFrame.PROFILE.ICON_FRUIT_TYPE)
                    AnimatedLivestockTrailer.resizeShopAnimalTextCell(cell, icon, text)
                else
                    icon:applyProfile(profile)
                end
            end

            cell:setSize(icon.absSize[1] + icon.margin[1] + text.absSize[1], nil)
        end
    end

    AnimatedLivestockTrailer.statisticsAnimalSpecsPatched = true
end

function AnimatedLivestockTrailer.getShopAnimalIconFilename(profile)
    if profile == nil or profile:sub(1, #AnimatedLivestockTrailer.SHOP_ANIMAL_ICON_PREFIX) ~= AnimatedLivestockTrailer.SHOP_ANIMAL_ICON_PREFIX then
        return nil
    end

    return profile:sub(#AnimatedLivestockTrailer.SHOP_ANIMAL_ICON_PREFIX + 1)
end

function AnimatedLivestockTrailer.applyShopFillTypeIcon(icon, iconFilename, iconProfile)
    icon:applyProfile(iconProfile)
    icon:setImageFilename(iconFilename)

    local fullUVs = GuiUtils.getUVs("0 0 1 1")
    if fullUVs ~= nil then
        icon:setImageUVs(GuiOverlay.STATE_NORMAL, unpack(fullUVs))
        icon:setImageUVs(GuiOverlay.STATE_DISABLED, unpack(fullUVs))
        icon:setImageUVs(GuiOverlay.STATE_FOCUSED, unpack(fullUVs))
        icon:setImageUVs(GuiOverlay.STATE_PRESSED, unpack(fullUVs))
        icon:setImageUVs(GuiOverlay.STATE_SELECTED, unpack(fullUVs))
        icon:setImageUVs(GuiOverlay.STATE_HIGHLIGHTED, unpack(fullUVs))
    end

    icon:setImageColor(GuiOverlay.STATE_NORMAL, 1, 1, 1, 1)
    icon:setImageColor(GuiOverlay.STATE_DISABLED, 1, 1, 1, 1)
    icon:setImageColor(GuiOverlay.STATE_FOCUSED, 1, 1, 1, 1)
    icon:setImageColor(GuiOverlay.STATE_PRESSED, 1, 1, 1, 1)
    icon:setImageColor(GuiOverlay.STATE_SELECTED, 1, 1, 1, 1)
    icon:setImageColor(GuiOverlay.STATE_HIGHLIGHTED, 1, 1, 1, 1)
end

function AnimatedLivestockTrailer.resizeShopAnimalTextCell(cell, icon, text)
    local cellHeight = GuiUtils.getNormalizedYValue("46px")
    local textHeight = GuiUtils.getNormalizedYValue("46px")

    text:setSize(nil, textHeight)
    cell:setSize(icon.absSize[1] + icon.margin[1] + text.absSize[1], cellHeight)
end

function AnimatedLivestockTrailer.applyShopAnimalSlotAttributes(displayItem)
    local storeItem = displayItem ~= nil and displayItem.storeItem or nil
    local animalSlots = storeItem ~= nil and storeItem.specs ~= nil and storeItem.specs.animatedLivestockTrailerAnimalSlots or nil

    if animalSlots == nil or #animalSlots == 0 then
        return
    end

    for index = #displayItem.attributeIconProfiles, 1, -1 do
        local profile = displayItem.attributeIconProfiles[index]

        if AnimatedLivestockTrailer.SHOP_STATIC_ANIMAL_ICON_PROFILES[profile] then
            table.remove(displayItem.attributeIconProfiles, index)
            table.remove(displayItem.attributeValues, index)
        end
    end

    for _, animalSlot in ipairs(animalSlots) do
        local fillType = AnimatedLivestockTrailer.getAnimalTypeFillType(animalSlot.typeName)
        local iconFilename = fillType ~= nil and fillType.hudOverlayFilename or nil

        if iconFilename ~= nil then
            table.insert(displayItem.attributeIconProfiles, AnimatedLivestockTrailer.SHOP_ANIMAL_ICON_PREFIX .. iconFilename)
            table.insert(displayItem.attributeValues, string.format("%s\n%d %s", AnimatedLivestockTrailer.getAnimalTypeDisplayTitle(animalSlot.typeName, fillType, animalSlot.displayTitle), animalSlot.numSlots, g_i18n:getText("unit_pieces")))
        end
    end
end

function AnimatedLivestockTrailer.getAnimalTypeFillTypeIconFilename(typeName)
    local fillType = AnimatedLivestockTrailer.getAnimalTypeFillType(typeName)

    return fillType ~= nil and fillType.hudOverlayFilename or nil
end

function AnimatedLivestockTrailer.getAnimalTypeFillType(typeName)
    local fillTypeIndex
    local animalSystem = g_currentMission ~= nil and g_currentMission.animalSystem or nil

    if animalSystem ~= nil and typeName ~= nil then
        local animalType = animalSystem:getTypeByName(typeName)

        if animalType ~= nil and animalType.subTypes ~= nil then
            for _, subTypeIndex in ipairs(animalType.subTypes) do
                local subType = animalSystem:getSubTypeByIndex(subTypeIndex)

                if subType ~= nil and subType.fillTypeIndex ~= nil then
                    fillTypeIndex = subType.fillTypeIndex
                    break
                end
            end
        end
    end

    if fillTypeIndex == nil and typeName ~= nil then
        fillTypeIndex = g_fillTypeManager:getFillTypeIndexByName(string.upper(typeName))
    end

    local fillType = fillTypeIndex ~= nil and g_fillTypeManager:getFillTypeByIndex(fillTypeIndex) or nil

    return fillType
end

function AnimatedLivestockTrailer.getAnimalTypeDisplayTitle(typeName, fillType, displayTitle)
    if displayTitle ~= nil and displayTitle ~= "" then
        return displayTitle
    end

    local animalSystem = g_currentMission ~= nil and g_currentMission.animalSystem or nil
    local animalType = animalSystem ~= nil and typeName ~= nil and animalSystem:getTypeByName(typeName) or nil

    if animalType ~= nil and animalType.groupTitle ~= nil and animalType.groupTitle ~= "" then
        return animalType.groupTitle
    end

    if fillType ~= nil and fillType.title ~= nil and fillType.title ~= "" then
        return fillType.title
    end

    return typeName or ""
end

function AnimatedLivestockTrailer.loadSpecValueAnimalSlots(xmlFile, customEnvironment, baseDir)
    local rootName = xmlFile:getRootName()

    if not xmlFile:hasProperty(rootName .. ".animatedLivestockTrailer") then
        return nil
    end

    local slots = {}
    local index = 0

    while true do
        local key = string.format("%s.livestockTrailer.animal(%d)", rootName, index)
        if not xmlFile:hasProperty(key) then
            break
        end

        local typeName = xmlFile:getValue(key .. "#type")
        local numSlots = xmlFile:getValue(key .. "#numSlots", 0)
        local displayTitle = AnimatedLivestockTrailer.getOptionalXMLText(xmlFile, key .. "#shopTitle", customEnvironment)

        if typeName ~= nil and numSlots > 0 and AnimatedLivestockTrailer.getIsAnimalTypeAvailable(typeName) then
            table.insert(slots, {
                typeName = typeName,
                numSlots = numSlots,
                displayTitle = displayTitle
            })
        end

        index = index + 1
    end

    return #slots > 0 and slots or nil
end

function AnimatedLivestockTrailer.getIsAnimalTypeAvailable(typeName)
    local animalSystem = g_currentMission ~= nil and g_currentMission.animalSystem or nil

    if animalSystem == nil or typeName == nil then
        return true
    end

    return animalSystem:getTypeIndexByName(typeName) ~= nil
end

function AnimatedLivestockTrailer.getOptionalXMLText(xmlFile, key, customEnvironment)
    local text = xmlFile:getValue(key)

    if text == nil or text == "" then
        return nil
    end

    return g_i18n:convertText(text, customEnvironment)
end

function AnimatedLivestockTrailer.indexToLoadedI3DObject(rootNode, path)
    if rootNode == nil or rootNode == 0 then
        return nil
    end

    if path == nil or path == "" then
        return rootNode
    end

    local nodePath = tostring(path)
    if string.find(nodePath, ">", 1, true) ~= nil then
        nodePath = string.gsub(nodePath, ">", "|")
    end

    return I3DUtil.indexToObject(rootNode, nodePath)
end

function AnimatedLivestockTrailer.namePathToLoadedI3DObject(rootNode, path)
    if rootNode == nil or rootNode == 0 then
        return nil
    end

    if path == nil or path == "" then
        return rootNode
    end

    local nodePath = tostring(path)
    if string.find(nodePath, ">", 1, true) ~= nil then
        nodePath = string.gsub(nodePath, ">", "|")
    end

    local currentNode = rootNode
    local isFirstPart = true

    for part in string.gmatch(nodePath, "[^|]+") do
        if part ~= "" then
            local skipPart = isFirstPart and getName(currentNode) == part

            if not skipPart then
                local nextNode = AnimatedLivestockTrailer.findDirectChildByName(currentNode, part)

                if nextNode == nil and isFirstPart then
                    nextNode = AnimatedLivestockTrailer.findChildByNameRecursive(currentNode, part)
                end

                if nextNode == nil then
                    return nil
                end

                currentNode = nextNode
            end

            isFirstPart = false
        end
    end

    return currentNode
end

function AnimatedLivestockTrailer.findDirectChildByName(rootNode, name)
    if rootNode == nil or rootNode == 0 or name == nil then
        return nil
    end

    local numChildren = getNumOfChildren(rootNode)
    for i = 0, numChildren - 1 do
        local child = getChildAt(rootNode, i)

        if getName(child) == name then
            return child
        end
    end

    return nil
end

function AnimatedLivestockTrailer.findChildByNameRecursive(rootNode, name)
    if rootNode == nil or rootNode == 0 or name == nil then
        return nil
    end

    if getName(rootNode) == name then
        return rootNode
    end

    local numChildren = getNumOfChildren(rootNode)
    for i = 0, numChildren - 1 do
        local found = AnimatedLivestockTrailer.findChildByNameRecursive(getChildAt(rootNode, i), name)

        if found ~= nil then
            return found
        end
    end

    return nil
end

function AnimatedLivestockTrailer.getAnimalAssetsSchema()
    if AnimatedLivestockTrailer.animalAssetsSchema == nil then
        local schema = XMLSchema.new("animatedLivestockTrailerAnimalAssets")

        schema:register(XMLValueType.STRING, "animalHusbandry.animals.animal(?).assets#filename", "Animated animal i3d filename")
        schema:register(XMLValueType.STRING, "animalHusbandry.animals.animal(?).assets#filenamePosed", "Posed animal i3d filename")
        schema:register(XMLValueType.STRING, "animalHusbandry.animals.animal(?).assets#animation", "Animal animation i3d filename")
        schema:register(XMLValueType.STRING, "animalHusbandry.animals.animal(?).assets#skeletonIndex", "Node path of the animated skeleton")
        schema:register(XMLValueType.STRING, "animalHusbandry.animals.animal(?).locomotion#filename", "Animal locomotion xml filename")
        schema:register(XMLValueType.STRING, "animalHusbandry.animals.animal(?).audio#yellSoundGroup", "Animal voice sound group")
        schema:register(XMLValueType.INT, "animalHusbandry.animals.animal(?).audio#yellMinInterval", "Minimum animal voice interval")
        schema:register(XMLValueType.INT, "animalHusbandry.animals.animal(?).audio#yellMaxInterval", "Maximum animal voice interval")
        schema:register(XMLValueType.FLOAT, "animalHusbandry.animals.animal(?).audio#yellTimerCrowdScale", "Animal voice crowd scale")
        schema:register(XMLValueType.STRING, "animalHusbandry.sound.soundGroup(?)#name", "Animal sound group name")
        schema:register(XMLValueType.FLOAT, "animalHusbandry.sound.soundGroup(?)#volume", "Animal sound group volume")
        schema:register(XMLValueType.FLOAT, "animalHusbandry.sound.soundGroup(?)#indoorVolume", "Animal sound group indoor volume")
        schema:register(XMLValueType.FLOAT, "animalHusbandry.sound.soundGroup(?)#range", "Animal sound group range")
        schema:register(XMLValueType.FLOAT, "animalHusbandry.sound.soundGroup(?)#innerRange", "Animal sound group inner range")
        schema:register(XMLValueType.FLOAT, "animalHusbandry.sound.soundGroup(?)#volumeRandMin", "Animal sound group minimum volume randomization")
        schema:register(XMLValueType.FLOAT, "animalHusbandry.sound.soundGroup(?)#volumeRandMax", "Animal sound group maximum volume randomization")
        schema:register(XMLValueType.FLOAT, "animalHusbandry.sound.soundGroup(?)#pitch", "Animal sound group pitch")
        schema:register(XMLValueType.FLOAT, "animalHusbandry.sound.soundGroup(?)#pitchRandMin", "Animal sound group minimum pitch randomization")
        schema:register(XMLValueType.FLOAT, "animalHusbandry.sound.soundGroup(?)#pitchRandMax", "Animal sound group maximum pitch randomization")
        schema:register(XMLValueType.STRING, "animalHusbandry.sound.soundGroup(?).sample(?)#filename", "Animal sound sample filename")

        AnimatedLivestockTrailer.animalAssetsSchema = schema
    end

    return AnimatedLivestockTrailer.animalAssetsSchema
end

function AnimatedLivestockTrailer.getLocomotionSchema()
    if AnimatedLivestockTrailer.locomotionSchema == nil then
        local schema = XMLSchema.new("animatedLivestockTrailerLocomotion")

        schema:register(XMLValueType.STRING, "locomotion.animation#filename", "Animal animation xml filename")

        AnimatedLivestockTrailer.locomotionSchema = schema
    end

    return AnimatedLivestockTrailer.locomotionSchema
end

function AnimatedLivestockTrailer.getAnimationSchema()
    if AnimatedLivestockTrailer.animationSchema == nil then
        local schema = XMLSchema.new("animatedLivestockTrailerAnimation")

        schema:register(XMLValueType.STRING, "animation.states.state(?)#id", "Locomotion state id")
        schema:register(XMLValueType.STRING, "animation.states.state(?).animation(?)#clip", "Animation clip name")
        schema:register(XMLValueType.STRING, "animation.states.state(?).animation(?)#clipLeft", "Left animation clip name")
        schema:register(XMLValueType.STRING, "animation.states.state(?).animation(?)#clipRight", "Right animation clip name")
        schema:register(XMLValueType.FLOAT, "animation.states.state(?).animation(?)#speed", "Animation speed")

        AnimatedLivestockTrailer.animationSchema = schema
    end

    return AnimatedLivestockTrailer.animationSchema
end

function AnimatedLivestockTrailer.prerequisitesPresent(specializations)
    return SpecializationUtil.hasSpecialization(LivestockTrailer, specializations)
end

function AnimatedLivestockTrailer.initSpecialization()
    if g_storeManager:getSpecTypeByName("animatedLivestockTrailerAnimalSlots") == nil then
        g_storeManager:addSpecType("animatedLivestockTrailerAnimalSlots", nil, AnimatedLivestockTrailer.loadSpecValueAnimalSlots, nil, StoreSpecies.VEHICLE)
    end
    AnimatedLivestockTrailer.patchLivestockTrailerOnLoad()
    AnimatedLivestockTrailer.patchShopAnimalSpecs()

    local schema = Vehicle.xmlSchema

    schema:setXMLSpecializationType("AnimatedLivestockTrailer")
    schema:register(XMLValueType.BOOL, "vehicle.animatedLivestockTrailer#enabled", "Use animated animal visuals instead of posed livestock trailer meshes", true)
    schema:register(XMLValueType.BOOL, "vehicle.animatedLivestockTrailer#showOnHud", "Show animal load level on the fill level HUD", true)
    schema:register(XMLValueType.STRING, "vehicle.animatedLivestockTrailer#hudText", "Optional animal load HUD text or l10n key")
    schema:register(XMLValueType.FLOAT, "vehicle.animatedLivestockTrailer#maxLoadedSpeed", "Maximum vehicle speed in kph while animals are loaded")
    schema:register(XMLValueType.INT, "vehicle.animatedLivestockTrailer#minimumLoadAge", "Minimum animal age in months that can be loaded", 0)
    schema:register(XMLValueType.INT, "vehicle.animatedLivestockTrailer#maximumLoadAge", "Maximum animal age in months that can be loaded", 0)
    schema:register(XMLValueType.BOOL, "vehicle.animatedLivestockTrailer#filterMissingAnimalTypes", "Skip livestockTrailer animal entries that do not exist on the current map", true)
    schema:register(XMLValueType.L10N_STRING, "vehicle.animatedLivestockTrailer#unsupportedAgeWarningText", "Warning shown when trying to load an unsupported animal age", "$l10n_warning_animalAgeNotSupportedByTrailer")
    schema:register(XMLValueType.BOOL, "vehicle.animatedLivestockTrailer#alignToTerrain", "Keep animal visuals on terrain height", true)
    schema:register(XMLValueType.BOOL, "vehicle.animatedLivestockTrailer#alignToGroundCollisions", "Use static collision raycasts before falling back to terrain height", false)
    schema:register(XMLValueType.FLOAT, "vehicle.animatedLivestockTrailer#groundRaycastOffset", "Raycast start height above the animal slot", 4)
    schema:register(XMLValueType.FLOAT, "vehicle.animatedLivestockTrailer#groundRaycastDistance", "Raycast distance used to detect bridges and static ground collisions", 12)
    schema:register(XMLValueType.BOOL, "vehicle.animatedLivestockTrailer#useSpeedAnimations", "Switch between idle, walk and run clips based on trailer speed", true)
    schema:register(XMLValueType.BOOL, "vehicle.animatedLivestockTrailer#randomIdleStart", "Start idle animations at a random time offset", true)
    schema:register(XMLValueType.BOOL, "vehicle.animatedLivestockTrailer#randomMovementStart", "Start walk and run animations at a random time offset", true)
    schema:register(XMLValueType.BOOL, "vehicle.animatedLivestockTrailer#reverseMovementAnimations", "Play walk and run animations backwards while reversing", true)
    schema:register(XMLValueType.BOOL, "vehicle.animatedLivestockTrailer#useAnimalSounds", "Play random animal voice samples while animals are loaded", true)
    schema:register(XMLValueType.NODE_INDEX, "vehicle.animatedLivestockTrailer#animalSoundNode", "Optional node used as shared animal sound source")
    schema:register(XMLValueType.FLOAT, "vehicle.animatedLivestockTrailer#animalSoundVolumeScale", "Volume scale for random animal voice samples", 0.25)
    schema:register(XMLValueType.INT, "vehicle.animatedLivestockTrailer#animalSoundMinInterval", "Fallback minimum random animal voice interval in milliseconds", 8000)
    schema:register(XMLValueType.INT, "vehicle.animatedLivestockTrailer#animalSoundMaxInterval", "Fallback maximum random animal voice interval in milliseconds", 22000)
    schema:register(XMLValueType.INT, "vehicle.animatedLivestockTrailer#animalSoundMinimumInterval", "Hard minimum interval after crowd scaling in milliseconds", 3500)
    schema:register(XMLValueType.FLOAT, "vehicle.animatedLivestockTrailer#groundOffset", "Additional height offset above terrain", 0)
    schema:register(XMLValueType.FLOAT, "vehicle.animatedLivestockTrailer#walkSpeed", "Speed in kph where walk animation starts", 0.5)
    schema:register(XMLValueType.FLOAT, "vehicle.animatedLivestockTrailer#runSpeed", "Speed in kph where run animation starts", 9)
    schema:register(XMLValueType.STRING, "vehicle.animatedLivestockTrailer#idleClip", "Default clip used while the trailer is stopped", "idle1Source")
    schema:register(XMLValueType.STRING, "vehicle.animatedLivestockTrailer#walkClip", "Default clip used at low speed", "walkFwdLSource")
    schema:register(XMLValueType.STRING, "vehicle.animatedLivestockTrailer#runClip", "Default clip used at high speed", "runFwdLSource")
    schema:register(XMLValueType.STRING, "vehicle.animatedLivestockTrailer#animationSourcePath", "Default node path inside animation i3d used as source character set")
    schema:register(XMLValueType.FLOAT, "vehicle.animatedLivestockTrailer#playbackScale", "Default animation playback multiplier", 1)
    schema:register(XMLValueType.FLOAT, "vehicle.animatedLivestockTrailer#referenceWalkSpeed", "Default trailer speed in kph that maps to 1x walk playback", 4)
    schema:register(XMLValueType.FLOAT, "vehicle.animatedLivestockTrailer#referenceRunSpeed", "Default trailer speed in kph that maps to 1x run playback", 12)

    schema:register(XMLValueType.STRING, "vehicle.animatedLivestockTrailer.animal(?)#type", "Animal type name matching livestockTrailer animal type")
    schema:register(XMLValueType.STRING, "vehicle.animatedLivestockTrailer.animal(?)#filename", "Optional override for animated animal i3d filename")
    schema:register(XMLValueType.STRING, "vehicle.animatedLivestockTrailer.animal(?)#animationFilename", "Optional override for animation i3d filename")
    schema:register(XMLValueType.STRING, "vehicle.animatedLivestockTrailer.animal(?)#hudText", "Optional animal load HUD text or l10n key")
    schema:register(XMLValueType.STRING, "vehicle.livestockTrailer.animal(?)#shopTitle", "Optional shop display title or l10n key for this animal slot")
    schema:register(XMLValueType.STRING, "vehicle.animatedLivestockTrailer.animal(?)#visualMode", "Visual mode: animal or cage", "animal")
    schema:register(XMLValueType.FILENAME, "vehicle.animatedLivestockTrailer.animal(?)#cageFilename", "Cage i3d filename")
    schema:register(XMLValueType.NODE_INDEX, "vehicle.animatedLivestockTrailer.animal(?)#cageSlotNode", "Optional parent node containing cage placement slots")
    schema:register(XMLValueType.STRING, "vehicle.animatedLivestockTrailer.animal(?)#cageAnimalSlotsPath", "Node path inside loaded cage i3d containing animal slots", "animalSlots")
    schema:register(XMLValueType.INT, "vehicle.animatedLivestockTrailer.animal(?)#animalsPerCage", "Number of real animals represented by one visible cage", 4)
    schema:register(XMLValueType.INT, "vehicle.animatedLivestockTrailer.animal(?)#cageSlotStep", "Fallback step between normal livestock slots used as cage slots", 4)
    schema:register(XMLValueType.STRING, "vehicle.animatedLivestockTrailer.animal(?)#cageAnimalMode", "Cage animal mode: none or animated", "animated")
    schema:register(XMLValueType.STRING, "vehicle.animatedLivestockTrailer.animal(?)#clipRootPath", "Optional override for node path inside loaded animal i3d that owns the animation character set")
    schema:register(XMLValueType.STRING, "vehicle.animatedLivestockTrailer.animal(?)#animationSourcePath", "Node path inside animation i3d used as source character set")
    schema:register(XMLValueType.STRING, "vehicle.animatedLivestockTrailer.animal(?)#idleClip", "Clip used while the trailer is stopped", "idle1Source")
    schema:register(XMLValueType.STRING, "vehicle.animatedLivestockTrailer.animal(?)#walkClip", "Clip used at low speed", "walkFwdLSource")
    schema:register(XMLValueType.STRING, "vehicle.animatedLivestockTrailer.animal(?)#runClip", "Clip used at high speed", "runFwdLSource")
    schema:register(XMLValueType.BOOL, "vehicle.animatedLivestockTrailer.animal(?)#randomIdleStart", "Start idle animations at a random time offset", true)
    schema:register(XMLValueType.BOOL, "vehicle.animatedLivestockTrailer.animal(?)#randomMovementStart", "Start walk and run animations at a random time offset", true)
    schema:register(XMLValueType.BOOL, "vehicle.animatedLivestockTrailer.animal(?)#reverseMovementAnimations", "Play walk and run animations backwards while reversing", true)
    schema:register(XMLValueType.FLOAT, "vehicle.animatedLivestockTrailer.animal(?)#playbackScale", "Animation playback multiplier", 1)
    schema:register(XMLValueType.FLOAT, "vehicle.animatedLivestockTrailer.animal(?)#referenceWalkSpeed", "Trailer speed in kph that maps to 1x walk playback", 4)
    schema:register(XMLValueType.FLOAT, "vehicle.animatedLivestockTrailer.animal(?)#referenceRunSpeed", "Trailer speed in kph that maps to 1x run playback", 12)

    schema:register(XMLValueType.NODE_INDEX, "vehicle.livestockTrailer.baleTrigger#node", "Bale trigger node")
    schema:register(XMLValueType.FLOAT, "vehicle.livestockTrailer.baleTrigger#inputLitresPerSecond", "Bale delete litres per second", 100)
    schema:register(XMLValueType.INT, "vehicle.livestockTrailer.baleTrigger#fillUnitIndex", "Fill Unit Index", 1)
    schema:register(XMLValueType.INT, "vehicle.livestockTrailer.bedding#minimumAnimals", "Minimum number of animals to start conversion timer", 1)
    schema:register(XMLValueType.INT, "vehicle.livestockTrailer.bedding#conversionSeconds", "Conversion rate in seconds when carrying minimum number of animals", 60)
    schema:register(XMLValueType.STRING, "vehicle.livestockTrailer.bedding#fillType", "Bedding fill type", "STRAW")
    schema:register(XMLValueType.STRING, "vehicle.livestockTrailer.bedding#convertedFillType", "Converted fill type", "MANURE")
    schema:setXMLSpecializationType()

    local schemaSavegame = Vehicle.xmlSchemaSavegame
    schemaSavegame:register(XMLValueType.FLOAT, string.format("vehicles.vehicle(?).%s.animatedLivestockTrailer#conversionTime", AnimatedLivestockTrailer.MOD_NAME), "Current bedding conversion time")
    schemaSavegame:register(XMLValueType.FLOAT, string.format("vehicles.vehicle(?).%s.livestockTrailerSpecial#conversionTime", AnimatedLivestockTrailer.MOD_NAME), "Legacy bedding conversion time")
end

function AnimatedLivestockTrailer.registerFunctions(vehicleType)
    SpecializationUtil.registerFunction(vehicleType, "livestockTrailerBaleTriggerCallback", AnimatedLivestockTrailer.livestockTrailerBaleTriggerCallback)
    SpecializationUtil.registerFunction(vehicleType, "animatedLivestockTrailerGroundRaycastCallback", AnimatedLivestockTrailer.animatedLivestockTrailerGroundRaycastCallback)
end

function AnimatedLivestockTrailer.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onLoad", AnimatedLivestockTrailer)
    SpecializationUtil.registerEventListener(vehicleType, "onLoadFinished", AnimatedLivestockTrailer)
    SpecializationUtil.registerEventListener(vehicleType, "onDelete", AnimatedLivestockTrailer)
    SpecializationUtil.registerEventListener(vehicleType, "onUpdate", AnimatedLivestockTrailer)
    SpecializationUtil.registerEventListener(vehicleType, "onFillUnitFillLevelChanged", AnimatedLivestockTrailer)
    SpecializationUtil.registerEventListener(vehicleType, "saveToXMLFile", AnimatedLivestockTrailer)
end

function AnimatedLivestockTrailer.registerOverwrittenFunctions(vehicleType)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "updateAnimals", AnimatedLivestockTrailer.updateAnimals)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "clearAnimals", AnimatedLivestockTrailer.clearAnimals)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "getFillLevelInformation", AnimatedLivestockTrailer.getFillLevelInformation)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "doCheckSpeedLimit", AnimatedLivestockTrailer.doCheckSpeedLimit)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "getRawSpeedLimit", AnimatedLivestockTrailer.getRawSpeedLimit)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "addAnimals", AnimatedLivestockTrailer.addAnimals)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "addCluster", AnimatedLivestockTrailer.addCluster)
end

function AnimatedLivestockTrailer:onLoad(savegame)
    AnimatedLivestockTrailer.patchAnimalScreenDealerTrailer()
    AnimatedLivestockTrailer.patchShopAnimalSpecs()

    self.spec_animatedLivestockTrailer = self[AnimatedLivestockTrailer.SPEC_NAME]

    local spec = self.spec_animatedLivestockTrailer
    if spec == nil then
        Logging.error("[%s] Missing specialization data for animatedLivestockTrailer", AnimatedLivestockTrailer.MOD_NAME)
        return
    end

    spec.enabled = self.xmlFile:getValue("vehicle.animatedLivestockTrailer#enabled", true)
    spec.showOnHud = self.xmlFile:getValue("vehicle.animatedLivestockTrailer#showOnHud", true)
    spec.hudText = self.xmlFile:getValue("vehicle.animatedLivestockTrailer#hudText")
    spec.maxLoadedSpeed = self.xmlFile:getValue("vehicle.animatedLivestockTrailer#maxLoadedSpeed")
    spec.minimumLoadAge = self.xmlFile:getValue("vehicle.animatedLivestockTrailer#minimumLoadAge", 0)
    spec.maximumLoadAge = self.xmlFile:getValue("vehicle.animatedLivestockTrailer#maximumLoadAge", 0)
    spec.filterMissingAnimalTypes = self.xmlFile:getValue("vehicle.animatedLivestockTrailer#filterMissingAnimalTypes", true)
    spec.unsupportedAgeWarningText = self.xmlFile:getValue("vehicle.animatedLivestockTrailer#unsupportedAgeWarningText", "$l10n_warning_animalAgeNotSupportedByTrailer", self.customEnvironment)
    spec.alignToTerrain = self.xmlFile:getValue("vehicle.animatedLivestockTrailer#alignToTerrain", true)
    spec.alignToGroundCollisions = self.xmlFile:getValue("vehicle.animatedLivestockTrailer#alignToGroundCollisions", false)
    spec.groundRaycastOffset = self.xmlFile:getValue("vehicle.animatedLivestockTrailer#groundRaycastOffset", 4)
    spec.groundRaycastDistance = self.xmlFile:getValue("vehicle.animatedLivestockTrailer#groundRaycastDistance", 12)
    spec.groundRaycastHitY = nil
    spec.groundRaycastHitDistance = nil
    spec.useSpeedAnimations = self.xmlFile:getValue("vehicle.animatedLivestockTrailer#useSpeedAnimations", true)
    spec.useAnimalSounds = self.xmlFile:getValue("vehicle.animatedLivestockTrailer#useAnimalSounds", true)
    spec.animalSoundNode = self.xmlFile:getValue("vehicle.animatedLivestockTrailer#animalSoundNode", nil, self.components, self.i3dMappings)
    spec.animalSoundVolumeScale = self.xmlFile:getValue("vehicle.animatedLivestockTrailer#animalSoundVolumeScale", 0.25)
    spec.animalSoundMinInterval = self.xmlFile:getValue("vehicle.animatedLivestockTrailer#animalSoundMinInterval", 8000)
    spec.animalSoundMaxInterval = self.xmlFile:getValue("vehicle.animatedLivestockTrailer#animalSoundMaxInterval", 22000)
    spec.animalSoundMinimumInterval = self.xmlFile:getValue("vehicle.animatedLivestockTrailer#animalSoundMinimumInterval", 3500)
    spec.animalSoundGroups = {}
    spec.animalSoundSignature = nil
    spec.animalSoundTimer = 0
    spec.currentAnimalSoundSample = nil
    spec.animalSoundAnimalCount = 0
    spec.groundOffset = self.xmlFile:getValue("vehicle.animatedLivestockTrailer#groundOffset", 0)
    spec.walkSpeed = self.xmlFile:getValue("vehicle.animatedLivestockTrailer#walkSpeed", 0.5)
    spec.runSpeed = self.xmlFile:getValue("vehicle.animatedLivestockTrailer#runSpeed", 9)
    spec.defaultConfig = {
        filename = nil,
        animationFilename = nil,
        clipRootPath = nil,
        animationSourcePath = self.xmlFile:getValue("vehicle.animatedLivestockTrailer#animationSourcePath"),
        visualMode = "animal",
        cageFilename = nil,
        cageSlotNode = nil,
        cageAnimalSlotsPath = "animalSlots",
        animalsPerCage = 4,
        cageSlotStep = 4,
        cageAnimalMode = "animated",
        idleClip = self.xmlFile:getValue("vehicle.animatedLivestockTrailer#idleClip", "idle1Source"),
        walkClip = self.xmlFile:getValue("vehicle.animatedLivestockTrailer#walkClip", "walkFwdLSource"),
        runClip = self.xmlFile:getValue("vehicle.animatedLivestockTrailer#runClip", "runFwdLSource"),
        randomIdleStart = self.xmlFile:getValue("vehicle.animatedLivestockTrailer#randomIdleStart", true),
        randomMovementStart = self.xmlFile:getValue("vehicle.animatedLivestockTrailer#randomMovementStart", true),
        reverseMovementAnimations = self.xmlFile:getValue("vehicle.animatedLivestockTrailer#reverseMovementAnimations", true),
        playbackScale = self.xmlFile:getValue("vehicle.animatedLivestockTrailer#playbackScale", 1),
        referenceWalkSpeed = self.xmlFile:getValue("vehicle.animatedLivestockTrailer#referenceWalkSpeed", 4),
        referenceRunSpeed = self.xmlFile:getValue("vehicle.animatedLivestockTrailer#referenceRunSpeed", 12)
    }
    spec.configsByTypeIndex = {}
    spec.loadedSlots = {}
    spec.loadedCages = {}
    spec.pendingCageLoadRequestIds = {}
    spec.pendingAnimatedSlots = {}
    spec.loadGeneration = 0

    self.xmlFile:iterate("vehicle.animatedLivestockTrailer.animal", function(_, key)
        local typeName = self.xmlFile:getValue(key .. "#type")
        local typeIndex = g_currentMission.animalSystem:getTypeIndexByName(typeName)

        if typeIndex == nil then
            if not spec.filterMissingAnimalTypes then
                Logging.xmlWarning(self.xmlFile, "Unknown animal type '%s' at '%s'", tostring(typeName), key)
            end

            return
        end

        local typeConfig = {
            filename = AnimatedLivestockTrailer.resolveFilename(self.xmlFile:getValue(key .. "#filename"), self.baseDirectory),
            animationFilename = AnimatedLivestockTrailer.resolveFilename(self.xmlFile:getValue(key .. "#animationFilename"), self.baseDirectory),
            hudText = self.xmlFile:getValue(key .. "#hudText"),
            visualMode = self.xmlFile:getValue(key .. "#visualMode", spec.defaultConfig.visualMode),
            cageFilename = AnimatedLivestockTrailer.resolveFilename(self.xmlFile:getValue(key .. "#cageFilename"), self.baseDirectory),
            cageSlotNode = self.xmlFile:getValue(key .. "#cageSlotNode", nil, self.components, self.i3dMappings),
            cageAnimalSlotsPath = self.xmlFile:getValue(key .. "#cageAnimalSlotsPath", spec.defaultConfig.cageAnimalSlotsPath),
            animalsPerCage = self.xmlFile:getValue(key .. "#animalsPerCage", spec.defaultConfig.animalsPerCage),
            cageSlotStep = self.xmlFile:getValue(key .. "#cageSlotStep", self.xmlFile:getValue(key .. "#animalsPerCage", spec.defaultConfig.animalsPerCage)),
            cageAnimalMode = self.xmlFile:getValue(key .. "#cageAnimalMode", spec.defaultConfig.cageAnimalMode),
            clipRootPath = self.xmlFile:getValue(key .. "#clipRootPath"),
            animationSourcePath = self.xmlFile:getValue(key .. "#animationSourcePath"),
            idleClip = self.xmlFile:getValue(key .. "#idleClip", "idle1Source"),
            walkClip = self.xmlFile:getValue(key .. "#walkClip", "walkFwdLSource"),
            runClip = self.xmlFile:getValue(key .. "#runClip", "runFwdLSource"),
            randomIdleStart = self.xmlFile:getValue(key .. "#randomIdleStart", spec.defaultConfig.randomIdleStart),
            randomMovementStart = self.xmlFile:getValue(key .. "#randomMovementStart", spec.defaultConfig.randomMovementStart),
            reverseMovementAnimations = self.xmlFile:getValue(key .. "#reverseMovementAnimations", spec.defaultConfig.reverseMovementAnimations),
            playbackScale = self.xmlFile:getValue(key .. "#playbackScale", 1),
            referenceWalkSpeed = self.xmlFile:getValue(key .. "#referenceWalkSpeed", 4),
            referenceRunSpeed = self.xmlFile:getValue(key .. "#referenceRunSpeed", 12)
        }

        spec.configsByTypeIndex[typeIndex] = typeConfig
    end)

    AnimatedLivestockTrailer.loadBeddingSupport(self, spec)
end

function AnimatedLivestockTrailer:getFillLevelInformation(superFunc, display)
    superFunc(self, display)

    local spec = self.spec_animatedLivestockTrailer
    local livestockSpec = self.spec_livestockTrailer

    if spec == nil or livestockSpec == nil or not spec.enabled or not spec.showOnHud then
        return
    end

    local currentAnimalType = self:getCurrentAnimalType()
    if currentAnimalType == nil then
        return
    end

    local fillLevel = self:getNumOfAnimals()
    local capacity = self:getMaxNumOfAnimals(currentAnimalType)

    if capacity <= 0 and fillLevel <= 0 then
        return
    end

    local fillType = AnimatedLivestockTrailer.getAnimalHudFillType(self)
    local hudText = AnimatedLivestockTrailer.getAnimalHudText(self, currentAnimalType, fillType)

    AnimatedLivestockTrailer.ensureAnimalHudUnit(fillType)

    display:addFillLevel(fillType, fillLevel, capacity, 0, fillLevel >= capacity and capacity > 0, FillLevelsDisplay.TYPE_BAR, hudText)
end

function AnimatedLivestockTrailer.getAnimalHudFillType(vehicle)
    local livestockSpec = vehicle.spec_livestockTrailer
    if livestockSpec ~= nil and livestockSpec.clusterSystem ~= nil then
        local clusters = livestockSpec.clusterSystem:getClusters()
        local firstCluster = clusters[1]

        if firstCluster ~= nil then
            local subType = g_currentMission.animalSystem:getSubTypeByIndex(firstCluster:getSubTypeIndex())

            if subType ~= nil and subType.fillTypeIndex ~= nil then
                return subType.fillTypeIndex
            end
        end
    end

    return FillType.UNKNOWN
end

function AnimatedLivestockTrailer.getAnimalHudText(vehicle, animalType, fillType)
    local spec = vehicle.spec_animatedLivestockTrailer
    local typeConfig = spec ~= nil and spec.configsByTypeIndex[animalType.typeIndex] or nil
    local hudText = typeConfig ~= nil and typeConfig.hudText or spec ~= nil and spec.hudText or nil

    if hudText ~= nil then
        return AnimatedLivestockTrailer.resolveText(hudText)
    end

    if animalType.groupTitle ~= nil then
        return animalType.groupTitle
    end

    if fillType ~= FillType.UNKNOWN then
        local fillTypeTitle = g_fillTypeManager:getFillTypeTitleByIndex(fillType)

        if fillTypeTitle ~= nil then
            return fillTypeTitle
        end
    end

    return g_i18n:getText("ui_animal") or animalType.name or "Animal"
end

function AnimatedLivestockTrailer.resolveText(text)
    if text == nil then
        return nil
    end

    if string.sub(text, 1, 6) == "$l10n_" then
        return g_i18n:getText(string.sub(text, 7)) or text
    end

    return text
end

function AnimatedLivestockTrailer.ensureAnimalHudUnit(fillType)
    if fillType == FillType.UNKNOWN then
        return
    end

    local fillTypeDesc = g_fillTypeManager:getFillTypeByIndex(fillType)
    if fillTypeDesc == nil or not string.isNilOrWhitespace(fillTypeDesc.unitShort) then
        return
    end

    local piecesText = g_i18n:getText("unit_pieces")

    if piecesText == nil or piecesText == "unit_pieces" then
        piecesText = "pcs"
    end

    fillTypeDesc.unitShort = piecesText
end

function AnimatedLivestockTrailer:onDelete()
    AnimatedLivestockTrailer.removeBeddingSupport(self)
    AnimatedLivestockTrailer.deleteAnimalSounds(self)
    AnimatedLivestockTrailer.clearAnimatedAnimals(self)
end

function AnimatedLivestockTrailer:onUpdate(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
    local spec = self.spec_animatedLivestockTrailer
    if spec == nil then
        return
    end

    local hasLoadedAnimals = false

    if spec.enabled then
        local signedSpeed = AnimatedLivestockTrailer.getSignedSpeed(self)

        for _, cageState in pairs(spec.loadedCages or {}) do
            AnimatedLivestockTrailer.updateCageTransform(self, cageState)
        end

        for _, state in pairs(spec.loadedSlots) do
            AnimatedLivestockTrailer.updateAnimalTransform(self, state)
            AnimatedLivestockTrailer.updateAnimalAnimation(self, state, signedSpeed, dt)
        end

        hasLoadedAnimals = next(spec.loadedSlots) ~= nil or next(spec.loadedCages or {}) ~= nil

        if hasLoadedAnimals then
            AnimatedLivestockTrailer.clearStaticAnimals(self)
        end
    end

    local needsBeddingUpdate = AnimatedLivestockTrailer.updateBeddingSupport(self, spec, dt)
    local needsSoundUpdate = AnimatedLivestockTrailer.updateAnimalSounds(self, spec, dt)

    if hasLoadedAnimals or needsBeddingUpdate or needsSoundUpdate then
        self:raiseActive()
    end
end

function AnimatedLivestockTrailer.getSignedSpeed(vehicle)
    local attacherVehicle = vehicle.attacherVehicle

    if attacherVehicle ~= nil and attacherVehicle.lastSignedSpeed ~= nil then
        return attacherVehicle.lastSignedSpeed * 3600
    end

    if vehicle.lastSignedSpeed ~= nil then
        return vehicle.lastSignedSpeed * 3600
    end

    local direction = vehicle.movingDirection or 1
    if direction == 0 and attacherVehicle ~= nil then
        direction = attacherVehicle.movingDirection or 0
    end
    if direction == 0 then
        direction = 1
    end

    return math.abs(vehicle:getLastSpeed(true)) * direction
end

function AnimatedLivestockTrailer:onLoadFinished(savegame)
    local spec = self.spec_animatedLivestockTrailer

    if self.isServer and spec ~= nil and savegame ~= nil and savegame.xmlFile ~= nil then
        local newKey = string.format("%s.%s.animatedLivestockTrailer#conversionTime", savegame.key, AnimatedLivestockTrailer.MOD_NAME)
        local legacyKey = string.format("%s.%s.livestockTrailerSpecial#conversionTime", savegame.key, AnimatedLivestockTrailer.MOD_NAME)

        spec.conversionTime = savegame.xmlFile:getValue(newKey, savegame.xmlFile:getValue(legacyKey, 0))
    end
end

function AnimatedLivestockTrailer:onFillUnitFillLevelChanged(fillUnitIndex, fillLevelDelta, fillTypeIndex, toolType, fillPositionData, appliedDelta)
    local spec = self.spec_animatedLivestockTrailer

    if spec ~= nil and spec.beddingFillUnitIndex == fillUnitIndex then
        spec.conversionTime = 0
    end
end

function AnimatedLivestockTrailer:saveToXMLFile(xmlFile, key, usedModNames)
    local spec = self.spec_animatedLivestockTrailer

    if spec ~= nil and spec.strawBeddingConversionMs ~= nil and spec.strawBeddingConversionMs > 0 then
        xmlFile:setValue(key .. "#conversionTime", spec.conversionTime or 0)
    end
end

function AnimatedLivestockTrailer:addAnimals(superFunc, subTypeIndex, numAnimals, age)
    if AnimatedLivestockTrailer.getCanLoadAnimalAge(self, age) == false then
        AnimatedLivestockTrailer.showAgeUnsupportedWarning(self)
        return
    end

    return superFunc(self, subTypeIndex, numAnimals, age)
end

function AnimatedLivestockTrailer:addCluster(superFunc, cluster)
    if AnimatedLivestockTrailer.getCanLoadAnimalCluster(self, cluster) == false then
        AnimatedLivestockTrailer.showAgeUnsupportedWarning(self)
        return
    end

    return superFunc(self, cluster)
end

function AnimatedLivestockTrailer.getCanLoadAnimalCluster(vehicle, cluster)
    if cluster == nil then
        return true
    end

    return AnimatedLivestockTrailer.getCanLoadAnimalAge(vehicle, cluster:getAge())
end

function AnimatedLivestockTrailer.getCanLoadAnimalAge(vehicle, age)
    local spec = vehicle ~= nil and vehicle.spec_animatedLivestockTrailer or nil

    if spec == nil or age == nil then
        return true
    end

    if spec.minimumLoadAge ~= nil and spec.minimumLoadAge > 0 and age < spec.minimumLoadAge then
        return false
    end

    if spec.maximumLoadAge ~= nil and spec.maximumLoadAge > 0 and age > spec.maximumLoadAge then
        return false
    end

    return true
end

function AnimatedLivestockTrailer.showAgeUnsupportedWarning(vehicle, errorCallback)
    local text = AnimatedLivestockTrailer.getAgeUnsupportedWarningText(vehicle)

    if errorCallback ~= nil then
        errorCallback(text)
    elseif g_currentMission ~= nil then
        g_currentMission:showBlinkingWarning(text, 2500)
    end
end

function AnimatedLivestockTrailer.getAgeUnsupportedWarningText(vehicle)
    local spec = vehicle ~= nil and vehicle.spec_animatedLivestockTrailer or nil

    if spec ~= nil and spec.unsupportedAgeWarningText ~= nil and spec.unsupportedAgeWarningText ~= "" then
        return spec.unsupportedAgeWarningText
    end

    return g_i18n:getText("warning_animalAgeNotSupportedByTrailer")
end

function AnimatedLivestockTrailer:doCheckSpeedLimit(superFunc)
    return superFunc(self) or AnimatedLivestockTrailer.getShouldApplyLoadedSpeedLimit(self)
end

function AnimatedLivestockTrailer:getRawSpeedLimit(superFunc)
    local speedLimit = superFunc(self)

    if AnimatedLivestockTrailer.getShouldApplyLoadedSpeedLimit(self) then
        return math.min(speedLimit, self.spec_animatedLivestockTrailer.maxLoadedSpeed)
    end

    return speedLimit
end

function AnimatedLivestockTrailer.getShouldApplyLoadedSpeedLimit(vehicle)
    local spec = vehicle.spec_animatedLivestockTrailer

    return (spec ~= nil
        and spec.maxLoadedSpeed ~= nil
        and spec.maxLoadedSpeed > 0
        and AnimatedLivestockTrailer.getHasLoadedAnimals(vehicle))
end

function AnimatedLivestockTrailer.getHasLoadedAnimals(vehicle)
    if vehicle.getNumOfAnimals ~= nil and vehicle:getNumOfAnimals() > 0 then
        return true
    end

    local livestockSpec = vehicle.spec_livestockTrailer
    if livestockSpec ~= nil and livestockSpec.clusterSystem ~= nil then
        for _, cluster in ipairs(livestockSpec.clusterSystem:getClusters()) do
            if cluster:getNumAnimals() > 0 then
                return true
            end
        end
    end

    return false
end

function AnimatedLivestockTrailer.loadBeddingSupport(vehicle, spec)
    spec.conversionTime = 0
    spec.strawBeddingConversionMs = -1
    spec.balesInTrigger = nil
    spec.baleTriggerNode = nil
    spec.beddingFillUnitIndex = nil

    if not vehicle.isServer or vehicle.xmlFile == nil or vehicle.getFillUnitByIndex == nil then
        return
    end

    if vehicle.xmlFile:hasProperty("vehicle.livestockTrailer.baleTrigger") then
        spec.balesInTrigger = {}
        spec.baleTriggerNode = vehicle.xmlFile:getValue("vehicle.livestockTrailer.baleTrigger#node", nil, vehicle.components, vehicle.i3dMappings)
        spec.inputLitresPerMs = vehicle.xmlFile:getValue("vehicle.livestockTrailer.baleTrigger#inputLitresPerSecond", 100) / 1000
        spec.beddingFillUnitIndex = vehicle.xmlFile:getValue("vehicle.livestockTrailer.baleTrigger#fillUnitIndex", 1)

        if spec.baleTriggerNode ~= nil then
            addTrigger(spec.baleTriggerNode, "livestockTrailerBaleTriggerCallback", vehicle)
        end
    end

    if vehicle.xmlFile:hasProperty("vehicle.livestockTrailer.bedding") then
        spec.beddingFillUnitIndex = spec.beddingFillUnitIndex or vehicle.xmlFile:getValue("vehicle.livestockTrailer.baleTrigger#fillUnitIndex", 1)
        spec.minimumAnimals = math.max(vehicle.xmlFile:getValue("vehicle.livestockTrailer.bedding#minimumAnimals", 1), 0)
        spec.strawBeddingConversionMs = vehicle.xmlFile:getValue("vehicle.livestockTrailer.bedding#conversionSeconds", 60) * 1000

        local fillTypeName = vehicle.xmlFile:getValue("vehicle.livestockTrailer.bedding#fillType", "STRAW")
        spec.beddingFillTypeIndex = g_fillTypeManager:getFillTypeIndexByName(fillTypeName)

        if spec.beddingFillTypeIndex == nil then
            spec.beddingFillTypeIndex = FillType.STRAW
            Logging.error("[%s] Invalid fillType '%s' given at 'vehicle.livestockTrailer.bedding', using STRAW instead!", AnimatedLivestockTrailer.MOD_NAME, fillTypeName)
        end

        local convertedFillTypeName = vehicle.xmlFile:getValue("vehicle.livestockTrailer.bedding#convertedFillType", "MANURE")
        spec.convertedFillTypeIndex = g_fillTypeManager:getFillTypeIndexByName(convertedFillTypeName)

        if spec.convertedFillTypeIndex == nil then
            spec.convertedFillTypeIndex = FillType.MANURE
            Logging.error("[%s] Invalid convertedFillType '%s' given at 'vehicle.livestockTrailer.bedding', using MANURE instead!", AnimatedLivestockTrailer.MOD_NAME, convertedFillTypeName)
        end
    end
end

function AnimatedLivestockTrailer.removeBeddingSupport(vehicle)
    local spec = vehicle.spec_animatedLivestockTrailer

    if spec ~= nil and spec.baleTriggerNode ~= nil then
        removeTrigger(spec.baleTriggerNode)
        spec.baleTriggerNode = nil
    end
end

function AnimatedLivestockTrailer.updateBeddingSupport(vehicle, spec, dt)
    if not vehicle.isServer or spec.beddingFillUnitIndex == nil or vehicle.getFillUnitByIndex == nil then
        return false
    end

    local fillUnit = vehicle:getFillUnitByIndex(spec.beddingFillUnitIndex)
    if fillUnit == nil then
        return false
    end

    local needsUpdate = false

    if spec.balesInTrigger ~= nil and next(spec.balesInTrigger) ~= nil then
        for bale, _ in pairs(spec.balesInTrigger) do
            if vehicle:getFillUnitFreeCapacity(spec.beddingFillUnitIndex) <= 0 then
                break
            end

            local fillType = bale:getFillType()

            if vehicle:getFillUnitAllowsFillType(spec.beddingFillUnitIndex, fillType) then
                local fillLevel = bale:getFillLevel()
                local delta = math.min((spec.inputLitresPerMs or 0) * dt, fillLevel)

                delta = vehicle:addFillUnitFillLevel(vehicle:getOwnerFarmId(), spec.beddingFillUnitIndex, delta, fillType, ToolType.BALE, nil)
                fillLevel = fillLevel - delta
                needsUpdate = true

                if fillLevel > 0.01 then
                    bale:setFillLevel(fillLevel)
                else
                    bale:delete()
                    spec.balesInTrigger[bale] = nil
                end
            else
                spec.balesInTrigger[bale] = nil
            end
        end
    end

    if spec.strawBeddingConversionMs > 0 and fillUnit.fillLevel > 0.01 and fillUnit.fillType == spec.beddingFillTypeIndex and spec.minimumAnimals <= vehicle:getNumOfAnimals() then
        spec.conversionTime = (spec.conversionTime or 0) + dt

        if spec.conversionTime >= spec.strawBeddingConversionMs then
            local fillLevel = fillUnit.fillLevel
            local farmId = vehicle:getOwnerFarmId()

            vehicle:addFillUnitFillLevel(farmId, spec.beddingFillUnitIndex, -fillLevel, spec.beddingFillTypeIndex, ToolType.UNDEFINED, nil)
            vehicle:addFillUnitFillLevel(farmId, spec.beddingFillUnitIndex, fillLevel, spec.convertedFillTypeIndex, ToolType.UNDEFINED, nil)

            spec.conversionTime = 0
        end

        needsUpdate = true
    end

    return needsUpdate
end

function AnimatedLivestockTrailer:livestockTrailerBaleTriggerCallback(triggerId, otherActorId, onEnter, onLeave, onStay, otherShapeId)
    local spec = self.spec_animatedLivestockTrailer

    if spec ~= nil and spec.baleTriggerNode == triggerId and otherActorId ~= 0 then
        local object = g_currentMission:getNodeObject(otherActorId)

        if object ~= nil and object:isa(Bale) then
            local fillType = object:getFillType()

            if fillType == spec.beddingFillTypeIndex and self:getFillUnitAllowsFillType(spec.beddingFillUnitIndex, fillType) then
                if onEnter then
                    spec.balesInTrigger[object] = (spec.balesInTrigger[object] or 0) + 1
                elseif onLeave then
                    spec.balesInTrigger[object] = (spec.balesInTrigger[object] or 1) - 1

                    if spec.balesInTrigger[object] <= 0 then
                        spec.balesInTrigger[object] = nil
                    end
                end

                self:raiseActive()
            end
        end
    end
end

function AnimatedLivestockTrailer:updateDebugValues(values)
    local spec = self.spec_animatedLivestockTrailer

    if self.isServer and spec ~= nil and spec.strawBeddingConversionMs ~= nil and spec.strawBeddingConversionMs > 0 then
        local fillUnit = self:getFillUnitByIndex(spec.beddingFillUnitIndex)

        if fillUnit ~= nil then
            if fillUnit.fillType == spec.beddingFillTypeIndex then
                table.insert(values, {
                    name = "Conversion Time",
                    value = string.format("%.0f seconds (%d%%)", (spec.conversionTime or 0) / 1000, ((spec.conversionTime or 0) / spec.strawBeddingConversionMs) * 100)
                })
            elseif fillUnit.fillType == spec.convertedFillTypeIndex then
                table.insert(values, {
                    name = "Conversion Time",
                    value = string.format("%.0f seconds (100%%)", spec.strawBeddingConversionMs / 1000)
                })
            end
        end

        table.insert(values, {
            name = "Bedding Fill Type",
            value = g_fillTypeManager:getFillTypeTitleByIndex(spec.beddingFillTypeIndex)
        })

        table.insert(values, {
            name = "Converted Fill Type",
            value = g_fillTypeManager:getFillTypeTitleByIndex(spec.convertedFillTypeIndex)
        })
    end
end

function AnimatedLivestockTrailer:updateAnimals(superFunc)
    local vehicle = self
    local spec = vehicle.spec_animatedLivestockTrailer

    if spec == nil or not spec.enabled then
        return superFunc(vehicle)
    end

    local livestockSpec = vehicle.spec_livestockTrailer

    vehicle:clearAnimals()
    AnimatedLivestockTrailer.clearStaticAnimals(vehicle)
    spec.loadGeneration = (spec.loadGeneration or 0) + 1
    local loadGeneration = spec.loadGeneration

    if spec == nil or livestockSpec == nil then
        return
    end

    local clusters = livestockSpec.clusterSystem:getClusters()
    local currentAnimalType = vehicle:getCurrentAnimalType()
    if currentAnimalType == nil then
        return
    end

    local typeConfig = spec.configsByTypeIndex[currentAnimalType.typeIndex] or spec.defaultConfig

    local place = livestockSpec.animalTypeIndexToPlaces[currentAnimalType.typeIndex]
    place.usedSlots = 0

    if typeConfig.visualMode == "cage" then
        AnimatedLivestockTrailer.updateCageAnimals(vehicle, clusters, currentAnimalType, typeConfig, place, loadGeneration)
        return
    end

    local soundConfigs = {}
    local slotIndex = 1
    for _, cluster in ipairs(clusters) do
        local visual = g_currentMission.animalSystem:getVisualByAge(cluster:getSubTypeIndex(), cluster:getAge())

        for _ = 1, cluster:getNumAnimals() do
            local slot = place.slots[slotIndex]
            if slot == nil then
                return
            end

            local config = AnimatedLivestockTrailer.getVisualConfig(vehicle, currentAnimalType, visual, typeConfig)
            AnimatedLivestockTrailer.addAnimalSoundConfig(soundConfigs, config.soundConfig)

            if config.filename == nil then
                Logging.warning("[%s] No animated filename found for animal type '%s'; falling back to static visuals", AnimatedLivestockTrailer.MOD_NAME, currentAnimalType.name)
                AnimatedLivestockTrailer.clearAnimatedAnimals(vehicle)
                superFunc(vehicle)
                return
            end

            slot.meshLoadingInProgress = true
            slot.animatedVisualConfig = config
            slot.animatedVisual = visual
            slot.sharedAnimatedLoadRequestId = g_i3DManager:loadSharedI3DFileAsync(config.filename, false, false, AnimatedLivestockTrailer.onAnimalLoaded, vehicle, {
                slot = slot,
                visual = visual,
                config = config,
                loadGeneration = loadGeneration
            })

            slotIndex = slotIndex + 1
            place.usedSlots = place.usedSlots + 1
        end
    end

    AnimatedLivestockTrailer.setAnimalSoundConfigs(vehicle, soundConfigs)
end

function AnimatedLivestockTrailer.updateCageAnimals(vehicle, clusters, currentAnimalType, typeConfig, place, loadGeneration)
    local spec = vehicle.spec_animatedLivestockTrailer

    if typeConfig.cageFilename == nil then
        Logging.warning("[%s] Cage visual mode for animal type '%s' needs cageFilename", AnimatedLivestockTrailer.MOD_NAME, currentAnimalType.name)
        return
    end

    local cageSlotNodes = AnimatedLivestockTrailer.getCageSlotNodes(typeConfig, place)
    if #cageSlotNodes == 0 then
        Logging.warning("[%s] Cage visual mode for animal type '%s' has no cage slots", AnimatedLivestockTrailer.MOD_NAME, currentAnimalType.name)
        return
    end

    local animalsPerCage = math.max(typeConfig.animalsPerCage or 4, 1)
    local soundConfigs = {}
    local cageAnimals = {}
    local totalAnimals = 0

    for _, cluster in ipairs(clusters) do
        local visual = g_currentMission.animalSystem:getVisualByAge(cluster:getSubTypeIndex(), cluster:getAge())
        local config = AnimatedLivestockTrailer.getVisualConfig(vehicle, currentAnimalType, visual, typeConfig)
        config.forceIdleOnly = true
        AnimatedLivestockTrailer.addAnimalSoundConfig(soundConfigs, config.soundConfig)

        for _ = 1, cluster:getNumAnimals() do
            local cageIndex = math.floor(totalAnimals / animalsPerCage) + 1

            if cageSlotNodes[cageIndex] == nil then
                place.usedSlots = totalAnimals
                AnimatedLivestockTrailer.setAnimalSoundConfigs(vehicle, soundConfigs)
                return
            end

            cageAnimals[cageIndex] = cageAnimals[cageIndex] or {}
            table.insert(cageAnimals[cageIndex], {
                visual = visual,
                config = config
            })

            totalAnimals = totalAnimals + 1
        end
    end

    for cageIndex, animals in ipairs(cageAnimals) do
        local args = {
            loadGeneration = loadGeneration,
            cageIndex = cageIndex,
            cageSlotNode = cageSlotNodes[cageIndex],
            typeConfig = typeConfig,
            animals = animals
        }

        local requestId = g_i3DManager:loadSharedI3DFileAsync(typeConfig.cageFilename, false, false, AnimatedLivestockTrailer.onCageLoaded, vehicle, args)
        args.requestId = requestId

        if requestId ~= nil then
            spec.pendingCageLoadRequestIds[requestId] = true
        end
    end

    place.usedSlots = totalAnimals
    AnimatedLivestockTrailer.setAnimalSoundConfigs(vehicle, soundConfigs)
end

function AnimatedLivestockTrailer.getCageSlotNodes(typeConfig, place)
    local nodes = {}

    if typeConfig.cageSlotNode ~= nil then
        local numChildren = getNumOfChildren(typeConfig.cageSlotNode)

        for i = 0, numChildren - 1 do
            table.insert(nodes, getChildAt(typeConfig.cageSlotNode, i))
        end
    end

    if #nodes == 0 and place ~= nil and place.slots ~= nil then
        local step = math.max(typeConfig.cageSlotStep or typeConfig.animalsPerCage or 4, 1)

        for slotIndex = 1, #place.slots, step do
            local slot = place.slots[slotIndex]

            if slot ~= nil and slot.linkNode ~= nil then
                table.insert(nodes, slot.linkNode)
            end
        end
    end

    return nodes
end

function AnimatedLivestockTrailer.onCageLoaded(vehicle, cageNode, failedReason, args)
    local spec = vehicle.spec_animatedLivestockTrailer

    if spec == nil then
        if cageNode ~= nil and cageNode ~= 0 then
            delete(cageNode)
        end
        return
    end

    if args.loadGeneration ~= spec.loadGeneration then
        if args.requestId ~= nil then
            spec.pendingCageLoadRequestIds[args.requestId] = nil
        end

        if cageNode ~= nil and cageNode ~= 0 then
            delete(cageNode)
        end
        return
    end

    if cageNode == nil or cageNode == 0 then
        if args.requestId ~= nil then
            spec.pendingCageLoadRequestIds[args.requestId] = nil
        end
        return
    end

    if args.requestId ~= nil then
        spec.pendingCageLoadRequestIds[args.requestId] = nil
    end

    link(getRootNode(), cageNode)

    local cageState = {
        node = cageNode,
        slotNode = args.cageSlotNode,
        cageIndex = args.cageIndex,
        typeConfig = args.typeConfig,
        sharedCageLoadRequestId = args.requestId
    }

    spec.loadedCages[cageNode] = cageState
    AnimatedLivestockTrailer.updateCageTransform(vehicle, cageState)

    if args.typeConfig.cageAnimalMode == "none" then
        return
    end

    AnimatedLivestockTrailer.loadCageAnimals(vehicle, cageState, args.animals, args.loadGeneration)
end

function AnimatedLivestockTrailer.loadCageAnimals(vehicle, cageState, animals, loadGeneration)
    local animalSlotsRoot = AnimatedLivestockTrailer.namePathToLoadedI3DObject(cageState.node, cageState.typeConfig.cageAnimalSlotsPath)

    if animalSlotsRoot == nil then
        Logging.warning("[%s] Cage animal slot node '%s' not found in cage i3d", AnimatedLivestockTrailer.MOD_NAME, tostring(cageState.typeConfig.cageAnimalSlotsPath))
        return
    end

    local numSlots = getNumOfChildren(animalSlotsRoot)

    if numSlots <= 0 then
        Logging.warning("[%s] Cage animal slot node '%s' has no children", AnimatedLivestockTrailer.MOD_NAME, tostring(cageState.typeConfig.cageAnimalSlotsPath))
        return
    end

    for animalIndex, animal in ipairs(animals or {}) do
        if animalIndex > numSlots then
            return
        end

        if animal.config.filename ~= nil then
            local slot = {
                linkNode = getChildAt(animalSlotsRoot, animalIndex - 1),
                cageNode = cageState.node
            }

            slot.meshLoadingInProgress = true
            slot.animatedVisualConfig = animal.config
            slot.animatedVisual = animal.visual

            slot.sharedAnimatedLoadRequestId = g_i3DManager:loadSharedI3DFileAsync(animal.config.filename, false, false, AnimatedLivestockTrailer.onAnimalLoaded, vehicle, {
                slot = slot,
                visual = animal.visual,
                config = animal.config,
                loadGeneration = loadGeneration
            })

            vehicle.spec_animatedLivestockTrailer.pendingAnimatedSlots[slot] = true
        end
    end
end

function AnimatedLivestockTrailer.updateCageTransform(vehicle, cageState)
    if cageState == nil or cageState.node == nil or cageState.slotNode == nil then
        return
    end

    local x, y, z = getWorldTranslation(cageState.slotNode)
    local rx, ry, rz = getWorldRotation(cageState.slotNode)

    setWorldTranslation(cageState.node, x, y, z)
    setWorldRotation(cageState.node, rx, ry, rz)
end

function AnimatedLivestockTrailer:clearAnimals(superFunc)
    AnimatedLivestockTrailer.clearAnimatedAnimals(self)

    if superFunc ~= nil then
        return superFunc(self)
    end
end

function AnimatedLivestockTrailer.clearAnimatedAnimals(vehicle)
    local spec = vehicle.spec_animatedLivestockTrailer
    if spec == nil then
        return
    end

    spec.loadGeneration = (spec.loadGeneration or 0) + 1

    for slot, state in pairs(spec.loadedSlots or {}) do
        if state.animationSharedLoadRequestId ~= nil then
            g_i3DManager:releaseSharedI3DFile(state.animationSharedLoadRequestId)
        end

        if slot.sharedAnimatedLoadRequestId ~= nil then
            g_i3DManager:releaseSharedI3DFile(slot.sharedAnimatedLoadRequestId)
            slot.sharedAnimatedLoadRequestId = nil
        end

        if state.node ~= nil and entityExists(state.node) then
            delete(state.node)
        end

        slot.meshLoadingInProgress = false
        slot.animatedVisualConfig = nil
        slot.animatedVisual = nil
    end

    for slot, _ in pairs(spec.pendingAnimatedSlots or {}) do
        if slot.sharedAnimatedLoadRequestId ~= nil then
            g_i3DManager:releaseSharedI3DFile(slot.sharedAnimatedLoadRequestId)
            slot.sharedAnimatedLoadRequestId = nil
        end

        slot.meshLoadingInProgress = false
        slot.animatedVisualConfig = nil
        slot.animatedVisual = nil
    end

    for requestId, _ in pairs(spec.pendingCageLoadRequestIds or {}) do
        g_i3DManager:releaseSharedI3DFile(requestId)
    end

    for _, cageState in pairs(spec.loadedCages or {}) do
        if cageState.sharedCageLoadRequestId ~= nil then
            g_i3DManager:releaseSharedI3DFile(cageState.sharedCageLoadRequestId)
            cageState.sharedCageLoadRequestId = nil
        end

        if cageState.node ~= nil and entityExists(cageState.node) then
            delete(cageState.node)
        end
    end

    AnimatedLivestockTrailer.clearPendingAnimatedAnimalLoads(vehicle)

    spec.loadedSlots = {}
    spec.loadedCages = {}
    spec.pendingCageLoadRequestIds = {}
    spec.pendingAnimatedSlots = {}
    AnimatedLivestockTrailer.deleteAnimalSounds(vehicle)
    AnimatedLivestockTrailer.clearStaticAnimals(vehicle)
end

function AnimatedLivestockTrailer.clearPendingAnimatedAnimalLoads(vehicle)
    local livestockSpec = vehicle.spec_livestockTrailer
    if livestockSpec == nil or livestockSpec.animalTypeIndexToPlaces == nil then
        return
    end

    for _, place in pairs(livestockSpec.animalTypeIndexToPlaces) do
        for _, slot in ipairs(place.slots or {}) do
            if slot.sharedAnimatedLoadRequestId ~= nil then
                g_i3DManager:releaseSharedI3DFile(slot.sharedAnimatedLoadRequestId)
                slot.sharedAnimatedLoadRequestId = nil
            end

            slot.meshLoadingInProgress = false
            slot.animatedVisualConfig = nil
            slot.animatedVisual = nil
        end
    end
end

function AnimatedLivestockTrailer.clearStaticAnimals(vehicle)
    local livestockSpec = vehicle.spec_livestockTrailer
    if livestockSpec == nil or livestockSpec.animalTypeIndexToPlaces == nil then
        return
    end

    for _, place in pairs(livestockSpec.animalTypeIndexToPlaces) do
        for _, slot in ipairs(place.slots or {}) do
            if slot.sharedLoadRequestId ~= nil then
                g_i3DManager:releaseSharedI3DFile(slot.sharedLoadRequestId)
                slot.sharedLoadRequestId = nil
            end

            if slot.loadedMesh ~= nil and slot.loadedMesh ~= 0 then
                if entityExists(slot.loadedMesh) then
                    delete(slot.loadedMesh)
                end

                slot.loadedMesh = nil
            else
                slot.loadedMesh = nil
            end
        end
    end
end

function AnimatedLivestockTrailer.addAnimalSoundConfig(soundConfigs, soundConfig)
    if soundConfig == nil or soundConfig.samples == nil or #soundConfig.samples == 0 then
        return
    end

    soundConfigs.signatures = soundConfigs.signatures or {}

    if not soundConfigs.signatures[soundConfig.signature] then
        soundConfigs.signatures[soundConfig.signature] = true
        table.insert(soundConfigs, soundConfig)
    end
end

function AnimatedLivestockTrailer.setAnimalSoundConfigs(vehicle, soundConfigs)
    local spec = vehicle.spec_animatedLivestockTrailer

    if spec == nil or not spec.useAnimalSounds or not vehicle.isClient then
        return
    end

    local signatureParts = {}
    for _, soundConfig in ipairs(soundConfigs) do
        table.insert(signatureParts, soundConfig.signature)
    end

    table.sort(signatureParts)

    local signature = table.concat(signatureParts, "|")
    local animalCount = vehicle:getNumOfAnimals()

    if spec.animalSoundSignature == signature and spec.animalSoundAnimalCount == animalCount then
        return
    end

    AnimatedLivestockTrailer.deleteAnimalSounds(vehicle)

    spec.animalSoundSignature = signature
    spec.animalSoundAnimalCount = animalCount

    if signature == "" or animalCount <= 0 then
        return
    end

    local linkNode = spec.animalSoundNode or (vehicle.components ~= nil and vehicle.components[1] ~= nil and vehicle.components[1].node or nil)
    if linkNode == nil then
        return
    end

    for _, soundConfig in ipairs(soundConfigs) do
        local loadedGroup = AnimatedLivestockTrailer.loadAnimalSoundGroup(vehicle, soundConfig, linkNode)

        if loadedGroup ~= nil and #loadedGroup.samples > 0 then
            table.insert(spec.animalSoundGroups, loadedGroup)
        end
    end

    if #spec.animalSoundGroups > 0 then
        spec.animalSoundTimer = math.random(1000, math.max(1000, spec.animalSoundMaxInterval))
    end
end

function AnimatedLivestockTrailer.loadAnimalSoundGroup(vehicle, soundConfig, linkNode)
    local spec = vehicle.spec_animatedLivestockTrailer
    local loadedGroup = {
        minInterval = soundConfig.minInterval,
        maxInterval = soundConfig.maxInterval,
        crowdScale = soundConfig.crowdScale,
        volume = soundConfig.volume,
        volumeRandMin = soundConfig.volumeRandMin,
        volumeRandMax = soundConfig.volumeRandMax,
        pitch = soundConfig.pitch,
        pitchRandMin = soundConfig.pitchRandMin,
        pitchRandMax = soundConfig.pitchRandMax,
        samples = {}
    }

    for _, filename in ipairs(soundConfig.samples) do
        local volume = math.max((soundConfig.volume or 1) * (spec.animalSoundVolumeScale or 1), 0)
        local soundNode = createAudioSource("animatedLivestockTrailerAnimalSound", filename, soundConfig.range or 40, soundConfig.innerRange or 1, volume, 1)

        if soundNode ~= nil and soundNode ~= 0 then
            link(linkNode, soundNode)
            setTranslation(soundNode, 0, 0, 0)

            local soundSample = getAudioSourceSample(soundNode)

            if soundSample ~= nil and soundSample ~= 0 then
                table.insert(loadedGroup.samples, {
                    filename = filename,
                    soundNode = soundNode,
                    soundSample = soundSample,
                    volume = volume
                })
            else
                delete(soundNode)
            end
        end
    end

    return loadedGroup
end

function AnimatedLivestockTrailer.deleteAnimalSounds(vehicle)
    local spec = vehicle.spec_animatedLivestockTrailer

    if spec == nil then
        return
    end

    if spec.animalSoundGroups ~= nil then
        for _, soundGroup in ipairs(spec.animalSoundGroups) do
            for _, sample in ipairs(soundGroup.samples) do
                AnimatedLivestockTrailer.deleteAnimalSoundSample(sample)
            end
        end
    end

    spec.animalSoundGroups = {}
    spec.animalSoundSignature = nil
    spec.currentAnimalSoundSample = nil
    spec.animalSoundTimer = 0
    spec.animalSoundAnimalCount = 0
end

function AnimatedLivestockTrailer.deleteAnimalSoundSample(sample)
    if sample == nil then
        return
    end

    if sample.soundSample ~= nil and isSamplePlaying(sample.soundSample) then
        stopSample(sample.soundSample, 0, 0)
    end

    if sample.soundNode ~= nil and entityExists(sample.soundNode) then
        delete(sample.soundNode)
    end

    sample.soundSample = nil
    sample.soundNode = nil
end

function AnimatedLivestockTrailer.updateAnimalSounds(vehicle, spec, dt)
    if not vehicle.isClient or not spec.useAnimalSounds or spec.animalSoundGroups == nil or #spec.animalSoundGroups == 0 then
        return false
    end

    if vehicle:getNumOfAnimals() <= 0 then
        return false
    end

    if spec.currentAnimalSoundSample ~= nil and g_soundManager:getIsSamplePlaying(spec.currentAnimalSoundSample) then
        return true
    end

    spec.animalSoundTimer = (spec.animalSoundTimer or 0) - dt

    if spec.animalSoundTimer <= 0 then
        local soundGroup = spec.animalSoundGroups[math.random(1, #spec.animalSoundGroups)]
        local sample = soundGroup.samples[math.random(1, #soundGroup.samples)]

        if sample ~= nil then
            local volume = sample.volume + AnimatedLivestockTrailer.randomFloat(soundGroup.volumeRandMin or 0, soundGroup.volumeRandMax or 0)
            local pitch = (soundGroup.pitch or 1) + AnimatedLivestockTrailer.randomFloat(soundGroup.pitchRandMin or 0, soundGroup.pitchRandMax or 0)

            g_soundManager:setSamplePitch(sample, math.max(pitch, 0.1))
            playSample(sample.soundSample, 1, math.max(volume, 0), 0, 0, 0)

            spec.currentAnimalSoundSample = sample
        end

        spec.animalSoundTimer = AnimatedLivestockTrailer.getNextAnimalSoundInterval(vehicle, spec, soundGroup)
    end

    return true
end

function AnimatedLivestockTrailer.randomFloat(minValue, maxValue)
    if maxValue <= minValue then
        return minValue
    end

    return minValue + math.random() * (maxValue - minValue)
end

function AnimatedLivestockTrailer.getNextAnimalSoundInterval(vehicle, spec, soundGroup)
    local minInterval = soundGroup.minInterval or spec.animalSoundMinInterval or 8000
    local maxInterval = soundGroup.maxInterval or spec.animalSoundMaxInterval or 22000
    local crowdScale = soundGroup.crowdScale or 0
    local animalCount = math.max(vehicle:getNumOfAnimals(), 1)
    local crowdDivider = 1 + math.max(animalCount - 1, 0) * crowdScale

    minInterval = minInterval / crowdDivider
    maxInterval = maxInterval / crowdDivider
    minInterval = math.max(minInterval, spec.animalSoundMinimumInterval or 3500)
    maxInterval = math.max(maxInterval, minInterval)

    return math.random(math.floor(minInterval), math.floor(maxInterval))
end

function AnimatedLivestockTrailer.getVisualConfig(vehicle, animalType, visual, typeConfig)
    local visualAnimal = visual ~= nil and visual.visualAnimal or nil
    local config = {
        filename = typeConfig.filename or (visualAnimal ~= nil and visualAnimal.filename or nil),
        animationFilename = typeConfig.animationFilename,
        clipRootPath = typeConfig.clipRootPath,
        animationSourcePath = typeConfig.animationSourcePath,
        idleClip = typeConfig.idleClip,
        walkClip = typeConfig.walkClip,
        runClip = typeConfig.runClip,
        randomIdleStart = typeConfig.randomIdleStart,
        randomMovementStart = typeConfig.randomMovementStart,
        reverseMovementAnimations = typeConfig.reverseMovementAnimations,
        playbackScale = typeConfig.playbackScale,
        referenceWalkSpeed = typeConfig.referenceWalkSpeed,
        referenceRunSpeed = typeConfig.referenceRunSpeed,
        soundConfig = nil
    }

    if visualAnimal ~= nil then
        local animalAssetConfig = AnimatedLivestockTrailer.getAnimalAssetConfig(animalType, visualAnimal.filename, visualAnimal.filenamePosed)

        if animalAssetConfig ~= nil then
            config.filename = typeConfig.filename or animalAssetConfig.filename or config.filename
            config.animationFilename = config.animationFilename or animalAssetConfig.animationFilename
            config.clipRootPath = config.clipRootPath or animalAssetConfig.skeletonIndex
            config.animationSourcePath = config.animationSourcePath or animalAssetConfig.skeletonIndex
            config.locomotionClips = animalAssetConfig.locomotionClips
            config.locomotionClipSets = animalAssetConfig.locomotionClipSets
            config.soundConfig = animalAssetConfig.soundConfig
        end
    end

    config.clipRootPath = config.clipRootPath or "0"
    config.animationSourcePath = config.animationSourcePath or config.clipRootPath or "0"

    return config
end

function AnimatedLivestockTrailer.getAnimalAssetConfig(animalType, ...)
    if animalType == nil or animalType.configFilename == nil then
        return nil
    end

    local cache = AnimatedLivestockTrailer.animalConfigCache[animalType.configFilename]
    if cache == nil then
        cache = AnimatedLivestockTrailer.loadAnimalAssetConfigs(animalType.configFilename)
        AnimatedLivestockTrailer.animalConfigCache[animalType.configFilename] = cache
    end

    for i = 1, select("#", ...) do
        local filename = select(i, ...)

        if filename ~= nil and cache[filename] ~= nil then
            return cache[filename]
        end
    end

    return nil
end

function AnimatedLivestockTrailer.loadAnimalAssetConfigs(configFilename)
    local configs = {}
    local xmlFile = XMLFile.load("animatedLivestockTrailerAnimals", configFilename, AnimatedLivestockTrailer.getAnimalAssetsSchema())

    if xmlFile == nil then
        return configs
    end

    local baseDirectory = Utils.getDirectory(configFilename)
    local _, modBaseDirectory = Utils.getModNameAndBaseDirectory(configFilename)
    local soundGroups = AnimatedLivestockTrailer.loadAnimalSoundGroups(xmlFile, baseDirectory)

    for _, key in xmlFile:iterator("animalHusbandry.animals.animal") do
        local rawFilename = xmlFile:getValue(key .. ".assets#filename")
        local rawFilenamePosed = xmlFile:getValue(key .. ".assets#filenamePosed")
        local filename = AnimatedLivestockTrailer.resolveFilename(rawFilename, baseDirectory)
        local locomotionClips, locomotionClipSets = AnimatedLivestockTrailer.loadLocomotionClips(AnimatedLivestockTrailer.resolveFilename(xmlFile:getValue(key .. ".locomotion#filename"), baseDirectory))

        if filename ~= nil then
            local config = {
                filename = filename,
                animationFilename = AnimatedLivestockTrailer.resolveFilename(xmlFile:getValue(key .. ".assets#animation"), baseDirectory),
                skeletonIndex = xmlFile:getValue(key .. ".assets#skeletonIndex"),
                locomotionClips = locomotionClips,
                locomotionClipSets = locomotionClipSets,
                soundConfig = AnimatedLivestockTrailer.getAnimalSoundConfig(xmlFile, key, soundGroups)
            }

            AnimatedLivestockTrailer.addConfigAlias(configs, rawFilename, baseDirectory, config)
            AnimatedLivestockTrailer.addConfigAlias(configs, rawFilename, modBaseDirectory, config)
            AnimatedLivestockTrailer.addConfigAlias(configs, rawFilenamePosed, baseDirectory, config)
            AnimatedLivestockTrailer.addConfigAlias(configs, rawFilenamePosed, modBaseDirectory, config)
        end
    end

    xmlFile:delete()

    return configs
end

function AnimatedLivestockTrailer.loadAnimalSoundGroups(xmlFile, baseDirectory)
    local soundGroups = {}

    for _, groupKey in xmlFile:iterator("animalHusbandry.sound.soundGroup") do
        local name = xmlFile:getString(groupKey .. "#name")

        if name ~= nil then
            local soundGroup = {
                name = name,
                volume = xmlFile:getFloat(groupKey .. "#volume", 1),
                range = xmlFile:getFloat(groupKey .. "#range", 40),
                innerRange = xmlFile:getFloat(groupKey .. "#innerRange", 1),
                volumeRandMin = xmlFile:getFloat(groupKey .. "#volumeRandMin", 0),
                volumeRandMax = xmlFile:getFloat(groupKey .. "#volumeRandMax", 0),
                pitch = xmlFile:getFloat(groupKey .. "#pitch", 1),
                pitchRandMin = xmlFile:getFloat(groupKey .. "#pitchRandMin", 0),
                pitchRandMax = xmlFile:getFloat(groupKey .. "#pitchRandMax", 0),
                samples = {}
            }

            for _, sampleKey in xmlFile:iterator(groupKey .. ".sample") do
                local filename = AnimatedLivestockTrailer.resolveFilename(xmlFile:getString(sampleKey .. "#filename"), baseDirectory)

                if filename ~= nil then
                    table.insert(soundGroup.samples, filename)
                end
            end

            if #soundGroup.samples > 0 then
                soundGroups[name] = soundGroup
            end
        end
    end

    return soundGroups
end

function AnimatedLivestockTrailer.getAnimalSoundConfig(xmlFile, animalKey, soundGroups)
    local groupName = xmlFile:getString(animalKey .. ".audio#yellSoundGroup")
    local soundGroup = groupName ~= nil and soundGroups[groupName] or nil

    if soundGroup == nil then
        soundGroup = AnimatedLivestockTrailer.getFallbackAnimalSoundGroup(soundGroups)
    end

    if soundGroup == nil then
        return nil
    end

    local soundConfig = {
        name = soundGroup.name,
        minInterval = xmlFile:getInt(animalKey .. ".audio#yellMinInterval", 8000),
        maxInterval = xmlFile:getInt(animalKey .. ".audio#yellMaxInterval", 22000),
        crowdScale = xmlFile:getFloat(animalKey .. ".audio#yellTimerCrowdScale", 0),
        volume = soundGroup.volume,
        range = soundGroup.range,
        innerRange = soundGroup.innerRange,
        volumeRandMin = soundGroup.volumeRandMin,
        volumeRandMax = soundGroup.volumeRandMax,
        pitch = soundGroup.pitch,
        pitchRandMin = soundGroup.pitchRandMin,
        pitchRandMax = soundGroup.pitchRandMax,
        samples = soundGroup.samples
    }

    soundConfig.signature = AnimatedLivestockTrailer.getAnimalSoundSignature(soundConfig)

    return soundConfig
end

function AnimatedLivestockTrailer.getFallbackAnimalSoundGroup(soundGroups)
    for name, soundGroup in pairs(soundGroups) do
        local lowerName = string.lower(name)

        if lowerName:find("yell") ~= nil or lowerName:find("voice") ~= nil or lowerName:find("call") ~= nil then
            return soundGroup
        end
    end

    return nil
end

function AnimatedLivestockTrailer.getAnimalSoundSignature(soundConfig)
    local parts = {soundConfig.name or ""}

    for _, filename in ipairs(soundConfig.samples) do
        table.insert(parts, filename)
    end

    return table.concat(parts, ";")
end

function AnimatedLivestockTrailer.loadLocomotionClips(locomotionFilename)
    if locomotionFilename == nil then
        return nil, nil
    end

    local locomotionXML = XMLFile.load("animatedLivestockTrailerLocomotion", locomotionFilename, AnimatedLivestockTrailer.getLocomotionSchema())
    if locomotionXML == nil then
        return nil, nil
    end

    local animationFilename = AnimatedLivestockTrailer.resolveFilename(locomotionXML:getString("locomotion.animation#filename"), Utils.getDirectory(locomotionFilename))
    locomotionXML:delete()

    return AnimatedLivestockTrailer.loadAnimationStateClips(animationFilename)
end

function AnimatedLivestockTrailer.loadAnimationStateClips(animationFilename)
    if animationFilename == nil then
        return nil, nil
    end

    local animationXML = XMLFile.load("animatedLivestockTrailerAnimation", animationFilename, AnimatedLivestockTrailer.getAnimationSchema())
    if animationXML == nil then
        return nil, nil
    end

    local locomotionClips = {
        idle = {},
        walk = {},
        run = {}
    }
    local locomotionClipSets = {
        idle = {},
        walk = {},
        run = {}
    }

    for _, stateKey in animationXML:iterator("animation.states.state") do
        local clipKey = AnimatedLivestockTrailer.getClipKeyFromStateId(animationXML:getString(stateKey .. "#id"))

        if clipKey ~= nil then
            for _, animationKey in animationXML:iterator(stateKey .. ".animation") do
                local clip = animationXML:getString(animationKey .. "#clip")
                local clipLeft = animationXML:getString(animationKey .. "#clipLeft")
                local clipRight = animationXML:getString(animationKey .. "#clipRight")

                AnimatedLivestockTrailer.addClipCandidate(locomotionClips[clipKey], clip)
                AnimatedLivestockTrailer.addClipCandidate(locomotionClips[clipKey], clipLeft)
                AnimatedLivestockTrailer.addClipCandidate(locomotionClips[clipKey], clipRight)

                local clipSet = AnimatedLivestockTrailer.createClipSet(clip, clipLeft, clipRight, animationXML:getValue(animationKey .. "#speed", 1))
                if clipSet ~= nil then
                    table.insert(locomotionClipSets[clipKey], clipSet)
                end
            end
        end
    end

    animationXML:delete()

    return locomotionClips, locomotionClipSets
end

function AnimatedLivestockTrailer.createClipSet(clip, clipLeft, clipRight, speedScale)
    local clips = {}

    if not string.isNilOrWhitespace(clip) then
        table.insert(clips, clip)
    else
        if not string.isNilOrWhitespace(clipLeft) then
            table.insert(clips, clipLeft)
        end

        if not string.isNilOrWhitespace(clipRight) then
            table.insert(clips, clipRight)
        end
    end

    if #clips == 0 then
        return nil
    end

    return {
        clips = clips,
        speedScale = speedScale or 1
    }
end

function AnimatedLivestockTrailer.getClipKeyFromStateId(stateId)
    if string.isNilOrWhitespace(stateId) then
        return nil
    end

    local lowerStateId = string.lower(stateId)

    if lowerStateId == "idle" or lowerStateId == "idletransition" then
        return "idle"
    elseif lowerStateId == "walk" then
        return "walk"
    elseif lowerStateId == "run" then
        return "run"
    end

    return nil
end

function AnimatedLivestockTrailer.onAnimalLoaded(vehicle, i3dNode, failedReason, args)
    if i3dNode == nil or i3dNode == 0 then
        return
    end

    local spec = vehicle.spec_animatedLivestockTrailer
    if spec == nil then
        delete(i3dNode)
        return
    end

    local slot = args.slot
    if args.loadGeneration ~= spec.loadGeneration then
        delete(i3dNode)
        return
    end

    local visual = args.visual
    local config = args.config

    if spec.pendingAnimatedSlots ~= nil then
        spec.pendingAnimatedSlots[slot] = nil
    end

    link(getRootNode(), i3dNode)
    slot.meshLoadingInProgress = false

    local state = {
        node = i3dNode,
        slot = slot,
        config = config,
        currentClip = nil,
        clipDuration = 0,
        clipTime = 0,
        clipSpeedScale = 1,
        activeTracks = {},
        characterSet = nil,
        track = AnimatedLivestockTrailer.DEFAULT_TRACK,
        warnedMissingClip = {}
    }

    spec.loadedSlots[slot] = state

    AnimatedLivestockTrailer.applyVisualVariation(i3dNode, visual)
    AnimatedLivestockTrailer.updateAnimalTransform(vehicle, state)
    AnimatedLivestockTrailer.prepareAnimation(vehicle, state)
end

function AnimatedLivestockTrailer.applyVisualVariation(rootNode, visual)
    if visual == nil or visual.visualAnimal == nil then
        return
    end

    local variations = visual.visualAnimal.variations
    if variations == nil or #variations == 0 then
        return
    end

    local variation = variations[math.random(1, #variations)]
    local offsetU = variation.tileUIndex / variation.numTilesU
    local offsetV = variation.tileVIndex / variation.numTilesV

    I3DUtil.setShaderParameterRec(rootNode, "atlasInvSizeAndOffsetUV", 1 / variation.numTilesU, 1 / variation.numTilesV, offsetU, offsetV)
    I3DUtil.setShaderParameterRec(rootNode, "dirt", 0, nil, nil, nil)
end

function AnimatedLivestockTrailer.updateAnimalTransform(vehicle, state)
    local spec = vehicle.spec_animatedLivestockTrailer
    local slotNode = state.slot.linkNode

    if slotNode == nil or state.node == nil then
        return
    end

    local x, y, z = getWorldTranslation(slotNode)
    local rx, ry, rz = getWorldRotation(slotNode)

    if state.slot.cageNode == nil and spec.alignToTerrain then
        y = AnimatedLivestockTrailer.getGroundAlignedY(vehicle, x, y, z) + spec.groundOffset
    end

    setWorldTranslation(state.node, x, y, z)
    setWorldRotation(state.node, rx, ry, rz)
end

function AnimatedLivestockTrailer.getGroundAlignedY(vehicle, x, fallbackY, z)
    local spec = vehicle.spec_animatedLivestockTrailer
    local terrainY = fallbackY

    if g_terrainNode ~= nil then
        terrainY = getTerrainHeightAtWorldPos(g_terrainNode, x, 0, z)
    end

    if spec.alignToGroundCollisions then
        spec.groundRaycastHitY = nil
        spec.groundRaycastHitDistance = nil

        local raycastOffset = math.max(spec.groundRaycastOffset or 4, 0.1)
        local raycastDistance = math.max(spec.groundRaycastDistance or 12, raycastOffset + 0.1)
        local startY = math.max(fallbackY, terrainY) + raycastOffset

        raycastClosest(x, startY, z, 0, -1, 0, raycastDistance, "animatedLivestockTrailerGroundRaycastCallback", vehicle, AnimatedLivestockTrailer.GROUND_RAYCAST_COLLISION_MASK)

        if spec.groundRaycastHitY ~= nil and spec.groundRaycastHitY > terrainY - 0.25 then
            return spec.groundRaycastHitY
        end
    end

    return terrainY
end

function AnimatedLivestockTrailer:animatedLivestockTrailerGroundRaycastCallback(hitObjectId, x, y, z, distance, nx, ny, nz, subShapeIndex, shapeId, isLast)
    local spec = self.spec_animatedLivestockTrailer

    if spec == nil or hitObjectId == nil or hitObjectId == 0 then
        return false
    end

    spec.groundRaycastHitY = y
    spec.groundRaycastHitDistance = distance

    return false
end

function AnimatedLivestockTrailer.prepareAnimation(vehicle, state)
    local config = state.config
    local targetNode = AnimatedLivestockTrailer.indexToLoadedI3DObject(state.node, config.clipRootPath) or state.node

    if config.animationFilename ~= nil and config.animationFilename ~= config.filename then
        state.animationSharedLoadRequestId = g_i3DManager:loadSharedI3DFileAsync(config.animationFilename, false, false, AnimatedLivestockTrailer.onAnimationLoaded, vehicle, {
            state = state,
            targetNode = targetNode
        })
        return
    end

    state.characterSet = AnimatedLivestockTrailer.findCharacterSet(targetNode)
end

function AnimatedLivestockTrailer.findCharacterSet(node)
    if node == nil or node == 0 then
        return nil
    end

    local characterSet = getAnimCharacterSet(node)
    if characterSet ~= nil and characterSet ~= 0 then
        return characterSet
    end

    local numChildren = getNumOfChildren(node)
    for i = 0, numChildren - 1 do
        characterSet = getAnimCharacterSet(getChildAt(node, i))
        if characterSet ~= nil and characterSet ~= 0 then
            return characterSet
        end
    end

    return nil
end

function AnimatedLivestockTrailer.onAnimationLoaded(vehicle, node, failedReason, args)
    local state = args.state
    if node == nil or node == 0 or state.node == nil then
        return
    end

    local sourceNode = AnimatedLivestockTrailer.indexToLoadedI3DObject(node, state.config.animationSourcePath)
    if sourceNode == nil and getNumOfChildren(node) > 0 then
        sourceNode = getChildAt(node, 0)
    end
    if sourceNode ~= nil and sourceNode ~= 0 then
        local cloned = false

        if args.targetNode ~= nil and args.targetNode ~= 0 then
            cloned = cloneAnimCharacterSet(sourceNode, args.targetNode)
        end

        if not cloned then
            local targetParent = getParent(args.targetNode)
            if targetParent ~= nil and targetParent ~= 0 then
                cloned = cloneAnimCharacterSet(sourceNode, targetParent)
            end
        end
    end

    delete(node)
    state.characterSet = AnimatedLivestockTrailer.findCharacterSet(args.targetNode)
end

function AnimatedLivestockTrailer.updateAnimalAnimation(vehicle, state, signedSpeed, dt)
    if state.characterSet == nil or state.characterSet == 0 then
        return
    end

    local config = state.config
    local speed = math.abs(signedSpeed)
    local clipKey = "idle"
    local referenceSpeed = 0

    if not config.forceIdleOnly and vehicle.spec_animatedLivestockTrailer.useSpeedAnimations and speed >= vehicle.spec_animatedLivestockTrailer.runSpeed then
        clipKey = "run"
        referenceSpeed = config.referenceRunSpeed
    elseif not config.forceIdleOnly and vehicle.spec_animatedLivestockTrailer.useSpeedAnimations and speed >= vehicle.spec_animatedLivestockTrailer.walkSpeed then
        clipKey = "walk"
        referenceSpeed = config.referenceWalkSpeed
    end

    if state.currentClipKey ~= clipKey then
        if not AnimatedLivestockTrailer.setClipSet(state, AnimatedLivestockTrailer.getClipSetCandidates(config, clipKey, state.characterSet), clipKey) then
            return
        end
    end

    if state.clipDuration <= 0 then
        return
    end

    local speedFactor = 1
    if referenceSpeed > 0 then
        speedFactor = math.max(speed / referenceSpeed, 0.15)
    end

    local playbackDirection = 1
    if clipKey ~= "idle" and config.reverseMovementAnimations and signedSpeed < -0.05 then
        playbackDirection = -1
    end

    state.clipTime = AnimatedLivestockTrailer.wrapAnimationTime(state.clipTime + dt * speedFactor * config.playbackScale * (state.clipSpeedScale or 1) * playbackDirection, state.clipDuration)

    for _, trackInfo in ipairs(state.activeTracks or {{track = state.track, duration = state.clipDuration}}) do
        local track = trackInfo.track or trackInfo
        local trackTime = state.clipTime

        if trackInfo.duration ~= nil and trackInfo.duration > 0 then
            trackTime = AnimatedLivestockTrailer.wrapAnimationTime(state.clipTime, trackInfo.duration)
        end

        enableAnimTrack(state.characterSet, track)
        setAnimTrackTime(state.characterSet, track, trackTime, true)
    end
end

function AnimatedLivestockTrailer.wrapAnimationTime(time, duration)
    if duration == nil or duration <= 0 then
        return 0
    end

    time = time % duration

    if time < 0 then
        time = time + duration
    end

    return time
end

function AnimatedLivestockTrailer.addClipCandidate(candidates, clipName)
    if string.isNilOrWhitespace(clipName) then
        return
    end

    for _, existingClipName in ipairs(candidates) do
        if existingClipName == clipName then
            return
        end
    end

    table.insert(candidates, clipName)
end

function AnimatedLivestockTrailer.addClipCandidates(candidates, clipNames)
    if clipNames == nil then
        return
    end

    for _, clipName in ipairs(clipNames) do
        AnimatedLivestockTrailer.addClipCandidate(candidates, clipName)
    end
end

function AnimatedLivestockTrailer.getClipCandidates(config, clipKey, characterSet)
    local candidates = {}

    if clipKey == "idle" then
        AnimatedLivestockTrailer.addClipCandidate(candidates, config.idleClip)
    elseif clipKey == "walk" then
        AnimatedLivestockTrailer.addClipCandidate(candidates, config.walkClip)
    elseif clipKey == "run" then
        AnimatedLivestockTrailer.addClipCandidate(candidates, config.runClip)
    end

    if config.locomotionClips ~= nil then
        AnimatedLivestockTrailer.addClipCandidates(candidates, config.locomotionClips[clipKey])
    end

    for _, clipName in ipairs(AnimatedLivestockTrailer.CLIP_FALLBACKS[clipKey] or {}) do
        AnimatedLivestockTrailer.addClipCandidate(candidates, clipName)
    end

    AnimatedLivestockTrailer.addDynamicClipCandidates(candidates, characterSet, clipKey)

    return candidates
end

function AnimatedLivestockTrailer.getClipSetCandidates(config, clipKey, characterSet)
    local candidates = {}

    if config.locomotionClipSets ~= nil and config.locomotionClipSets[clipKey] ~= nil then
        for _, clipSet in ipairs(config.locomotionClipSets[clipKey]) do
            table.insert(candidates, clipSet)
        end
    end

    for _, clipName in ipairs(AnimatedLivestockTrailer.getClipCandidates(config, clipKey, characterSet)) do
        table.insert(candidates, {
            clips = {clipName},
            speedScale = 1
        })
    end

    return candidates
end

function AnimatedLivestockTrailer.addDynamicClipCandidates(candidates, characterSet, clipKey)
    if characterSet == nil or characterSet == 0 then
        return
    end

    local numClips = getAnimNumOfClips(characterSet)
    if numClips == nil then
        return
    end

    local dynamicCandidates = {}
    for i = 0, numClips - 1 do
        local clipName = getAnimClipName(characterSet, i)
        local priority = AnimatedLivestockTrailer.getDynamicClipPriority(clipName, clipKey)

        if priority ~= nil then
            table.insert(dynamicCandidates, {
                name = clipName,
                priority = priority
            })
        end
    end

    table.sort(dynamicCandidates, function(a, b)
        if a.priority == b.priority then
            return a.name < b.name
        end

        return a.priority < b.priority
    end)

    for _, candidate in ipairs(dynamicCandidates) do
        AnimatedLivestockTrailer.addClipCandidate(candidates, candidate.name)
    end
end

function AnimatedLivestockTrailer.getDynamicClipPriority(clipName, clipKey)
    if string.isNilOrWhitespace(clipName) or string.find(clipName, "_to_", 1, true) ~= nil then
        return nil
    end

    local lowerClipName = string.lower(clipName)
    if string.find(lowerClipName, "graze", 1, true) ~= nil then
        return nil
    end

    if clipKey == "idle" then
        if string.find(lowerClipName, "turn", 1, true) ~= nil then
            return nil
        end

        if clipName == "idle1Source" then
            return 10
        elseif clipName == "idleSource" then
            return 20
        elseif clipName == "idle01Source" then
            return 30
        elseif clipName == "idleBabySource" then
            return 40
        elseif string.match(clipName, "^idle%d*Source$") ~= nil then
            return 50
        elseif string.match(clipName, "^idle.*BabySource$") ~= nil then
            return 60
        elseif string.match(clipName, "^idle.*Source$") ~= nil then
            return 70
        elseif string.find(lowerClipName, "idle", 1, true) ~= nil then
            return 80
        end
    elseif clipKey == "walk" then
        if string.match(clipName, "^walkFwdL.*Source$") ~= nil then
            return 10
        elseif string.match(clipName, "^walkFwd.*Source$") ~= nil then
            return 20
        elseif string.match(clipName, "^trotFwdL.*Source$") ~= nil then
            return 30
        elseif string.match(clipName, "^trotFwd.*Source$") ~= nil then
            return 40
        elseif string.match(clipName, "^runFwdL.*Source$") ~= nil then
            return 50
        elseif string.match(clipName, "^runFwd.*Source$") ~= nil then
            return 60
        elseif string.find(lowerClipName, "walk", 1, true) ~= nil then
            return 70
        elseif string.find(lowerClipName, "trot", 1, true) ~= nil then
            return 80
        elseif string.find(lowerClipName, "run", 1, true) ~= nil then
            return 90
        end
    elseif clipKey == "run" then
        if string.match(clipName, "^runFwdL.*Source$") ~= nil then
            return 10
        elseif string.match(clipName, "^runFwd.*Source$") ~= nil then
            return 20
        elseif string.match(clipName, "^trotFwdL.*Source$") ~= nil then
            return 30
        elseif string.match(clipName, "^trotFwd.*Source$") ~= nil then
            return 40
        elseif string.match(clipName, "^walkFwdL.*Source$") ~= nil then
            return 50
        elseif string.match(clipName, "^walkFwd.*Source$") ~= nil then
            return 60
        elseif string.find(lowerClipName, "run", 1, true) ~= nil then
            return 70
        elseif string.find(lowerClipName, "trot", 1, true) ~= nil then
            return 80
        elseif string.find(lowerClipName, "walk", 1, true) ~= nil then
            return 90
        end
    end

    return nil
end

function AnimatedLivestockTrailer.setClipSet(state, clipSets, clipKey)
    local selectedClipSet
    local selectedClipIndexes
    local selectedClipNames

    for _, candidateClipSet in ipairs(clipSets) do
        local clipIndexes = {}
        local clipNames = {}
        local allClipsFound = true

        for _, candidateClipName in ipairs(candidateClipSet.clips or {}) do
            local clipIndex = getAnimClipIndex(state.characterSet, candidateClipName)

            if clipIndex == nil or clipIndex < 0 then
                allClipsFound = false
                break
            end

            table.insert(clipIndexes, clipIndex)
            table.insert(clipNames, candidateClipName)
        end

        if allClipsFound and #clipIndexes > 0 then
            selectedClipSet = candidateClipSet
            selectedClipIndexes = clipIndexes
            selectedClipNames = clipNames
            break
        end
    end

    if selectedClipSet == nil then
        local warningKey = clipKey or "unknown"
        local clipNames = {}

        for _, clipSet in ipairs(clipSets) do
            for _, clipName in ipairs(clipSet.clips or {}) do
                table.insert(clipNames, clipName)
            end
        end

        if not state.warnedMissingClip[warningKey] then
            Logging.warning("[%s] Animation clips '%s' not found in animated animal '%s'", AnimatedLivestockTrailer.MOD_NAME, table.concat(clipNames, ", "), state.config.filename)
            state.warnedMissingClip[warningKey] = true
        end

        return false
    end

    AnimatedLivestockTrailer.clearAnimationTracks(state)

    local clipDuration = 0
    local blendWeight = 1 / #selectedClipIndexes
    state.activeTracks = {}

    for i, clipIndex in ipairs(selectedClipIndexes) do
        local track = i - 1

        clearAnimTrackClip(state.characterSet, track)
        assignAnimTrackClip(state.characterSet, track, clipIndex)
        setAnimTrackLoopState(state.characterSet, track, true)
        setAnimTrackBlendWeight(state.characterSet, track, blendWeight)
        setAnimTrackSpeedScale(state.characterSet, track, 1)
        enableAnimTrack(state.characterSet, track)

        local duration = getAnimClipDuration(state.characterSet, clipIndex) or 0

        table.insert(state.activeTracks, {
            track = track,
            duration = duration,
            blendWeight = blendWeight
        })
        clipDuration = math.max(clipDuration, duration)
    end

    state.currentClip = table.concat(selectedClipNames, "+")
    state.currentClipKey = clipKey
    state.clipDuration = clipDuration
    state.clipMovementSpeed = selectedClipSet.speedScale or 1
    state.clipSpeedScale = selectedClipSet.speedScale or 1

    local useRandomStart = (clipKey == "idle" and state.config.randomIdleStart) or (clipKey ~= "idle" and state.config.randomMovementStart)
    if useRandomStart and state.clipDuration > 0 then
        state.clipTime = math.random() * state.clipDuration
    else
        state.clipTime = 0
    end

    return true
end

function AnimatedLivestockTrailer.clearAnimationTracks(state)
    for track = 0, AnimatedLivestockTrailer.MAX_ANIMATION_TRACKS - 1 do
        disableAnimTrack(state.characterSet, track)
        clearAnimTrackClip(state.characterSet, track)
    end
end

function AnimatedLivestockTrailer.setClip(state, clipNames, clipKey)
    local clipName
    local clipIndex

    for _, candidateClipName in ipairs(clipNames) do
        clipIndex = getAnimClipIndex(state.characterSet, candidateClipName)

        if clipIndex ~= nil and clipIndex >= 0 then
            clipName = candidateClipName
            break
        end
    end

    if clipName == nil then
        local warningKey = clipKey or table.concat(clipNames, ",")

        if not state.warnedMissingClip[warningKey] then
            Logging.warning("[%s] Animation clips '%s' not found in animated animal '%s'", AnimatedLivestockTrailer.MOD_NAME, table.concat(clipNames, ", "), state.config.filename)
            state.warnedMissingClip[warningKey] = true
        end

        return false
    end

    clearAnimTrackClip(state.characterSet, state.track)
    assignAnimTrackClip(state.characterSet, state.track, clipIndex)
    setAnimTrackLoopState(state.characterSet, state.track, true)
    enableAnimTrack(state.characterSet, state.track)

    state.currentClip = clipName
    state.currentClipKey = clipKey
    state.clipDuration = getAnimClipDuration(state.characterSet, clipIndex)

    if state.config.randomIdleStart and clipKey == "idle" and state.clipDuration > 0 then
        state.clipTime = math.random() * state.clipDuration
    else
        state.clipTime = 0
    end

    return true
end
