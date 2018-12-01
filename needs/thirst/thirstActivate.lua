
--[[
	When the player looks at a water source (fresh water, wells, etc), 
	a tooltip will display, and pressing the activate button will bring up
	a menu that allows the player to drink or fill up a container with water.
]]--


local thirstCommon = require("mer.ashfall.needs.thirst.thirstCommon")
-- register UI Ids

local id_waterTooltip = tes3ui.registerID("Ashfall:waterTooltip")
local id_waterTooltipLabel = tes3ui.registerID("Ashfall:waterTooltipLabel")

--Create water/well tooltip if it doesn't exist
local function createTooltip(text)
	local tooltip = tes3ui.findMenu(id_waterTooltip)
	if not tooltip then
		tooltip = tes3ui.createMenu{id = id_waterTooltip, fixedFrame = true}
		tooltip.positionX = 200
		tooltip.absolutePosAlignY  = 0.05
		tooltip.autoHeight = true
		tooltip.autoWidth = true

		local label = tooltip:createLabel{ id=id_waterTooltipLabel, text = text}
		label.autoHeight = true
		label.autoWidth = true
		label.wrapText = true
		label.justifyText = "center"
	end
end

-- Destroy the water/well tooltip if it exists
local function destroyTooltip()
	local tooltip = tes3ui.findMenu(id_waterTooltip)
	if tooltip then
		tooltip:destroy()
	end
end


local function refillContainer(bottleId)
	mwscript.removeItem({reference = tes3.player, item = bottleId})
	
	local newContainer
	if string.find(string.lower(bottleId), "flask") then
		
		newContainer = "fw_water_flask_full"
	else
		newContainer = "fw_water_bottle_full"
	end
	mwscript.addItem({reference = tes3.player, item = newContainer})
	tes3.playSound({reference = tes3.player, sound="Swim Left"})
	tes3.messageBox("%s has been added to your inventory", tes3.getObject(newContainer).name)
end



--Buttons list
local buttons = {}
local bDrink = "Drink"
local bFillBottle = "Fill bottle"
local bNothing = "Nothing"
--Menu for drinking and refilling water bottle
local function activateWaterMenu(e)
	local buttonIndex = e.button + 1
	--Drink
	if buttons[buttonIndex] == bDrink then 
		tes3.playSound({reference=tes3.getPlayerRef(), sound="Swallow"})
		thirstCommon.drinkAmount(100)
		
	--refill
	elseif buttons[buttonIndex] == bFillBottle then
		local filled
		--first refill semiFilled containers
		for _, bottleId in pairs(thirstCommon.containerList.partialFilled) do
			if mwscript.getItemCount({reference = tes3.player, item = bottleId}) > 0 then
				tes3.messageBox("its a half full")
				refillContainer(bottleId)
				filled = true
				break
			end
		end	

		--check bottles
		if not filled then
			for _, bottleId in ipairs(thirstCommon.containerList.bottles) do
				if mwscript.getItemCount({reference = tes3.player, item = bottleId}) > 0 then
					refillContainer(bottleId)
					filled = true
					break
				end
			end
		end
		--Flasks		
		if not filled then
			for _, bottleId in ipairs(thirstCommon.containerList.flasks) do
				if mwscript.getItemCount({reference = tes3.player, item = bottleId}) > 0 then
					refillContainer(bottleId)
					filled = true
					break
				end
			end			
		end
		--Nothing to fill
		if not filled then
			tes3.messageBox("You have no containers")
		end
	end
end

--Create messageBox for water menu
local function callWatermenu()
	buttons = { bDrink, bFillBottle, bNothing }
	tes3.messageBox{
		message = "What would you like to do?",
		buttons = buttons,
		callback = activateWaterMenu
	}
end

--If player presses activate while looking at water source
--(determined by presence of tooltip), then open the water menu
local function onActivateWater(e)
	local inputController = tes3.worldController.inputController
	local keyTest = inputController:keybindTest(tes3.keybind.activate)
	if (keyTest) then
		local tooltip = tes3ui.findMenu(id_waterTooltip)
		if tooltip then
			if e.pressed then
				callWatermenu()
			end
		end
	end
end

--Use rayTest to see if the player is looking at a water source
local function checkForWater()
	if not tes3.menuMode() then
		local camPosition = tes3.getCameraPosition()
        local result = tes3.rayTest{
            position = camPosition,
			direction = tes3.getCameraVector(),
		}
		if not result then return end
		local distance = camPosition:distance(result.intersection)

		if distance < 200 then
			local targetRef = result.reference
			if targetRef then
				--Open menu for water well
				if string.find(string.lower(targetRef.id), "ex_nord_well") then
					createTooltip("Well")
					return
				end
			end
		end

		--Check if player is looking at water and nothing else
		local cell =  tes3.player.cell
		local waterLevel = cell.waterLevel or 0
		local intersection = result.intersection
		local adjustedIntersection = tes3vector3.new( intersection.x, intersection.y, waterLevel )
		local adjustedDistance = camPosition:distance(adjustedIntersection)
		if adjustedDistance < 300 and cell.hasWater then
			local blocked
			if result.reference then
				if result.reference.object.objectType ~= tes3.objectType.static then
					blocked = true
				end
			end
			if camPosition.z > waterLevel and intersection.z < waterLevel and not blocked then
				createTooltip("Water")
				return
			end
		end

	end
	destroyTooltip()
end

--Register events
event.register("keyDown", onActivateWater )
event.register("enterFrame", checkForWater)
event.register("menuEnter", destroyTooltip)