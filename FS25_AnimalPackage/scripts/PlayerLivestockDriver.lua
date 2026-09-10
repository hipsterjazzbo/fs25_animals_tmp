--
-- PlayerLivestockDriver
--
-- Turns the player into a virtual livestock carrier while standing at an
-- AnimalLoadingTrigger. The normal Giants animal screen is reused, but animal
-- clusters are moved through this script instead of a real trailer vehicle.
--

PlayerLivestockDriver = PlayerLivestockDriver or {}
PlayerLivestockDriver.MOD_NAME = "FS25_lsfmAnimalTransportPack"
PlayerLivestockDriver.MOD_DIRECTORY = g_currentModDirectory or ""
PlayerLivestockDriver.ACTION_TOGGLE_WAIT = "LSFM_PLAYER_LIVESTOCK_TOGGLE_WAIT"
PlayerLivestockDriver.ACTION_TOGGLE_DRIVE_MODE = "LSFM_PLAYER_LIVESTOCK_TOGGLE_DRIVE_MODE"
PlayerLivestockDriver.ACTION_OPEN_LOAD_MENU = "LSFM_PLAYER_LIVESTOCK_OPEN_LOAD_MENU"
PlayerLivestockDriver.ACTION_SOUND_CALL_FILENAME = "sounds/playerLivestock_call.ogg"
PlayerLivestockDriver.INPUT_BLOCK_AFTER_VEHICLE_MS = 800
PlayerLivestockDriver.HERD_MODE_FOLLOW = "follow"
PlayerLivestockDriver.HERD_MODE_DRIVE = "drive"
PlayerLivestockDriver.MAX_ANIMALS = 12
PlayerLivestockDriver.MAX_ANIMALS_BY_TYPE_NAME = {
    COW = 6,
    WATER_BUFFALO = 4,
    BUFFALO = 4,
    HORSE = 2,
    PIG = 16,
    SHEEP = 24,
    GOAT = 24,
    CHICKEN = 40,
    DUCK = 40,
    GOOSE = 40,
    TURKEY = 30
}
PlayerLivestockDriver.MAX_VISIBLE_ANIMALS = 25
PlayerLivestockDriver.SLOT_SPACING_X = 1.15
PlayerLivestockDriver.SLOT_SPACING_Z = 1.45
PlayerLivestockDriver.SLOT_START_Z = 1.9
PlayerLivestockDriver.SLOT_COLUMNS = 3
PlayerLivestockDriver.FOLLOW_LOCAL_Z_SIGN = -1
PlayerLivestockDriver.FOLLOW_BASE_SPEED = 1.45
PlayerLivestockDriver.FOLLOW_CATCHUP_SPEED = 2.35
PlayerLivestockDriver.FOLLOW_SNAP_DISTANCE = 55
PlayerLivestockDriver.ANIMAL_ROTATION_OFFSET_Y = 0
PlayerLivestockDriver.FOLLOW_ANIMATION_MIN_SPEED = 1.1
PlayerLivestockDriver.FOLLOW_ANIMATION_MAX_SPEED = 4.6
PlayerLivestockDriver.FOLLOW_RANDOM_X = 0.55
PlayerLivestockDriver.FOLLOW_RANDOM_Z = 0.60
PlayerLivestockDriver.FOLLOW_SWAY_X = 0.12
PlayerLivestockDriver.FOLLOW_SWAY_Z = 0.24
PlayerLivestockDriver.FOLLOW_SWAY_SPEED = 0.00115
PlayerLivestockDriver.FOLLOW_PLAYER_ANIMATION_SCALE = 1.0
PlayerLivestockDriver.FOLLOW_DEFAULT_RADIUS = 0.45
PlayerLivestockDriver.FOLLOW_RADIUS_X_SCALE = 2.25
PlayerLivestockDriver.FOLLOW_RADIUS_Z_SCALE = 4.4
PlayerLivestockDriver.FOLLOW_RUN_PLAYER_SPEED = 7.6
PlayerLivestockDriver.FOLLOW_RUN_EXIT_PLAYER_SPEED = 5.4
PlayerLivestockDriver.FOLLOW_RUN_ANIMATION_MIN_SPEED = 9.4
PlayerLivestockDriver.FOLLOW_RUN_ANIMATION_MAX_SPEED = 13.0
PlayerLivestockDriver.FOLLOW_RUN_CATCHUP_SPEED = 2.45
PlayerLivestockDriver.FOLLOW_SPRINT_EXTRA_SPEED = 0
PlayerLivestockDriver.FOLLOW_HEADING_MOVE_THRESHOLD = 0.015
PlayerLivestockDriver.FOLLOW_HEADING_LERP_SPEED = 0.045
PlayerLivestockDriver.FOLLOW_ANIMAL_MOVE_YAW_THRESHOLD = 0.006
PlayerLivestockDriver.FOLLOW_ANIMAL_YAW_LERP_SPEED = 0.055
PlayerLivestockDriver.FOLLOW_ANIMAL_IDLE_LOOK_YAW_LERP_SPEED = 0.025
PlayerLivestockDriver.FOLLOW_TARGET_LERP_SPEED = 0.040
PlayerLivestockDriver.FOLLOW_RUN_TARGET_LERP_SPEED = 0.055
PlayerLivestockDriver.FOLLOW_SPEED_SMOOTHING = 0.35
PlayerLivestockDriver.FOLLOW_RUN_HOLD_TIME = 2600
PlayerLivestockDriver.FOLLOW_PLAYER_SPEED_CAP = 14.5
PlayerLivestockDriver.FOLLOW_TELEPORT_DISTANCE = 2.5
PlayerLivestockDriver.FOLLOW_HERD_BASE_DISTANCE = 1.25
PlayerLivestockDriver.FOLLOW_HERD_RING_DISTANCE = 0.95
PlayerLivestockDriver.FOLLOW_HERD_SIDE_SPREAD = 0.55
PlayerLivestockDriver.FOLLOW_HERD_WANDER_X = 0.38
PlayerLivestockDriver.FOLLOW_HERD_WANDER_Z = 0.72
PlayerLivestockDriver.FOLLOW_HERD_WANDER_LERP = 0.018
PlayerLivestockDriver.FOLLOW_HERD_WANDER_MIN_TIME = 1800
PlayerLivestockDriver.FOLLOW_HERD_WANDER_MAX_TIME = 4300
PlayerLivestockDriver.HERD_ACTOR_STOP_DISTANCE = 0.95
PlayerLivestockDriver.HERD_ACTOR_WALK_DISTANCE = 1.45
PlayerLivestockDriver.HERD_ACTOR_RUN_DISTANCE = 3.25
PlayerLivestockDriver.HERD_ACTOR_WALK_SPEED = 3.6
PlayerLivestockDriver.HERD_ACTOR_RUN_SPEED = 15.0
PlayerLivestockDriver.HERD_ACTOR_CATCHUP_RUN_SPEED = 22.0
PlayerLivestockDriver.HERD_ACTOR_LOST_DISTANCE = 55
PlayerLivestockDriver.HERD_ACTOR_TARGET_LERP = 0.18
PlayerLivestockDriver.HERD_ACTOR_YAW_RATE = 1.35
PlayerLivestockDriver.HERD_ACTOR_RUN_YAW_RATE = 1.65
PlayerLivestockDriver.HERD_ACTOR_IDLE_YAW_RATE = 0.45
PlayerLivestockDriver.HERD_ACTOR_SEPARATION_SCALE = 1.50
PlayerLivestockDriver.HERD_ACTOR_TRAIL_SPACING = 1.55
PlayerLivestockDriver.HERD_ACTOR_SIDE_SPREAD = 0.38
PlayerLivestockDriver.HERD_ACTOR_STAND_PLAYER_SPEED = 0.55
PlayerLivestockDriver.HERD_ACTOR_STAND_RUN_DISTANCE_MULT = 1.85
PlayerLivestockDriver.FOLIAGE_BENDING_ENABLED = true
PlayerLivestockDriver.FOLIAGE_BENDING_MIN_HALF_WIDTH = 0.22
PlayerLivestockDriver.FOLIAGE_BENDING_MAX_HALF_WIDTH = 0.85
PlayerLivestockDriver.FOLIAGE_BENDING_MIN_HALF_LENGTH = 0.30
PlayerLivestockDriver.FOLIAGE_BENDING_MAX_HALF_LENGTH = 1.10
PlayerLivestockDriver.FOLIAGE_BENDING_MIN_Y_OFFSET = 0.12
PlayerLivestockDriver.FOLIAGE_BENDING_MAX_Y_OFFSET = 0.42
PlayerLivestockDriver.HERD_ANIM_IDLE_DELAY = 320
PlayerLivestockDriver.HERD_ANIM_MOVE_DELAY = 180
PlayerLivestockDriver.HERD_ANIM_RUN_DELAY = 260
PlayerLivestockDriver.HERDING_DOG_ENABLED = true
PlayerLivestockDriver.HERDING_DOG_FILENAME = "dataS/character/animals/domesticated/dog/borderCollie/borderCollie.i3d"
PlayerLivestockDriver.HERDING_DOG_ANIMATION_FILENAME = "dataS/character/animals/domesticated/dog/borderCollie/animations/adult/borderCollieAnimations.i3d"
PlayerLivestockDriver.HERDING_DOG_IDLE_CLIP = "sniffSource"
PlayerLivestockDriver.HERDING_DOG_WALK_CLIP = "walkLeftSource"
PlayerLivestockDriver.HERDING_DOG_RUN_CLIP = "runLeftSource"
PlayerLivestockDriver.HERDING_DOG_SIDE_DISTANCE = 1.85
PlayerLivestockDriver.HERDING_DOG_BACK_DISTANCE = 1.65
PlayerLivestockDriver.HERDING_DOG_SIDE_SWITCH_MIN_TIME = 3600
PlayerLivestockDriver.HERDING_DOG_SIDE_SWITCH_MAX_TIME = 7800
PlayerLivestockDriver.HERDING_DOG_PRESSURE_RADIUS = 3.25
PlayerLivestockDriver.HERDING_DOG_PRESSURE_STRENGTH = 0.42
PlayerLivestockDriver.HERDING_DOG_GATHER_SCALE = 0.18
PlayerLivestockDriver.HERDING_DOG_STOP_DISTANCE = 0.35
PlayerLivestockDriver.HERDING_DOG_WALK_DISTANCE = 1.10
PlayerLivestockDriver.HERDING_DOG_RUN_DISTANCE = 3.00
PlayerLivestockDriver.HERDING_DOG_WALK_SPEED = 7.0
PlayerLivestockDriver.HERDING_DOG_RUN_SPEED = 20.0
PlayerLivestockDriver.HERDING_DOG_PANT_VOLUME = 0.38
PlayerLivestockDriver.HERDING_DOG_PANT_RANGE = 24
PlayerLivestockDriver.HERDING_DOG_PANT_INNER_RANGE = 1
PlayerLivestockDriver.HERDING_DOG_PANT_WALK_MIN_INTERVAL = 1500
PlayerLivestockDriver.HERDING_DOG_PANT_WALK_MAX_INTERVAL = 3000
PlayerLivestockDriver.HERDING_DOG_PANT_RUN_MIN_INTERVAL = 750
PlayerLivestockDriver.HERDING_DOG_PANT_RUN_MAX_INTERVAL = 1700
PlayerLivestockDriver.HERDING_DOG_PANT_SOUNDS = {
    "sounds/anmlDogSitBreath_01.ogg",
    "sounds/anmlDogSitBreath_02.ogg",
    "sounds/anmlDogSitBreath_03.ogg",
    "sounds/anmlDogSitBreath_04.ogg",
    "sounds/anmlDogSitBreath_05.ogg",
    "sounds/anmlDogSitBreath_06.ogg",
    "sounds/anmlDogSitBreath_07.ogg",
    "sounds/anmlDogSitBreath_08.ogg"
}
local PlayerLivestockDriverCarrier = {}
local PlayerLivestockDriverCarrier_mt = Class(PlayerLivestockDriverCarrier)

local PlayerLivestockDriverClusterSystem = {}
local PlayerLivestockDriverClusterSystem_mt = Class(PlayerLivestockDriverClusterSystem)

function PlayerLivestockDriverClusterSystem.new(owner)
    local self = setmetatable({}, PlayerLivestockDriverClusterSystem_mt)
    self.owner = owner
    self.clusters = {}
    self.idToIndex = {}
    return self
end

function PlayerLivestockDriverClusterSystem:rebuildIdMapping()
    self.idToIndex = {}
    for index, cluster in ipairs(self.clusters) do
        self.idToIndex[cluster.id] = index
        cluster.clusterSystem = self
    end
end

function PlayerLivestockDriverClusterSystem:getClusters()
    return self.clusters
end

function PlayerLivestockDriverClusterSystem:getClusterById(clusterId)
    local index = self.idToIndex[clusterId]
    return index ~= nil and self.clusters[index] or nil
end

function PlayerLivestockDriverClusterSystem:setDirty()
    if self.owner ~= nil then
        self.owner:onClustersChanged()
    end
end

function PlayerLivestockDriverClusterSystem:addCluster(cluster)
    if cluster == nil or cluster:getNumAnimals() <= 0 then
        return
    end

    if cluster:getSupportsMerging() then
        local hash = cluster:getHash()
        for _, existingCluster in ipairs(self.clusters) do
            if existingCluster:getSupportsMerging() and existingCluster:getHash() == hash then
                existingCluster:merge(cluster)
                existingCluster.clusterSystem = self
                self:rebuildIdMapping()
                self:setDirty()
                return
            end
        end
    end

    table.insert(self.clusters, cluster)
    cluster.clusterSystem = self
    self:rebuildIdMapping()
    self:setDirty()
end

function PlayerLivestockDriverClusterSystem:removeEmptyClusters()
    for index = #self.clusters, 1, -1 do
        if self.clusters[index]:getNumAnimals() <= 0 then
            self.clusters[index].clusterSystem = nil
            table.remove(self.clusters, index)
        end
    end

    self:rebuildIdMapping()
    self:setDirty()
end

function PlayerLivestockDriverClusterSystem:clear()
    for _, cluster in ipairs(self.clusters) do
        cluster.clusterSystem = nil
    end

    self.clusters = {}
    self.idToIndex = {}
    self:setDirty()
end

function PlayerLivestockDriverCarrier.new(farmId)
    local self = setmetatable({}, PlayerLivestockDriverCarrier_mt)
    self.isPlayerLivestockCarrier = true
    self.farmId = farmId
    self.clusterSystem = PlayerLivestockDriverClusterSystem.new(self)
    self.loadingTrigger = nil
    self.storeItem = {
        imageFilename = PlayerLivestockDriver.MOD_DIRECTORY .. "store/store_playerLivestockDriver.dds",
        name = "playerLivestockDriverStoreItem"
    }
    self.visualDirty = true
    self.visualGeneration = 0
    self.visualSlots = {}
    self.visibleStates = {}
    self.herdingDogSlot = nil
    self.herdingDogSoundSamples = {}
    self.herdingDogSoundSamplesLoaded = false
    self.herdingDogSoundTimer = 0
    self.herdingDogSide = math.random() < 0.5 and -1 or 1
    self.herdingDogSideTimer = 0
    self.lastPlayerX = nil
    self.lastPlayerY = nil
    self.lastPlayerZ = nil
    self.lastMoveX = 0
    self.lastMoveZ = 1
    self.followHeadingYaw = nil
    self.isHerdWaiting = false
    self.herdMode = PlayerLivestockDriver.HERD_MODE_FOLLOW
    self.runAnimationActive = false
    self.runHoldTimer = 0
    self.rawSpeedKph = 0
    self.smoothedSpeedKph = 0
    self.lastSpeedKph = 0
    self.isClient = true
    self.soundNode = createTransformGroup("playerLivestockSoundNode")
    link(getRootNode(), self.soundNode)
    self.formationNode = createTransformGroup("playerLivestockFormationNode")
    link(getRootNode(), self.formationNode)
    self.actionSoundNode = createTransformGroup("playerLivestockActionSoundNode")
    link(getRootNode(), self.actionSoundNode)
    self.components = {{node = self.soundNode}}
    self.actionSoundSamples = {}
    self.spec_animatedLivestockTrailer = {
        loadedSlots = {},
        pendingAnimatedSlots = {},
        loadedCages = {},
        animalSoundGroups = {},
        alignToTerrain = true,
        alignToGroundCollisions = false,
        groundOffset = 0,
        loadGeneration = 0,
        groundRaycastOffset = 4,
        groundRaycastDistance = 12,
        useSpeedAnimations = true,
        walkSpeed = 0.5,
        runSpeed = PlayerLivestockDriver.FOLLOW_RUN_PLAYER_SPEED,
        randomIdleStart = true,
        randomMovementStart = true,
        reverseMovementAnimations = true,
        useAnimalSounds = true,
        animalSoundNode = self.soundNode,
        animalSoundVolumeScale = 0.24,
        animalSoundMinInterval = 4500,
        animalSoundMaxInterval = 12000,
        animalSoundMinimumInterval = 2200,
        animalSoundSignature = nil,
        animalSoundTimer = 0,
        currentAnimalSoundSample = nil,
        animalSoundAnimalCount = 0,
        configsByTypeIndex = {},
        defaultConfig = {
            filename = nil,
            animationFilename = nil,
            clipRootPath = nil,
            animationSourcePath = nil,
            idleClip = "idle1Source",
            walkClip = "walkFwdLSource",
            runClip = "runFwdLSource",
            randomIdleStart = true,
            randomMovementStart = true,
            reverseMovementAnimations = true,
            playbackScale = 1,
            referenceWalkSpeed = 4,
            referenceRunSpeed = 12
        }
    }
    return self
