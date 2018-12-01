--[[
    Needs displayed in stats menu
]]--
local this = {}
local common = require("mer.ashfall.common")

local needsBlockId = tes3ui.registerID("Ashfall:NeedsBlock")
local thirstValueId = tes3ui.registerID("Ashfall:thirstValue")

local HungerBlockId = tes3ui.registerID("Ashfall:hungerBlock")
local sleepBlockId = tes3ui.registerID("Ashfall:sleepBlock")


function this.updateNeedsUI()
    if not common.data then return end
    local inventoryMenu = tes3ui.findMenu(tes3ui.registerID("MenuStat"))

    if inventoryMenu then   
        local thirstLabel = inventoryMenu:findChild(thirstValueId)
        if not thirstLabel then return end

        local thirstVal = common.data.thirst or 0
        local thirstCondition = common.data.thirstCondition or "THIRSTY"
        local thirstText = string.format("%d", thirstVal)

        thirstLabel.text = thirstText

        inventoryMenu:updateLayout()
    end
end

local function createNeedsUI(e)
    local leftPane = e.element:findChild(tes3ui.registerID("MenuStat_left_main"))
    local needsBlock = leftPane:createThinBorder(needsBlockId)
    needsBlock.borderAllSides = 4
    needsBlock.paddingTop = 6
    needsBlock.paddingBottom = 6
    needsBlock.paddingLeft = 3
    needsBlock.paddingRight = 5
    
    needsBlock.autoHeight = true
    needsBlock.autoWidth = true
    needsBlock.widthProportional = 1
    needsBlock.flowDirection = "top_to_bottom"

    local needsHeader = needsBlock:createLabel({text = "Needs"})
    needsHeader.color = tes3ui.getPalette("header_color")

    local thirstBlock = needsBlock:createBlock()
    thirstBlock.autoHeight = true
    thirstBlock.autoWidth = true
    thirstBlock.widthProportional = 1
    thirstBlock.paddingLeft = 8
    thirstBlock.flowDirection = "left_to_right"
    local thirstHeader = thirstBlock:createLabel({text = "Thirst"})
    

    local thirstValLabel = thirstBlock:createLabel({ id = thirstValueId, text = ""})
    thirstValLabel.absolutePosAlignX = 1.0
end

event.register("uiCreated", createNeedsUI, { filter = "MenuStat" } )

return this