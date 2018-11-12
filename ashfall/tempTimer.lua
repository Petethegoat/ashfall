--[[ Timer function for weather updates]]--

local calcTemp = require("mer.ashfall.tempEffects.calcTemp")

local weather = require("mer.ashfall.tempEffects.weather")
local wetness = require("mer.ashfall.tempEffects.wetness")
local condition = require("mer.ashfall.conditions")
local wetCondition = require("mer.ashfall.wetCondition")
local torch = require("mer.ashfall.tempEffects.torch")
local armorClothing = require("mer.ashfall.tempEffects.armorClothing")

local hud = require("mer.ashfall.ui.hud")

--How often the script should run in gameTime
local scriptInterval = 0.0005

local function callUpdates()
    calcTemp.calculateTemp(scriptInterval)
	weather.calculateTimeEffect()
	wetness.calcaulateWetTemp(scriptInterval)
    
    --For heavy scripts and those that don't need to be run while sleeping
	if tes3.menuMode() == false then
        torch.calculateTorchTemp()
		condition.updateConditionState()
		wetCondition.updateWetConditionState()
	end
	hud.updateUI()			
end

local function dataLoaded()
	callUpdates()
	timer.delayOneFrame(function()
		timer.start({duration = scriptInterval, callback = callUpdates, type = timer.game, iterations = -1})
	end)
	print("tempTimer.lua loaded successfully")
end

--Register functions
event.register("Ashfall:dataLoaded", dataLoaded)