--[[
	Update the wetness condition of the player
]]--

local this = {}

local common = require("mer.ashfall.common")

local previousWetCondition


function this.updateWetConditionState()
	if not common.data then return end
	
	previousWetCondition = common.data.wetCondition or "dry"
	local wetness = common.data.wetness or 0
	local newWetCondition
	
	for conditionType, conditionValues in pairs(common.wetnessValues) do
		if conditionValues.min <= wetness and wetness <= conditionValues.max then
			--This is our current condition, break after this
			newWetCondition = conditionType
			--different to last time?
			if newWetCondition ~= previousWetCondition then
				
				--Changing conditions, remove old, add new
				for _, innerVal in pairs(common.wetnessValues)  do
					if innerVal.spell ~= "NONE" then
						mwscript.removeSpell({ reference = tes3.player, spell = innerVal.spell })
					end
				end
				--Add new condition
				tes3.messageBox("You are " .. newWetCondition)
				if newWetCondition ~= "dry" then
					mwscript.addSpell({ reference=tes3.player, spell = conditionValues.spell })
				end
				common.data.wetCondition = newWetCondition
			end
			break
		end
	end
end

return this