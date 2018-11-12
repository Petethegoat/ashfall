--timeEffect
--[[local this = {}

local common = require("mer.ashfall.common")


local timeTempRange = 80

function this.calculateTimeEffect()
	local gameHour = tes3.getGlobal("GameHour")
	local convertedTime = gameHour > 12 and gameHour - 12 or  12 - gameHour
	--Round off the edges so midday and midnight last a couple hours
	convertedTime = convertedTime < 1 and 1 or convertedTime
	convertedTime = convertedTime > 11 and 11 or convertedTime
	convertedTime = convertedTime - 1 -- recalibrate to 0-10
	convertedTime = convertedTime / 10 * timeTempRange
	common.data.timeTemp = (timeTempRange / 2) - convertedTime
end

return this]]--