local debugMode = false
local function debugMessage(message)
    if debugMode then
        tes3.messageBox(message)
        print(message)
    end
end

--[[
	Update Player Condition

	updateConditionState checks if condition has changed
	
	LevelUp event triggers rescaling of condition spell effects
	
	updateConditionEffect()
	
]]--
--how many seconds between each running of script
local this = {}

local common = require("mer.ashfall.common")
local faderController = require("mer.ashfall.faderController")

local tempPlayer


local previousCondition
local currentCondition = common.data and common.data.currentCondition or "Comfortable"

-- An array of our conditions, maintaining an order.
local conditionValues = common.conditionValues 


--Updates condition spell effect strength based on player stats
--Uses base version of spell as a reference to get attribute  values without multiplier
local function updateConditionEffect(spellID)
	--No effect for comfortable
	if spellID == "NONE" then
		return
	end
	local baseID = spellID .. "_BASE"
	local baseSpell = tes3.getObject(baseID)
	local realSpell = tes3.getObject(spellID)
	
	--Warm has a special case
	if spellID == "fw_cond_warm" then
		--Level based increase
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
				--debugMessage("min = " .. baseEffect.min .. ", STR = " .. tes3.mobilePlayer.attributes[attribute + 1].base .. ", strength/40 = " .. (tes3.mobilePlayer.attributes[attribute + 1].base / 40) )
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
	
	previousCondition = previousCondition or "Comfortable"

	tempPlayer = common.data.tempPlayer or 0
    for conditionType, condition in pairs(conditionValues) do
        if tempPlayer > condition.min  and tempPlayer <= condition.max then
            currentCondition = conditionType
			
			--Condition changed
			if currentCondition ~= previousCondition then
				--remove old fader, add new fader
				local oldFader = faderController.faders[previousCondition]
				local newFader = faderController.faders[currentCondition]
				if oldFader then
					faderController.fadeOut(oldFader)
				end
				if newFader then
					newFader:activate()
					tes3.playSound({reference=playerRef, sound="ashfall_freeze"})
					faderController.fadeIn(newFader)
				end
				
				
				updateConditionEffect(conditionValues[currentCondition].spell)
				tes3.messageBox("You are " .. string.lower( conditionValues[currentCondition].text ) )
				--Remove old condition
				for _, conditionInner in pairs(conditionValues) do
					mwscript.removeSpell({reference=tes3.player, spell=conditionInner.spell}) 
				end
				--Add new condition
				if currentCondition ~= "comfortable" then	
					mwscript.addSpell({reference=tes3.player, spell=conditionValues[currentCondition].spell })
				end
				common.data.currentCondition = currentCondition
				previousCondition = currentCondition
			end
			break
		end
	end
end

local function onKeyB(e)
	if not tes3.menuMode() and e.pressed then
		debugMessage("Current condition = " .. currentCondition)
		--debugMessage("Player Temp = " .. tempPlayer)
		debugMessage("Wetness = " .. common.data.wetness)
		debugMessage("Wet Condition: " ..( common.data.wetCondition or "none" ) )
	end
end
event.register("key", onKeyB, {filter = 48})


return this