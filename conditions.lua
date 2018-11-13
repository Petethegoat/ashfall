--[[
    Sets condition based on temperature. 
    If condition has changed, update condition effect
    Scales condition effects with player attributes
]]--
--how many seconds between each running of script
local this = {}
local common = require("mer.ashfall.common")
local faderController = require("mer.ashfall.faderController")

local previousCondition

--Updates condition spell effect strength based on player stats
--Uses base version of spell as a reference to get attribute  values without multiplier
local function setSpellStrength(spellID)
	--No effect for comfortable
	if not spellID then
		return
	end
    
	local baseID = spellID .. "_BASE"
	local baseSpell = tes3.getObject(baseID)
	local realSpell = tes3.getObject(spellID)
	
	--Warm has a special case
	if spellID == "fw_cond_warm" then
		--TODO: Level based increase
		return
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
		end
	end
end

--Called in tempTimer
function this.updateConditionState()
	if not common.data then return end
	
	previousCondition = previousCondition or "comfortable"

	local tempPlayer = common.data.tempPlayer or 0
    for conditionType, condition in pairs(common.conditionValues) do
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
				
                
				setSpellStrength(common.conditionValues[common.data.currentCondition].spell)
                
				--Remove old condition
				for _, innerLoopCondition in pairs(common.conditionValues) do
					mwscript.removeSpell({reference= tes3.player , spell = innerLoopCondition.spell}) 
				end
				--Add new condition
                local newSpell = common.conditionValues[common.data.currentCondition].spell
				if newSpell then	
					mwscript.addSpell({reference = tes3.player, spell = newSpell })
				end
                
				previousCondition = common.data.currentCondition
                
                
                --This needs wrapping in an MCM option
				tes3.messageBox("You are " .. string.lower( common.conditionValues[common.data.currentCondition].text ) )
			end
			break
		end
	end
end

local function onKeyB(e)
	if not tes3.menuMode() and e.pressed then
		tes3.messageBox("Current condition = " .. common.data.currentCondition)
		tes3.messageBox("Player Temp = " .. common.data.tempPlayer )
		tes3.messageBox("Wetness = " .. common.data.wetness)
	end
end
event.register("key", onKeyB, {filter = 48})


return this