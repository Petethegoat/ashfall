--Updates condition spell effect strength based on player stats
--Uses base version of spell as a reference to get attribute  values without multiplier
local common = require("mer.ashfall.common")
local this = {}

local ignoreList = {
    "fw_cond_warm"
}

this.needsData = {
    temp = {
        value = "tempPlayer",
        default = "comfortable",
        condition = "tempCondition",
        conditionsList = common.tempConditions,
        showMessageOption = "showTempMessages"
    },
    hunger = {
        value = "hunger",
        default = "satiated",
        condition = "hungerCondition",
        conditionsList = common.hungerConditions,
        showMessageOption = "showHungerMessages"
    },   
    thirst = {
        value = "thirst",
        default = "hydrated",
        condition = "thirstCondition",
        conditionsList = common.thirstConditions,
        showMessageOption = "showThirstMessages"
    },   
    sleep =  {
        value = "sleep",
        default = "rested",
        condition = "sleepCondition",
        conditionsList = common.sleepConditions,
        showMessageOption = "showSleepMessages"
    },
    wetness = {
        value = "wetness",
        default = "dry",
        condition = "wetCondition",
        conditionsList = common.wetConditions,
        showMessageOption = "showWetMessages"        
    }
}

--Update the spell strength to scale with player attributes/level
local function scaleSpellValues(spellID)
    mwse.log("Entering scaleSpellValues")
    --No effect for comfortable
    if not spellID then
        mwse.log("no spell ID sent")
        return
    end
    
    local baseID = spellID .. "_BASE"
    local baseSpell = tes3.getObject(baseID)
    local realSpell = tes3.getObject(spellID)
    
    --Warm has a special case
    for _, id in ipairs(ignoreList) do
        if spellID == id then
            return
        end
    end
    --all others

    for i=1, #realSpell.effects do

        local effect = realSpell.effects[i]
        if effect.id ~= -1 then
            local baseEffect = baseSpell.effects[i]
            --Attributes: scale by matching player attribute
            local attribute  = effect.attribute
            if attribute ~= -1 then
                effect.min = baseEffect.min * ( tes3.mobilePlayer.attributes[attribute + 1].base / 40 ) --40 average starting stat
                effect.max = effect.min
            else
                --Other: scale by level
                effect.min = baseEffect.min * ( tes3.player.object.level / 20 )
                effect.max = effect.min
            end
            mwse.log("%s: %s", spellID, effect.min)
        end
    end
end

function this.updateCondition(id)
    local c = this.needsData[id]
    if not common.data then return end

    previousCondition = common.data[c.condition] or c.default
    local currentValue = common.data[c.value] or 0
    local newCondition

    for conditionType, conditionValues in pairs(c.conditionsList) do
        if conditionValues.min <= currentValue and currentValue <= conditionValues.max then
            newCondition = conditionType
            if newCondition ~= previousCondition then
                --Changing conditions, remove old, add new
                for _, innerVal in pairs(c.conditionsList)  do
                    local spellID = innerVal.spell
                    local playerHasCondition = 
                        innerVal.spell and 
                        tes3.player.object.spells:contains(spellID) 
                    if playerHasCondition then
                        mwse.log("Removing spell: %s", spellID )
                        mwscript.removeSpell({ reference = tes3.player, spell = spellID })
                    end
                end
                
                scaleSpellValues(c.conditionsList[newCondition].spell)

                --Add new condition
                if common.data[c.showMessageOption] then
                    tes3.messageBox("You are " .. string.lower(c.conditionsList[ newCondition].text) )
                end
                if conditionValues.spell then
                    mwscript.addSpell({ reference=tes3.player, spell = conditionValues.spell })
                end
                common.data[c.condition] = newCondition
            end
            break
        end
    end
end

--Update all conditions - called by the script timer
function this.updateConditions()
    for name, _ in pairs(this.needsData) do
        this.updateCondition(name)
    end
end

--Remove and re-add the condition spell if the player healed their stats with a potion or spell. 
local function refreshAfterRestore(e)
    local doRefresh = 
        e.effectInstance.state == tes3.spellState.ending and
        not string.startswith(e.source.id, "fw")

    if doRefresh then
        mwse.log("checking refresh")
        for name, conditionData in pairs(this.needsData) do
            local condition = common.data[conditionData.condition]
            if conditionData.conditionsList[condition] then
                local spell = conditionData.conditionsList[condition].spell

                mwse.log("Spell = %s", spell)
                if spell and tes3.player.object.spells:contains(spell) then
                    mwse.log("Refreshing spell: %s", spell)
                    mwscript.removeSpell({ reference = tes3.player, spell = spell })
                    mwscript.addSpell({ reference = tes3.player, spell = spell })
                end
            end
        end
    end
end

event.register("spellTick", refreshAfterRestore)

return this