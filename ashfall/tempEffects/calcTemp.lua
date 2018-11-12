--[[

    This script runs on a timer to update the External temperature and player temperature
    This is where 

]]--
local this = {}

local common = require("mer.ashfall.common")

-------------------------------------CONFIG VALUES-------------------------------------

--Determines how fast tempLimit catches up to tempReal (diff per second)
local limitRate = 70

--Determines how fast tempPlayer catches up to tempLimit (diff per GameHour)
local playerRate = 1.0
local minPlayerDiff = 60    

--"Region" temp when inside
local interiorTemp = 5
----------------------------------------------------------------------------------------

--temperature variables
local tempRaw
local tempReal
local tempLimit
local tempPlayer

--How slowly changes during sleep
local sleepMulti = 0.7 
--GameHour variables
local gameHour

--[[------------------------------------------------------------------

	calculateTemp()
	Calculate tempLimit and tempPlayer

	called by tempTimer module
	
]]-------------------------------------------------------------------
function this.calculateTemp(timerInterval)
	if not common.data then return end
    tempRaw = common.data.tempRaw or 0
    tempReal = common.data.tempReal or 0
    tempLimit = common.data.tempLimit or 0
    tempPlayer = common.data.tempPlayer or 0
    
    
	--Environmental Factors -- additives
    local timeTemp = common.data.timeTemp or 0
	local regionTemp = common.data.regionTemp or 0
	local wetTemp = common.data.wetTemp or 0
    local torchTemp = common.data.torchTemp or 0
	local fireTemp = common.data.fireTemp or 0
	local fireDamTemp = common.data.fireDamTemp or 0
	local frostDamTemp = common.data.frostDamTemp or 0
	local clothingTemp = common.data.clothingTemp or 0
	local armorTemp = common.data.armorTemp or 0

	--Player Effects -- multipliers
	local hungerEffect = common.data.hungerEffect or 1
	local thirstEffect = common.data.thirstEffect or 1
	local raceColdEffect = common.data.raceColdEffect or 1
	local raceHotEffect = common.data.raceHotEffect or 1
	local resistFrostEffect = common.data.ResistFrostEffect or 1
	local resistFireEffect = common.data.resistFireEffect or 1
	local alcoholEffect = common.data.alcoholEffect or 1

	local cell = tes3.getPlayerCell()
	if cell.isInterior then
		regionTemp = interiorTemp
		timeTemp = 0
	end
	tempRaw = ( 	timeTemp
				+ 	regionTemp
				+	wetTemp
                +   torchTemp
				+	fireTemp
				+	fireDamTemp
				+	frostDamTemp
				+	clothingTemp
				+	armorTemp )
	--cold exclusive effects
	if tempRaw < 0 then
		tempReal = ( tempRaw * hungerEffect 
							 * raceColdEffect
							 * resistFrostEffect
							 * alcoholEffect )
	--hot exclusive effects
	elseif tempRaw > 0 then
		tempReal = ( tempRaw * thirstEffect
							 * raceHotEffect
							 * resistFireEffect
							 * alcoholEffect )
	else
		tempReal = tempRaw
	end 
	
	--[[------------------------------------
	Calculate tempLimit
            - "Environment Temp"
			- Moves towards tempReal
			- Synced to GameHour
	]]-----------------------------------
	tempLimit = common.data.tempLimit or 0
	local limitDiff = math.abs( tempReal - tempLimit )
    --limitChange: how much to move towards tempReal this call
	local limitChange = limitDiff * limitRate * timerInterval

	--Prevent overshoot: set to difference if the change is greater than difference
	if math.abs(limitChange) > limitDiff then
		limitChange = limitChange < 0 and -limitDiff or limitDiff 
	end
	
	tempLimit = tempLimit < tempReal and tempLimit + limitChange or tempLimit - limitChange
	common.data.tempLimit = tempLimit

	
	--[[------------
	------------------------

		Calculate tempPlayer
			- Moves towards tempLimit
			- Synced to GameHour
			- Slower while sleeping

	]]--------------------------------------
	tempPlayer = common.data.tempPlayer or 0
	local playerDiff = tempLimit - tempPlayer
	
	--Change at least as much as minPlayerDiff
	local diffEffect
	if 0 < playerDiff and playerDiff < minPlayerDiff then
		diffEffect = minPlayerDiff
	elseif -minPlayerDiff < playerDiff and playerDiff < 0  then
		diffEffect = -minPlayerDiff
	else
		diffEffect = playerDiff
	end

	local playerChange = diffEffect * playerRate * timerInterval
    
    if tes3.menuMode() then
        playerChange = playerChange * sleepMulti
    end
	--Warmth slowed by wetness: 0.5 speed at 100 wetness
	local wetness = common.data.wetness or 0
	local wetMulti = math.remap( wetness, 0, 100, 1.0, 0.5 )
	if playerChange > 0 then
		playerChange = playerChange * wetMulti
	end
	--and cooling down quickened by wetness: 1.5 speed at 100 wetness
	wetMulti = math.remap( wetness, 0, 100, 1.0, 1.5 )
	if playerChange < 0 then
		playerChange = playerChange * wetMulti
	end	
	
	--prevent overshoot
	playerChange = math.abs(playerChange) > math.abs(playerDiff) and playerDiff or playerChange
	
	tempPlayer = tempPlayer + playerChange
	--set player temp
	common.data.tempPlayer = tempPlayer
    -----------------------------------------------
	
end

--Press G key to see temperature updates
local function onKeyG(e)
	if not common.data then return end
    if not tes3.menuMode() then
		if e.pressed then
			if not common.data.regionTemp then 
				tes3.messageBox("No regionTemp")
			elseif not common.data.timeTemp then 
				tes3.messageBox("No timeTemp")
			end
		
			gameHour = tes3.getGlobal("GameHour")
			local currentTime = common.hourToClockTime(gameHour)
            tes3.messageBox(
                "Total Warmth = " .. ( common.data.armorTemp + common.data.clothingTemp )  
                .. ", Total Coverage: " .. ( common.data.armorCoverage + common.data.clothingCoverage ) 
            )
        	--tes3.messageBox("Temperature: (%.2f/%.2f) \nTime: %s", tempPlayer, tempLimit, currentTime )
			--tes3.messageBox("RegionTemp: %.2f \n TimeTemp: %.2f \n WetTemp: %.2f",  common.data.regionTemp, common.data.timeTemp, common.data.wetTemp)
		end
    end
end


event.register("key", onKeyG, {filter = 34})
return this


