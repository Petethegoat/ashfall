--[[
    Thirst mechanics
]]--

local common = require("mer.ashfall.common")
local this = {}
local thirstRate = 2.0
local heatMulti = 2.0
function this.calculateThirstLevel(scriptInterval)
    local thirst = common.data.thirst or 0
    local temp = common.data.tempPlayer or 0
    local heatEffect = math.clamp(temp, 0, 100 )
    heatEffect = math.remap(heatEffect, 0, 100, 1.0, heatMulti)
    thirst = thirst + ( scriptInterval * thirstRate * heatEffect )


    common.data.thirst = thirst
end

return this