--[[
	Plugin: ashfall.esp
--]]
function onLoaded()
	-- set global to disable mwscripts
	tes3.setGlobal("a_lua_enabled", 1)
end

local function initialized()
	if tes3.isModActive("Ashfall.ESP") then
		event.register("loaded", onLoaded)
		-- load modules
		require ("mer.ashfall.common")
        
        --temp effect modules
		require ("mer.ashfall.tempEffects.scriptTimer")
        require("mer.ashfall.tempEffects.ratings.ratingEffects")
        
		
		require("mer.ashfall.harvest_wood")
		require("mer.ashfall.needs.thirst.thirstActivate")
		require("mer.ashfall.ui.hud")

		require("mer.ashfall.activators.bedroll")
        require("mer.ashfall.sleepController")   
		
		require("mer.ashfall.frostbreath")

		mwse.log("[Ashfall: INFO] Initialized Ashfall")
	end
end


--Need to initialise faders immediately
--require ("mer.ashfall.faderController")

event.register("initialized", initialized)
