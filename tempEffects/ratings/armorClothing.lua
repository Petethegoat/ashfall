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
local ratingsCommon = require ("mer.ashfall.tempEffects.ratings.armorClothingCommon")
local armorClothingData = ratingsCommon.data
local ui = require("mer.ashfall.tempEffects.ratings.ratingUI")

local armorWarmthCache = ratingsCommon.armorWarmthCache
local clothingWarmthCache = ratingsCommon.clothingWarmthCache
local armorCoverageCache = ratingsCommon.armorCoverageCache
local clothingCoverageCache = ratingsCommon.clothingCoverageCache

local function updateArmorValues()
    if not common.data then return end
    
    local totalWarmth = 0
    local totalCoverage = 0.0
    
    for slotName, armorSlot in pairs(tes3.armorSlot) do
        local armorStack = tes3.getEquippedItem({ actor = tes3.player, objectType = tes3.objectType.armor, slot = armorSlot })
        if armorStack and ratingsCommon
    .isValidArmorSlot(armorSlot) then
            local itemWarmth = ratingsCommon.calculateItemValue( armorStack.object, slotName, armorClothingData.armorData.warmth, armorWarmthCache )
            local itemCoverage = ratingsCommon.calculateItemValue(  armorStack.object, slotName, armorClothingData.armorData.coverage, armorCoverageCache )
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

        if clothingStack and ratingsCommon.isValidClothingSlot( clothingSlot ) then
            local itemWarmth = ratingsCommon.calculateItemValue( clothingStack.object, slotName, armorClothingData.clothingData.warmth, clothingWarmthCache )
            local itemCoverage = ratingsCommon.calculateItemValue(  clothingStack.object, slotName, armorClothingData.clothingData.coverage, clothingCoverageCache )
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
     ui.updateArmorRatings()
end

local function calculateEquipped(e)
    updateArmorValues()
    updateClothingValues()
    ui.updateArmorRatings()
    if e.item.objectType == tes3.objectType.armor then
        tes3.messageBox(
            "Warmth: " .. ratingsCommon.getWarmthRating( armorWarmthCache[e.item.id] or 0) 
            .. ", Coverage: " .. ratingsCommon.getCoverageRating( ( armorCoverageCache[e.item.id] or 0 ) ) 
        )
    elseif e.item.objectType == tes3.objectType.clothing then
        tes3.messageBox(
            "Warmth: " .. ratingsCommon.getWarmthRating( ( clothingWarmthCache[e.item.id] or 0 ) )
            .. ", Coverage: " .. ratingsCommon.getCoverageRating( ( clothingCoverageCache[e.item.id] or 0 ) ) 
        )
    end
end


event.register("uiCreated", ui.createArmorRatings, { filter = "MenuInventory" } )

event.register("unequipped", calculate)
event.register("equipped", calculateEquipped)
event.register("Ashfall:dataLoaded", calculate)

event.register("uiObjectTooltip", ui.insertRatings )

return this