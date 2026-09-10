--[[
Author: GtX | Andy
Date: 04.02.2018
Revision: FS22-01

Contact:
https://forum.giants-software.com
https://github.com/GtX-Andy

Usage: Increases the fill type limit when required. Use the following in your modDesc with the correct path set.

<modDesc descVersion="99">
    <extraSourceFiles>
        <sourceFile filename="multifruit/scripts/FillTypeLimitIncrease.lua"/>
    </extraSourceFiles>
</modDesc>
]]

if FillTypeManager.NUM_BITS_CHECK == nil then
    FillTypeManager.NUM_BITS_CHECK = true

    FillTypeManager.loadMapData = Utils.overwrittenFunction(FillTypeManager.loadMapData, function(self, superFunc, ...)
        local oldSendNumBits = math.max(FillTypeManager.SEND_NUM_BITS, 8)

        FillTypeManager.SEND_NUM_BITS = 10 -- Increase limit to 1023 while all fill types load. It would be dumb to reach this limit.

        if not superFunc(self, ...) then
            return false
        end

        local newSendNumBits = MathUtil.getNumRequiredBits(#self.fillTypes)

        FillTypeManager.SEND_NUM_BITS = math.max(newSendNumBits, oldSendNumBits) -- Set the new limit but no less than the default / original limit.

        if oldSendNumBits ~= newSendNumBits then
            Logging.devInfo("Fill type limit '%d' changed to %d successfully.", 2 ^ oldSendNumBits - 1, 2 ^ newSendNumBits - 1)
        end

        return true
    end)
end
