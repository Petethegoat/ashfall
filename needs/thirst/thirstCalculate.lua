--[[
    Thirst mechanics
]]--

local common = require("mer.ashfall.common")
local this = {}
local thirstRate = 4.0
local heatMulti = 2.0
local thirstEffectMax = 1.5
function this.calculate(scriptInterval)
    local thirst = common.data.thirst or 0
    local temp = common.data.tempPlayer or 0

    --Hotter it gets the faster you become thirsty
    local heatEffect = math.clamp(temp, 0, 100 )
    heatEffect = math.remap(heatEffect, 0, 100, 1.0, heatMulti)

    --Calculate thirst
    thirst = thirst + ( scriptInterval * thirstRate * heatEffect )
    thirst = math.clamp(thirst, 0, 100)
    common.data.thirst = thirst

    --The thirstier you are, the more extreme heat temps are
    local thirstEffect = math.remap(thirst, 0, 100, 1.0, thirstEffectMax)
    common.data.thirstEffect = thirstEffect
end

return this