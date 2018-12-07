local common = require("mer.ashfall.common")
local this = {}

local coldRestLimit = common.tempConditions.veryCold.min
local hotRestLimit = common.tempConditions.veryHot.max
local interruptText = ""
local isScripted

local bedTemp = 20
local tentTemp = 35

local function setRestValues(e)
    if not common.data then return end
    --scripted means the player has activated a bed or bedroll
    isScripted = e.scripted
    --Set interrupt text
    local tempText
    local temp = common.data.tempLimit
    local tempText = ( temp < 0 ) and "cold" or "hot"
    local restText = ( e.allowRest ) and "rest" or "wait"
    interruptText = string.format("It is too %s to %s, you must find shelter!", tempText, restText)


end



--Prevent sleep if ENVIRONMENT is too cold/hot
--We do this by tapping into the Rest Menu,
--replacing the text and removing rest/wait buttons
local function activateRestMenu (e)
    if not common.data then return end

    if isScripted then
        local RestText = e.element:findChild(tes3ui.registerID("MenuRestWait_label_text"))
        local warmthRatingLabelText = string.format("Warmth Rating: %s", bedTemp)
        RestText.text = RestText.text .. " (" .. warmthRatingLabelText ..")"

        --manually update temp so you can see what it will be with the bedTemp added
        if common.data.tempLimit < 0 then
            common.data.bedTemp = bedTemp
            common.data.tempLimit = common.data.tempLimit + bedTemp
        end
        require("mer.ashfall.tempEffects.calcTemp").calculateTemp(0)
    end

    local temp = common.data.tempLimit + ( isScripted and common.bedTemp or 0 )
    if temp < ( coldRestLimit ) or temp > ( hotRestLimit - common.data.bedTemp ) then

        local restMenu = e.element
        
        local labelText = restMenu:findChild( tes3ui.registerID("MenuRestWait_label_text") )
        labelText.text = interruptText
        
        local hiddenList = {}
        hiddenList.scrollbar = restMenu:findChild( tes3ui.registerID("MenuRestWait_scrollbar") )
        hiddenList.hourText = restMenu:findChild( tes3ui.registerID("MenuRestWait_hour_text") )
        hiddenList.hourActualText = hiddenList.hourText.parent.children[2]
        hiddenList.untilHealed = restMenu:findChild( tes3ui.registerID("MenuRestWait_untilhealed_button") )
        hiddenList.wait = restMenu:findChild( tes3ui.registerID("MenuRestWait_wait_button") )
        hiddenList.rest = restMenu:findChild( tes3ui.registerID("MenuRestWait_rest_button") )

        for _, element in pairs(hiddenList) do
            element.visible = false
        end
        restMenu:updateLayout()
    end
end

--Wake up if sleeping and ENVIRONMENT is too cold/hot
function this.checkSleeping()
    --whether waiting or sleeping, wake up
    if tes3.menuMode() then
        if isScripted then
            --mwse.log("using bed")
            common.data.usingBed = true
            common.data.bedTemp = bedTemp
        --not using a bed at all
        else
           -- mwse.log("not using bed")
            common.data.usingBed = false
        end

        local temp = common.data.tempLimit
        if temp < coldRestLimit or temp > hotRestLimit then
            tes3.runLegacyScript({ command = "WakeUpPC" })
            tes3.messageBox({ message = interruptText, buttons = { "Okay" } })
        end
    else
        common.data.bedTemp = 0
    end
end

local insideTentGlobal = tes3.findGlobal("a_inside_tent")
function this.checkForTent()
    if insideTentGlobal.value == 1 then
        common.data.tentTemp = tentTemp
    end
end



event.register("uiActivated", activateRestMenu, { filter = "MenuRestWait" })
event.register("uiShowRestMenu", setRestValues )

return this