end

function PlayerLivestockDriverCarrier:delete()
    self:clearVisuals()
    self:deleteActionSounds()

    if self.soundNode ~= nil and entityExists(self.soundNode) then
        delete(self.soundNode)
        self.soundNode = nil
    end

    if self.formationNode ~= nil and entityExists(self.formationNode) then
        delete(self.formationNode)
        self.formationNode = nil
    end

    if self.actionSoundNode ~= nil and entityExists(self.actionSoundNode) then
        delete(self.actionSoundNode)
        self.actionSoundNode = nil
    end
end

function PlayerLivestockDriverCarrier:raiseActive()
end

function PlayerLivestockDriverCarrier:createActionSound(key, filename, range, innerRange, volume)
    if filename == nil then
        return
    end

    local fullFilename = PlayerLivestockDriver.MOD_DIRECTORY .. filename
    if fileExists ~= nil and not fileExists(fullFilename) then
        Logging.warning("[%s] Missing player livestock action sound: %s", PlayerLivestockDriver.MOD_NAME, fullFilename)
        return
    end

    local linkNode = self.actionSoundNode or getRootNode()
    local soundNode = createAudioSource("playerLivestockActionSound_" .. tostring(key), fullFilename, range or 35, innerRange or 1, volume or 1, 1)
    if soundNode == nil or soundNode == 0 then
        Logging.warning("[%s] Could not create player livestock action sound: %s", PlayerLivestockDriver.MOD_NAME, fullFilename)
        return
    end

    link(linkNode, soundNode)
    setTranslation(soundNode, 0, 0, 0)

    local sample = getAudioSourceSample(soundNode)
    if sample == nil or sample == 0 then
        delete(soundNode)
        Logging.warning("[%s] Could not create player livestock action sample: %s", PlayerLivestockDriver.MOD_NAME, fullFilename)
        return
    end

    self.actionSoundSamples[key] = {
        soundNode = soundNode,
        sample = sample,
        volume = volume or 1
    }
end

function PlayerLivestockDriverCarrier:loadActionSounds()
    if self.actionSoundSamplesLoaded then
        return
    end

    self.actionSoundSamplesLoaded = true
    self.actionSoundSamples = self.actionSoundSamples or {}
    self:createActionSound("call", PlayerLivestockDriver.ACTION_SOUND_CALL_FILENAME, 42, 1, 0.75)
end

function PlayerLivestockDriverCarrier:stopActionSounds()
    if self.actionSoundSamples ~= nil then
        for _, sample in pairs(self.actionSoundSamples) do
            if sample.sample ~= nil and stopSample ~= nil then
                stopSample(sample.sample, 0, 0)
            end
        end
    end
end

function PlayerLivestockDriverCarrier:deleteActionSounds()
    self:stopActionSounds()

    if self.actionSoundSamples ~= nil then
        for _, sample in pairs(self.actionSoundSamples) do
            if sample.soundNode ~= nil and entityExists(sample.soundNode) then
                delete(sample.soundNode)
            end
        end
    end

    self.actionSoundSamples = {}
    self.actionSoundSamplesLoaded = false
end

function PlayerLivestockDriverCarrier:updateActionSoundPosition()
    if self.actionSoundNode == nil or not entityExists(self.actionSoundNode) then
        return
    end

    if g_localPlayer ~= nil and g_localPlayer.rootNode ~= nil then
        local x, y, z = getWorldTranslation(g_localPlayer.rootNode)
        setWorldTranslation(self.actionSoundNode, x, y + 1.55, z)
    end
end

function PlayerLivestockDriverCarrier:playActionSound(key)
    self:updateActionSoundPosition()
    self:loadActionSounds()

    local sample = self.actionSoundSamples ~= nil and self.actionSoundSamples[key] or nil
    if sample ~= nil and sample.sample ~= nil then
        if stopSample ~= nil then
            stopSample(sample.sample, 0, 0)
        end
        playSample(sample.sample, 1, sample.volume or 1, 0, 0, 0)
    end
end

function PlayerLivestockDriverCarrier:animatedLivestockTrailerGroundRaycastCallback(...)
    if AnimatedLivestockTrailer ~= nil and AnimatedLivestockTrailer.animatedLivestockTrailerGroundRaycastCallback ~= nil then
        return AnimatedLivestockTrailer.animatedLivestockTrailerGroundRaycastCallback(self, ...)
    end

    return false
end

function PlayerLivestockDriverCarrier:setLoadingTrigger(trigger)
    self.loadingTrigger = trigger
end

function PlayerLivestockDriverCarrier:getName()
    return PlayerLivestockDriver:getText("playerLivestockDriver_playerTargetName", "Viehtrieb")
end

function PlayerLivestockDriverCarrier:getOwnerFarmId()
    return self.farmId
end

function PlayerLivestockDriverCarrier:getClusterSystem()
    return self.clusterSystem
end

function PlayerLivestockDriverCarrier:getClusters()
    return self.clusterSystem:getClusters()
end

function PlayerLivestockDriverCarrier:getClusterById(clusterId)
    return self.clusterSystem:getClusterById(clusterId)
end

function PlayerLivestockDriverCarrier:getNumOfAnimals()
    local numAnimals = 0
    for _, cluster in ipairs(self:getClusters()) do
        numAnimals = numAnimals + cluster:getNumAnimals()
    end
    return numAnimals
end

function PlayerLivestockDriverCarrier:getIsHerdWaiting()
    return self.isHerdWaiting == true
end

function PlayerLivestockDriverCarrier:getIsDriveMode()
    return self.herdMode == PlayerLivestockDriver.HERD_MODE_DRIVE
end

function PlayerLivestockDriverCarrier:setHerdMode(mode)
    local newMode = mode == PlayerLivestockDriver.HERD_MODE_DRIVE and PlayerLivestockDriver.HERD_MODE_DRIVE or PlayerLivestockDriver.HERD_MODE_FOLLOW
    if self.herdMode == newMode then
        return
    end

    self.herdMode = newMode
    for _, slot in ipairs(self.visualSlots or {}) do
        slot.targetX = nil
        slot.targetY = nil
        slot.targetZ = nil
    end
end

function PlayerLivestockDriverCarrier:toggleHerdMode()
    if self:getIsDriveMode() then
        self:setHerdMode(PlayerLivestockDriver.HERD_MODE_FOLLOW)
    else
        self:setHerdMode(PlayerLivestockDriver.HERD_MODE_DRIVE)
    end
end

function PlayerLivestockDriverCarrier:setHerdWaiting(isWaiting)
    self.isHerdWaiting = isWaiting == true
    self.rawSpeedKph = 0
    self.smoothedSpeedKph = 0
    self.lastSpeedKph = 0
    self.runAnimationActive = false
    self.runHoldTimer = 0

    if not self.isHerdWaiting then
        self.lastPlayerX = nil
        self.lastPlayerY = nil
        self.lastPlayerZ = nil
    end

    for _, slot in ipairs(self.visualSlots or {}) do
        slot.speedKph = 0
        slot.animationSpeedKph = 0
        slot.movementState = "idle"
        slot.lastFollowDistance = 0

        if not self.isHerdWaiting then
            slot.targetX = nil
            slot.targetY = nil
            slot.targetZ = nil
        end
    end
end

function PlayerLivestockDriverCarrier:getCurrentAnimalType()
    local firstCluster = self:getClusters()[1]
    if firstCluster ~= nil then
        local subType = g_currentMission.animalSystem:getSubTypeByIndex(firstCluster:getSubTypeIndex())
        return subType ~= nil and g_currentMission.animalSystem:getTypeByIndex(subType.typeIndex) or nil
    end

    if self.loadingTrigger ~= nil and self.loadingTrigger.husbandry ~= nil then
        return g_currentMission.animalSystem:getTypeByIndex(self.loadingTrigger.husbandry:getAnimalTypeIndex())
    end

    return nil
end

function PlayerLivestockDriver:getAnimalTypeCapacity(animalType)
    if animalType ~= nil and animalType.name ~= nil then
        local capacity = self.MAX_ANIMALS_BY_TYPE_NAME[tostring(animalType.name)]
        if capacity ~= nil then
            return capacity
        end
    end

    return self.MAX_ANIMALS
end

function PlayerLivestockDriverCarrier:getMaxNumOfAnimals(animalType)
    local currentAnimalType = self:getCurrentAnimalType()
    if currentAnimalType ~= nil and self:getNumOfAnimals() > 0 then
        if animalType ~= nil and currentAnimalType.typeIndex ~= animalType.typeIndex then
            return 0
        end

        animalType = currentAnimalType
    end

    return PlayerLivestockDriver:getAnimalTypeCapacity(animalType)
end

function PlayerLivestockDriverCarrier:getNumOfFreeAnimalSlots(subTypeIndex)
    if subTypeIndex ~= nil and not self:getSupportsAnimalSubType(subTypeIndex) then
        return 0
    end

    local animalType = self:getCurrentAnimalType()
    if subTypeIndex ~= nil then
        local subType = g_currentMission.animalSystem:getSubTypeByIndex(subTypeIndex)
        animalType = subType ~= nil and g_currentMission.animalSystem:getTypeByIndex(subType.typeIndex) or animalType
    end

    return math.max(self:getMaxNumOfAnimals(animalType) - self:getNumOfAnimals(), 0)
end

function PlayerLivestockDriverCarrier:getSupportsAnimalSubType(subTypeIndex)
    local subType = g_currentMission.animalSystem:getSubTypeByIndex(subTypeIndex)
    if subType == nil then
        return false
    end

    local animalType = g_currentMission.animalSystem:getTypeByIndex(subType.typeIndex)
    if animalType == nil then
        return false
    end

    local currentAnimalType = self:getCurrentAnimalType()
    return currentAnimalType == nil or self:getNumOfAnimals() == 0 or currentAnimalType.typeIndex == animalType.typeIndex
end

function PlayerLivestockDriverCarrier:addCluster(cluster)
    self.clusterSystem:addCluster(cluster)
end

function PlayerLivestockDriverCarrier:removeAnimalsFromCluster(clusterId, numAnimals)
    local cluster = self:getClusterById(clusterId)
    if cluster == nil then
        return false
    end

    cluster:changeNumAnimals(-numAnimals)
    self.clusterSystem:removeEmptyClusters()
    return true
end

function PlayerLivestockDriverCarrier:onClustersChanged()
    if self:getNumOfAnimals() <= 0 then
        self:setHerdWaiting(false)
        self:deleteActionSounds()

        if PlayerLivestockDriver ~= nil then
            PlayerLivestockDriver.herdInputBlockedUntil = PlayerLivestockDriver:getCurrentMissionTime() + PlayerLivestockDriver.INPUT_BLOCK_AFTER_VEHICLE_MS
            PlayerLivestockDriver:updateActionEventState()
        end
    end

    self.visualDirty = true
    g_messageCenter:publish(AnimalClusterUpdateEvent, self, self:getClusters())
end

function PlayerLivestockDriverCarrier:setClustersFromStream(clusters)
    self.clusterSystem:clear()
    for _, cluster in ipairs(clusters) do
        self.clusterSystem:addCluster(cluster)
    end
    self:onClustersChanged()
end

function PlayerLivestockDriverCarrier:ensureVisualSlot(index)
    local slot = self.visualSlots[index]
    if slot ~= nil then
        return slot
    end

    local node = createTransformGroup("playerLivestockHerdAnimal")
    link(getRootNode(), node)

    local row = index - 1
    local laneRoll = math.random()
    local lane = 0
    if row % 3 == 1 then
        lane = laneRoll < 0.55 and -1 or 0
    elseif row % 3 == 2 then
        lane = laneRoll < 0.55 and 1 or 0
    elseif laneRoll < 0.16 then
        lane = -1
    elseif laneRoll > 0.84 then
        lane = 1
    end

    slot = {
        linkNode = node,
        meshLoadingInProgress = false,
        visualIndex = index,
        animalRadius = PlayerLivestockDriver.FOLLOW_DEFAULT_RADIUS,
        lane = lane,
        trailOrder = math.floor(row / 2) + math.random() * 0.50,
        baseSideOffset = (math.random() * 2 - 1) * 0.16,
        baseTrailOffset = (math.random() * 2 - 1) * 0.45,
        wanderOffsetX = 0,
        wanderOffsetZ = 0,
        wanderTargetX = (math.random() * 2 - 1) * 0.18,
        wanderTargetZ = (math.random() * 2 - 1) * 0.50,
        wanderTimer = PlayerLivestockDriver.FOLLOW_HERD_WANDER_MIN_TIME + math.random() * (PlayerLivestockDriver.FOLLOW_HERD_WANDER_MAX_TIME - PlayerLivestockDriver.FOLLOW_HERD_WANDER_MIN_TIME),
        followBlendScale = 0.75 + math.random() * 0.45,
        animationSpeedScale = 0.94 + math.random() * 0.12,
        yawNoise = (math.random() * 2 - 1) * 0.18,
        animationSpeedKph = 0,
        movementState = "idle"
    }

    self.visualSlots[index] = slot
    return slot
end

function PlayerLivestockDriverCarrier:getFoliageBendingSystem()
    if not PlayerLivestockDriver.FOLIAGE_BENDING_ENABLED then
        return nil
    end

    if g_currentMission ~= nil and g_currentMission.foliageBendingSystem ~= nil then
        return g_currentMission.foliageBendingSystem
    end

    return nil
end

function PlayerLivestockDriverCarrier:destroySlotFoliageBending(slot)
    if slot == nil or slot.foliageBendingId == nil then
        return
    end

    local system = self:getFoliageBendingSystem()
    if system ~= nil then
        system:destroyObject(slot.foliageBendingId)
    end

    slot.foliageBendingId = nil
    slot.foliageBendingKey = nil
end

function PlayerLivestockDriverCarrier:ensureSlotFoliageBending(slot)
    if slot == nil or slot.linkNode == nil or not entityExists(slot.linkNode) then
        return
    end

    local system = self:getFoliageBendingSystem()
    if system == nil then
        return
    end

    local radius = slot.animalRadius or PlayerLivestockDriver.FOLLOW_DEFAULT_RADIUS
    local halfWidth = math.min(math.max(radius * 0.85, PlayerLivestockDriver.FOLIAGE_BENDING_MIN_HALF_WIDTH), PlayerLivestockDriver.FOLIAGE_BENDING_MAX_HALF_WIDTH)
    local halfLength = math.min(math.max(radius * 1.25, PlayerLivestockDriver.FOLIAGE_BENDING_MIN_HALF_LENGTH), PlayerLivestockDriver.FOLIAGE_BENDING_MAX_HALF_LENGTH)
    local yOffset = math.min(math.max(radius * 0.45 + 0.05, PlayerLivestockDriver.FOLIAGE_BENDING_MIN_Y_OFFSET), PlayerLivestockDriver.FOLIAGE_BENDING_MAX_Y_OFFSET)
    local key = string.format("%.3f:%.3f:%.3f", halfWidth, halfLength, yOffset)

    if slot.foliageBendingId ~= nil and slot.foliageBendingKey == key then
        return
    end

    self:destroySlotFoliageBending(slot)
    slot.foliageBendingId = system:createRectangle(-halfWidth, halfWidth, -halfLength, halfLength, yOffset, slot.linkNode)
    slot.foliageBendingKey = key
end
function PlayerLivestockDriverCarrier:clearVisuals()
    if AnimatedLivestockTrailer ~= nil and AnimatedLivestockTrailer.clearAnimatedAnimals ~= nil then
        AnimatedLivestockTrailer.clearAnimatedAnimals(self)
    end

    if self.visualSlots ~= nil then
        for _, slot in ipairs(self.visualSlots) do
            self:destroySlotFoliageBending(slot)

            if slot.linkNode ~= nil and entityExists(slot.linkNode) then
                delete(slot.linkNode)
            end
        end
    end

    self:deleteHerdingDogVisual()

    self.visualSlots = {}
    self.visibleStates = {}
end

function PlayerLivestockDriverCarrier:getAnimalRadius(animalType)
    local radius = animalType ~= nil and animalType.navMeshAgentAttributes ~= nil and animalType.navMeshAgentAttributes.radius or nil
    return math.max(radius or PlayerLivestockDriver.FOLLOW_DEFAULT_RADIUS, PlayerLivestockDriver.FOLLOW_DEFAULT_RADIUS)
