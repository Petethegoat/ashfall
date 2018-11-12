local common = require("mer.ashfall.common")


local function checkSleeping()
    --Wake if sleeping and cold
	if common.data.tempLimit < common.conditionValues.veryCold.max then
		if tes3.menuMode() then
			tes3.runLegacyScript({ command = "WakeUpPC" })
			tes3.messageBox({ message = "It is too cold to sleep, you must find shelter!", buttons = {"Okay"} })
		end
	end
end

local allowRest
local scripted

local function checkCanSleep(e)
   allowRest = e.allowRest
   scripted = e.scripted
end

--Prevent sleep if environment is too cold
local function changeRestMenu (e)
    local temp = common.data.tempLimit
    
    --scripted means the player has activated a bed or bedroll
    if scripted then
        temp = temp + common.bedTemp
    end
        
    --If it's too cold, prevent player from sleeping
	if temp < common.conditionValues.veryCold.max then
        local restMenu = e.element
        
        local labelText = restMenu:findChild( tes3ui.registerID("MenuRestWait_label_text") )
        if allowRest then
            labelText.text = "It is too cold to rest. You must find shelter."
        else
            labelText.text = "It is too cold to wait. You must find shelter."
        end
        
        local scrollbar = restMenu:findChild( tes3ui.registerID("MenuRestWait_scrollbar") )
        scrollbar.visible = false
        local hourText = restMenu:findChild( tes3ui.registerID("MenuRestWait_hour_text") )
        hourText.visible = false
        local hourActualText = hourText.parent.children[2]
        hourActualText.visible = false
        local untilHealed = restMenu:findChild( tes3ui.registerID("MenuRestWait_untilhealed_button") )
        untilHealed.visible = false
        local wait = restMenu:findChild( tes3ui.registerID("MenuRestWait_wait_button") )
        wait.visible = false
        local rest = restMenu:findChild( tes3ui.registerID("MenuRestWait_rest_button") )
        rest.visible = false
        
        restMenu:updateLayout()
	end
end

local registerOnce
local function dataLoaded()
    timer.start({ type = timer.game, duration = 0.01, iterations = -1, callback = checkSleeping })
    if not registerOnce then
        registerOnce = true
        event.register("uiActivated", changeRestMenu, { filter = "MenuRestWait" })
        event.register("uiShowRestMenu", checkCanSleep )
    end
end
event.register("Ashfall:dataLoaded", dataLoaded )
