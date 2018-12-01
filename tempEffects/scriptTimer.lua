--[[ Timer function for weather updates]]--

local calcTemp = require("mer.ashfall.tempEffects.calcTemp")

local weather = require("mer.ashfall.tempEffects.weather")
local wetness = require("mer.ashfall.tempEffects.wetness")
local condition = require("mer.ashfall.conditions")
local wetCondition = require("mer.ashfall.wetCondition")
local torch = require("mer.ashfall.tempEffects.torch")
local raceEffects = require("mer.ashfall.tempEffects.raceEffects")
local fireEffect = require("mer.ashfall.tempEffects.fireEffect")
local magicEffects = require("mer.ashfall.tempEffects.magicEffects")
local hazardEffects = require("mer.ashfall.tempEffects.hazardEffects")

local frostBreath = require("mer.ashfall.frostBreath")
local hud = require("mer.ashfall.ui.hud")
local sleepController = require("mer.ashfall.sleepController")   

--Needs
local needsUI = require("mer.ashfall.needs.needsUI")
local thirst = require("mer.ashfall.needs.thirst.thirstCalculate")

--How often the script should run in gameTime
local scriptInterval = 0.0005

local function callUpdates()
    calcTemp.calculateTemp(scriptInterval)
	weather.calculateWeatherEffect()
	wetness.calcaulateWetTemp(scriptInterval)
	thirst.calculateThirstLevel(scriptInterval)
	sleepController.checkSleeping()
	--Needs:

    --For heavy scripts and those that don't need to be run while sleeping
	if tes3.menuMode() == false then
		--temp effects
        raceEffects.calculateRaceEffects()
        torch.calculateTorchTemp()
		fireEffect.calculateFireEffect()
		magicEffects.calculateMagicEffects()
		hazardEffects.calculateHazards()
		--conditions
		condition.updateConditionState()
		wetCondition.updateWetConditionState()
		--visuals
		frostBreath.doFrostBreath()
		needsUI.updateNeedsUI()
	end
	hud.updateHUD()
end

local function dataLoaded()
	callUpdates()
	timer.delayOneFrame(function()
		timer.start({duration = scriptInterval, callback = callUpdates, type = timer.game, iterations = -1})
	end)
end

--Register functions
event.register("Ashfall:dataLoaded", dataLoaded)
event.register("loaded", dataLoaded)