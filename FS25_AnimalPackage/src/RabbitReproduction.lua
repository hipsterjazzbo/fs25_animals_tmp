RabbitReproduction = {}

-- A script beállítja, hogy a nyulak szaporodásakor 50-50% eséllyel hím vagy nőstény szülessen.
function RabbitReproduction.updateReproduction(self, superFunc)
    if not g_server then
        return superFunc(self)
    end
    
    local animalSystem = g_currentMission.animalSystem
    local subType = animalSystem:getSubTypeByIndex(self:getSubTypeIndex())
    
    if subType ~= nil and subType.name == "RABBIT_FEMALE" then
        if self:getCanReproduce() then
            local reproductionDelta = self:getReproductionDelta(subType.reproductionDurationMonth)
            
            if reproductionDelta > 0 then
                self:changeReproduction(reproductionDelta)
                
                if self.reproduction >= 100 then
                    self.reproduction = 0
                    self:setDirty()
                    
                    local numNewAnimals = self.numAnimals
                    local maleCount = 0
                    local femaleCount = 0
                    
                    for i = 1, numNewAnimals do
                        if math.random() > 0.5 then
                            maleCount = maleCount + 1
                        else
                            femaleCount = femaleCount + 1
                        end
                    end
                    
                    local maleSubTypeIndex = nil
                    local femaleSubTypeIndex = self:getSubTypeIndex()
                    
                    for index, st in pairs(animalSystem.subTypes) do
                        if st.name == "RABBIT_MALE" then
                            maleSubTypeIndex = index
                            break
                        end
                    end
                    
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
    
    return superFunc(self)
end

AnimalCluster.updateReproduction = Utils.overwrittenFunction(AnimalCluster.updateReproduction, RabbitReproduction.updateReproduction)