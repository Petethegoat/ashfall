local this = {}
local common = require("mer.ashfall.common")
local ratingsCommon = require("mer.ashfall.tempEffects.ratings.armorClothingCommon")
local armorClothingData = ratingsCommon.data
local armorWarmthCache = ratingsCommon.armorWarmthCache
local clothingWarmthCache = ratingsCommon.clothingWarmthCache
local armorCoverageCache = ratingsCommon.armorCoverageCache
local clothingCoverageCache = ratingsCommon.clothingCoverageCache

local function quickFormat(element, padding)
	element.paddingAllSides = padding
	element.autoHeight = true
	element.autoWidth = true
	return element
end

--[[
    Create warmth and coverage ratings inside the Character Box in the inventory menu
]]
function this.createArmorRatings()
    tes3.messageBox("Menu created")
    local inventoryMenu = tes3ui.findMenu(tes3ui.registerID("MenuInventory"))
    if not inventoryMenu then
        tes3.messageBox("Menu doesn't exist")
        return
    end
    local characterBox = inventoryMenu:findChild(tes3ui.registerID("MenuInventory_character_box"))
    local outerBlock = characterBox:findChild(tes3ui.registerID("Ashfall:armorRatings"))
    if not outerBlock then
        outerBlock = characterBox:createBlock({ id = tes3ui.registerID("Ashfall:armorRatings") })
        outerBlock.flowDirection = "left_to_right"
        outerBlock.paddingTop = 2
        outerBlock.paddingBottom = 2
        outerBlock.paddingLeft = 5
        outerBlock.paddingRight = 5
        outerBlock.autoWidth = true
        outerBlock.autoHeight = true 

        warmthText = "Warmth: "
        local warmthLabel = outerBlock:createLabel({ id = tes3ui.registerID("Ashfall:WarmthRating"), text = warmthText }) 

        coverageText = "Coverage: "
        local coverageLabel = outerBlock:createLabel({ id = tes3ui.registerID("Ashfall:CoverageRating"), text = coverageText }) 

        --characterBox:reorderChildren(0, outerBlock, 1)

        inventoryMenu:updateLayout()
    end
end

--[[
    Update the warmth/coverage ratings in character box
]]
function this.updateArmorRatings()
    if not common.data then return end
    tes3.messageBox("Menu created")
    local inventoryMenu = tes3ui.findMenu(tes3ui.registerID("MenuInventory"))
    if inventoryMenu then
        local warmthLabel = inventoryMenu:findChild(tes3ui.registerID("Ashfall:WarmthRating"))
        local warmthValue = math.floor( common.data.armorTempRating + common.data.clothingTempRating )
        warmthLabel.text = "Warmth: " .. warmthValue .. "    "

        local coverageLabel = inventoryMenu:findChild(tes3ui.registerID("Ashfall:CoverageRating"))
        local coverageValue = math.floor( common.data.armorCoverageRating + common.data.clothingCoverageRating )
        coverageValue = math.clamp( coverageValue, 0, 100 )
        coverageLabel.text = "Coverage: " .. coverageValue

        inventoryMenu:updateLayout()
    end
end

--[[
    Insert ratings into Equipment tooltips
]]
function this.insertRatings(e)
    local tooltip = e.tooltip
    if not e.tooltip then return end
    if not e.object then return end
    local slot
    local data
    local warmthCache
    local coverageCache
    local isValidSlot

    if e.object.objectType == tes3.objectType.armor then
        slot = ratingsCommon.armorSlotDict[e.object.slot]
        data = armorClothingData.armorData
        warmthCache = armorWarmthCache
        coverageCache = armorCoverageCache
        isValidSlot = ratingsCommon.isValidArmorSlot( tes3.armorSlot[slot] )
    elseif e.object.objectType == tes3.objectType.clothing then
        slot = ratingsCommon.clothingSlotDict[e.object.slot]
        data = armorClothingData.clothingData
        warmthCache = clothingWarmthCache
        coverageCache = clothingCoverageCache
        isValidSlot = ratingsCommon.isValidClothingSlot( tes3.clothingSlot[slot] )
    end
    if isValidSlot then
        local partmenuID = tes3ui.registerID("PartHelpMenu_main")
        local innerBlock = tooltip:findChild(partmenuID):findChild(partmenuID):findChild(partmenuID)
       
        local statsIndex
        for i, element in ipairs(innerBlock.children) do
            if string.find(element.text, "Weight:") then
                statsIndex = i - 1
            end
            --But if Armor rating exists, put it after that
            if string.find(element.text, "Armor Rating:") then
                statsIndex = i 
                break
            end
        end
        
        
        local ratingsBlock = innerBlock:createBlock({ id = tes3ui.registerID("Ashfall:ratings_block") })
        ratingsBlock.flowDirection = "top_to_bottom"
        ratingsBlock.paddingTop = 0
        ratingsBlock.paddingBottom = 0
        ratingsBlock.paddingLeft = 6
        ratingsBlock.paddingRight = 6
        ratingsBlock.width = 300
        ratingsBlock.autoHeight = true
        
        local warmthBlock = ratingsBlock:createBlock({ id = tes3ui.registerID("Ashfall:ratings_warmthBlock") })
        warmthBlock.flowDirection = "left_to_right"
        warmthBlock.widthProportional = 1.0
        warmthBlock.childAlignX  = 0.5
        warmthBlock.autoHeight = true
        
        local warmthHeader = warmthBlock:createLabel({ id = tes3ui.registerID("Ashfall:ratings_warmthHeader"), text = "Warmth Rating: " })
        quickFormat(warmthHeader)
        --warmthHeader.color = tes3ui.getPalette("header_color")
        
        local warmth = " " .. ratingsCommon.getWarmthRating( ratingsCommon.calculateItemValue( e.object, slot, data.warmth, warmthCache ) )
        local warmthValue = warmthBlock:createLabel({ id = tes3ui.registerID("Ashfall:ratings_warmthValue"), text = warmth })
        warmthValue.autoHeight = true
        warmthValue.autoWidth = true
        
        local coverageBlock = ratingsBlock:createBlock({ id = tes3ui.registerID("Ashfall:ratings_coverageBlock") })
        coverageBlock.flowDirection = "left_to_right"
        coverageBlock.widthProportional = 1.0
        coverageBlock.childAlignX  = 0.5
        coverageBlock.autoHeight = true
        
        local coverageHeader = coverageBlock:createLabel({ id = tes3ui.registerID("Ashfall:ratings_coverageHeader"), text = "Coverage Rating: " })
        quickFormat(coverageHeader)
        --coverageHeader.color = tes3ui.getPalette("header_color")
        
        local coverage = " " .. ratingsCommon.getCoverageRating( ratingsCommon.calculateItemValue( e.object, slot, data.coverage,  coverageCache) )
        local coverageValue = coverageBlock:createLabel({ id = tes3ui.registerID("Ashfall:ratings_coverageValue"), text = coverage })
        coverageValue.autoHeight = true
        coverageValue.autoWidth = true            
        
        innerBlock:reorderChildren( statsIndex, ratingsBlock, -1 )
        innerBlock:updateLayout()
    end
end



return this