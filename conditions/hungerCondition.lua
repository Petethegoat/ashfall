local this = {}
local common = require("mer.ashfall.common")
local previousCondition

local conditions = common.hungerConditions

function this.updateCondition()
    if not common.data then return end

    previousCondition = common.data.hungerCondition or "satiated"
    local hunger = common.data.hunger or 0
    local newCondition

    for conditionType, conditionValues in pairs(conditions) do
        if conditionValues.min <= hunger and hunger <= conditionValues.max then
            newCondition = conditionType
            if newCondition ~= previousCondition then
				--Changing conditions, remove old, add new
				for _, innerVal in pairs(conditions)  do
					if innerVal.spell ~= "NONE" then
						mwscript.removeSpell({ reference = tes3.player, spell = innerVal.spell })
					end
                end               
                --Add new condition
                if common.data.showHungerMessages then
                    tes3.messageBox("You are " .. string.lower(conditions[ newCondition].text) )
                end
				if newCondition ~= "dry" then
					mwscript.addSpell({ reference=tes3.player, spell = conditionValues.spell })
				end
                common.data.hungerCondition = newCondition 
            end
            break
        end
    end

end

return this