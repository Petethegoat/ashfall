--[[
    Script to check if player is holding a torch and set torchTemp
]]--
local common = require("mer.ashfall.common")
local this = {}

local maxHeat = 15

function this.calculateTorchTemp()
    local torchStack = tes3.mobilePlayer.torchSlot
    if torchStack then
        local maxTime = torchStack.object.time
        local currentTime = torchStack.object:getTimeLeft(torchStack) 
        common.data.torchTemp =  math.floor( math.remap( currentTime, 0, maxTime, 0, maxHeat ) )
    else
        common.data.torchTemp = 0
    end
end
return this