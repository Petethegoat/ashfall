--[[
    Checks for nearby fires and adds warmth
    based on how far away they are. 
    Will need special logic for player-built fires which
    have heat based on firewood level
]]--
local this = {}
local common = require("mer.ashfall.common")

---CONFIGS----------------------------------------
--max distance where fire has an effect
local heatValues = {
    lantern = 3,
    lamp = 3,
    candle = 5, 
    chandelier = 3,
    sconce = 10,
    torch = 15,
    flame = 20
}



local heatDefault = 5
local heatFirepit = 40
local maxDistance = 350
--Multiplier when warming hands next to firepit
local warmHandsBonus = 1.4
--------------------------------------------------

--Check if player has Magic ready stance
local warmingHands 
local triggerWarmMessage
local function checkWarmHands()
    if tes3.mobilePlayer.castReady then
        if not warmingHands then
            warmingHands = true
            triggerWarmMessage = true
        end
    else
        warmingHands = false
    end
end

--Check Ids to see if this light is a firepit of some kind
local function checkForFirePit(id)
    local patterns = {
        "firepit",
        "pitfire",
        "logpile"
    }
    for _, pattern in pairs(patterns) do
        if string.find( string.lower(id), pattern) then
            return true
        end
    end
    return false
end

function this.calculateFireEffect()
    local totalHeat = 0
    local closeEnough
    common.data.fireType = "none"
    for _, cell in pairs( tes3.getActiveCells() ) do
        for ref in cell:iterateReferences(tes3.objectType.light) do
            --if ref.object.isFire then
                local distance = mwscript.getDistance({reference = "player", target = ref})
                if distance < maxDistance then
                    local maxHeat = heatDefault
                    --Firepits have special logic for hand warming
                    if checkForFirePit(ref.object.id) then
                        common.data.fireType = "firepit"
                        closeEnough = true
                        maxHeat = heatFirepit
                        checkWarmHands()
                        if warmingHands then
                            maxHeat = maxHeat * warmHandsBonus
                        end
                    --other fires
                    else
                        for pattern, heatValue in pairs(heatValues) do
                            if string.find(string.lower(ref.object.id), pattern) then
                                common.data.fireType = pattern
                                maxHeat = heatValue
                                --mwse.log("Fire source: %s", ref.object.id)
                            end
                        end
                    end
                    local heat = math.remap( distance, maxDistance, 0,  0, maxHeat )
                    totalHeat = totalHeat + heat
                end
            --end
        end
    end
    if not closeEnough then
        warmingHands = false
    end
    if triggerWarmMessage then
        triggerWarmMessage = false
        tes3.messageBox("You warm your hands by the fire")
    end
    common.data.fireTemp = totalHeat
end


return this