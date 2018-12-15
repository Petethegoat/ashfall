--[[
    Sets condition based on temperature. 
    If condition has changed, update condition effect
    Scales condition effects with player attributes
]]--
--how many seconds between each running of script
local this = {}
local common = require("mer.ashfall.common")
local conditionsCommon = require("mer.ashfall.conditions.conditionsCommon")
local faderController = require("mer.ashfall.faderController")

local previousCondition



--Called in tempTimer
function this.updateCondition()
    if not common.data then return end

    previousCondition = previousCondition or "comfortable"

    local tempPlayer = common.data.tempPlayer or 0
    for conditionType, condition in pairs(common.tempConditions) do
        if tempPlayer >= condition.min and tempPlayer <= condition.max then
            common.data.currentCondition = conditionType

            --Condition changed
            if common.data.currentCondition ~= previousCondition then
                --remove old fader, add new fader
                local oldFader = faderController.faders[previousCondition]
                local newFader = faderController.faders[common.data.currentCondition]
                if oldFader then
                    faderController.fadeOut(oldFader)
                end
                if newFader then
                    newFader:activate()
                    tes3.playSound({reference=tes3.player, sound="ashfall_freeze"})
                    faderController.fadeIn(newFader)
                end


                conditionsCommon.setSpellStrength(common.tempConditions[common.data.currentCondition].spell)

                --Remove old condition
                for _, innerLoopCondition in pairs(common.tempConditions) do
                    mwscript.removeSpell({reference= tes3.player , spell = innerLoopCondition.spell}) 
                end
                --Add new condition
                local newSpell = common.tempConditions[common.data.currentCondition].spell
                if newSpell then    
                    mwscript.addSpell({reference = tes3.player, spell = newSpell })
                end

                previousCondition = common.data.currentCondition


                --This needs wrapping in an MCM option
                if common.data.showTempMessages then
                    tes3.messageBox("You are " .. string.lower( common.tempConditions[common.data.currentCondition].text ) )
                end
            end
            break
        end
    end
end

local function onKeyB()
    if not tes3.menuMode() then
        tes3.messageBox("Current condition = " .. common.data.currentCondition)
        tes3.messageBox("Player Temp = " .. common.data.tempPlayer )
        tes3.messageBox("Wetness = " .. common.data.wetness)
    end
end
--event.register("keyDown", onKeyB, {filter = 48})


return this