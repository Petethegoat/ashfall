--[[
    Checks for nearby fires and adds warmth
    based on how far away they are. 
    Will need special logic for player-built fires which
    have heat based on firewood level
]]--
local this = {}
local common = require("mer.ashfall.common")

---CONFIGS----------------------------------------
--non-fire pits (torches etc)
local maxHeatDefault = 15
--Heat for vanilla firepits
local maxHeatFirePit = 40
--max distance where fire has an effect
local maxDistance = 350
--Multiplier when warming hands next to firepit
local warmHandsBonus = 1.4
--------------------------------------------------

--Check if player has Magic ready stance
local warmingHands
local triggerWarmMessage
local function checkWarmHands()
    mwse.log("Checking hands")
    if tes3.mobilePlayer.castReady then
        mwse.log("Hands at the ready")
        if not warmingHands then
            mwse.log("Setting to true")
            warmingHands = true
            triggerWarmMessage = true
        end
    else
        warmingHands = false
    end
end

--Check Ids to see if this light is a firepit of some kind
local function checkForFirePit(id)
    return (
        string.find( string.lower(id), "firepit" )
        or string.find( string.lower(id), "pitfire" )
        or string.find( string.lower(id), "logpile" )
    )
end
function this.calculateFireEffect()
    local totalHeat = 0
    local closeEnough
    for ref in tes3.getPlayerCell():iterateReferences(tes3.objectType.light) do
        if ref.object.isFire then
            local distance = mwscript.getDistance({reference = "player", target = ref})
            --tes3.messageBox("Fire distance: %.2f", distance) 
            if distance < maxDistance then
                local maxHeat
                if checkForFirePit(ref.object.id) then
                    closeEnough = true
                    maxHeat = maxHeatFirePit
                    checkWarmHands()
                    if warmingHands then
                        maxHeat = maxHeat * warmHandsBonus
                    end
                else
                    maxHeat = maxHeatDefault
                end

                local heat = math.remap( distance, maxDistance, 0,  0, maxHeat )
                totalHeat = totalHeat + heat
            end
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