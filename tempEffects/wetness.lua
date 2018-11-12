--[[
	Wetness mechanics
]]--
local this = {}
local common = require("mer.ashfall.common")


--How much rain and thunder increase wetness per game hour (without armor
local rainEffect = 120
local thunderEffect = 160
local maxDryingEffect = 50 --dry per hour at max heat

--Boundaries for wetEffects
this.dampLevel = common.wetnessValues.damp.min
this.wetLevel = common.wetnessValues.wet.min
this.soakedLevel = common.wetnessValues.soaked.min

--Height at which Player gets wetEfects
local dampHeight = 50
local wetHeight = 80
local soakedHeight = 110

--How Cold 100% wetness is
local wetTempMax = -25

--Keep track of player position to save on rayTests
local lastX
local lastY
local isSheltered

local function checkForShelter()
	local newPlayerPos = tes3.getMobilePlayer().position
	local newX = math.floor(newPlayerPos.x)
	local newY = math.floor(newPlayerPos.y)
	
	
	if  lastX ~= newX or lastY ~= newY then
		lastX = newX
		lastY = newY
		
		local result = tes3.rayTest{
			position = newPlayerPos,
			direction = {0, 0, 1},
		}
		if result and result.reference and result.reference.object and result.reference.object.objectType == tes3.objectType.static then 
			--tes3.messageBox("sheltered")
			isSheltered = true
		else
			--tes3.messageBox("not sheltered")
			isSheltered = false
		end
	end
end


--[[ 
	Called by tempTimer
]]--
function this.calcaulateWetTemp(timeSinceLastRan)
	if not common.data then return end

	local currentWetness = common.data and common.data.wetness or 0

	
	--Check if player is submerged 
    -- does not care about coverage
	local cell = tes3.getPlayerCell()
	if cell.hasWater then
		local waterLevel = cell.waterLevel or 0
		local playerHeight = tes3.getPlayerRef().position.z
		--soaked
		if waterLevel > ( playerHeight + soakedHeight ) then
			currentWetness = 100
	
		--wet
		elseif waterLevel > ( playerHeight + wetHeight ) then
			if currentWetness < ( this.wetLevel + 10 ) then 
				currentWetness = ( this.wetLevel + 10 )
			end
			
		--damp:
		elseif waterLevel > ( playerHeight + dampHeight ) then
			if currentWetness < ( this.dampLevel + 10 ) then 
				currentWetness = ( this.dampLevel + 10 )
			end
		end
	end
	
	--increase wetness if it's raining, otherwise reduce wetness over time
	-- wetness decreased by coverage
	local weather = tes3.getCurrentWeather()
	
	local tempMultiplier = 0.5 + ( ( common.data.tempPlayer + 100 ) / 400 ) --between 0.5 and 1.0
	

	if weather.rainActive and not cell.isInterior then
        --Check if there's anything above the player's head		
		checkForShelter()
		local armorCoverage = common.data.armorCoverage or 0.0
        local clothingCoverage = common.data.clothingCoverage or 0.0
		local coverage = math.clamp( ( armorCoverage + clothingCoverage ), 0, 0.95 )
        
        --Raining
		if weather.index == tes3.weather.rain and isSheltered == false then
			currentWetness = currentWetness + rainEffect * timeSinceLastRan * ( 1.0 - coverage )
		
        --Thunder
		elseif weather.index == tes3.weather.thunder and isSheltered == false then
			currentWetness = currentWetness + thunderEffect * timeSinceLastRan * ( 1.0 - coverage )
		end
	else
		isSheltered = true
	end
	--Drying off (indoors or clear weather)
	if isSheltered then
		currentWetness = currentWetness - ( tempMultiplier * timeSinceLastRan * maxDryingEffect )
	end
	--assert min/max values
	currentWetness = currentWetness < 0 and 0 or currentWetness
	currentWetness = currentWetness > 100 and 100 or currentWetness
	
	--Update wetness and wetTemp on player data
	common.data.wetness = currentWetness
	common.data.wetTemp = (currentWetness / 100) * wetTempMax
end

local function onLoad()
	checkForShelter()
end

event.register("loaded", onLoad)

return this


