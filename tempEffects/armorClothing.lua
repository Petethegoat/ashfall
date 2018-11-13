--[[
    Get Clothing and Armor warmth and coverage values
    
    Coverage between 0 and 0.90. At 0.90, you get wet very very slowly in the rain (still do from swimming)
]]--

-------CONFIG VALUES-------
--Coverage
--local maxCoverage = 0.9

--Should add up to 1.0
-- Then multiplied by maxTotalWarmth

---------------------------
local this = {}

local common = require("mer.ashfall.common")
local armorClothingData = require ("mer.ashfall.tempEffects.armorClothingData")
--Cache values for faster processing
local armorWarmthCache = mwse.loadConfig("ashfall/armor_warmth") or {}
local clothingWarmthCache = mwse.loadConfig("ashfall/clothing_warmth") or {}
local armorCoverageCache = mwse.loadConfig("ashfall/armor_coverage") or {}
local clothingCoverageCache = mwse.loadConfig("ashfall/clothing_coverage") or {}


--Get ratings from raw values for individual items
local function getWarmthRating( rawValue )
    return math.floor( rawValue * armorClothingData.warmthRatingMultiplier )
end

local function getCoverageRating( rawValue )
    return math.floor( rawValue * armorClothingData.coverageRatingMultiplier )
end

local function isValidArmorSlot( armorSlot )
    return armorSlot ~= tes3.armorSlot.shield
end
local function isValidClothingSlot( clothingSlot )
    return(
        clothingSlot ~= tes3.clothingSlot.ring  
        and clothingSlot ~= tes3.clothingSlot.amulet 
        and clothingSlot ~= tes3.clothingSlot.belt 
    )
end

local function calculateItemWarmth( item, slotName, thisData, cache )
    local itemId = item.id
    local itemName = item.name   
    local thisWarmth
    --Check if warmth value exists in config file
    for id, val in pairs(cache) do
        if itemId == id then
            thisWarmth = val
            break
        end
    end
    --Otherwise calculate
    if not thisWarmth then
        --Check name patterns
        for pattern, val in pairs(thisData.warmthRatings) do
            if string.find(itemName, pattern) then
                thisWarmth = val
                break
            end
        end
        --No pattern, default
        if not thisWarmth then
            thisWarmth = thisData.defaultWarmth
        end
        --Check slot type and remap values
        local slotMax = thisData.slotRatios[slotName]
        print("Item: " .. itemName .. ", warmth: " .. thisWarmth .. ", slotMax: " .. slotMax .. ", warmthMax: " .. armorClothingData.warmthRealMultiplier )
        thisWarmth = math.remap( thisWarmth, 0, 100, 0, slotMax ) * armorClothingData.warmthRealMultiplier
        print("Final warmth: " .. thisWarmth )
    end
    return thisWarmth
end

local function calculateItemCoverage( item, slotName, data, cache )
    local itemId = item.id
    local itemName =item.name   
    local thisCoverage
    --Check if coverage value exists in config file
    for id, val in pairs(cache) do
        if itemId == id then
            thisCoverage = val
            break
        end
    end
    --Otherwise calculate
    if not thisCoverage then
        --Check name patterns
        for pattern, val in pairs(data.coverageRatings) do
            if string.find(itemName, pattern) then
                thisCoverage = val
                break
            end
        end
        --No pattern, default
        if not thisCoverage then
            thisCoverage = data.defaultCoverage
        end
        --Check slot type and remap values
        local slotMax = data.slotRatios[slotName]
        print("Item: " .. itemName .. ", coverage: " .. thisCoverage .. ", slotMax: " .. slotMax .. ", coverageMax: " .. armorClothingData.coverageRealMultiplier )
        thisCoverage = math.remap( thisCoverage, 0, 100, 0, slotMax ) * armorClothingData.coverageRealMultiplier
        print("Final coverage: " .. thisCoverage )
    end
    return thisCoverage
end


local function updateArmorValues()
    if not common.data then return end
    
    local totalWarmth = 0
    local totalCoverage = 0.0
    
    for slotName, armorSlot in pairs(tes3.armorSlot) do
        local armorStack = tes3.getEquippedItem({ actor = tes3.player, objectType = tes3.objectType.armor, slot = armorSlot })
        if armorStack and isValidArmorSlot(armorSlot)
        then
            local itemWarmth = calculateItemWarmth( armorStack.object, slotName, armorClothingData.armorData, armorWarmthCache )
            local itemCoverage = calculateItemCoverage(  armorStack.object, slotName, armorClothingData.armorData, armorCoverageCache )
            --update Cache
            armorWarmthCache[armorStack.object.id] = itemWarmth
            armorCoverageCache[armorStack.object.id] = itemCoverage
            --Add to total warmth           
            totalWarmth = totalWarmth + itemWarmth
            totalCoverage = totalCoverage + itemCoverage
        end
    end
    --Save to cache
    mwse.saveConfig( "ashfall/armor_warmth", armorWarmthCache )
    mwse.saveConfig( "ashfall/armor_coverage", armorCoverageCache )
    --Update temp
    common.data.armorTemp = totalWarmth
    common.data.armorCoverage = totalCoverage
    
    --Player-visible ratings
    common.data.armorTempRating = totalWarmth * armorClothingData.warmthRatingMultiplier
    common.data.armorCoverageRating = totalCoverage * armorClothingData.coverageRatingMultiplier
    
end



