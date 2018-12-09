local this = {}

--[[
    This script creates tooltips when looking at Ashfall activators.
    Other scripts can see what the player is looking at by checking]
    this.currentActivator
]]--



this.currentActivator = nil

this.activatorList = {
    water = "Water",
    well = "Well",
    keg = "Keg",
    tree = "Tree",
    campfire = "Fire",
    cookingPot = "Cooking Pot"

}

local activatorPatterns = {
	["ex_nord_well"] = "well",
    ["kegstand"] = "keg",
    ["firepit"] = "campfire",
    ["pitfire"] = "campfire",
    ["logpile"] = "campfire",
}

local id_toolTip = tes3ui.registerID("Ashfall:activatorTooltip")
local id_label = tes3ui.registerID("Ashfall:activatorTooltipLabel")



local lookingAtWater

--Create water/well tooltip if it doesn't exist
local function createTooltip()
    local text = this.currentActivator
	local tooltip = tes3ui.findMenu(id_toolTip)
	if not tooltip then
		tooltip = tes3ui.createMenu{id = id_toolTip, fixedFrame = true}
		tooltip.positionX = 200
		tooltip.absolutePosAlignY  = 0.05
		tooltip.autoHeight = true
		tooltip.autoWidth = true

		local label = tooltip:createLabel{ id=id_label, text = text}
		label.autoHeight = true
		label.autoWidth = true
		label.wrapText = true
        label.justifyText = "center"
        
        lookingAtWater = true
	end
end

-- Destroy the water/well tooltip if it exists
local function destroyTooltip()
	local tooltip = tes3ui.findMenu(id_toolTip)
	if tooltip then
        tooltip:destroy()
        lookingAtWater = false
	end
end


local function callRayTest()
    if not tes3.menuMode() then
        local camPosition = tes3.getCameraPosition()
        local result = tes3.rayTest{
            position = camPosition,
            direction = tes3.getCameraVector(),
        }
        if not result then return end
        local distance = camPosition:distance(result.intersection)

        --Look for activators from list
        if distance < 200 then
            local targetRef = result.reference
            if targetRef then

                mwse.log("Looking at: %s", targetRef.id)

                for pattern, activator in pairs(activatorPatterns) do
                    if string.find(string.lower(targetRef.id), pattern) then

                        mwse.log("Returning activator")

                        this.currentActivator = this.activatorList[activator]
                        createTooltip()
                        return
                    end
                end
            end
        end

        --Special case for looking at water
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
                this.currentActivator = this.activatorList.water
                createTooltip()
                return
            end
        end
    end
    this.currentActivator = nil
	destroyTooltip()
end

local function dataLoaded()
	event.register("enterFrame", callRayTest)
end

--Register functions
event.register("Ashfall:dataLoaded", dataLoaded)

return this