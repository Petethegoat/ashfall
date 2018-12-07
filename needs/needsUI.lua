--[[
    Needs displayed in stats menu
]]--
local this = {}
local common = require("mer.ashfall.common")

local IDs = {
    hunger = {
        fillBar = tes3ui.registerID("Ashfall:hungerFillBar"),
        condition = tes3ui.registerID("Ashfall:hungerConditionId"),
        border = tes3ui.registerID("Ashfall:hungerBorder")
    },
    thirst = {
        fillBar = tes3ui.registerID("Ashfall:thirstFillBar"),
        condition = tes3ui.registerID("Ashfall:thirstConditionId"),
        border = tes3ui.registerID("Ashfall:thirstBorder")
    },
    sleep = {
        fillBar = tes3ui.registerID("Ashfall:sleepFillBar"),
        condition = tes3ui.registerID("Ashfall:sleepConditionId"),
        border = tes3ui.registerID("Ashfall:sleepBorder")
    }
}

function this.updateNeedsUI()
    if not common.data then return end
    local inventoryMenu = tes3ui.findMenu(tes3ui.registerID("MenuStat"))

    if inventoryMenu then   
        --Update Hunger
        local hungerFillBar = inventoryMenu:findChild(IDs.hunger.fillBar)
        local hungerConditionLabel = inventoryMenu:findChild(IDs.hunger.condition)
        if hungerFillBar and hungerConditionLabel then

            --update condition
            local condition = common.data.hungerCondition or "satiated"
            hungerConditionLabel.text = common.hungerConditions[ condition ].text or common.thirstConditions.satiated.text
            
            --update fillBar
            local hungerLevel = common.data.hunger or 0
            hungerFillBar.widget.current = 100 - hungerLevel
        end

        --Update Thirst
        local thirstFillBar = inventoryMenu:findChild(IDs.thirst.fillBar)
        local thirstConditionLabel = inventoryMenu:findChild(IDs.thirst.condition)
        if thirstFillBar and thirstConditionLabel then

            --update condition
            local condition = common.data.thirstCondition or "hydrated"
            thirstConditionLabel.text = common.thirstConditions[ condition ].text or common.thirstConditions.hydrated.text

            --update fillBar
            local thirstLevel = common.data.thirst or 0
            thirstFillBar.widget.current = 100 - thirstLevel
        end

        --Update Sleep
        local sleepFillBar = inventoryMenu:findChild(IDs.sleep.fillBar)
        local sleepConditionLabel = inventoryMenu:findChild(IDs.sleep.condition)
        if sleepFillBar and sleepConditionLabel then

            --update condition
            local condition = common.data.sleepCondition or "rested"
            sleepConditionLabel.text = common.sleepConditions[ condition].text or common.sleepConditions.rested.text

            --update fillBar
            local sleepLevel = common.data.sleep or 100
            sleepFillBar.widget.current = sleepLevel
        end
        inventoryMenu:updateLayout()
    end
end

local function setupNeedsBlock(element)
    element.borderAllSides = 4
    element.paddingTop = 6
    element.paddingLeft = 5
    element.paddingRight = 5
    element.paddingBottom = 2
    element.autoHeight = true
    element.autoWidth = true
    element.widthProportional = 1
    element.flowDirection = "top_to_bottom"
end


local function setupNeedsElementBlock(element)
    element.autoHeight = true
    element.autoWidth = true

    element.paddingBottom = 5
    element.widthProportional = 1
    element.flowDirection = "left_to_right"
end

local function setupNeedsBar(element)
    element.widget.showText = false
    element.height = 28
    element.widthProportional = 1.0
end

local function setupConditionLabel(element)
    element.absolutePosAlignX = 0.03
    element.absolutePosAlignY = 0.4
    element.widthProportional = 1.0
    element.wrapText = true
    element.justifyText = "center"
end

local function createNeedsUI(e)
    local leftPane = e.element:findChild(tes3ui.registerID("MenuStat_left_main"))


    ---Needs Block
    local needsBlock = leftPane:createThinBorder( )
    setupNeedsBlock(needsBlock)
    local needsHeader = needsBlock:createLabel({text = "Needs"})
    needsHeader.color = tes3ui.getPalette("header_color")
    needsHeader.borderBottom = 6


    --Hunger
    local hungerBlock = needsBlock:createBlock()
    setupNeedsElementBlock(hungerBlock)

    local hungerBar = hungerBlock:createFillBar({ id = IDs.hunger.fillBar, current = 100, max = 100 })
    setupNeedsBar(hungerBar)
    hungerBar.widget.fillColor = {(135/255), (6/255), (6/255)}

    local hungerConditionLabel = hungerBlock:createLabel({ id = IDs.hunger.condition, text = "Satiated"})
    setupConditionLabel(hungerConditionLabel)


    --Thirst
    local thirstBlock = needsBlock:createBlock()
    setupNeedsElementBlock(thirstBlock)

    local thirstBar = thirstBlock:createFillBar({ id = IDs.thirst.fillBar, current = 100, max = 100 })
    setupNeedsBar(thirstBar)
    thirstBar.widget.fillColor = {(0/255), (65/255), (95/255)}


    local thirstConditionLabel = thirstBlock:createLabel({ id = IDs.thirst.condition, text = "Hydrated"})
    setupConditionLabel(thirstConditionLabel)


    --Sleep
    local sleepBlock = needsBlock:createBlock()
    setupNeedsElementBlock(sleepBlock)

    local sleepBar = sleepBlock:createFillBar({ id = IDs.sleep.fillBar, current = 100, max = 100})
    setupNeedsBar(sleepBar)
    sleepBar.widget.fillColor = {(4/255), (114/255), (43/255)}

    local sleepConditionLabel = sleepBlock:createLabel({ id = IDs.sleep.condition, text = "Rested"})
    setupConditionLabel(sleepConditionLabel)

    
end

event.register("uiCreated", createNeedsUI, { filter = "MenuStat" } )

return this