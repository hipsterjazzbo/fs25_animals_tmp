DashboardAlwaysUpdate = {}
DashboardAlwaysUpdate.MOD_NAME = g_currentModName or "unknownMod"

function DashboardAlwaysUpdate.prerequisitesPresent(specializations)
    return SpecializationUtil.hasSpecialization(Dashboard, specializations)
end

function DashboardAlwaysUpdate.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onLoad", DashboardAlwaysUpdate)
    SpecializationUtil.registerEventListener(vehicleType, "onUpdate", DashboardAlwaysUpdate)
end

function DashboardAlwaysUpdate.registerFunctions(vehicleType)
    SpecializationUtil.registerFunction(vehicleType, "lsfmUpdateAllDashboardValueTypes", DashboardAlwaysUpdate.lsfmUpdateAllDashboardValueTypes)
    SpecializationUtil.registerFunction(vehicleType, "lsfmSetAllDashboardValueTypesDirty", DashboardAlwaysUpdate.lsfmSetAllDashboardValueTypesDirty)
    SpecializationUtil.registerFunction(vehicleType, "lsfmRefreshAllDashboardsNow", DashboardAlwaysUpdate.lsfmRefreshAllDashboardsNow)
end

function DashboardAlwaysUpdate.registerOverwrittenFunctions(vehicleType)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "onUpdateTick", DashboardAlwaysUpdate.onUpdateTick)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "onUpdateEnd", DashboardAlwaysUpdate.onUpdateEnd)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "setDashboardsDirty", DashboardAlwaysUpdate.setDashboardsDirty)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "updateDashboardValueType", DashboardAlwaysUpdate.updateDashboardValueType)
end

-- ############################################################
-- Reload-Fix Teil nach Muster vom FillableBucketFix:
-- onLoad nur Flag setzen, eigentliche Korrektur später in onUpdate
-- ############################################################

function DashboardAlwaysUpdate:onLoad(savegame)
    local spec = self.spec_dashboardAlwaysUpdate
    if spec == nil then
        spec = {}
        self.spec_dashboardAlwaysUpdate = spec
    end

    spec.needsInitAfterLoad = true
    spec.delayFrames = 2
    spec.initAttempts = 0
end

function DashboardAlwaysUpdate:onUpdate(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
    if not self.isClient then
        return
    end

    local specFix = self.spec_dashboardAlwaysUpdate
    local specDash = self.spec_dashboard

    if specFix == nil or specDash == nil or not specFix.needsInitAfterLoad then
        return
    end

    -- ein paar Frames warten, damit Savegame/FillUnit/Compounds wirklich da sind
    if specFix.delayFrames ~= nil and specFix.delayFrames > 0 then
        specFix.delayFrames = specFix.delayFrames - 1
        return
    end

    specFix.initAttempts = (specFix.initAttempts or 0) + 1

    -- alles auf dirty setzen
    specDash.isDirty = true
    specDash.isDirtyTick = true
    self:lsfmSetAllDashboardValueTypesDirty()

    -- einmal alles hart anwenden
    self:lsfmRefreshAllDashboardsNow(0, true)

    -- zur Sicherheit noch ein zweites Mal einen Frame später
    if specFix.initAttempts < 2 then
        specFix.delayFrames = 1
        return
    end

    specFix.needsInitAfterLoad = false
end

-- ############################################################
-- bisheriger Always-Update-Teil
-- ############################################################

function DashboardAlwaysUpdate:lsfmUpdateAllDashboardValueTypes(dt, force)
    local spec = self.spec_dashboard

    if spec == nil or spec.dashboardsByValueType == nil then
        return
    end

    for _, dashboards in pairs(spec.dashboardsByValueType) do
        if dashboards ~= nil and #dashboards > 0 then
            self:updateDashboards(dashboards, dt or 0, force == true)
        end
    end
end

function DashboardAlwaysUpdate:lsfmSetAllDashboardValueTypesDirty()
    local spec = self.spec_dashboard

    if spec == nil or spec.dashboardsByValueTypeDirty == nil then
        return
    end

    for valueTypeName, _ in pairs(spec.dashboardsByValueTypeDirty) do
        spec.dashboardsByValueTypeDirty[valueTypeName] = true
    end
end

function DashboardAlwaysUpdate:lsfmRefreshAllDashboardsNow(dt, force)
    local spec = self.spec_dashboard
    if spec == nil then
        return
    end

    dt = dt or 0
    force = force == true

    if spec.groupDashboards ~= nil and #spec.groupDashboards > 0 then
        self:updateDashboards(spec.groupDashboards, dt, force)
    end

    if spec.tickDashboards ~= nil and #spec.tickDashboards > 0 then
        self:updateDashboards(spec.tickDashboards, dt, force)
    end

    if spec.criticalDashboards ~= nil and #spec.criticalDashboards > 0 then
        self:updateDashboards(spec.criticalDashboards, dt, force)
    end

    self:lsfmUpdateAllDashboardValueTypes(dt, force)
end

function DashboardAlwaysUpdate:onUpdateTick(superFunc, dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
    if superFunc ~= nil then
        superFunc(self, dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
    end

    if not self.isClient then
        return
    end

    local spec = self.spec_dashboard
    if spec == nil then
        return
    end

    -- Wie im LS22-Gefühl: valueType-Dashboards permanent nachziehen
    if self.currentUpdateDistance < spec.maxUpdateDistance or spec.isDirtyTick then
        self:lsfmUpdateAllDashboardValueTypes(dt, false)

        if spec.dashboardsByValueTypeDirty ~= nil then
            for valueTypeName, _ in pairs(spec.dashboardsByValueTypeDirty) do
                spec.dashboardsByValueTypeDirty[valueTypeName] = false
            end
        end
    end
end

function DashboardAlwaysUpdate:onUpdateEnd(superFunc, dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
    if superFunc ~= nil then
        superFunc(self, dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
    end

    if not self.isClient then
        return
    end

    -- am Ende nochmal hart anwenden
    self:lsfmRefreshAllDashboardsNow(dt, true)
end

function DashboardAlwaysUpdate:setDashboardsDirty(superFunc)
    if superFunc ~= nil then
        superFunc(self)
    else
        local spec = self.spec_dashboard
        if spec ~= nil then
            spec.isDirty = true
            spec.isDirtyTick = true
        end

        self:raiseActive()
    end

    self:lsfmSetAllDashboardValueTypesDirty()
end

function DashboardAlwaysUpdate:updateDashboardValueType(superFunc, valueTypeName)
    if superFunc ~= nil then
        superFunc(self, valueTypeName)
    else
        local spec = self.spec_dashboard
        if spec ~= nil and spec.dashboardsByValueTypeDirty ~= nil then
            spec.dashboardsByValueTypeDirty[valueTypeName] = true
        end
    end

    local spec = self.spec_dashboard
    if spec ~= nil then
        spec.isDirtyTick = true
    end

    self:raiseActive()
end