
local common = require("mer.ashfall.common")

local id_waterTooltip = tes3ui.registerID("Ashfall:waterTooltip")
local id_waterTooltipLabel = tes3ui.registerID("Ashfall:waterTooltipLabel")

local toolTipActive

local function updateTooltip(text)
	local tooltip = tes3ui.findMenu(id_waterTooltip)
	if text and not tooltip then
		tooltip = tes3ui.createMenu{id = id_waterTooltip, fixedFrame = true}
		--tooltip.minWidth = 100
		--tooltip.minHeight = 50
		tooltip.positionX = 200
		tooltip.absolutePosAlignY  = 0.05
		tooltip.autoHeight = true
		tooltip.autoWidth = true
        --tooltip.childAlignX  = 0.5
        
		
		local label = tooltip:createLabel{ id=id_waterTooltipLabel, text = text}
		label.autoHeight = true		
		label.autoWidth = true
		label.wrapText = true
		label.justifyText = "center"
		--label.color = tes3ui.getPalette("header_color")		

	end
end

local function destroyTooltip()
	local tooltip = tes3ui.findMenu(id_waterTooltip)
	if tooltip then
		tooltip:destroy() 
	end
end


local function onWellMenu(e)
	if e.button == 0 then --Drink
		tes3.playSound({reference=tes3.getPlayerRef(), sound="Swallow"})
		common.data.thirst = 0
	elseif e.button == 1 then --Refill waterskin
		tes3.messageBox("Your waterskin has been refilled")
		tes3.playSound({reference=tes3.getPlayerRef(), sound="Swim Left"})
	--elseif e.button == 2 then --Nothing
	
	end
end

local function openWaterMenu()
	tes3.messageBox{
		message = "What would you like to do?",
		buttons = {"Drink", "Refill waterskin", "Nothing"},
		callback = onWellMenu
	}
end


local function onActivateWater(e)
	local tooltip = tes3ui.findMenu(id_waterTooltip)
	if tooltip then
		if e.pressed then
			openWaterMenu()
		end
	end
end

local function checkForWater()
	if not tes3.menuMode() then
		local camPosition = tes3.getCameraPosition()
        local result = tes3.rayTest{
            position = camPosition,
			direction = tes3.getCameraVector(),
		}
		if not result then return end
		local distance = tes3.player.position:distance(result.intersection)

		if distance < 300 then
			local targetRef = result.reference
			if targetRef then
				--Open menu for water well
				if string.find(string.lower(targetRef.id), "ex") and string.find(string.lower(targetRef.id), "well") then
					updateTooltip("Well")
					return
				end
			end
		end
		
		--Check if player is looking at water and nothing else
		local cell =  tes3.getPlayerCell()
		local waterLevel = cell.waterLevel or 0
		local intersection = result.intersection
		local adjustedIntersection = tes3vector3.new( intersection.x, intersection.y, waterLevel )
		local adjustedDistance = camPosition:distance(adjustedIntersection)
		if adjustedDistance < 300 then
			local blocked
			if result.reference then
				if result.reference.object.objectType ~= tes3.objectType.static then
					blocked = true
				end
			end
			if camPosition.z > waterLevel and intersection.z < waterLevel and not blocked then
				updateTooltip("Water")
				return
			end
		end
		
	end
	destroyTooltip()
end

--Register events
event.register("key", onActivateWater, {filter = 18})
event.register("enterFrame", checkForWater)
event.register("menuEnter", destroyTooltip)