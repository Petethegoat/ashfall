--[[
	Update the wetness condition of the player
]]--

local this = {}

local common = require("mer.ashfall.common")
local wetness = require("mer.ashfall.tempEffects.wetness")

local previousWetCondition

local wetConditionValues = {
	{ condition = "Soaked"	, value = wetness.soakedLevel 	, spell = "fw_wetcond_soaked" 	},
	{ condition = "Wet"		, value = wetness.wetLevel 		, spell = "fw_wetcond_wet" 		},
	{ condition = "Damp"	, value = wetness.dampLevel 	, spell = "fw_wetcond_damp" 	},
	{ condition = "Dry"		, value = -1					, spell = "NONE"			 	}
}
-- We also want to access conditions by name, so create a dictionary that lets us do that.
local wetConditionDict = {}
for i = 1, #wetConditionValues do
    local conditionData = wetConditionValues[i]
    wetConditionDict[conditionData.condition] = conditionData
end


function this.updateWetConditionState()
	if not common.data then return end
	
	previousWetCondition = common.data.wetCondition or "Dry"
	local wetness = common.data.wetness or 0
	local newWetCondition
	
	for i=1, table.getn(wetConditionValues), 1 do
		if wetness > wetConditionValues[i]["value"] then
			--This is our current condition, break after this
			newWetCondition = wetConditionValues[i]["condition"]
			--different to last time?
			if newWetCondition ~= previousWetCondition then
				
				--Changing conditions, remove old, add new
				for x=1,table.getn(wetConditionValues), 1 do
					if wetConditionValues[x]["spell"] ~= "NONE" then
						mwscript.removeSpell({reference=tes3.player, spell=wetConditionValues[x]["spell"]})
					end
				end
				--Add new condition
				tes3.messageBox("You are " .. newWetCondition)
				if newWetCondition ~= "Dry" then
					mwscript.addSpell({reference=tes3.player, spell=wetConditionDict[newWetCondition]["spell"] })
				end
				common.data.wetCondition = newWetCondition
			end
			break
		end
	end
end

return this