end

function PlayerLivestockDriverCarrier:collectVisualRequests()
    local requests = {}

    for _, cluster in ipairs(self:getClusters()) do
        local subType = g_currentMission.animalSystem:getSubTypeByIndex(cluster:getSubTypeIndex())
        local animalType = subType ~= nil and g_currentMission.animalSystem:getTypeByIndex(subType.typeIndex) or nil
        local visual = g_currentMission.animalSystem:getVisualByAge(cluster:getSubTypeIndex(), cluster:getAge())

        if animalType ~= nil and visual ~= nil then
            for _ = 1, cluster:getNumAnimals() do
                table.insert(requests, {
                    cluster = cluster,
                    animalType = animalType,
                    visual = visual,
                    radius = self:getAnimalRadius(animalType)
                })

                if #requests >= PlayerLivestockDriver.MAX_VISIBLE_ANIMALS then
                    return requests
                end
            end
        end
    end

    return requests
end

function PlayerLivestockDriverCarrier:getIsHerdingDogAnimalType(animalType)
    if animalType == nil or animalType.name == nil then
        return false
    end

    local typeName = string.upper(tostring(animalType.name))
    return typeName == "SHEEP" or typeName == "GOAT"
end

function PlayerLivestockDriverCarrier:getShouldUseHerdingDog()
    if not PlayerLivestockDriver.HERDING_DOG_ENABLED or self:getNumOfAnimals() <= 0 then
        return false
    end

    for _, cluster in ipairs(self:getClusters()) do
        local subType = g_currentMission.animalSystem:getSubTypeByIndex(cluster:getSubTypeIndex())
        local animalType = subType ~= nil and g_currentMission.animalSystem:getTypeByIndex(subType.typeIndex) or nil

        if self:getIsHerdingDogAnimalType(animalType) then
            return true
        end
    end

    return false
end

function PlayerLivestockDriverCarrier:getHasActiveHerdingDog()
    return self.herdingDogSlot ~= nil and self.herdingDogSlot.linkNode ~= nil and entityExists(self.herdingDogSlot.linkNode)
end

function PlayerLivestockDriverCarrier:getHerdingDogVisualConfig()
    return {
        filename = PlayerLivestockDriver.HERDING_DOG_FILENAME,
        animationFilename = PlayerLivestockDriver.HERDING_DOG_ANIMATION_FILENAME,
        clipRootPath = "0",
        animationSourcePath = "0",
        idleClip = PlayerLivestockDriver.HERDING_DOG_IDLE_CLIP,
        walkClip = PlayerLivestockDriver.HERDING_DOG_WALK_CLIP,
        runClip = PlayerLivestockDriver.HERDING_DOG_RUN_CLIP,
        locomotionClipSets = {
            idle = {
                {clips = {"sniffSource"}, speedScale = 1},
                {clips = {"sitSource"}, speedScale = 1}
            },
            walk = {
                {clips = {"walkLeftSource", "walkRightSource"}, speedScale = 1}
            },
            run = {
                {clips = {"runLeftSource", "runRightSource"}, speedScale = 1}
            }
        },
        randomIdleStart = true,
        randomMovementStart = true,
        reverseMovementAnimations = false,
        playbackScale = 1,
        referenceWalkSpeed = PlayerLivestockDriver.HERDING_DOG_WALK_SPEED,
        referenceRunSpeed = 16,
        soundConfig = nil
    }
end

function PlayerLivestockDriverCarrier:createHerdingDogSlot()
    if self.herdingDogSlot ~= nil then
        return self.herdingDogSlot
    end

    local node = createTransformGroup("playerLivestockHerdingDog")
    link(getRootNode(), node)

    self.herdingDogSlot = {
        linkNode = node,
        meshLoadingInProgress = false,
        visualIndex = -1000,
        isHerdingDog = true,
        animalRadius = 0.42,
        animationSpeedKph = 0,
        movementState = "idle",
        speedKph = 0,
        lastYaw = self.followHeadingYaw or 0
    }

    self:ensureSlotFoliageBending(self.herdingDogSlot)

    return self.herdingDogSlot
end

function PlayerLivestockDriverCarrier:loadHerdingDogVisual()
    if AnimatedLivestockTrailer == nil or g_i3DManager == nil then
        return
    end

    local slot = self:createHerdingDogSlot()
    if slot.meshLoadingInProgress or slot.sharedAnimatedLoadRequestId ~= nil then
        return
    end

    local config = self:getHerdingDogVisualConfig()
    slot.meshLoadingInProgress = true
    slot.animatedVisualConfig = config
    slot.sharedAnimatedLoadRequestId = g_i3DManager:loadSharedI3DFileAsync(config.filename, false, false, AnimatedLivestockTrailer.onAnimalLoaded, self, {
        slot = slot,
        visual = nil,
        config = config,
        loadGeneration = self.visualGeneration
    })

    self.spec_animatedLivestockTrailer.pendingAnimatedSlots[slot] = true
end

function PlayerLivestockDriverCarrier:deleteHerdingDogSounds()
    if self.herdingDogSoundSamples ~= nil then
        for _, sample in ipairs(self.herdingDogSoundSamples) do
            if sample.soundNode ~= nil and entityExists(sample.soundNode) then
                delete(sample.soundNode)
            end
        end
    end

    self.herdingDogSoundSamples = {}
    self.herdingDogSoundSamplesLoaded = false
    self.herdingDogSoundTimer = 0
end

function PlayerLivestockDriverCarrier:loadHerdingDogSounds()
    if self.herdingDogSoundSamplesLoaded then
        return
    end

    local slot = self.herdingDogSlot
    if slot == nil or slot.linkNode == nil or not entityExists(slot.linkNode) then
        return
    end

    self.herdingDogSoundSamplesLoaded = true
    self.herdingDogSoundSamples = {}

    for index, filename in ipairs(PlayerLivestockDriver.HERDING_DOG_PANT_SOUNDS or {}) do
        local fullFilename = PlayerLivestockDriver.MOD_DIRECTORY .. filename

        if fileExists ~= nil and not fileExists(fullFilename) then
            Logging.warning("[%s] Missing herding dog sound: %s", PlayerLivestockDriver.MOD_NAME, fullFilename)
        else
            local soundNode = createAudioSource("playerLivestockHerdingDogPant_" .. tostring(index), fullFilename, PlayerLivestockDriver.HERDING_DOG_PANT_RANGE, PlayerLivestockDriver.HERDING_DOG_PANT_INNER_RANGE, PlayerLivestockDriver.HERDING_DOG_PANT_VOLUME, 1)
            if soundNode ~= nil and soundNode ~= 0 then
                link(slot.linkNode, soundNode)
                setTranslation(soundNode, 0, 0.35, 0)

                local sample = getAudioSourceSample(soundNode)
                if sample ~= nil and sample ~= 0 then
                    table.insert(self.herdingDogSoundSamples, {
                        soundNode = soundNode,
                        sample = sample,
                        volume = PlayerLivestockDriver.HERDING_DOG_PANT_VOLUME
                    })
                else
                    delete(soundNode)
                    Logging.warning("[%s] Could not create herding dog sound sample: %s", PlayerLivestockDriver.MOD_NAME, fullFilename)
                end
            else
                Logging.warning("[%s] Could not create herding dog sound: %s", PlayerLivestockDriver.MOD_NAME, fullFilename)
            end
        end
    end
end

