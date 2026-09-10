--[[
Copyright (C) GtX (Andy), 2022

Author: GtX | Andy
Date: 28.10.2022
Revision: FS25-01

Contact:
https://forum.giants-software.com
https://github.com/GtX-Andy

Important:
Free for use in mods (FS25 Only) - no permission needed.
No modifications may be made to this script, including conversion to other game versions without written permission from GtX | Andy
Copying or removing any part of this code for external use without written permission from GtX | Andy is prohibited.

Frei verwendbar (Nur LS25) - keine erlaubnis nötig
Ohne schriftliche Genehmigung von GtX | Andy dürfen keine Änderungen an diesem Skript vorgenommen werden, einschließlich der Konvertierung in andere Spielversionen
Das Kopieren oder Entfernen irgendeines Teils dieses Codes zur externen Verwendung ohne schriftliche Genehmigung von GtX | Andy ist verboten.
]]

EnterableEnterText = {}

EnterableEnterText.MOD_NAME = g_currentModName or ""
EnterableEnterText.SPEC_NAME = string.format("spec_%s.enterableEnterText", g_currentModName)

function EnterableEnterText.prerequisitesPresent(specializations)
    return true
end

function EnterableEnterText.initSpecialization()
    local schema = Vehicle.xmlSchema

    schema:setXMLSpecializationType("EnterableEnterText")

    -- Driver enter texts
    schema:register(XMLValueType.L10N_STRING, "vehicle.enterable#enterText")
    schema:register(XMLValueType.STRING, "vehicle.enterable#enterTextParams", "Parameters to insert into #enterText")

    -- Passenger enter texts
    schema:register(XMLValueType.L10N_STRING, "vehicle.enterable#passengerEnterText")
    schema:register(XMLValueType.STRING, "vehicle.enterable#passengerEnterTextParams", "Parameters to insert into #passengerEnterText")

    -- Passenger texts for moving between seats
    schema:register(XMLValueType.L10N_STRING, "vehicle.enterable#passengerSwitchSeatDriverText")
    schema:register(XMLValueType.L10N_STRING, "vehicle.enterable#passengerSwitchSeatText")
    schema:register(XMLValueType.L10N_STRING, "vehicle.enterable#passengerSwitchNextSeatText")

    schema:setXMLSpecializationType()
end

function EnterableEnterText.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onPostLoad", EnterableEnterText)
end

function EnterableEnterText.registerOverwrittenFunctions(vehicleType)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "getInteractionHelp", EnterableEnterText.getInteractionHelp)
end

function EnterableEnterText:onPostLoad(savegame)
    local spec = self[EnterableEnterText.SPEC_NAME]

    if spec ~= nil then
        local xmlFile = self.xmlFile
        local customEnv = self.customEnvironment or EnterableEnterText.MOD_NAME

        local enterText = xmlFile:getValue("vehicle.enterable#enterText", nil, customEnv, false)

        if not string.isNilOrWhitespace(enterText) then
            local enterTextParams = xmlFile:getValue("vehicle.enterable#enterTextParams")

            if enterTextParams ~= nil then
                enterText = g_i18n:insertTextParams(enterText, enterTextParams, customEnv, xmlFile)
            end

            spec.enterText = enterText
            spec.available = true
        end

        local passengerEnterText = xmlFile:getValue("vehicle.enterable#passengerEnterText", nil, customEnv, false)

        if not string.isNilOrWhitespace(passengerEnterText) then
            local passengerEnterTextParams = xmlFile:getValue("vehicle.enterable#passengerEnterTextParams")

            if passengerEnterTextParams ~= nil then
                passengerEnterText = g_i18n:insertTextParams(passengerEnterText, passengerEnterTextParams, customEnv, xmlFile)
            end

            spec.passengerEnterText = passengerEnterText
            spec.available = true
        end

        if self.spec_enterablePassenger ~= nil and spec.passengerEnterText ~= nil then
            local passengerSwitchSeatDriverText = xmlFile:getValue("vehicle.enterable#passengerSwitchSeatDriverText", nil, customEnv, false)

            if not string.isNilOrWhitespace(passengerSwitchSeatDriverText) then
                self.spec_enterablePassenger.texts.switchSeatDriver = passengerSwitchSeatDriverText
            end

            local passengerSwitchSeatText = xmlFile:getValue("vehicle.enterable#passengerSwitchSeatText", nil, customEnv, false)

            if not string.isNilOrWhitespace(passengerSwitchSeatText) then
                self.spec_enterablePassenger.texts.switchSeatPassenger = passengerSwitchSeatText
            end

            local passengerSwitchNextSeatText = xmlFile:getValue("vehicle.enterable#passengerSwitchNextSeatText", nil, customEnv, false)

            if not string.isNilOrWhitespace(passengerSwitchNextSeatText) then
                self.spec_enterablePassenger.texts.switchNextSeat = passengerSwitchNextSeatText
            end
        end
    else
        Logging.error("[%s] Specialization with name 'enterableEnterText' was not found in modDesc!", EnterableEnterText.MOD_NAME)
    end
end

function EnterableEnterText:getInteractionHelp(superFunc)
    local spec = self[EnterableEnterText.SPEC_NAME]

    if spec ~= nil and spec.available then
        -- Driver seat
        if spec.enterText ~= nil and self.interactionFlag == Vehicle.INTERACTION_FLAG_ENTERABLE then
            return spec.enterText
        end

        -- Passenger seats when available
        if spec.passengerEnterText ~= nil and self.interactionFlag == Vehicle.INTERACTION_FLAG_ENTERABLE_PASSENGER then
            if self.spec_enterablePassenger ~= nil and self.spec_enterablePassenger.available then
                return spec.passengerEnterText
            end
        end
    end

    return superFunc(self)
end
