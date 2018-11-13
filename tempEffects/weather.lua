--[[

This script gets region and weather info on cell change/weather change

]]--
local this = {}
local common = require("mer.ashfall.common")

--[[
	Weather
	Determines the min and max value of timeTemp
]]--
local currentWeather

local weatherValues = { 
	[tes3.weather.blight]	= {	min	= -10	, max =  80  },
	[tes3.weather.ash] 		= {	min	= -15	, max =  60	 },
	[tes3.weather.clear] 	= {	min	= -50	, max =  50	 },
	[tes3.weather.cloudy] 	= {	min	= -55	, max =  15	 },
	[tes3.weather.overcast] = {	min	= -60	, max =  10	 },
	[tes3.weather.foggy] 	= {	min	= -70	, max =  0	 },
	[tes3.weather.rain] 	= {	min	= -75	, max = -20	 },
	[tes3.weather.thunder] 	= {	min	= -100	, max = -30	 },
	[tes3.weather.snow] 	= {	min	= -120	, max = -50	 },
	[tes3.weather.blizzard] = {	min	= -150	, max = -80	 }
}


local function updateWeather(weatherObj)
	currentWeather = weatherObj.index
end

local function immediateChange(e)
	updateWeather(e.to)
end

local function transitionEnd(e)
	updateWeather(e.to)
end


--[[
	Region
    Value applied directly to temp
]]--
local regionValues = {
	--Solstheim
	["Moesring Mountains Region"]	 = -50,
	["Felsaad Coast Region"]		 = -46,
	["Isinfier Plains Region"]	 	 = -42,
	["Brodir Grove Region"]		 	 = -38,
	["Thirsk Region"]				 = -34,
	["Hirstaang Forest Region"]		 = -30,
	--Vvardenfell
	["Sheogorad Region"]			 = -20,
	["Azura's Coast Region"]		 = -10,
	["Ascadian Isles Region"]		 =   0, --Perfectly normal weather here
	["Grazelands Region"]			 =  10,
	["Bitter Coast Region"]			 =  20, --swamp: muggy. Can cool off in water but warm+wet=sick!
	["West Gash Region"]		 	 =  25, --Balmora doesn't seem too hot but Ald Ruh'n does...
	["Ashlands Region"]				 =  30,
	["Molag Amur Region"]			 =  40,
	["Red Mountain Region"]			 =  50, 
}
local function updateRegion(e)
	local regionName = e.cell.region and e.cell.region.name or ""
	common.data.regionTemp = regionValues[regionName] or 0
	updateWeather(tes3.getCurrentWeather())
end

--[[
	Time
	Coldest at midnight
	Hottest at midday
	Weather determines min/max values
]]--
function this.calculateTimeEffect()
	if not currentWeather then updateWeather(tes3.getCurrentWeather()) end
	local gameHour = tes3.getGlobal("GameHour")
	--This puts Midnight at 0, Midday at 12, in both directions
	local convertedTime = gameHour < 12 and gameHour or ( 12 - ( gameHour - 12) ) 

   
    --Clamp so temp stays the same for an hour at midday and midnight
    local timeTemp = math.clamp(convertedTime, 0.5, 11.5)
    --remap to temperature based on weather ranges
    timeTemp = math.remap( timeTemp, 0.5, 11.5, weatherValues[currentWeather].min, weatherValues[currentWeather].max )
    
	common.data.timeTemp = timeTemp
end


local registerOnce
local function dataLoaded()
	updateWeather(tes3.getCurrentWeather())
	common.data.weatherTemp = 0
    if not registerOnce then
        registerOnce = true
        event.register("cellChanged", updateRegion)
        event.register("weatherChangedImmediate", immediateChange)
        event.register("weatherTransitionFinished", transitionEnd)
    end
end

event.register("Ashfall:dataLoaded", dataLoaded)

return this



