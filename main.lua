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
		require ("mer.ashfall.tempTimer")
		
		require("mer.ashfall.harvest_wood")
		require("mer.ashfall.drinking")
		require("mer.ashfall.ui.hud")

		require("mer.ashfall.activators.bedroll")
        require("mer.ashfall.sleepController")   
		
		print("Initialized Ashfall")
	end
end

--Need to initialise faders immediately
require ("mer.ashfall.faderController")

event.register("initialized", initialized)
