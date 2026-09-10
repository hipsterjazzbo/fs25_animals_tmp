OtherAnimalsReproduction = {}

-- Ebbe a táblázatba beírjuk az összes állatfajtát, kivéve a nyulakat.
-- Megadjuk, hogy melyik nőstényhez pontosan melyik hím tartozik.
OtherAnimalsReproduction.femaleToMale = {
    -- Baromfik (Tyúkok)
    ["HEN_LOHMANN"] = "ROOSTER_LOHMANN",
    ["HEN_LEGHORN"] = "ROOSTER_LEGHORN",
    ["HEN_PLYMOUTHROCK"] = "ROOSTER_PLYMOUTHROCK",
    ["HEN_BOHUSDAL"] = "ROOSTER_BOHUSDAL",
    
    -- Víziszárnyasok és Pulykák
    ["DUCK_FEMALE"] = "DUCK_MALE",
    ["LIBA"] = "LIBA_HIM",
    ["PULYKA"] = "PULYKA_HIM",
    
    -- Szarvasmarhák (FRISSÍTETT AZONOSÍTÓK!)
    ["COW_HOLSTEIN"] = "BULL_HOLSTEIN",
    ["COW_REDHOLSTEIN"] = "BULL_REDHOLSTEIN",
    ["COW_BROWNSWISS"] = "BULL_HOLSTEIN", -- Mivel külön Brown Swiss bikád nincs
    ["COW_LIMOUSIN"] = "BULL_ANGUS_RED", -- Mivel a kódod szerint ez a párja
    ["COW_ANGUS"] = "BULL_ANGUS_BLACK",
    ["COW_WATERBUFFALO"] = "BULL_WATERBUFFALO",
    
    -- Sertések
    ["SOW_LANDRACE"] = "BOAR_LANDRACE",
    ["SOW_PIETRAIN"] = "BOAR_PIETRAIN",
    ["SOW_BERKSHIRE"] = "BOAR_BERKSHIRE",
    
    -- Juhok
    ["EWE_MERINO"] = "RAM_MERINO",
    ["EWE_SUFFOLK"] = "RAM_SUFFOLK",
    ["EWE_MOUNTAINSHEEP"] = "RAM_MOUNTAINSHEEP",
    
    -- Kecskék
    ["DOE_THURINGIAN"] = "BUCK_THURINGIAN"
}

function OtherAnimalsReproduction.updateReproduction(self, superFunc)
    if not g_server then
        return superFunc(self)
    end
    
    local animalSystem = g_currentMission.animalSystem
    local subType = animalSystem:getSubTypeByIndex(self:getSubTypeIndex())
    
    -- Megnézzük, hogy az éppen szaporodó állat benne van-e a fenti listában (tehát NEM nyúl)
    if subType ~= nil and OtherAnimalsReproduction.femaleToMale[subType.name] ~= nil then
        if self:getCanReproduce() then
            local reproductionDelta = self:getReproductionDelta(subType.reproductionDurationMonth)
            
            if reproductionDelta > 0 then
                self:changeReproduction(reproductionDelta)
                
                -- Ha a terhesség/tojáskeltetés elérte a 100%-ot
                if self.reproduction >= 100 then
                    self.reproduction = 0
                    self:setDirty()
                    
                    local numNewAnimals = self.numAnimals
                    local maleCount = 0
                    local femaleCount = 0
                    
                    -- 50-50% sorsolás az újszülötteknél
                    for i = 1, numNewAnimals do
                        if math.random() > 0.5 then
                            maleCount = maleCount + 1
                        else
                            femaleCount = femaleCount + 1
                        end
                    end
                    
                    -- Dinamikusan lekérjük, mi a párja (pl. LIBA -> LIBA_HIM)
                    local targetMaleName = OtherAnimalsReproduction.femaleToMale[subType.name]
                    
                    local maleSubTypeIndex = nil
                    local femaleSubTypeIndex = self:getSubTypeIndex()
                    
                    -- Végigpörgetjük a rendszert, hogy megtaláljuk a hím belső azonosítóját
                    for index, st in pairs(animalSystem.subTypes) do
                        if st.name == targetMaleName then
                            maleSubTypeIndex = index
                            break
                        end
                    end
                    
                    -- Hímek hozzáadása
                    if maleCount > 0 and maleSubTypeIndex ~= nil then
                        local maleCluster = animalSystem:createClusterFromSubTypeIndex(maleSubTypeIndex)
                        maleCluster.numAnimals = maleCount
                        maleCluster.age = 0
                        maleCluster.health = self.health
                        maleCluster.reproduction = 0
                        
                        if self.clusterSystem then
                            self.clusterSystem:addPendingAddCluster(maleCluster)
                        end
                    end
                    
                    -- Nőstények hozzáadása
                    if femaleCount > 0 then
                         local femaleCluster = animalSystem:createClusterFromSubTypeIndex(femaleSubTypeIndex)
                         femaleCluster.numAnimals = femaleCount
                         femaleCluster.age = 0
                         femaleCluster.health = self.health
                         femaleCluster.reproduction = 0
                         
                         if self.clusterSystem then
                            self.clusterSystem:addPendingAddCluster(femaleCluster)
                         end
                    end
                    
                    return 0
                end
            end
        end
        return 0
    end
    
    -- Ha az állat nincs a listában (például nyúl), akkor hagyjuk, hogy a nyulas script vagy az alapjáték végezze a dolgát.
    return superFunc(self)
end

AnimalCluster.updateReproduction = Utils.overwrittenFunction(AnimalCluster.updateReproduction, OtherAnimalsReproduction.updateReproduction)