function PlayerLivestockDriverCarrier:updateHerdingDogSounds(dt)
    local slot = self.herdingDogSlot
    if slot == nil or slot.linkNode == nil or not entityExists(slot.linkNode) then
        return
    end

    local movementState = slot.movementState
    if self:getIsHerdWaiting() or (movementState ~= "walk" and movementState ~= "run") then
        self.herdingDogSoundTimer = math.max(self.herdingDogSoundTimer or 0, 400)
        return
    end

    self:loadHerdingDogSounds()

    if self.herdingDogSoundSamples == nil or #self.herdingDogSoundSamples == 0 then
        return
    end

    self.herdingDogSoundTimer = (self.herdingDogSoundTimer or 0) - (dt or 0)
    if self.herdingDogSoundTimer > 0 then
        return
    end

    local sample = self.herdingDogSoundSamples[math.random(1, #self.herdingDogSoundSamples)]
    if sample ~= nil and sample.sample ~= nil then
        playSample(sample.sample, 1, sample.volume or PlayerLivestockDriver.HERDING_DOG_PANT_VOLUME, 0, 0, 0)
    end

    local minInterval = PlayerLivestockDriver.HERDING_DOG_PANT_WALK_MIN_INTERVAL
    local maxInterval = PlayerLivestockDriver.HERDING_DOG_PANT_WALK_MAX_INTERVAL
    if movementState == "run" then
        minInterval = PlayerLivestockDriver.HERDING_DOG_PANT_RUN_MIN_INTERVAL
        maxInterval = PlayerLivestockDriver.HERDING_DOG_PANT_RUN_MAX_INTERVAL
    end

    self.herdingDogSoundTimer = math.random(minInterval, maxInterval)
end

function PlayerLivestockDriverCarrier:deleteHerdingDogVisual()
    self:deleteHerdingDogSounds()

    self:destroySlotFoliageBending(self.herdingDogSlot)

    if self.herdingDogSlot ~= nil and self.herdingDogSlot.linkNode ~= nil and entityExists(self.herdingDogSlot.linkNode) then
        delete(self.herdingDogSlot.linkNode)
    end

    self.herdingDogSlot = nil
end


function PlayerLivestockDriverCarrier:rebuildVisuals()
    self.visualDirty = false
    self.visualGeneration = self.visualGeneration + 1

    if AnimatedLivestockTrailer == nil or AnimatedLivestockTrailer.getVisualConfig == nil then
        return
    end

    self:clearVisuals()
    self.spec_animatedLivestockTrailer.loadGeneration = self.visualGeneration

    local requests = self:collectVisualRequests()
    local spec = self.spec_animatedLivestockTrailer
    local soundConfigs = {}
    spec.loadedSlots = {}
    spec.pendingAnimatedSlots = {}

    for index, request in ipairs(requests) do
        local slot = self:ensureVisualSlot(index)
        local config = AnimatedLivestockTrailer.getVisualConfig(self, request.animalType, request.visual, spec.defaultConfig)

        slot.animalRadius = request.radius or PlayerLivestockDriver.FOLLOW_DEFAULT_RADIUS
        slot.animalTypeName = request.animalType ~= nil and request.animalType.name or nil
        slot.canBeHerdedByDog = self:getIsHerdingDogAnimalType(request.animalType)
        slot.animalSpacingX = math.max(PlayerLivestockDriver.SLOT_SPACING_X, slot.animalRadius * PlayerLivestockDriver.FOLLOW_RADIUS_X_SCALE)
        slot.animalSpacingZ = math.max(PlayerLivestockDriver.SLOT_SPACING_Z, slot.animalRadius * PlayerLivestockDriver.FOLLOW_RADIUS_Z_SCALE)
        self:ensureSlotFoliageBending(slot)

        if config ~= nil then
            AnimatedLivestockTrailer.addAnimalSoundConfig(soundConfigs, config.soundConfig)
        end

        if config ~= nil and config.filename ~= nil then
            slot.meshLoadingInProgress = true
            slot.animatedVisualConfig = config
            slot.animatedVisual = request.visual
            slot.sharedAnimatedLoadRequestId = g_i3DManager:loadSharedI3DFileAsync(config.filename, false, false, AnimatedLivestockTrailer.onAnimalLoaded, self, {
                slot = slot,
                visual = request.visual,
                config = config,
                loadGeneration = self.visualGeneration
            })
            spec.pendingAnimatedSlots[slot] = true
        end
    end

    if self:getShouldUseHerdingDog() then
        self:loadHerdingDogVisual()
    end

    if AnimatedLivestockTrailer.setAnimalSoundConfigs ~= nil then
        AnimatedLivestockTrailer.setAnimalSoundConfigs(self, soundConfigs)
    end
end

function PlayerLivestockDriverCarrier:getFollowerGroundY(x, fallbackY, z)
    if g_terrainNode ~= nil then
        return getTerrainHeightAtWorldPos(g_terrainNode, x, 0, z)
    end

    return fallbackY
end

function PlayerLivestockDriverCarrier:getSlotTarget(slot, index, dtSeconds)
    local playerX, playerY, playerZ = getWorldTranslation(g_localPlayer.rootNode)
    local _, playerYaw, _ = getWorldRotation(g_localPlayer.rootNode)
    local playerSpeedKph = self.lastSpeedKph or 0
    local targetHeadingYaw = playerYaw

    if playerSpeedKph > 0.35 and self.lastMoveX ~= nil and self.lastMoveZ ~= nil then
        targetHeadingYaw = MathUtil.getYRotationFromDirection(self.lastMoveX, self.lastMoveZ)
    elseif self.followHeadingYaw ~= nil then
        targetHeadingYaw = self.followHeadingYaw
    end

    if self.followHeadingYaw == nil then
        self.followHeadingYaw = targetHeadingYaw
    else
        local normalizedTargetYaw = MathUtil.normalizeRotationForShortestPath(targetHeadingYaw, self.followHeadingYaw)
        local yawDelta = normalizedTargetYaw - self.followHeadingYaw
        local maxYawStep = PlayerLivestockDriver.FOLLOW_HEADING_LERP_SPEED * math.min(dtSeconds * 60, 3)
        yawDelta = math.min(math.max(yawDelta, -maxYawStep), maxYawStep)
        self.followHeadingYaw = MathUtil.getValidLimit(self.followHeadingYaw + yawDelta)
    end

    local followHeadingNode = self.formationNode or g_localPlayer.rootNode
    setWorldTranslation(followHeadingNode, playerX, playerY, playerZ)
    setWorldRotation(followHeadingNode, 0, self.followHeadingYaw, 0)

    slot.wanderTimer = (slot.wanderTimer or 0) - (dtSeconds * 1000)
    if slot.wanderTimer <= 0 then
        slot.wanderTimer = PlayerLivestockDriver.FOLLOW_HERD_WANDER_MIN_TIME + math.random() * (PlayerLivestockDriver.FOLLOW_HERD_WANDER_MAX_TIME - PlayerLivestockDriver.FOLLOW_HERD_WANDER_MIN_TIME)
        slot.wanderTargetX = (math.random() * 2 - 1) * 0.18
        slot.wanderTargetZ = (math.random() * 2 - 1) * 0.55
    end

    local wanderLerp = math.min(PlayerLivestockDriver.FOLLOW_HERD_WANDER_LERP * math.min(dtSeconds * 60, 3), 1)
    slot.wanderOffsetX = (slot.wanderOffsetX or 0) + ((slot.wanderTargetX or 0) - (slot.wanderOffsetX or 0)) * wanderLerp
    slot.wanderOffsetZ = (slot.wanderOffsetZ or 0) + ((slot.wanderTargetZ or 0) - (slot.wanderOffsetZ or 0)) * wanderLerp

    local radius = slot.animalRadius or PlayerLivestockDriver.FOLLOW_DEFAULT_RADIUS
    local sideSpacing = math.max(radius * 1.05, PlayerLivestockDriver.HERD_ACTOR_SIDE_SPREAD)
    local trailSpacing = math.max(radius * 2.55, PlayerLivestockDriver.HERD_ACTOR_TRAIL_SPACING)
    local localX = (slot.lane or 0) * sideSpacing + (slot.baseSideOffset or 0) + (slot.wanderOffsetX or 0)
    local zDirection = self:getIsDriveMode() and 1 or -1
    local trailZ = PlayerLivestockDriver.FOLLOW_HERD_BASE_DISTANCE + radius * 1.15 + (slot.trailOrder or math.floor((index - 1) / 2)) * trailSpacing
    local localZ = zDirection * trailZ + (slot.baseTrailOffset or 0) + (slot.wanderOffsetZ or 0)

    if slot.canBeHerdedByDog and self:getHasActiveHerdingDog() then
        local gatherScale = 1 - PlayerLivestockDriver.HERDING_DOG_GATHER_SCALE
        localX = localX * gatherScale
        localZ = localZ - zDirection * math.min(math.abs(localX) * 0.08, 0.22)
    end

    local targetX, targetY, targetZ = localToWorld(followHeadingNode, localX, 0, localZ)
    targetY = self:getFollowerGroundY(targetX, targetY, targetZ)

    return targetX, targetY, targetZ, playerX, playerY, playerZ
end

function PlayerLivestockDriverCarrier:applySlotSeparation(slot, targetX, targetZ)
    if slot.currentX == nil then
        return targetX, targetZ
    end

    local pushX, pushZ = 0, 0
    local radius = slot.animalRadius or PlayerLivestockDriver.FOLLOW_DEFAULT_RADIUS

    for _, other in ipairs(self.visualSlots) do
        if other ~= slot and other.currentX ~= nil then
            local otherRadius = other.animalRadius or PlayerLivestockDriver.FOLLOW_DEFAULT_RADIUS
            local minDistance = (radius + otherRadius) * PlayerLivestockDriver.HERD_ACTOR_SEPARATION_SCALE
            local dx = slot.currentX - other.currentX
            local dz = slot.currentZ - other.currentZ
            local distance = MathUtil.vector2Length(dx, dz)

            if distance > 0.001 and distance < minDistance then
                local strength = (minDistance - distance) / minDistance
                pushX = pushX + dx / distance * strength * minDistance * 0.45
                pushZ = pushZ + dz / distance * strength * minDistance * 0.45
            end
        end
    end

    local dogSlot = self.herdingDogSlot
    if slot.canBeHerdedByDog and dogSlot ~= nil and dogSlot.currentX ~= nil then
        local dx = slot.currentX - dogSlot.currentX
        local dz = slot.currentZ - dogSlot.currentZ
        local distance = MathUtil.vector2Length(dx, dz)
        local pressureDistance = PlayerLivestockDriver.HERDING_DOG_PRESSURE_RADIUS + radius

        if distance > 0.001 and distance < pressureDistance then
            local strength = (pressureDistance - distance) / pressureDistance
            pushX = pushX + dx / distance * strength * PlayerLivestockDriver.HERDING_DOG_PRESSURE_STRENGTH
            pushZ = pushZ + dz / distance * strength * PlayerLivestockDriver.HERDING_DOG_PRESSURE_STRENGTH
        end
    end

    return targetX + pushX, targetZ + pushZ
end

function PlayerLivestockDriverCarrier:getHerdingDogTarget(dtSeconds)
    if g_localPlayer == nil or g_localPlayer.rootNode == nil then
        return nil
    end

    self.herdingDogSideTimer = (self.herdingDogSideTimer or 0) - (dtSeconds * 1000)
    if self.herdingDogSideTimer <= 0 then
        self.herdingDogSide = (self.herdingDogSide or 1) * -1
        self.herdingDogSideTimer = PlayerLivestockDriver.HERDING_DOG_SIDE_SWITCH_MIN_TIME + math.random() * (PlayerLivestockDriver.HERDING_DOG_SIDE_SWITCH_MAX_TIME - PlayerLivestockDriver.HERDING_DOG_SIDE_SWITCH_MIN_TIME)
    end

    local playerX, playerY, playerZ = getWorldTranslation(g_localPlayer.rootNode)
    local followHeadingNode = self.formationNode or g_localPlayer.rootNode

    if self.followHeadingYaw ~= nil then
        setWorldTranslation(followHeadingNode, playerX, playerY, playerZ)
        setWorldRotation(followHeadingNode, 0, self.followHeadingYaw, 0)
    end

    local count = math.max(#(self.visualSlots or {}), 1)
    local averageTrail = 0

    for index, slot in ipairs(self.visualSlots or {}) do
        local radius = slot.animalRadius or PlayerLivestockDriver.FOLLOW_DEFAULT_RADIUS
        local trailSpacing = math.max(radius * 2.55, PlayerLivestockDriver.HERD_ACTOR_TRAIL_SPACING)
        averageTrail = averageTrail + PlayerLivestockDriver.FOLLOW_HERD_BASE_DISTANCE + radius * 1.15 + (slot.trailOrder or math.floor((index - 1) / 2)) * trailSpacing
    end

    averageTrail = averageTrail / count

    local zDirection = self:getIsDriveMode() and 1 or -1
    local localX = (self.herdingDogSide or 1) * (PlayerLivestockDriver.HERDING_DOG_SIDE_DISTANCE + math.min(count * 0.045, 0.75))
    local localZ

    if self:getIsDriveMode() then
        localZ = zDirection * math.max(PlayerLivestockDriver.FOLLOW_HERD_BASE_DISTANCE * 0.45, averageTrail * 0.30)
    else
        localZ = zDirection * (averageTrail + PlayerLivestockDriver.HERDING_DOG_BACK_DISTANCE)
    end

    local targetX, targetY, targetZ = localToWorld(followHeadingNode, localX, 0, localZ)
    targetY = self:getFollowerGroundY(targetX, targetY, targetZ)

    return targetX, targetY, targetZ, playerX, playerY, playerZ
end

function PlayerLivestockDriverCarrier:updateHerdingDogTransform(dt)
    local slot = self.herdingDogSlot
    if slot == nil or slot.linkNode == nil or not entityExists(slot.linkNode) then
        return
    end

    local dtSeconds = math.max((dt or 0) * 0.001, 0.001)
    local targetX, targetY, targetZ, playerX, playerY, playerZ = self:getHerdingDogTarget(dtSeconds)
    if targetX == nil then
        return
    end

    if slot.currentX == nil then
        slot.currentX = targetX
        slot.currentY = targetY
        slot.currentZ = targetZ
        slot.lastYaw = self.followHeadingYaw or 0
    end

    local dx = targetX - slot.currentX
    local dz = targetZ - slot.currentZ
    local distance = MathUtil.vector2Length(dx, dz)
    local desiredSpeedKph = 0
    local movementState = "idle"

    if not self:getIsHerdWaiting() and distance > PlayerLivestockDriver.HERDING_DOG_STOP_DISTANCE then
        if distance > PlayerLivestockDriver.HERDING_DOG_RUN_DISTANCE or (self.lastSpeedKph or 0) >= PlayerLivestockDriver.FOLLOW_RUN_PLAYER_SPEED then
            movementState = "run"
            desiredSpeedKph = math.min(math.max(PlayerLivestockDriver.HERDING_DOG_RUN_SPEED, distance * 5.0), PlayerLivestockDriver.HERDING_DOG_RUN_SPEED + 8)
        elseif distance > PlayerLivestockDriver.HERDING_DOG_WALK_DISTANCE then
            movementState = "walk"
            desiredSpeedKph = PlayerLivestockDriver.HERDING_DOG_WALK_SPEED
        end
    end

    local yaw = slot.lastYaw or self.followHeadingYaw or 0
    local targetYaw = yaw

    if distance > 0.05 then
        targetYaw = MathUtil.getYRotationFromDirection(dx / distance, dz / distance)
    elseif playerX ~= nil then
        local lookX = playerX - slot.currentX
        local lookZ = playerZ - slot.currentZ
        local lookDistance = MathUtil.vector2Length(lookX, lookZ)
        if lookDistance > 0.1 then
            targetYaw = MathUtil.getYRotationFromDirection(lookX / lookDistance, lookZ / lookDistance)
        end
    end

    targetYaw = MathUtil.normalizeRotationForShortestPath(targetYaw, yaw)
    local yawRate = movementState == "run" and 2.6 or 1.8
    local yawDelta = math.min(math.max(targetYaw - yaw, -yawRate * dtSeconds), yawRate * dtSeconds)
    yaw = MathUtil.getValidLimit(yaw + yawDelta)
    slot.lastYaw = yaw

    if desiredSpeedKph > 0 and distance > PlayerLivestockDriver.HERDING_DOG_STOP_DISTANCE then
        local dirX, dirZ = MathUtil.getDirectionFromYRotation(yaw)
        local step = math.min((desiredSpeedKph / 3.6) * dtSeconds, math.max(distance - PlayerLivestockDriver.HERDING_DOG_STOP_DISTANCE * 0.45, 0))
        slot.currentX = slot.currentX + dirX * step
        slot.currentZ = slot.currentZ + dirZ * step
    end

    slot.currentY = (slot.currentY or targetY) + (targetY - (slot.currentY or targetY)) * math.min(dtSeconds * 6, 1)
    slot.speedKph = desiredSpeedKph
    slot.animationSpeedKph = desiredSpeedKph
    slot.movementState = movementState
    slot.lastFollowDistance = distance
    slot.lastFollowStep = desiredSpeedKph / 3.6 * dtSeconds
    slot.lastFollowFactor = distance > 0 and math.min(slot.lastFollowStep / distance, 1) or 0

    setWorldTranslation(slot.linkNode, slot.currentX, slot.currentY, slot.currentZ)
    setWorldRotation(slot.linkNode, 0, yaw, 0)

    self:updateHerdingDogSounds(dt)
end

function PlayerLivestockDriverCarrier:updateAnimalSoundPosition()
    if self.soundNode == nil or not entityExists(self.soundNode) then
        return
    end

    local x, y, z = 0, 0, 0
    local count = 0

    for _, slot in ipairs(self.visualSlots or {}) do
        if slot.currentX ~= nil then
            x = x + slot.currentX
            y = y + (slot.currentY or 0)
            z = z + slot.currentZ
            count = count + 1
        end
    end

    if count > 0 then
        setWorldTranslation(self.soundNode, x / count, y / count, z / count)
    elseif g_localPlayer ~= nil and g_localPlayer.rootNode ~= nil then
        setWorldTranslation(self.soundNode, getWorldTranslation(g_localPlayer.rootNode))
    end
end

function PlayerLivestockDriverCarrier:updateWaitingSlotTransforms(dt)
    local dtSeconds = math.max((dt or 0) * 0.001, 0.001)

    for index, slot in ipairs(self.visualSlots) do
        if slot.linkNode ~= nil and entityExists(slot.linkNode) then
            if slot.currentX == nil then
                local targetX, targetY, targetZ = self:getSlotTarget(slot, index, dtSeconds)
                slot.currentX = targetX
                slot.currentY = targetY
                slot.currentZ = targetZ
                slot.lastYaw = self.followHeadingYaw or 0
            end

            slot.currentY = self:getFollowerGroundY(slot.currentX, slot.currentY or 0, slot.currentZ)
            slot.speedKph = 0
            slot.animationSpeedKph = 0
            slot.movementState = "idle"
            slot.lastFollowDistance = 0
            slot.lastFollowStep = 0
            slot.lastFollowFactor = 0

            setWorldTranslation(slot.linkNode, slot.currentX, slot.currentY, slot.currentZ)
            setWorldRotation(slot.linkNode, 0, (slot.lastYaw or 0) + PlayerLivestockDriver.ANIMAL_ROTATION_OFFSET_Y, 0)
        end
    end

    self:updateHerdingDogTransform(dt)
    self:updateAnimalSoundPosition()
end

function PlayerLivestockDriverCarrier:updateSlotTransforms(dt)
    if g_localPlayer == nil or g_localPlayer.rootNode == nil then
        return
    end

    local dtSeconds = math.max((dt or 0) * 0.001, 0.001)
    self.visualTime = (self.visualTime or 0) + (dt or 0)

    if self:getIsHerdWaiting() then
        self:updateWaitingSlotTransforms(dt)
        return
    end

    for index, slot in ipairs(self.visualSlots) do
        if slot.linkNode ~= nil and entityExists(slot.linkNode) then
            local targetX, targetY, targetZ, playerX, playerY, playerZ = self:getSlotTarget(slot, index, dtSeconds)

            if slot.targetX == nil then
                slot.targetX, slot.targetY, slot.targetZ = targetX, targetY, targetZ
            else
                local speedLerpBoost = (self.lastSpeedKph or 0) >= PlayerLivestockDriver.FOLLOW_RUN_PLAYER_SPEED and 1.75 or 1.0
                local targetLerp = math.min(PlayerLivestockDriver.HERD_ACTOR_TARGET_LERP * speedLerpBoost * (slot.followBlendScale or 1) * math.min(dtSeconds * 60, 3), 1)
                slot.targetX = slot.targetX + (targetX - slot.targetX) * targetLerp
                slot.targetY = slot.targetY + (targetY - slot.targetY) * math.min(targetLerp * 1.8, 0.30)
                slot.targetZ = slot.targetZ + (targetZ - slot.targetZ) * targetLerp
            end

            targetX, targetZ = self:applySlotSeparation(slot, slot.targetX, slot.targetZ)
            targetY = slot.targetY

            if slot.currentX == nil then
                slot.currentX = targetX
                slot.currentY = targetY
                slot.currentZ = targetZ
                local lookX = playerX - slot.currentX
                local lookZ = playerZ - slot.currentZ
                local lookDistance = MathUtil.vector2Length(lookX, lookZ)
                slot.lastYaw = lookDistance > 0.05 and MathUtil.getYRotationFromDirection(lookX / lookDistance, lookZ / lookDistance) or (self.followHeadingYaw or 0)
            end

            local dx = targetX - slot.currentX
            local dz = targetZ - slot.currentZ
            local distance = MathUtil.vector2Length(dx, dz)
            local radius = slot.animalRadius or PlayerLivestockDriver.FOLLOW_DEFAULT_RADIUS
            local stopDistance = math.max(PlayerLivestockDriver.HERD_ACTOR_STOP_DISTANCE, radius * 1.7)
            local walkDistance = stopDistance + PlayerLivestockDriver.HERD_ACTOR_WALK_DISTANCE
            local runDistance = stopDistance + PlayerLivestockDriver.HERD_ACTOR_RUN_DISTANCE
            local playerSpeedKph = self.lastSpeedKph or 0
            local desiredSpeedKph = 0
            local movementState = "idle"

            if distance > stopDistance then
                local wantsRun = distance > runDistance or (playerSpeedKph >= PlayerLivestockDriver.FOLLOW_RUN_PLAYER_SPEED and distance > walkDistance)

                if slot.movementState == "run" and distance > walkDistance and playerSpeedKph > PlayerLivestockDriver.FOLLOW_RUN_EXIT_PLAYER_SPEED then
                    wantsRun = true
                end
                if playerSpeedKph < PlayerLivestockDriver.HERD_ACTOR_STAND_PLAYER_SPEED and distance < runDistance * PlayerLivestockDriver.HERD_ACTOR_STAND_RUN_DISTANCE_MULT then
                    wantsRun = false
                end



                if wantsRun then
                    movementState = "run"
                    desiredSpeedKph = math.min(math.max(slot.nativeRunSpeedKph or PlayerLivestockDriver.HERD_ACTOR_RUN_SPEED, playerSpeedKph + 4.0, distance * 3.0), PlayerLivestockDriver.HERD_ACTOR_CATCHUP_RUN_SPEED)
                else
                    movementState = "walk"
                    desiredSpeedKph = slot.nativeWalkSpeedKph or PlayerLivestockDriver.HERD_ACTOR_WALK_SPEED
                end
            end

            local yaw = slot.lastYaw or self.followHeadingYaw or 0
            local targetYaw = yaw
            local yawRate = PlayerLivestockDriver.HERD_ACTOR_IDLE_YAW_RATE

            if distance > 0.05 then
                targetYaw = MathUtil.getYRotationFromDirection(dx / distance, dz / distance)
                yawRate = movementState == "run" and PlayerLivestockDriver.HERD_ACTOR_RUN_YAW_RATE or PlayerLivestockDriver.HERD_ACTOR_YAW_RATE
            elseif playerSpeedKph < 0.2 then
                local lookX = playerX - slot.currentX
                local lookZ = playerZ - slot.currentZ
                local lookDistance = MathUtil.vector2Length(lookX, lookZ)
                if lookDistance > stopDistance * 1.35 then
                    targetYaw = MathUtil.getYRotationFromDirection(lookX / lookDistance, lookZ / lookDistance) + (slot.yawNoise or 0)
                end
            end

            targetYaw = MathUtil.normalizeRotationForShortestPath(targetYaw, yaw)
            local yawDelta = targetYaw - yaw
            local maxYawStep = yawRate * dtSeconds
            yawDelta = math.min(math.max(yawDelta, -maxYawStep), maxYawStep)
            yaw = MathUtil.getValidLimit(yaw + yawDelta)
            slot.lastYaw = yaw

            if desiredSpeedKph > 0 and distance > stopDistance then
                local dirX, dirZ = MathUtil.getDirectionFromYRotation(yaw)
                local anglePenalty = 1 - math.min(math.abs(yawDelta) / math.max(maxYawStep, 0.001), 1) * 0.35
                local step = math.min((desiredSpeedKph / 3.6) * dtSeconds * math.max(anglePenalty, 0.85), math.max(distance - stopDistance * 0.55, 0))
                slot.currentX = slot.currentX + dirX * step
                slot.currentZ = slot.currentZ + dirZ * step
            end

            slot.currentY = (slot.currentY or targetY) + (targetY - (slot.currentY or targetY)) * math.min(dtSeconds * 5, 1)
            slot.speedKph = desiredSpeedKph
            slot.animationSpeedKph = desiredSpeedKph
            slot.movementState = movementState
            slot.lastFollowDistance = distance
            slot.lastFollowStep = desiredSpeedKph / 3.6 * dtSeconds
            slot.lastFollowFactor = distance > 0 and math.min(slot.lastFollowStep / distance, 1) or 0

            setWorldTranslation(slot.linkNode, slot.currentX, slot.currentY, slot.currentZ)
            setWorldRotation(slot.linkNode, 0, yaw + PlayerLivestockDriver.ANIMAL_ROTATION_OFFSET_Y, 0)
        end
    end

    self:updateHerdingDogTransform(dt)
    self:updateAnimalSoundPosition()
end

function PlayerLivestockDriverCarrier:updatePlayerSpeed(dt)
    if g_localPlayer == nil or g_localPlayer.rootNode == nil then
        self.rawSpeedKph = 0
        self.smoothedSpeedKph = 0
        self.lastSpeedKph = 0
        self.runAnimationActive = false
        self.runHoldTimer = 0
        return
    end

    local x, y, z = getWorldTranslation(g_localPlayer.rootNode)
    local rawSpeedKph = 0
    local dtSeconds = math.max((dt or 0) * 0.001, 0.001)

    if self.lastPlayerX ~= nil and dt ~= nil and dt > 0 then
        local dx = x - self.lastPlayerX
        local dz = z - self.lastPlayerZ
        local horizontalDistance = MathUtil.vector3Length(dx, 0, dz)

        if horizontalDistance <= PlayerLivestockDriver.FOLLOW_TELEPORT_DISTANCE then
            rawSpeedKph = math.min(horizontalDistance / dtSeconds * 3.6, PlayerLivestockDriver.FOLLOW_PLAYER_SPEED_CAP)

            if horizontalDistance > PlayerLivestockDriver.FOLLOW_HEADING_MOVE_THRESHOLD then
                self.lastMoveX = dx / horizontalDistance
                self.lastMoveZ = dz / horizontalDistance
            end
        else
            rawSpeedKph = math.min(self.rawSpeedKph or 0, PlayerLivestockDriver.FOLLOW_PLAYER_SPEED_CAP)
        end
    end

    self.lastPlayerX = x
    self.lastPlayerY = y
    self.lastPlayerZ = z
    self.rawSpeedKph = rawSpeedKph

    if self.smoothedSpeedKph == nil then
        self.smoothedSpeedKph = rawSpeedKph
    else
        local speedBlend = math.min(dtSeconds / PlayerLivestockDriver.FOLLOW_SPEED_SMOOTHING, 1)
        self.smoothedSpeedKph = self.smoothedSpeedKph + (rawSpeedKph - self.smoothedSpeedKph) * speedBlend
    end

    self.smoothedSpeedKph = math.min(math.max(self.smoothedSpeedKph or 0, 0), PlayerLivestockDriver.FOLLOW_PLAYER_SPEED_CAP)
    self.lastSpeedKph = self.smoothedSpeedKph
    self.runHoldTimer = math.max((self.runHoldTimer or 0) - (dt or 0), 0)

    if rawSpeedKph >= PlayerLivestockDriver.FOLLOW_RUN_PLAYER_SPEED or self.smoothedSpeedKph >= PlayerLivestockDriver.FOLLOW_RUN_PLAYER_SPEED then
        self.runHoldTimer = PlayerLivestockDriver.FOLLOW_RUN_HOLD_TIME
    end

    if self.runAnimationActive then
        if self.runHoldTimer <= 0 and rawSpeedKph <= PlayerLivestockDriver.FOLLOW_RUN_EXIT_PLAYER_SPEED and self.smoothedSpeedKph <= PlayerLivestockDriver.FOLLOW_RUN_EXIT_PLAYER_SPEED then
            self.runAnimationActive = false
        end
    elseif self.runHoldTimer > 0 or self.smoothedSpeedKph >= PlayerLivestockDriver.FOLLOW_RUN_PLAYER_SPEED then
        self.runAnimationActive = true
    end
end

function PlayerLivestockDriverCarrier:updateHerdAnimalAnimation(state, signedSpeed)
    if AnimatedLivestockTrailer == nil or state == nil or state.characterSet == nil or state.characterSet == 0 then
        return
    end

    local config = state.config
    local spec = self.spec_animatedLivestockTrailer
    local speed = math.abs(signedSpeed or 0)
    local clipKey = "idle"
    local referenceSpeed = 0
    local slotState = state.slot ~= nil and state.slot.movementState or nil

    if not config.forceIdleOnly and spec.useSpeedAnimations then
        if slotState == "run" then
            clipKey = "run"
            referenceSpeed = config.referenceRunSpeed
        elseif slotState == "walk" then
            clipKey = "walk"
            referenceSpeed = config.referenceWalkSpeed
        elseif speed >= spec.runSpeed and (self.lastSpeedKph or 0) >= PlayerLivestockDriver.HERD_ACTOR_STAND_PLAYER_SPEED then
            clipKey = "run"
            referenceSpeed = config.referenceRunSpeed
        elseif speed >= spec.walkSpeed then
            clipKey = "walk"
            referenceSpeed = config.referenceWalkSpeed
        end
    end

    if (self.lastSpeedKph or 0) < PlayerLivestockDriver.HERD_ACTOR_STAND_PLAYER_SPEED and state.slot ~= nil and state.slot.lastFollowDistance ~= nil then
        local radius = state.slot.animalRadius or PlayerLivestockDriver.FOLLOW_DEFAULT_RADIUS
        local stopDistance = math.max(PlayerLivestockDriver.HERD_ACTOR_STOP_DISTANCE, radius * 1.7)
        if state.slot.lastFollowDistance <= stopDistance + 0.35 then
            clipKey = "idle"
            referenceSpeed = 0
        elseif clipKey == "run" then
            clipKey = "walk"
            referenceSpeed = config.referenceWalkSpeed
        end
    end

    local now = g_time or 0
    if state.currentClipKey ~= nil and state.currentClipKey ~= clipKey then
        local switchDelay = PlayerLivestockDriver.HERD_ANIM_MOVE_DELAY
        if clipKey == "idle" then
            switchDelay = PlayerLivestockDriver.HERD_ANIM_IDLE_DELAY
        elseif clipKey == "run" then
            switchDelay = PlayerLivestockDriver.HERD_ANIM_RUN_DELAY
        end

        if state.pendingClipKey ~= clipKey then
            state.pendingClipKey = clipKey
            state.pendingClipSince = now
            clipKey = state.currentClipKey
        elseif now - (state.pendingClipSince or now) < switchDelay then
            clipKey = state.currentClipKey
        else
            state.pendingClipKey = nil
            state.pendingClipSince = nil
        end
    else
        state.pendingClipKey = nil
        state.pendingClipSince = nil
    end

    if clipKey == "run" then
        referenceSpeed = config.referenceRunSpeed
    elseif clipKey == "walk" then
        referenceSpeed = config.referenceWalkSpeed
    else
        referenceSpeed = 0
    end

    local changedClip = state.currentClipKey ~= clipKey
    if changedClip then
        if not AnimatedLivestockTrailer.setClipSet(state, AnimatedLivestockTrailer.getClipSetCandidates(config, clipKey, state.characterSet), clipKey) then
            return
        end
    end

    if state.clipDuration == nil or state.clipDuration <= 0 then
        return
    end

    if state.slot ~= nil then
        local nativeSpeedKph = (state.clipMovementSpeed or 1) * 7.2
        if clipKey == "walk" then
            state.slot.nativeWalkSpeedKph = math.min(math.max(nativeSpeedKph, 2.0), 5.0)
        elseif clipKey == "run" then
            state.slot.nativeRunSpeedKph = math.min(math.max(nativeSpeedKph, 8.0), PlayerLivestockDriver.HERD_ACTOR_CATCHUP_RUN_SPEED)
        end
    end

    local speedFactor = 1
    if referenceSpeed > 0 then
        speedFactor = math.max(speed / referenceSpeed, 0.15)
    end

    local playbackDirection = 1
    if clipKey ~= "idle" and config.reverseMovementAnimations and signedSpeed < -0.05 then
        playbackDirection = -1
    end

    local playbackScale = speedFactor * (config.playbackScale or 1) * playbackDirection
    if clipKey == "walk" then
        playbackScale = math.min(math.max(playbackScale, 0.65), 1.15)
    elseif clipKey == "run" then
        playbackScale = math.min(math.max(playbackScale, 0.80), 1.20)
    end

    for _, trackInfo in ipairs(state.activeTracks or {}) do
        local track = trackInfo.track or trackInfo
        local blendWeight = trackInfo.blendWeight or (state.activeTracks ~= nil and #state.activeTracks > 0 and 1 / #state.activeTracks or 1)
        enableAnimTrack(state.characterSet, track)
        setAnimTrackBlendWeight(state.characterSet, track, blendWeight)
        setAnimTrackSpeedScale(state.characterSet, track, playbackScale)

        if changedClip and state.clipTime ~= nil then
            local duration = trackInfo.duration or state.clipDuration
            local trackTime = duration ~= nil and duration > 0 and AnimatedLivestockTrailer.wrapAnimationTime(state.clipTime, duration) or 0
            setAnimTrackTime(state.characterSet, track, trackTime, true)
        end
    end
end
function PlayerLivestockDriverCarrier:updateVisuals(dt)
    if self.visualDirty then
        self:rebuildVisuals()
    end

    self:updateActionSoundPosition()
    self:updatePlayerSpeed(dt)
    self:updateSlotTransforms(dt)

    if AnimatedLivestockTrailer == nil then
        return
    end

    local spec = self.spec_animatedLivestockTrailer
    for _, state in pairs(spec.loadedSlots or {}) do
        if AnimatedLivestockTrailer.updateAnimalTransform ~= nil then
            AnimatedLivestockTrailer.updateAnimalTransform(self, state)
        end

        if AnimatedLivestockTrailer.updateAnimalAnimation ~= nil then
            local animationSpeed = state.slot ~= nil and state.slot.animationSpeedKph or 0
            if state.slot ~= nil then
                state.slot.lastAnimationSpeed = animationSpeed or 0
            end
            self:updateHerdAnimalAnimation(state, animationSpeed or 0)
        end
    end

    self:updateAnimalSoundPosition()

    if AnimatedLivestockTrailer.updateAnimalSounds ~= nil then
        AnimatedLivestockTrailer.updateAnimalSounds(self, spec, dt)
    end

end

PlayerLivestockDriverMoveEvent = {}
local PlayerLivestockDriverMoveEvent_mt = Class(PlayerLivestockDriverMoveEvent, Event)
PlayerLivestockDriverMoveEvent.DIRECTION_TO_CARRIER = 1
PlayerLivestockDriverMoveEvent.DIRECTION_TO_HUSBANDRY = 2
PlayerLivestockDriverMoveEvent.DIRECTION_TO_TRAILER = 3
PlayerLivestockDriverMoveEvent.DIRECTION_FROM_TRAILER = 4
InitEventClass(PlayerLivestockDriverMoveEvent, "PlayerLivestockDriverMoveEvent")

function PlayerLivestockDriverMoveEvent.emptyNew()
    return Event.new(PlayerLivestockDriverMoveEvent_mt)
end

function PlayerLivestockDriverMoveEvent.new(husbandry, clusterId, numAnimals, direction, targetObject)
    local self = PlayerLivestockDriverMoveEvent.emptyNew()
    self.husbandry = husbandry
    self.clusterId = clusterId
    self.numAnimals = numAnimals
    self.direction = direction
    self.targetObject = targetObject
    return self
end

function PlayerLivestockDriverMoveEvent.newServerToClient(errorCode)
    local self = PlayerLivestockDriverMoveEvent.emptyNew()
    self.errorCode = errorCode
    return self
end

function PlayerLivestockDriverMoveEvent:readStream(streamId, connection)
    if connection:getIsServer() then
        self.errorCode = streamReadUIntN(streamId, 3)
    else
        self.direction = streamReadUIntN(streamId, 3)
        if self.direction == PlayerLivestockDriverMoveEvent.DIRECTION_TO_TRAILER then
            self.targetObject = NetworkUtil.readNodeObject(streamId)
        end
        self.husbandry = NetworkUtil.readNodeObject(streamId)
        self.clusterId = streamReadInt32(streamId)
        self.numAnimals = streamReadUInt8(streamId)
    end
    self:run(connection)
end

function PlayerLivestockDriverMoveEvent:writeStream(streamId, connection)
    if connection:getIsServer() then
        streamWriteUIntN(streamId, self.direction, 3)
        if self.direction == PlayerLivestockDriverMoveEvent.DIRECTION_TO_TRAILER then
            NetworkUtil.writeNodeObject(streamId, self.targetObject)
        end
        NetworkUtil.writeNodeObject(streamId, self.husbandry)
        streamWriteInt32(streamId, self.clusterId)
        streamWriteUInt8(streamId, self.numAnimals)
    else
        streamWriteUIntN(streamId, self.errorCode, 3)
    end
end

function PlayerLivestockDriverMoveEvent:run(connection)
    if connection:getIsServer() then
        g_messageCenter:publish(AnimalMoveEvent, self.errorCode)
        return
    end

    local uniqueUserId = g_currentMission.userManager:getUniqueUserIdByConnection(connection)
    local farm = g_farmManager:getFarmForUniqueUserId(uniqueUserId)
    local farmId = farm ~= nil and farm.farmId or FarmManager.SPECTATOR_FARM_ID
    local errorCode = PlayerLivestockDriver:serverMoveAnimals(farmId, self.husbandry, self.clusterId, self.numAnimals, self.direction, self.targetObject)
    connection:sendEvent(PlayerLivestockDriverMoveEvent.newServerToClient(errorCode))

    local carrier = PlayerLivestockDriver:getCarrier(farmId)
    if carrier ~= nil then
        PlayerLivestockDriver:sendCarrierSync(farmId)
    end
end

PlayerLivestockDriverSyncEvent = {}
local PlayerLivestockDriverSyncEvent_mt = Class(PlayerLivestockDriverSyncEvent, Event)
InitEventClass(PlayerLivestockDriverSyncEvent, "PlayerLivestockDriverSyncEvent")

function PlayerLivestockDriverSyncEvent.emptyNew()
    return Event.new(PlayerLivestockDriverSyncEvent_mt)
end

function PlayerLivestockDriverSyncEvent.new(farmId, clusters)
    local self = PlayerLivestockDriverSyncEvent.emptyNew()
    self.farmId = farmId
    self.clusters = clusters or {}
    return self
end

function PlayerLivestockDriverSyncEvent:readStream(streamId, connection)
    self.farmId = streamReadUIntN(streamId, FarmManager.FARM_ID_SEND_NUM_BITS)
    self.clusters = {}

    for _ = 1, streamReadUInt16(streamId) do
        local clusterId = streamReadInt32(streamId)
        local subTypeIndex = streamReadUIntN(streamId, AnimalCluster.NUM_BITS_SUB_TYPE)
        local cluster = g_currentMission.animalSystem:createClusterFromSubTypeIndex(subTypeIndex)
        cluster.id = clusterId
        cluster:readStream(streamId, connection)
        table.insert(self.clusters, cluster)
    end

    self:run(connection)
end

function PlayerLivestockDriverSyncEvent:writeStream(streamId, connection)
    streamWriteUIntN(streamId, self.farmId, FarmManager.FARM_ID_SEND_NUM_BITS)
    streamWriteUInt16(streamId, #self.clusters)

    for _, cluster in ipairs(self.clusters) do
        streamWriteInt32(streamId, cluster.id)
        streamWriteUIntN(streamId, cluster:getSubTypeIndex(), AnimalCluster.NUM_BITS_SUB_TYPE)
        cluster:writeStream(streamId, connection)
    end
end

function PlayerLivestockDriverSyncEvent:run(connection)
    local carrier = PlayerLivestockDriver:getCarrier(self.farmId)
    if carrier ~= nil then
        carrier:setClustersFromStream(self.clusters)
    end
end

function PlayerLivestockDriver:getFarmId()
    if g_localPlayer ~= nil and g_localPlayer.farmId ~= nil and g_localPlayer.farmId ~= FarmManager.SPECTATOR_FARM_ID then
        return g_localPlayer.farmId
    end

    return FarmManager.SINGLEPLAYER_FARM_ID
end

function PlayerLivestockDriver:getCarrier(farmId)
    farmId = farmId or self:getFarmId()
    self.carriers = self.carriers or {}

    if self.carriers[farmId] == nil then
        self.carriers[farmId] = PlayerLivestockDriverCarrier.new(farmId)
    end

    return self.carriers[farmId]
end

function PlayerLivestockDriver:getIsPlayerDriverActive()
    return g_localPlayer ~= nil and g_localPlayer.farmId ~= FarmManager.SPECTATOR_FARM_ID
end

function PlayerLivestockDriver:getIsPlayerCarrierController(controller)
    return controller ~= nil and controller.trailer ~= nil and controller.trailer.isPlayerLivestockCarrier
end

function PlayerLivestockDriver:getIsExtendedProductionAnimalInput(object)
    return object ~= nil
        and object.animalSubTypeToFillType ~= nil
        and object.fillTypeToAnimalSubType ~= nil
        and object.animalsTypeData ~= nil
end

function PlayerLivestockDriver:getIsExtendedProductionController(controller)
    return self:getIsPlayerCarrierController(controller) and self:getIsExtendedProductionAnimalInput(controller.husbandry)
end

function PlayerLivestockDriver:getIsExtendedProductionTrigger(trigger)
    return trigger ~= nil and self:getIsExtendedProductionAnimalInput(trigger.husbandry)
end

function PlayerLivestockDriver:getNumAnimalsFromClusters(object)
    local numAnimals = 0

    if object ~= nil and object.getClusters ~= nil then
        local clusters = object:getClusters()
        if clusters ~= nil then
            for _, cluster in ipairs(clusters) do
                if cluster ~= nil and cluster.getNumAnimals ~= nil then
                    numAnimals = numAnimals + cluster:getNumAnimals()
                elseif cluster ~= nil and cluster.numAnimals ~= nil then
                    numAnimals = numAnimals + cluster.numAnimals
                end
            end
        end
    end

    return numAnimals
end

function PlayerLivestockDriver:getUsePlayerLoadMode(controller)
    return self:getIsPlayerCarrierController(controller) and controller.husbandry ~= nil and not self:getIsExtendedProductionController(controller)
end

function PlayerLivestockDriver:getMoveObjects(husbandry, direction, farmId, targetObject)
    local carrier = self:getCarrier(farmId)
    if direction == PlayerLivestockDriverMoveEvent.DIRECTION_TO_CARRIER then
        return husbandry, carrier
    elseif direction == PlayerLivestockDriverMoveEvent.DIRECTION_TO_TRAILER then
        return carrier, targetObject
    elseif direction == PlayerLivestockDriverMoveEvent.DIRECTION_FROM_TRAILER then
        return husbandry, carrier
    end

    return carrier, husbandry
end

function PlayerLivestockDriver:canFarmAccess(farmId, object)
    if object == nil then
        return false
    end

    if object.isPlayerLivestockCarrier then
        return object:getOwnerFarmId() == farmId
    end

    return g_currentMission.accessHandler:canFarmAccess(farmId, object)
end

function PlayerLivestockDriver:validateMove(sourceObject, targetObject, clusterId, numAnimals, farmId)
    if sourceObject == nil then
        return AnimalMoveEvent.MOVE_ERROR_SOURCE_OBJECT_DOES_NOT_EXIST
    elseif targetObject == nil then
        return AnimalMoveEvent.MOVE_ERROR_TARGET_OBJECT_DOES_NOT_EXIST
    elseif not self:canFarmAccess(farmId, sourceObject) or not self:canFarmAccess(farmId, targetObject) then
        return AnimalMoveEvent.MOVE_ERROR_NO_PERMISSION
    end

    local cluster = sourceObject:getClusterById(clusterId)
    if cluster == nil then
        return AnimalMoveEvent.MOVE_ERROR_INVALID_CLUSTER
    elseif cluster:getNumAnimals() < numAnimals then
        return AnimalMoveEvent.MOVE_ERROR_NOT_ENOUGH_ANIMALS
    elseif not targetObject:getSupportsAnimalSubType(cluster:getSubTypeIndex()) then
        return AnimalMoveEvent.MOVE_ERROR_ANIMAL_NOT_SUPPORTED
    elseif targetObject:getNumOfFreeAnimalSlots(cluster:getSubTypeIndex()) < numAnimals then
        return AnimalMoveEvent.MOVE_ERROR_NOT_ENOUGH_SPACE
    end

    return nil
end

function PlayerLivestockDriver:serverMoveAnimals(farmId, husbandry, clusterId, numAnimals, direction, moveTargetObject)
    local sourceObject, targetObject = self:getMoveObjects(husbandry, direction, farmId, moveTargetObject)
    local errorCode = self:validateMove(sourceObject, targetObject, clusterId, numAnimals, farmId)
    if errorCode ~= nil then
        return errorCode
    end

    local sourceCluster = sourceObject:getClusterById(clusterId)
    local newCluster = sourceCluster:clone()
    newCluster:changeNumAnimals(numAnimals)
    targetObject:addCluster(newCluster)

    if sourceObject.isPlayerLivestockCarrier then
        sourceObject:removeAnimalsFromCluster(clusterId, numAnimals)
        sourceObject:onClustersChanged()
    else
        sourceCluster:changeNumAnimals(-numAnimals)
        sourceObject:getClusterSystem():updateNow()
    end

    if targetObject.isPlayerLivestockCarrier then
        targetObject:onClustersChanged()
    else
        targetObject:getClusterSystem():updateNow()
    end

    return AnimalMoveEvent.MOVE_SUCCESS
end

function PlayerLivestockDriver:sendCarrierSync(farmId, connection)
    if g_server == nil then
        return
    end

    local carrier = self:getCarrier(farmId)
    local event = PlayerLivestockDriverSyncEvent.new(farmId, carrier:getClusters())

    if connection ~= nil then
        connection:sendEvent(event)
    else
        g_server:broadcastEvent(event, true)
    end
end

function PlayerLivestockDriver:openAnimalMenu(superFunc, trigger)
    if trigger.husbandry ~= nil and trigger.loadingVehicle == nil and trigger.isPlayerInRange and self:getIsPlayerDriverActive() then
        local carrier = self:getCarrier(self:getFarmId())

        if carrier:getNumOfAnimals() > 0 then
            carrier:setLoadingTrigger(trigger)
            AnimalScreen.show(trigger.husbandry, carrier, trigger.isDealer)
            trigger.activatedTarget = carrier
            return
        end

        carrier:setLoadingTrigger(nil)
    end

    return superFunc(trigger)
end

function PlayerLivestockDriver:updateExtendedProductionLoadingTrailer(trigger)
    if not self:getIsExtendedProductionTrigger(trigger) or not self:getIsPlayerDriverActive() then
        return
    end

    local carrier = self:getCarrier(self:getFarmId())
    local hasCarrierAnimals = carrier ~= nil and carrier:getNumOfAnimals() > 0

    if trigger.isPlayerInRange and hasCarrierAnimals then
        if trigger.loadingVehicle == nil or (trigger.loadingVehicle.isPlayerLivestockCarrier and trigger.loadingVehicle ~= carrier) then
            trigger:setLoadingTrailer(carrier)
        end
    elseif trigger.loadingVehicle ~= nil and trigger.loadingVehicle.isPlayerLivestockCarrier then
        trigger:setLoadingTrailer(nil)
    end
end

function PlayerLivestockDriver:onLoadingTriggerCallback(superFunc, trigger, triggerId, otherId, onEnter, onLeave, onStay)
    local result = superFunc(trigger, triggerId, otherId, onEnter, onLeave, onStay)

    if g_localPlayer ~= nil and otherId == g_localPlayer.rootNode then
        if onEnter then
            self.playerLoadingTrigger = trigger
        elseif onLeave and self.playerLoadingTrigger == trigger then
            self.playerLoadingTrigger = nil
        end

        self:updateExtendedProductionLoadingTrailer(trigger)
        self:updateActionEventState()
    end

    return result
end

function PlayerLivestockDriver:getPlayerLoadingTrigger()
    local trigger = self.playerLoadingTrigger
    if trigger ~= nil and trigger.husbandry ~= nil and trigger.isPlayerInRange then
        return trigger
    end

    return nil
end

function PlayerLivestockDriver:getCanOpenPlayerLoadMenu()
    local trigger = self:getPlayerLoadingTrigger()
    if trigger == nil or trigger.loadingVehicle ~= nil then
        return false
    end

    if self:getHasAnimalsInLocalPlayerCarrier() or self:getIsLocalPlayerInVehicle() or self:getIsHerdInputBlocked() then
        return false
    end

    if not self:getIsPlayerDriverActive() then
        return false
    end

    if g_currentMission ~= nil then
        if g_currentMission.getHasPlayerPermission ~= nil and not g_currentMission:getHasPlayerPermission("tradeAnimals") then
            return false
        end

        if trigger.husbandry.getOwnerFarmId ~= nil and trigger.husbandry:getOwnerFarmId() ~= g_currentMission:getFarmId() then
            return false
        end
    end

    return self:getNumAnimalsFromClusters(trigger.husbandry) > 0
end

function PlayerLivestockDriver:openPlayerLoadMenu()
    if not self:getCanOpenPlayerLoadMenu() then
        return
    end

    local trigger = self:getPlayerLoadingTrigger()
    local carrier = self:getCarrier(self:getFarmId())
    carrier:setLoadingTrigger(trigger)
    AnimalScreen.show(trigger.husbandry, carrier, trigger.isDealer)
    trigger.activatedTarget = carrier
end


function PlayerLivestockDriver:getText(name, fallback)
    if g_i18n ~= nil then
        if g_i18n:hasText(name, self.MOD_NAME) then
            return g_i18n:getText(name, self.MOD_NAME)
        end

        if g_i18n:hasText(name) then
            return g_i18n:getText(name)
        end
    end

    return fallback or name
end

function PlayerLivestockDriver:getSourceActionText(superFunc, controller)
    if self:getIsPlayerCarrierController(controller) and not self:getIsExtendedProductionController(controller) then
        return self:getText("button_playerLivestockMoveToPlayer", "Aus dem Stall treiben")
    end

    return superFunc(controller)
end

function PlayerLivestockDriver:getTargetActionText(superFunc, controller)
    if self:getIsPlayerCarrierController(controller) and not self:getIsExtendedProductionController(controller) then
        return self:getText("button_playerLivestockMoveToFarm", "In den Stall treiben")
    end

    return superFunc(controller)
end

function PlayerLivestockDriver:getSourceName(superFunc, controller)
    if self:getIsPlayerCarrierController(controller) and controller.husbandry ~= nil and not self:getIsExtendedProductionController(controller) then
        local name = g_i18n:getText(AnimalScreenTrailerFarm.L10N_SYMBOL.FARM)
        local used = controller.husbandry:getNumOfAnimals()
        local total = controller.husbandry:getMaxNumOfAnimals()
        return string.format("%s (%d / %d)", name, used, total)
    end

    return superFunc(controller)
end

function PlayerLivestockDriver:getTargetName(superFunc, controller)
    if self:getIsPlayerCarrierController(controller) and not self:getIsExtendedProductionController(controller) then
        local used = controller.trailer:getNumOfAnimals()
        local animalType = controller.trailer:getCurrentAnimalType()

        if animalType == nil and controller.husbandry ~= nil then
            animalType = g_currentMission.animalSystem:getTypeByIndex(controller.husbandry:getAnimalTypeIndex())
        end

        local total = controller.trailer:getMaxNumOfAnimals(animalType)
        return string.format("%s (%d / %d)", self:getText("playerLivestockDriver_playerTargetName", "Viehtrieb"), used, total)
    end

    return superFunc(controller)
end

function PlayerLivestockDriver:getApplySourceConfirmationText(superFunc, controller, animalTypeIndex, itemIndex, numItems)
    if self:getIsPlayerCarrierController(controller) and not self:getIsExtendedProductionController(controller) then
        local textKey = numItems == 1 and "playerLivestockDriver_confirmMoveToPlayerSingular" or "playerLivestockDriver_confirmMoveToPlayer"
        local text = self:getText(textKey, "Möchtest du %{numAnimals}d %{animalType}s aus dem Stall treiben?")
        local item = controller.sourceItems[animalTypeIndex] ~= nil and controller.sourceItems[animalTypeIndex][itemIndex] or nil
        if item == nil then
            return text
        end

        return string.namedFormat(text, "numAnimals", numItems, "animalType", item:getTitle() .. ", " .. item:getName())
    end

    return superFunc(controller, animalTypeIndex, itemIndex, numItems)
end

function PlayerLivestockDriver:getApplyTargetConfirmationText(superFunc, controller, animalTypeIndex, itemIndex, numItems)
    if self:getIsPlayerCarrierController(controller) and not self:getIsExtendedProductionController(controller) then
        local textKey = numItems == 1 and "playerLivestockDriver_confirmMoveToFarmSingular" or "playerLivestockDriver_confirmMoveToFarm"
        local text = self:getText(textKey, "Möchtest du %{numAnimals}d %{animalType}s in den Stall treiben?")
        local item = controller.targetItems[itemIndex]
        if item == nil then
            return text
        end

        return string.namedFormat(text, "numAnimals", numItems, "animalType", item:getTitle() .. ", " .. item:getName())
    end

    return superFunc(controller, animalTypeIndex, itemIndex, numItems)
end

function PlayerLivestockDriver:addClusterItemsByAnimalType(itemsByType, clusters, defaultAnimalTypeIndex)
    if clusters == nil then
        return
    end

    for _, cluster in ipairs(clusters) do
        local subType = g_currentMission.animalSystem:getSubTypeByIndex(cluster:getSubTypeIndex())
        local animalTypeIndex = subType ~= nil and subType.typeIndex or defaultAnimalTypeIndex
        local item = AnimalItemStock.new(cluster)
        if itemsByType[animalTypeIndex] == nil then
            itemsByType[animalTypeIndex] = {}
        end

        table.insert(itemsByType[animalTypeIndex], item)
    end
end

function PlayerLivestockDriver:initSourceItems(superFunc, controller)
    if self:getUsePlayerLoadMode(controller) then
        controller.sourceItems = {}
        self:addClusterItemsByAnimalType(controller.sourceItems, controller.husbandry:getClusters(), controller.husbandry:getAnimalTypeIndex())
        return
    end

    return superFunc(controller)
end

function PlayerLivestockDriver:initTargetItems(superFunc, controller)
    if self:getIsPlayerCarrierController(controller) and not self:getIsExtendedProductionController(controller) then
        controller.targetItems = {}
        local clusters = controller.trailer:getClusters()
        if clusters ~= nil then
            for _, cluster in ipairs(clusters) do
                table.insert(controller.targetItems, AnimalItemStock.new(cluster))
            end
        end

        return
    end

    return superFunc(controller)
end

function PlayerLivestockDriver:getSourceAnimalTypes(superFunc, controller)
    if self:getUsePlayerLoadMode(controller) then
        local animalTypes = {}
        for animalTypeIndex, _ in pairs(controller.sourceItems or {}) do
            local animalType = g_currentMission.animalSystem:getTypeByIndex(animalTypeIndex)
            if animalType ~= nil then
                table.insert(animalTypes, animalType)
            end
        end

        if #animalTypes == 0 and controller.husbandry ~= nil then
            local animalType = g_currentMission.animalSystem:getTypeByIndex(controller.husbandry:getAnimalTypeIndex())
            if animalType ~= nil then
                table.insert(animalTypes, animalType)
            end
        end

        table.sort(animalTypes, function(a, b)
            return (a.typeIndex or 0) < (b.typeIndex or 0)
        end)

        return animalTypes
    end

    return superFunc(controller)
end

function PlayerLivestockDriver:getSourceMaxNumAnimals(superFunc, controller, animalTypeIndex, itemIndex)
    if self:getUsePlayerLoadMode(controller) then
        if controller.sourceItems[animalTypeIndex] == nil then
            return 0
        end

        local item = controller.sourceItems[animalTypeIndex][itemIndex]
        if item == nil then
            return 0
        end

        return math.min(controller:getMaxNumAnimals(), item:getNumAnimals(), controller.trailer:getNumOfFreeAnimalSlots(item:getSubTypeIndex()))
    end

    return superFunc(controller, animalTypeIndex, itemIndex)
end

function PlayerLivestockDriver:getTargetMaxNumAnimals(superFunc, controller, itemIndex)
    if self:getIsPlayerCarrierController(controller) and not self:getIsExtendedProductionController(controller) then
        local item = controller.targetItems[itemIndex]
        if item == nil then
            return 0
        end

        return math.min(controller:getMaxNumAnimals(), item:getNumAnimals(), controller.husbandry:getNumOfFreeAnimalSlots(item:getSubTypeIndex()))
    end

    return superFunc(controller, itemIndex)
end

function AnimalScreenTrailerFarm:onPlayerLivestockMovedToPlayerFromSource(errorCode)
    g_messageCenter:unsubscribe(AnimalMoveEvent, self)
    self.actionTypeCallback(AnimalScreenBase.ACTION_TYPE_NONE, nil)

    local data = AnimalScreenTrailerFarm.MOVE_TO_TRAILER_ERROR_CODE_MAPPING[errorCode]
    self.sourceActionFinished(data.isWarning, g_i18n:getText(data.text))
end

function AnimalScreenTrailerFarm:onPlayerLivestockMovedToFarmFromTarget(errorCode)
    g_messageCenter:unsubscribe(AnimalMoveEvent, self)
    self.actionTypeCallback(AnimalScreenBase.ACTION_TYPE_NONE, nil)

    local data = AnimalScreenTrailerFarm.MOVE_TO_FARM_ERROR_CODE_MAPPING[errorCode]
    self.targetActionFinished(data.isWarning, g_i18n:getText(data.text))
end

function PlayerLivestockDriver:applyTarget(superFunc, controller, animalTypeIndex, itemIndex, numItems)
    if not self:getIsPlayerCarrierController(controller) or self:getIsExtendedProductionController(controller) then
        return superFunc(controller, animalTypeIndex, itemIndex, numItems)
    end

    local item = controller.targetItems[itemIndex]
    local clusterId = item ~= nil and item:getClusterId() or nil
    local direction = PlayerLivestockDriverMoveEvent.DIRECTION_TO_HUSBANDRY
    local sourceObject, targetObject = self:getMoveObjects(controller.husbandry, direction, controller.trailer:getOwnerFarmId())
    local errorCode = self:validateMove(sourceObject, targetObject, clusterId, numItems, controller.trailer:getOwnerFarmId())
    if errorCode ~= nil then
        local data = AnimalScreenTrailerFarm.MOVE_TO_FARM_ERROR_CODE_MAPPING[errorCode]
        controller.errorCallback(g_i18n:getText(data.text))
        return false
    end

    controller.actionTypeCallback(AnimalScreenBase.ACTION_TYPE_TARGET, self:getTargetActionText(function(c) return g_i18n:getText(AnimalScreenTrailerFarm.L10N_SYMBOL.MOVE_TO_FARM) end, controller))
    g_messageCenter:subscribe(AnimalMoveEvent, controller.onPlayerLivestockMovedToFarmFromTarget, controller)
    g_client:getServerConnection():sendEvent(PlayerLivestockDriverMoveEvent.new(controller.husbandry, clusterId, numItems, direction))
    return true
end

function PlayerLivestockDriver:applySource(superFunc, controller, animalTypeIndex, itemIndex, numItems)
    if not self:getIsPlayerCarrierController(controller) then
        return superFunc(controller, animalTypeIndex, itemIndex, numItems)
    end

    local item = controller.sourceItems[animalTypeIndex] ~= nil and controller.sourceItems[animalTypeIndex][itemIndex] or nil
    local clusterId = item ~= nil and item:getClusterId() or nil

    if self:getIsExtendedProductionController(controller) then
        local direction = PlayerLivestockDriverMoveEvent.DIRECTION_TO_HUSBANDRY
        local sourceObject, targetObject = self:getMoveObjects(controller.husbandry, direction, controller.trailer:getOwnerFarmId())
        local errorCode = self:validateMove(sourceObject, targetObject, clusterId, numItems, controller.trailer:getOwnerFarmId())

        if errorCode ~= nil then
            local data = AnimalScreenTrailerFarm.MOVE_TO_FARM_ERROR_CODE_MAPPING[errorCode]
            controller.errorCallback(g_i18n:getText(data.text))
            return false
        end

        local actionText = controller.getSourceActionText ~= nil and controller:getSourceActionText() or g_i18n:getText(AnimalScreenTrailerFarm.L10N_SYMBOL.MOVE_TO_FARM)
        controller.actionTypeCallback(AnimalScreenBase.ACTION_TYPE_SOURCE, actionText)
        g_messageCenter:subscribe(AnimalMoveEvent, controller.onAnimalMovedToFarm, controller)
        g_client:getServerConnection():sendEvent(PlayerLivestockDriverMoveEvent.new(controller.husbandry, clusterId, numItems, direction))
        return true
    end

    local direction = PlayerLivestockDriverMoveEvent.DIRECTION_TO_CARRIER
    local sourceObject, targetObject = self:getMoveObjects(controller.husbandry, direction, controller.trailer:getOwnerFarmId())
    local errorCode = self:validateMove(sourceObject, targetObject, clusterId, numItems, controller.trailer:getOwnerFarmId())

    if errorCode ~= nil then
        local data = AnimalScreenTrailerFarm.MOVE_TO_TRAILER_ERROR_CODE_MAPPING[errorCode]
        controller.errorCallback(g_i18n:getText(data.text))
        return false
    end

    controller.actionTypeCallback(AnimalScreenBase.ACTION_TYPE_SOURCE, self:getSourceActionText(function(c) return g_i18n:getText(AnimalScreenTrailerFarm.L10N_SYMBOL.MOVE_TO_TRAILER) end, controller))
    g_messageCenter:subscribe(AnimalMoveEvent, controller.onPlayerLivestockMovedToPlayerFromSource, controller)
    g_client:getServerConnection():sendEvent(PlayerLivestockDriverMoveEvent.new(controller.husbandry, clusterId, numItems, direction))
    return true
end

function PlayerLivestockDriver:getIsLivestockTrailerCandidate(trailer)
    return trailer ~= nil
        and trailer.spec_livestockTrailer ~= nil
        and trailer.getNumOfFreeAnimalSlots ~= nil
        and trailer.getSupportsAnimalSubType ~= nil
        and trailer.addCluster ~= nil
        and trailer.getClusterSystem ~= nil
end

function PlayerLivestockDriver:getLivestockTrailerSearchList()
    if g_currentMission ~= nil and g_currentMission.husbandrySystem ~= nil and g_currentMission.husbandrySystem.livestockTrailers ~= nil then
        return g_currentMission.husbandrySystem.livestockTrailers
    end

    if g_currentMission ~= nil and g_currentMission.vehicleSystem ~= nil then
        return g_currentMission.vehicleSystem.vehicles
    end

    return nil
end

function PlayerLivestockDriver:getDistanceToLivestockTrailer(playerNode, trailer)
    local bestDistance = math.huge
    local spec = trailer ~= nil and trailer.spec_livestockTrailer or nil

    if spec ~= nil and spec.triggerNode ~= nil and spec.triggerNode ~= 0 and entityExists(spec.triggerNode) then
        bestDistance = math.min(bestDistance, calcDistanceFrom(playerNode, spec.triggerNode))
    end

    if trailer ~= nil and trailer.rootNode ~= nil and trailer.rootNode ~= 0 and entityExists(trailer.rootNode) then
        bestDistance = math.min(bestDistance, calcDistanceFrom(playerNode, trailer.rootNode))
    end

    return bestDistance
end

function PlayerLivestockDriver:findNearbyLivestockTrailer()
    if g_localPlayer == nil or g_localPlayer.rootNode == nil then
        return nil
    end

    local trailers = self:getLivestockTrailerSearchList()
    if trailers == nil then
        return nil
    end

    local playerNode = g_localPlayer.rootNode
    local bestTrailer = nil
    local bestDistance = 12

    for _, trailer in pairs(trailers) do
        if self:getIsLivestockTrailerCandidate(trailer) then
            local distance = self:getDistanceToLivestockTrailer(playerNode, trailer)
            if distance < bestDistance then
                bestTrailer = trailer
                bestDistance = distance
            end
        end
    end

    return bestTrailer
end

function PlayerLivestockDriver:getPlayerLivestockTrailer()
    local trailer = self.playerLivestockTrailer
    if self:getIsLivestockTrailerCandidate(trailer) then
        if g_localPlayer ~= nil and g_localPlayer.rootNode ~= nil and self:getDistanceToLivestockTrailer(g_localPlayer.rootNode, trailer) < 14 then
            return trailer
        end

        self.playerLivestockTrailer = nil
    end

    trailer = self:findNearbyLivestockTrailer()
    if trailer ~= nil then
        self.playerLivestockTrailer = trailer
        return trailer
    end

    return nil
end

function PlayerLivestockDriver:collectTrailerLoadMoves(trailer, carrier)
    local moves = {}
    local total = 0
    local freeByTypeIndex = {}

    if trailer == nil or carrier == nil then
        return moves, total
    end

    for _, cluster in ipairs(carrier:getClusters()) do
        local subTypeIndex = cluster:getSubTypeIndex()
        if trailer:getSupportsAnimalSubType(subTypeIndex) then
            local subType = g_currentMission.animalSystem:getSubTypeByIndex(subTypeIndex)
            local typeIndex = subType ~= nil and subType.typeIndex or subTypeIndex
            local freeSlots = freeByTypeIndex[typeIndex]

            if freeSlots == nil then
                freeSlots = math.max(trailer:getNumOfFreeAnimalSlots(subTypeIndex), 0)
            end

            local numAnimals = math.min(cluster:getNumAnimals(), freeSlots)
            if numAnimals > 0 then
                table.insert(moves, {
                    clusterId = cluster.id,
                    numAnimals = numAnimals
                })

                freeSlots = freeSlots - numAnimals
                freeByTypeIndex[typeIndex] = freeSlots
                total = total + numAnimals
            end
        end
    end

    return moves, total
end

function PlayerLivestockDriver:collectTrailerUnloadMoves(trailer, carrier)
    local moves = {}
    local total = 0
    local freeByTypeIndex = {}

    if trailer == nil or carrier == nil then
        return moves, total
    end

    for _, cluster in ipairs(trailer:getClusters()) do
        local subTypeIndex = cluster:getSubTypeIndex()
        if carrier:getSupportsAnimalSubType(subTypeIndex) then
            local subType = g_currentMission.animalSystem:getSubTypeByIndex(subTypeIndex)
            local typeIndex = subType ~= nil and subType.typeIndex or subTypeIndex
            local freeSlots = freeByTypeIndex[typeIndex]

            if freeSlots == nil then
                freeSlots = math.max(carrier:getNumOfFreeAnimalSlots(subTypeIndex), 0)
            end

            local numAnimals = math.min(cluster:getNumAnimals(), freeSlots)
            if numAnimals > 0 then
                table.insert(moves, {
                    clusterId = cluster.id,
                    numAnimals = numAnimals
                })

                freeSlots = freeSlots - numAnimals
                freeByTypeIndex[typeIndex] = freeSlots
                total = total + numAnimals
            end
        end
    end

    return moves, total
end

function PlayerLivestockDriver:getCanLoadPlayerAnimalsIntoTrailer()
    local trailer = self:getPlayerLivestockTrailer()
    local carrier = self:getCarrier(self:getFarmId())
    if trailer == nil or carrier == nil or carrier:getNumOfAnimals() <= 0 then
        return false
    end

    if self:getIsLocalPlayerInVehicle() or self:getIsHerdInputBlocked() or not self:getIsPlayerDriverActive() then
        return false
    end

    if g_currentMission ~= nil and g_currentMission.getHasPlayerPermission ~= nil and not g_currentMission:getHasPlayerPermission("tradeAnimals") then
        return false
    end

    return true
end

function PlayerLivestockDriver:getCanUnloadTrailerAnimalsToPlayer()
    local trailer = self:getPlayerLivestockTrailer()
    local carrier = self:getCarrier(self:getFarmId())
    if trailer == nil or carrier == nil or trailer:getNumOfAnimals() <= 0 then
        return false
    end

    if self:getIsLocalPlayerInVehicle() or self:getIsHerdInputBlocked() or not self:getIsPlayerDriverActive() then
        return false
    end

    if g_currentMission ~= nil and g_currentMission.getHasPlayerPermission ~= nil and not g_currentMission:getHasPlayerPermission("tradeAnimals") then
        return false
    end

    return true
end

function PlayerLivestockDriver:loadPlayerAnimalsIntoTrailer()
    local trailer = self:getPlayerLivestockTrailer()
    local carrier = self:getCarrier(self:getFarmId())

    if trailer == nil or carrier == nil or carrier:getNumOfAnimals() <= 0 then
        return false
    end

    local moves, total = self:collectTrailerLoadMoves(trailer, carrier)
    if total <= 0 then
        local text = self:getText("playerLivestockDriver_trailerNoSpace", "Der Viehtrailer kann diese Tiere nicht aufnehmen oder ist voll.")
        if g_currentMission ~= nil and g_currentMission.showBlinkingWarning ~= nil then
            g_currentMission:showBlinkingWarning(text, 2500)
        end
        return false
    end

    for _, move in ipairs(moves) do
        g_client:getServerConnection():sendEvent(PlayerLivestockDriverMoveEvent.new(trailer, move.clusterId, move.numAnimals, PlayerLivestockDriverMoveEvent.DIRECTION_TO_TRAILER, trailer))
    end

    if g_currentMission ~= nil and g_currentMission.showBlinkingWarning ~= nil then
        g_currentMission:showBlinkingWarning(self:getText("playerLivestockDriver_loadedToTrailer", "Tiere werden in den Viehtrailer getrieben."), 2000)
    end

    return true
end

function PlayerLivestockDriver:unloadTrailerAnimalsToPlayer()
    local trailer = self:getPlayerLivestockTrailer()
    local carrier = self:getCarrier(self:getFarmId())

    if trailer == nil or carrier == nil or trailer:getNumOfAnimals() <= 0 then
        return false
    end

    local moves, total = self:collectTrailerUnloadMoves(trailer, carrier)
    if total <= 0 then
        local text = self:getText("playerLivestockDriver_trailerNoUnloadSpace", "Diese Tiere koennen gerade nicht zum Spieler getrieben werden oder die Herde ist voll.")
        if g_currentMission ~= nil and g_currentMission.showBlinkingWarning ~= nil then
            g_currentMission:showBlinkingWarning(text, 2500)
        end
        return false
    end

    for _, move in ipairs(moves) do
        g_client:getServerConnection():sendEvent(PlayerLivestockDriverMoveEvent.new(trailer, move.clusterId, move.numAnimals, PlayerLivestockDriverMoveEvent.DIRECTION_FROM_TRAILER))
    end

    if g_currentMission ~= nil and g_currentMission.showBlinkingWarning ~= nil then
        g_currentMission:showBlinkingWarning(self:getText("playerLivestockDriver_unloadedFromTrailer", "Tiere werden aus dem Viehtrailer getrieben."), 2000)
    end

    return true
end

function PlayerLivestockDriver:onInputOpenPlayerLoadMenu()
    if self:getCanLoadPlayerAnimalsIntoTrailer() then
        self:loadPlayerAnimalsIntoTrailer()
        return
    end

    if self:getCanUnloadTrailerAnimalsToPlayer() then
        self:unloadTrailerAnimalsToPlayer()
        return
    end

    self:openPlayerLoadMenu()
end

function PlayerLivestockDriver:onInputToggleWait()
    if not self:getCanUseHerdAction() then
        return
    end

    local carrier = self:getCarrier(self:getFarmId())
    if carrier == nil or carrier:getNumOfAnimals() <= 0 then
        return
    end

    local isWaiting = not carrier:getIsHerdWaiting()
    carrier:setHerdWaiting(isWaiting)
    carrier:playActionSound("call")
    self:updateActionEventState()
end

function PlayerLivestockDriver:onInputToggleHerdMode()
    if not self:getCanUseHerdAction() then
        return
    end

    local carrier = self:getCarrier(self:getFarmId())
    if carrier == nil or carrier:getNumOfAnimals() <= 0 then
        return
    end

    carrier:toggleHerdMode()
    carrier:playActionSound("call")
    self:updateActionEventState()
end

function PlayerLivestockDriver:removeActionEvents()
    if g_inputBinding == nil or PlayerInputComponent == nil then
        return
    end

    g_inputBinding:beginActionEventsModification(PlayerInputComponent.INPUT_CONTEXT_NAME)
    g_inputBinding:removeActionEventsByTarget(self)
    g_inputBinding:endActionEventsModification()
    self.toggleWaitActionEventId = nil
    self.toggleHerdModeActionEventId = nil
    self.openLoadMenuActionEventId = nil
end

function PlayerLivestockDriver:registerActionEvents()
    if g_inputBinding == nil or PlayerInputComponent == nil or InputAction == nil then
        return
    end

    self:removeActionEvents()
    g_inputBinding:beginActionEventsModification(PlayerInputComponent.INPUT_CONTEXT_NAME)

    if InputAction[self.ACTION_OPEN_LOAD_MENU] ~= nil then
        local _, actionEventId = g_inputBinding:registerActionEvent(InputAction[self.ACTION_OPEN_LOAD_MENU], self, self.onInputOpenPlayerLoadMenu, false, true, false, true)
        self.openLoadMenuActionEventId = actionEventId

        if actionEventId ~= nil then
            g_inputBinding:setActionEventTextVisibility(actionEventId, true)
            g_inputBinding:setActionEventTextPriority(actionEventId, GS_PRIO_HIGH)
        end
    end
    if InputAction[self.ACTION_TOGGLE_WAIT] ~= nil then
        local _, actionEventId = g_inputBinding:registerActionEvent(InputAction[self.ACTION_TOGGLE_WAIT], self, self.onInputToggleWait, false, true, false, true)
        self.toggleWaitActionEventId = actionEventId

        if actionEventId ~= nil then
            g_inputBinding:setActionEventTextVisibility(actionEventId, true)
            g_inputBinding:setActionEventTextPriority(actionEventId, GS_PRIO_HIGH)
        end
    end

    if InputAction[self.ACTION_TOGGLE_DRIVE_MODE] ~= nil then
        local _, actionEventId = g_inputBinding:registerActionEvent(InputAction[self.ACTION_TOGGLE_DRIVE_MODE], self, self.onInputToggleHerdMode, false, true, false, true)
        self.toggleHerdModeActionEventId = actionEventId

        if actionEventId ~= nil then
            g_inputBinding:setActionEventTextVisibility(actionEventId, true)
            g_inputBinding:setActionEventTextPriority(actionEventId, GS_PRIO_HIGH)
        end
    end

    g_inputBinding:endActionEventsModification()
    self:updateActionEventState()
end

function PlayerLivestockDriver:onInputBindingsChanged()
    self:registerActionEvents()
end

function PlayerLivestockDriver:updateActionEventState()
    if g_inputBinding == nil then
        return
    end

    local carrier = self:getCarrier(self:getFarmId())
    local hasAnimals = carrier ~= nil and carrier:getNumOfAnimals() > 0
    local canUseAction = hasAnimals and self:getCanUseHerdAction()

    if self.openLoadMenuActionEventId ~= nil then
        local canLoadIntoTrailer = self:getCanLoadPlayerAnimalsIntoTrailer()
        local canUnloadFromTrailer = not canLoadIntoTrailer and self:getCanUnloadTrailerAnimalsToPlayer()
        local canOpenLoadMenu = self:getCanOpenPlayerLoadMenu()
        g_inputBinding:setActionEventActive(self.openLoadMenuActionEventId, canOpenLoadMenu or canLoadIntoTrailer or canUnloadFromTrailer)

        if canLoadIntoTrailer then
            g_inputBinding:setActionEventText(self.openLoadMenuActionEventId, self:getText("button_playerLivestockMoveToTrailer", "In Viehtrailer treiben"))
        elseif canUnloadFromTrailer then
            g_inputBinding:setActionEventText(self.openLoadMenuActionEventId, self:getText("button_playerLivestockMoveFromTrailer", "Aus Viehtrailer treiben"))
        else
            g_inputBinding:setActionEventText(self.openLoadMenuActionEventId, self:getText("button_playerLivestockMoveToPlayer", "Aus dem Stall treiben"))
        end
    end
    if self.toggleWaitActionEventId ~= nil then
        local textKey = hasAnimals and carrier:getIsHerdWaiting() and "button_playerLivestockFollow" or "button_playerLivestockWait"
        local fallback = hasAnimals and carrier:getIsHerdWaiting() and "Herde rufen" or "Herde warten lassen"
        g_inputBinding:setActionEventActive(self.toggleWaitActionEventId, canUseAction)
        g_inputBinding:setActionEventText(self.toggleWaitActionEventId, self:getText(textKey, fallback))
    end

    if self.toggleHerdModeActionEventId ~= nil then
        local textKey = hasAnimals and carrier:getIsDriveMode() and "button_playerLivestockModeFollow" or "button_playerLivestockModeDrive"
        local fallback = hasAnimals and carrier:getIsDriveMode() and "Tiere folgen lassen" or "Tiere vorantreiben"
        g_inputBinding:setActionEventActive(self.toggleHerdModeActionEventId, canUseAction)
        g_inputBinding:setActionEventText(self.toggleHerdModeActionEventId, self:getText(textKey, fallback))
    end
end

function PlayerLivestockDriver:getCurrentMissionTime()
    if g_currentMission ~= nil and g_currentMission.time ~= nil then
        return g_currentMission.time
    end

    return g_time or 0
end

function PlayerLivestockDriver:blockHerdInputAfterVehicleChange()
    self.herdInputBlockedUntil = self:getCurrentMissionTime() + self.INPUT_BLOCK_AFTER_VEHICLE_MS
    local carrier = self:getCarrier(self:getFarmId())
    if carrier ~= nil and carrier.stopActionSounds ~= nil then
        carrier:stopActionSounds()
    end
    self:updateActionEventState()
end

function PlayerLivestockDriver:getIsHerdInputBlocked()
    return (self.herdInputBlockedUntil or 0) > self:getCurrentMissionTime()
end

function PlayerLivestockDriver:getIsLocalPlayerInVehicle()
    return g_localPlayer ~= nil and g_localPlayer.getIsInVehicle ~= nil and g_localPlayer:getIsInVehicle()
end

function PlayerLivestockDriver:getCanUseHerdAction()
    return self:getHasAnimalsInLocalPlayerCarrier() and not self:getIsLocalPlayerInVehicle() and not self:getIsHerdInputBlocked()
end

function PlayerLivestockDriver:onVehiclePlayerEntered(vehicle, player)
    if player == nil or player == g_localPlayer then
        self:blockHerdInputAfterVehicleChange()
    end
end

function PlayerLivestockDriver:onVehiclePlayerLeft(vehicle, player)
    if player == nil or player == g_localPlayer then
        self:blockHerdInputAfterVehicleChange()
    end
end

function PlayerLivestockDriver:onLivestockTrailerLoadTriggerCallback(superFunc, trailer, triggerId, otherId, onEnter, onLeave, onStay)
    local result = superFunc(trailer, triggerId, otherId, onEnter, onLeave, onStay)

    local isLocalPlayer = g_localPlayer ~= nil and otherId == g_localPlayer.rootNode
    if not isLocalPlayer and g_currentMission ~= nil and g_currentMission.players ~= nil then
        isLocalPlayer = g_currentMission.players[otherId] == g_localPlayer
    end

    if isLocalPlayer then
        if onEnter or onStay then
            self.playerLivestockTrailer = trailer
        elseif onLeave and self.playerLivestockTrailer == trailer then
            self.playerLivestockTrailer = nil
        end

        self:updateActionEventState()
    end

    return result
end

function PlayerLivestockDriver:update(dt)
    local carrier = self:getCarrier(self:getFarmId())
    if carrier ~= nil then
        carrier:updateVisuals(dt)

        if carrier:getNumOfAnimals() <= 0 and carrier.actionSoundSamplesLoaded then
            carrier:deleteActionSounds()
        end
    end

    self:updateActionEventState()
end

function PlayerLivestockDriver:deleteMap()
    self:removeActionEvents()

    if g_messageCenter ~= nil and MessageType ~= nil then
        if MessageType.VEHICLE_PLAYER_ENTERED ~= nil then
            g_messageCenter:unsubscribe(MessageType.VEHICLE_PLAYER_ENTERED, self)
        end

        if MessageType.VEHICLE_PLAYER_LEFT ~= nil then
            g_messageCenter:unsubscribe(MessageType.VEHICLE_PLAYER_LEFT, self)
        end
    end

    if self.carriers ~= nil then
        for _, carrier in pairs(self.carriers) do
            carrier:delete()
        end
    end

    self.carriers = {}
    self.playerLivestockTrailer = nil
end

function PlayerLivestockDriver:getActiveCarrierAnimalCount()
    local count = 0
    for _, carrier in pairs(self.carriers or {}) do
        if carrier ~= nil and carrier.getNumOfAnimals ~= nil then
            count = count + carrier:getNumOfAnimals()
        end
    end

    return count
end

function PlayerLivestockDriver:getHasAnimalsInPlayerCarrier()
    return self:getActiveCarrierAnimalCount() > 0
end

function PlayerLivestockDriver:getHasAnimalsInLocalPlayerCarrier()
    local carrier = self:getCarrier(self:getFarmId())
    return carrier ~= nil and carrier:getNumOfAnimals() > 0
end

function PlayerLivestockDriver:showSaveBlockedMessage()
    local text = self:getText("playerLivestockDriver_saveBlocked", "Du führst gerade Tiere. Gib sie zuerst an einem Stall oder Tiertrigger ab, bevor du speicherst.")
    if InfoDialog ~= nil and g_dedicatedServer == nil then
        InfoDialog.show(text)
    else
        Logging.warning("[%s] %s", self.MOD_NAME, text)
    end
end

function PlayerLivestockDriver:showVehicleBlockedWarning()
    local text = self:getText("playerLivestockDriver_vehicleBlocked", "Du führst gerade Tiere. Gib sie zuerst an einem Stall oder Tiertrigger ab, bevor du in ein Fahrzeug steigst.")
    if g_currentMission ~= nil and g_currentMission.showBlinkingWarning ~= nil then
        g_currentMission:showBlinkingWarning(text, 2500)
    elseif InfoDialog ~= nil and g_dedicatedServer == nil then
        InfoDialog.show(text)
    else
        Logging.warning("[%s] %s", self.MOD_NAME, text)
    end
end

function PlayerLivestockDriver:onInputEnter(superFunc, inputComponent, ...)
    if self:getHasAnimalsInLocalPlayerCarrier() then
        self:showVehicleBlockedWarning()
        return
    end

    return superFunc(inputComponent, ...)
end

function PlayerLivestockDriver:onInputSwitchVehicle(superFunc, inputComponent, ...)
    if self:getHasAnimalsInLocalPlayerCarrier() then
        self:showVehicleBlockedWarning()
        return
    end

    return superFunc(inputComponent, ...)
end

function PlayerLivestockDriver:onButtonSaveGame(superFunc, menu)
    if self:getHasAnimalsInPlayerCarrier() then
        self:showSaveBlockedMessage()
        return
    end

    return superFunc(menu)
end

function PlayerLivestockDriver:startSaveCurrentGame(superFunc, mission, hiddenUI, blocking)
    if self:getHasAnimalsInPlayerCarrier() then
        self:showSaveBlockedMessage()
        return
    end

    return superFunc(mission, hiddenUI, blocking)
end

function PlayerLivestockDriver:saveSavegame(superFunc, mission, blocking)
    if self:getHasAnimalsInPlayerCarrier() then
        self:showSaveBlockedMessage()
        if mission ~= nil then
            mission.doSaveGameState = SavegameController.SAVE_STATE_NONE
            mission.doSaveGameBlocking = nil
        end
        return
    end

    return superFunc(mission, blocking)
end

function PlayerLivestockDriver:onMissionLoaded()
    if g_currentMission ~= nil and not g_currentMission:getHasUpdateable(self) then
        g_currentMission:addUpdateable(self)
    end

    self:registerActionEvents()
end

function PlayerLivestockDriver.install()
    if PlayerLivestockDriver.installed then
        return
    end

    PlayerLivestockDriver.installed = true

    AnimalLoadingTrigger.openAnimalMenu = Utils.overwrittenFunction(AnimalLoadingTrigger.openAnimalMenu, function(trigger, superFunc)
        return PlayerLivestockDriver:openAnimalMenu(superFunc, trigger)
    end)

    AnimalLoadingTrigger.triggerCallback = Utils.overwrittenFunction(AnimalLoadingTrigger.triggerCallback, function(trigger, superFunc, triggerId, otherId, onEnter, onLeave, onStay)
        return PlayerLivestockDriver:onLoadingTriggerCallback(superFunc, trigger, triggerId, otherId, onEnter, onLeave, onStay)
    end)

    AnimalScreenTrailerFarm.initSourceItems = Utils.overwrittenFunction(AnimalScreenTrailerFarm.initSourceItems, function(controller, superFunc)
        return PlayerLivestockDriver:initSourceItems(superFunc, controller)
    end)

    AnimalScreenTrailerFarm.initTargetItems = Utils.overwrittenFunction(AnimalScreenTrailerFarm.initTargetItems, function(controller, superFunc)
        return PlayerLivestockDriver:initTargetItems(superFunc, controller)
    end)

    AnimalScreenTrailerFarm.getSourceAnimalTypes = Utils.overwrittenFunction(AnimalScreenTrailerFarm.getSourceAnimalTypes, function(controller, superFunc)
        return PlayerLivestockDriver:getSourceAnimalTypes(superFunc, controller)
    end)

    AnimalScreenTrailerFarm.getSourceActionText = Utils.overwrittenFunction(AnimalScreenTrailerFarm.getSourceActionText, function(controller, superFunc)
        return PlayerLivestockDriver:getSourceActionText(superFunc, controller)
    end)

    AnimalScreenTrailerFarm.getSourceName = Utils.overwrittenFunction(AnimalScreenTrailerFarm.getSourceName, function(controller, superFunc)
        return PlayerLivestockDriver:getSourceName(superFunc, controller)
    end)

    AnimalScreenTrailerFarm.getTargetName = Utils.overwrittenFunction(AnimalScreenTrailerFarm.getTargetName, function(controller, superFunc)
        return PlayerLivestockDriver:getTargetName(superFunc, controller)
    end)

    AnimalScreenTrailerFarm.getTargetActionText = Utils.overwrittenFunction(AnimalScreenTrailerFarm.getTargetActionText, function(controller, superFunc)
        return PlayerLivestockDriver:getTargetActionText(superFunc, controller)
    end)

    AnimalScreenTrailerFarm.getApplySourceConfirmationText = Utils.overwrittenFunction(AnimalScreenTrailerFarm.getApplySourceConfirmationText, function(controller, superFunc, animalTypeIndex, itemIndex, numItems)
        return PlayerLivestockDriver:getApplySourceConfirmationText(superFunc, controller, animalTypeIndex, itemIndex, numItems)
    end)

    AnimalScreenTrailerFarm.getApplyTargetConfirmationText = Utils.overwrittenFunction(AnimalScreenTrailerFarm.getApplyTargetConfirmationText, function(controller, superFunc, animalTypeIndex, itemIndex, numItems)
        return PlayerLivestockDriver:getApplyTargetConfirmationText(superFunc, controller, animalTypeIndex, itemIndex, numItems)
    end)

    AnimalScreenTrailerFarm.getSourceMaxNumAnimals = Utils.overwrittenFunction(AnimalScreenTrailerFarm.getSourceMaxNumAnimals, function(controller, superFunc, animalTypeIndex, itemIndex)
        return PlayerLivestockDriver:getSourceMaxNumAnimals(superFunc, controller, animalTypeIndex, itemIndex)
    end)

    AnimalScreenTrailerFarm.getTargetMaxNumAnimals = Utils.overwrittenFunction(AnimalScreenTrailerFarm.getTargetMaxNumAnimals, function(controller, superFunc, itemIndex)
        return PlayerLivestockDriver:getTargetMaxNumAnimals(superFunc, controller, itemIndex)
    end)

    AnimalScreenTrailerFarm.applyTarget = Utils.overwrittenFunction(AnimalScreenTrailerFarm.applyTarget, function(controller, superFunc, animalTypeIndex, itemIndex, numItems)
        return PlayerLivestockDriver:applyTarget(superFunc, controller, animalTypeIndex, itemIndex, numItems)
    end)

    AnimalScreenTrailerFarm.applySource = Utils.overwrittenFunction(AnimalScreenTrailerFarm.applySource, function(controller, superFunc, animalTypeIndex, itemIndex, numItems)
        return PlayerLivestockDriver:applySource(superFunc, controller, animalTypeIndex, itemIndex, numItems)
    end)

    PlayerInputComponent.onInputEnter = Utils.overwrittenFunction(PlayerInputComponent.onInputEnter, function(inputComponent, superFunc, ...)
        return PlayerLivestockDriver:onInputEnter(superFunc, inputComponent, ...)
    end)

    PlayerInputComponent.onInputSwitchVehicle = Utils.overwrittenFunction(PlayerInputComponent.onInputSwitchVehicle, function(inputComponent, superFunc, ...)
        return PlayerLivestockDriver:onInputSwitchVehicle(superFunc, inputComponent, ...)
    end)

    if LivestockTrailer ~= nil and LivestockTrailer.onAnimalLoadTriggerCallback ~= nil then
        LivestockTrailer.onAnimalLoadTriggerCallback = Utils.overwrittenFunction(LivestockTrailer.onAnimalLoadTriggerCallback, function(trailer, superFunc, triggerId, otherId, onEnter, onLeave, onStay)
            return PlayerLivestockDriver:onLivestockTrailerLoadTriggerCallback(superFunc, trailer, triggerId, otherId, onEnter, onLeave, onStay)
        end)
    end

    if g_messageCenter ~= nil and MessageType ~= nil then
        if MessageType.INPUT_BINDINGS_CHANGED ~= nil then
            g_messageCenter:subscribe(MessageType.INPUT_BINDINGS_CHANGED, PlayerLivestockDriver.onInputBindingsChanged, PlayerLivestockDriver)
        end

        if MessageType.VEHICLE_PLAYER_ENTERED ~= nil then
            g_messageCenter:subscribe(MessageType.VEHICLE_PLAYER_ENTERED, PlayerLivestockDriver.onVehiclePlayerEntered, PlayerLivestockDriver)
        end

        if MessageType.VEHICLE_PLAYER_LEFT ~= nil then
            g_messageCenter:subscribe(MessageType.VEHICLE_PLAYER_LEFT, PlayerLivestockDriver.onVehiclePlayerLeft, PlayerLivestockDriver)
        end
    end

    BaseMission.loadMapFinished = Utils.appendedFunction(BaseMission.loadMapFinished, function()
        PlayerLivestockDriver:onMissionLoaded()
    end)

    BaseMission.delete = Utils.prependedFunction(BaseMission.delete, function()
        PlayerLivestockDriver:deleteMap()
    end)

    InGameMenu.onButtonSaveGame = Utils.overwrittenFunction(InGameMenu.onButtonSaveGame, function(menu, superFunc)
        return PlayerLivestockDriver:onButtonSaveGame(superFunc, menu)
    end)

    FSBaseMission.startSaveCurrentGame = Utils.overwrittenFunction(FSBaseMission.startSaveCurrentGame, function(mission, superFunc, hiddenUI, blocking)
        return PlayerLivestockDriver:startSaveCurrentGame(superFunc, mission, hiddenUI, blocking)
    end)

    FSBaseMission.saveSavegame = Utils.overwrittenFunction(FSBaseMission.saveSavegame, function(mission, superFunc, blocking)
        return PlayerLivestockDriver:saveSavegame(superFunc, mission, blocking)
    end)

end

PlayerLivestockDriver.install()

















