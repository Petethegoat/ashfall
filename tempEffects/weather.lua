--[[

This script gets region and weather info on cell change/weather change

]]--
local this = {}
local common = require("mer.ashfall.common")

--[[
	Weather
	Determines the min and max value of weatherTemp
]]--
local currentWeather

local weatherValues = { 
	[tes3.weather.blight]	= {	min	= -30	, max =  40  },
	[tes3.weather.ash] 		= {	min	= -30	, max =  35 },
	[tes3.weather.clear] 	= {	min	= -50	, max =  20	 },
	[tes3.weather.cloudy] 	= {	min	= -55	, max =  0	 },
	[tes3.weather.overcast] = {	min	= -60	, max = -5	 },
	[tes3.weather.foggy] 	= {	min	= -65	, max = -10 },
	[tes3.weather.rain] 	= {	min	= -70	, max = -30	 },
	[tes3.weather.thunder] 	= {	min	= -75	, max = -40	 },
	[tes3.weather.snow] 	= {	min	= -90	, max = -50	 },
	[tes3.weather.blizzard] = {	min	= -95	, max = -70	 }
}

--Alter min/max weather values 
local regionValues = {
	["Moesring Mountains Region"]	= {	min	= -50 , max =  -50 },
	["Felsaad Coast Region"]		= {	min	= -45 , max =  -50 },
	["Isinfier Plains Region"]	 	= {	min	= -40 , max =  -40 },
	["Brodir Grove Region"]		 	= {	min	= -40 , max =  -40 },
	["Thirsk Region"]				= {	min	= -35 , max =  -35 },
	["Hirstaang Forest Region"]		= {	min	= -35 , max =  -35 },
	--Vvardenfell
	--Cold
	["Sheogorad"]			 		= {	min	= -30 , max =  -30 },
	["Azura's Coast Region"]		= {	min	= -20 , max =  -20 },
	--Normal
	["Ascadian Isles Region"]		= {	min	= 0 , max =  0 }, --Perfectly normal weather here
	["Grazelands Region"]			= {	min	= -10 , max =  20 },-- gets cold at night, warm in day
	--Hot
	["Bitter Coast Region"]			= {	min	= 10 , max =  10 }, 
	["West Gash Region"]		 	= {	min	= 10 , max =  30 },
	["Ashlands Region"]				= {	min	= 30 , max =  40 },
	["Molag Mar Region"]			= {	min	= 50 , max =  50 },
	["Red Mountain Region"]			= {	min	= 50 , max =  60 },
}

--Keyword search in interior names for cold caves etc
local interiorValues = {
	[" Sewers"] 	= -5,
	[" Eggmine"] 	= -5,
	[" Egg Mine"] 	= -5,
	[" Grotto"] 	= -5,
	[" Dungeon"]	= -10,
	[" Tomb"] 		= -15,
	[" Crypt"] 		= -15,
	[" Catacomb"] 	= -15,
	[" Cave"] 		= -20,
	[" Barrow"] 	= -30
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

function this.calculateWeatherEffect()
	if not currentWeather then updateWeather(tes3.getCurrentWeather()) end
	local regionID = tes3.player.cell.region and tes3.player.cell.region.id or ""

	local gameHour = tes3.getGlobal("GameHour")
	--This puts Midnight at 0, Midday at 12, in both directions
	local convertedTime = gameHour < 12 and gameHour or ( 12 - ( gameHour - 12) ) 
    --Clamp so temp stays the same for an hour at midday and midnight
    local weatherTemp = math.clamp(convertedTime, 0.5, 11.5)
	--remap to temperature based on weather ranges and region effects
	local min =  weatherValues[currentWeather].min + ( regionValues[regionID] and regionValues[regionID].min or 0 )
	local max = weatherValues[currentWeather].max +  ( regionValues[regionID] and regionValues[regionID].max or 0 )
    weatherTemp = math.remap( weatherTemp, 0.5, 11.5, min, max )
    
	common.data.weatherTemp = weatherTemp
end


local function cellChanged(e)
	updateWeather(tes3.getCurrentWeather())
	local intWeatherEffect = 0
	tes3.messageBox("cell ID: %s", e.cell.id)
	for key, val in pairs(interiorValues) do
		if string.find(e.cell.id, key) then
			tes3.messageBox("key: %s, val: %s", key, val)
			intWeatherEffect = val
		end
	end
	common.data.intWeatherEffect = intWeatherEffect
end

local registerOnce
local function dataLoaded()
	updateWeather(tes3.getCurrentWeather())
	common.data.weatherTemp = 0
    if not registerOnce then
        registerOnce = true
        event.register("cellChanged", cellChanged)
        event.register("weatherChangedImmediate", immediateChange)
        event.register("weatherTransitionFinished", transitionEnd)
    end
end

event.register("Ashfall:dataLoaded", dataLoaded)

return this



