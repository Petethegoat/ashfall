--[[local swings
local lastRef

local function onAttack()

	--Use RayTest to get object reference of whatever the player is looking at
    local result = tes3.rayTest{
        position = tes3.getCameraPosition(),
        direction = tes3.getCameraVector(),
    }
	--not looking at anything, return
	if not result or not result.reference then return end
	--get references
	local playerRef = tes3.getPlayerRef()
	local targetRef = result.reference
	local playerPos = playerRef.position
	--Get distance between player and object
	local dist = playerPos:distance(result.intersection)
			

	local weapon = tes3.getMobilePlayer().readiedWeapon
	if not weapon then return end
	local swingType = tes3.getMobilePlayer().actionData.attackDirection
	local swingStrength = tes3.getMobilePlayer().actionData.attackSwing
	
	--If attacking the same target, accumulate swings
	if lastRef == targetRef then
		swings = swings + swingStrength
	else
		lastRef = targetRef
		swings = 0
	end
	
	if dist < 200 and swingType == 2 and string.find(string.lower(weapon.object.id), "pick") then
		if string.find(string.lower(targetRef.id), "terrain") and string.find(string.lower(targetRef.id), "rock") then
			tes3.playSound({reference=playerRef, sound="Heavy Armor Hit"})
			weapon.variables.condition = weapon.variables.condition - (10 * swingStrength)
			--Weapon degradation, unequip if below 0
			if weapon.variables.condition <= 0 then
				weapon.variables.condition = 0
				mwscript.addItem{reference=playerRef, item="a_dummyaxe" }
				mwscript.equip{reference=playerRef, item="a_dummyaxe" }
				mwscript.removeItem{reference=playerRef, item="a_dummyaxe" }
			end
			--wait until chopped tree 3 times
			if swings > 2 then 
				--stone collected based on strength of previous swings
				local numStone =  tonumber(string.format("%d", (math.random() * swings) ))
				--minimum 1 stone collected
				if numStone < 1 then
					numStone = 1
				end
				if numStone == 1 then
					tes3.messageBox("You have harvested 1 stone")
				else
					tes3.messageBox("You have harvested %d stones", numStone)
				end
				tes3.playSound({reference=playerRef, sound="Item Misc Up"})
				mwscript.addItem{reference=playerRef, item="Ashfall_Stone", count=numStone}				
				--reset swings
				swings = 0
			end
		end
	end

end

local function onLoaded()
	-- update outer scoped vars
	swings = 0
end

--Register events
event.register("loaded", onLoaded)
event.register("attack", onAttack )
]]--