local function updateClothingValues()
    if not common.data then return end
    local totalWarmth = 0
    local totalCoverage = 0.0
    
    for slotName, clothingSlot in pairs(tes3.clothingSlot) do
        local clothingStack = tes3.getEquippedItem({ actor = tes3.player, objectType = tes3.objectType.clothing, slot = clothingSlot })

        if clothingStack and isValidClothingSlot( clothingSlot ) then
            local itemWarmth = calculateItemWarmth( clothingStack.object, slotName, armorClothingData.clothingData, clothingWarmthCache )
            local itemCoverage = calculateItemCoverage(  clothingStack.object, slotName, armorClothingData.clothingData, clothingCoverageCache )
            --update Cache
            clothingWarmthCache[clothingStack.object.id] = itemWarmth
            clothingCoverageCache[clothingStack.object.id] = itemCoverage
            --Add to total warmth           
            totalWarmth = totalWarmth + itemWarmth
            totalCoverage =  totalCoverage + itemCoverage
        end
    end
    --Save to cache
    mwse.saveConfig( "ashfall/clothing_warmth", clothingWarmthCache )
    mwse.saveConfig( "ashfall/clothing_coverage", clothingCoverageCache )
    --Update temp
    common.data.clothingTemp = totalWarmth
    common.data.clothingCoverage = totalCoverage
    --For player to see
    common.data.clothingTempRating = totalWarmth * armorClothingData.warmthRatingMultiplier
    common.data.clothingCoverageRating =  totalCoverage * armorClothingData.coverageRatingMultiplier
end

local function calculate()
     updateArmorValues()
     updateClothingValues()
end

local function calculateEquipped(e)
    updateArmorValues()
    updateClothingValues()
    if e.item.objectType == tes3.objectType.armor then
        tes3.messageBox(
            "Warmth: " .. getWarmthRating( armorWarmthCache[e.item.id] or 0) 
            .. ", Coverage: " .. getCoverageRating( ( armorCoverageCache[e.item.id] or 0 ) ) 
        )
    elseif e.item.objectType == tes3.objectType.clothing then
        tes3.messageBox(
            "Warmth: " .. getWarmthRating( ( clothingWarmthCache[e.item.id] or 0 ) )
            .. ", Coverage: " .. getCoverageRating( ( clothingCoverageCache[e.item.id] or 0 ) ) 
        )
    end
end

local function quickFormat(element, padding)
	element.paddingAllSides = padding
	element.autoHeight = true
	element.autoWidth = true
	return element
end

local armorSlotDict = {}
for name, slot in pairs(tes3.armorSlot) do
    armorSlotDict[slot] = name
end
local clothingSlotDict = {}
for name, slot in pairs(tes3.clothingSlot) do
    clothingSlotDict[slot] = name
end

local function insertRatings(e)
    local tooltip = e.tooltip
    if not e.tooltip then return end
    if not e.object then return end
    if e.object.objectType == tes3.objectType.armor then
        if isValidArmorSlot( e.object.slot ) then
            
            local ratingsBlock = tooltip:createBlock({ id = tes3ui.registerID("Ashfall:ratings_block") })
            ratingsBlock.flowDirection = "left_to_right"
            ratingsBlock.paddingTop = 6
            ratingsBlock.paddingBottom = 12
            ratingsBlock.paddingLeft = 6
            ratingsBlock.paddingRight = 6
            ratingsBlock.width = 300
            ratingsBlock.autoHeight = true
            
            local warmthBlock = ratingsBlock:createBlock({ id = tes3ui.registerID("Ashfall:ratings_warmthBlock") })
            warmthBlock.flowDirection = "left_to_right"
            warmthBlock.widthProportional = 1.0
            warmthBlock.childAlignX  = 0.5
            warmthBlock.autoHeight = true
            
            local warmthHeader = warmthBlock:createLabel({ id = tes3ui.registerID("Ashfall:ratings_warmthHeader"), text = "Warmth: " })
            quickFormat(warmthHeader)
            --warmthHeader.color = tes3ui.getPalette("header_color")
            
            local warmth = " " .. getWarmthRating( calculateItemWarmth( e.object, armorSlotDict[e.object.slot], armorClothingData.armorData, armorWarmthCache ) )
            local warmthValue = warmthBlock:createLabel({ id = tes3ui.registerID("Ashfall:ratings_warmthValue"), text = warmth })
            warmthValue.autoHeight = true
            warmthValue.autoWidth = true
            
            local coverageBlock = ratingsBlock:createBlock({ id = tes3ui.registerID("Ashfall:ratings_coverageBlock") })
            coverageBlock.flowDirection = "left_to_right"
            coverageBlock.widthProportional = 1.0
            coverageBlock.childAlignX  = 0.5
            coverageBlock.autoHeight = true
            
            local coverageHeader = coverageBlock:createLabel({ id = tes3ui.registerID("Ashfall:ratings_coverageHeader"), text = "Coverage: " })
            quickFormat(coverageHeader)
            --coverageHeader.color = tes3ui.getPalette("header_color")
            
            local coverage = " " .. getCoverageRating( calculateItemCoverage( e.object, armorSlotDict[e.object.slot], armorClothingData.armorData, armorCoverageCache ) )
            local coverageValue = coverageBlock:createLabel({ id = tes3ui.registerID("Ashfall:ratings_coverageValue"), text = coverage })
            coverageValue.autoHeight = true
            coverageValue.autoWidth = true            
            
            
            ratingsBlock:updateLayout()
        end
    end
end

event.register("unequipped", calculate)
event.register("equipped", calculateEquipped)
event.register("Ashfall:dataLoaded", calculate)

event.register("uiObjectTooltip", insertRatings )

return this