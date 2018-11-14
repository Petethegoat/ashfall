--[[

    This script runs on a timer to update the External temperature and player temperature
    This is where 

]]--
local this = {}

local common = require("mer.ashfall.common")

-------------------------------------CONFIG VALUES-------------------------------------

--Determines how fast tempLimit catches up to tempReal
local limitRate = 60

--Determines how fast tempPlayer catches up to tempLimit
local playerRate = 1
local minPlayerDiff = 60    

--"Region" temp when inside
local intRegionMultiplier = 0.1
local intTimeMultiplier = 0.3
local interiorBaseTemp = 0
local exteriorBaseTemp = 0
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
    local bedTemp = common.data.bedTemp or 0
    local tentTemp = common.data.tentTemp or 0
    local furTemp = common.data.furTemp or 0

	--Player Effects -- multipliers
	local hungerEffect = common.data.hungerEffect or 1
	local thirstEffect = common.data.thirstEffect or 1
	local resistFrostEffect = common.data.ResistFrostEffect or 1
	local resistFireEffect = common.data.resistFireEffect or 1
	local alcoholEffect = common.data.alcoholEffect or 1
    local vampireColdEffect = common.data.vampireColdEffect or 1
    local vampireWarmEffect = common.data.vampireWarmEffect or 1

    --Inside: region/time have significantly reduced effect, temp hovers around comfortable
	local cell = tes3.getPlayerCell()
	if cell.isInterior then
        tempRaw = interiorBaseTemp 
                + ( regionTemp * intRegionMultiplier )
                + ( timeTemp * intTimeMultiplier )
    else
        tempRaw = exteriorBaseTemp + regionTemp + timeTemp
	end

    tempReal = (
        tempRaw  + wetTemp
                 + torchTemp
                 + fireTemp
                 + fireDamTemp
                 + frostDamTemp
                 + clothingTemp
                 + armorTemp
                 + bedTemp
                 + tentTemp
                 + furTemp
    )
    common.data.tempRaw = tempRaw
	--cold exclusive effects
	if tempReal < 0 then
		tempReal = ( 
            tempReal * hungerEffect 
                     * resistFrostEffect
                     * alcoholEffect 
                     * vampireColdEffect
        )
	--hot exclusive effects
	elseif tempReal > 0 then
		tempReal = ( 
            tempReal * thirstEffect
                    * resistFireEffect
                    * alcoholEffect 
                    * vampireWarmEffect
        )
	end
    common.data.tempReal = tempReal
	--[[------------------------------------
	Calculate tempLimit
            - "Environment Temp"
			- Moves towards tempReal
			- Synced to GameHour
	]]-----------------------------------
	local limitDiff = math.abs( tempReal - tempLimit )
	local limitChange = limitDiff * limitRate * timerInterval
    limitChange = math.clamp( limitChange, 0, limitDiff )

	tempLimit = tempLimit + ( ( tempLimit < tempReal ) and limitChange or -limitChange )
	common.data.tempLimit = tempLimit

	--[[------------
	------------------------

		Calculate tempPlayer
			- Moves towards tempLimit
			- Synced to GameHour
			- Slower while sleeping

	]]--------------------------------------
	local playerDiff = math.abs( tempLimit - tempPlayer )
	playerDiff = ( playerDiff < minPlayerDiff ) and minPlayerDiff or playerDiff

	local playerChange = playerDiff * playerRate * timerInterval
    
    if tes3.menuMode() then
        playerChange = playerChange * sleepMulti
    end
    
	--Warmth rate 0.5x at 100 wetness. Cooling rate 1.5x at 100% wetness
	local wetness = common.data.wetness or 0
    local wetTempEffect = ( tempPlayer < tempLimit ) and 0.5 or 1.5
	local wetMulti = math.remap( wetness, 0, 100, 1.0, wetTempEffect )
	playerChange = playerChange * wetMulti
    
	--prevent overshoot
    playerChange = math.clamp( playerChange, 0, playerDiff )
    
    --set player temp
	tempPlayer = tempPlayer + ( ( tempPlayer < tempLimit) and playerChange or -playerChange )
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


