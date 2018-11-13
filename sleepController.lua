local common = require("mer.ashfall.common")

local coldRestLimit = common.conditionValues.veryCold.min
local hotRestLimit = common.conditionValues.veryHot.max

local interruptText = ""
local isScripted

local function setRestValues(e)
    --scripted means the player has activated a bed or bedroll
    if e.scripted then
        isScripted = true
    else
        isScripted = false
    end
    --Set interrupt text
    local tempText
    local temp = common.data.tempLimit
	if temp <= 0 then
        tempText = "cold"
    elseif temp >= 0 then
        tempText = "hot"
    end
    local restText
    if e.allowRest then
        restText = "rest"
    else
        restText = "wait"
    end     
    interruptText = "It is too " .. tempText .. " to " .. restText .. ". You must find shelter."
end



--Prevent sleep if ENVIRONMENT is too cold/hot
local function activateRestMenu (e)
    local temp = common.data.tempLimit
    if isScripted then
        temp = temp + common.bedTemp
    end
    if temp < coldRestLimit or temp > hotRestLimit then
        local restMenu = e.element
        local labelText = restMenu:findChild( tes3ui.registerID("MenuRestWait_label_text") )
        labelText.text = interruptText

        
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

--Wake up if sleeping and PLAYER is too cold/hot
local function checkSleeping()
    if tes3.menuMode() then
        local temp = common.data.tempPlayer
        if isScripted then
            temp = temp + common.bedTemp
        end
        if temp < coldRestLimit or temp > hotRestLimit then
            tes3.runLegacyScript({ command = "WakeUpPC" })
            tes3.messageBox({ message = interruptText, buttons = { "Okay" } })
		end
	end
end

local registerOnce
local function dataLoaded()
    timer.start({ type = timer.game, duration = 0.01, iterations = -1, callback = checkSleeping })
    if not registerOnce then
        registerOnce = true
        event.register("uiActivated", activateRestMenu, { filter = "MenuRestWait" })
        event.register("uiShowRestMenu", setRestValues )
    end
end
event.register("Ashfall:dataLoaded", dataLoaded )
