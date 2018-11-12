
local function onWellMenu(e)
	if e.button == 0 then --Drink
		tes3.playSound({reference=tes3.getPlayerRef(), sound="Swallow"})
	elseif e.button == 1 then --Refill waterskin
		tes3.messageBox("Your waterskin has been refilled")
		tes3.playSound({reference=tes3.getPlayerRef(), sound="Swim Left"})
	--elseif e.button == 2 then --Nothing
	
	end
end

local function onKeyG(e)
    if not tes3.menuMode() then
        local result = tes3.rayTest{
            position = tes3.getCameraPosition(),
            direction = tes3.getCameraVector(),
        }
		if e.pressed then
			local targetRef = result.reference
			local playerPos = tes3.getPlayerRef().position
			local dist = playerPos:distance(result.intersection)
			if dist < 200 and string.find(string.lower(targetRef.id), "ex") and string.find(string.lower(targetRef.id), "well") then
				tes3.messageBox{
					message = "What would you like to do?",
					buttons = {"Drink", "Refill waterskin", "Nothing"},
					callback = onWellMenu
				}
			end
		end
    end
end


--Register events
event.register("key", onKeyG, {filter = 18})
