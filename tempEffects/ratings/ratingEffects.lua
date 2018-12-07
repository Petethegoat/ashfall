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
local ratingsCommon = require ("mer.ashfall.tempEffects.ratings.ratingsCommon")
local armorClothingData = ratingsCommon.data
local ui = require("mer.ashfall.tempEffects.ratings.ratingUI")
local function updateArmorValues()
    if not common.data then return end
    
    local totalWarmth = 0
    local totalCoverage = 0.0
    
    for slotName, armorSlot in pairs(tes3.armorSlot) do
        local armorStack = tes3.getEquippedItem({ actor = tes3.player, objectType = tes3.objectType.armor, slot = armorSlot })
        local warmthData = armorClothingData.armorData.warmth
        local coverageData = armorClothingData.armorData.coverage
        if armorStack and ratingsCommon.isValidArmorSlot(armorSlot) then
            local itemWarmth = ratingsCommon.calculateItemWarmth( armorStack.object )
            local itemCoverage = ratingsCommon.calculateItemCoverage( armorStack.object )

            --Check slot type and remap values with realMultiplier
            local slotWarmMax = warmthData.slotRatios[slotName]
            local slotAdjustedWarmth = itemWarmth * slotWarmMax

            local slotCoverageMax = coverageData.slotRatios[slotName]
            local slotAdjustedCoverage = itemCoverage * slotCoverageMax

            --Add to total warmth           
            totalWarmth = totalWarmth + slotAdjustedWarmth
            totalCoverage = totalCoverage + slotAdjustedCoverage
        end
    end

    --Update temp
    common.data.armorTemp = totalWarmth
    common.data.armorCoverage = totalCoverage
    
    --Player-visible ratings
    common.data.armorTempRating = ratingsCommon.getWarmthRating(totalWarmth)
    common.data.armorCoverageRating = ratingsCommon.getCoverageRating(totalCoverage)
    
end



local function updateClothingValues()
    if not common.data then return end
    local totalWarmth = 0
    local totalCoverage = 0.0

    for slotName, clothingSlot in pairs(tes3.clothingSlot) do
        local clothingStack = tes3.getEquippedItem({ actor = tes3.player, objectType = tes3.objectType.clothing, slot = clothingSlot })

        if clothingStack and ratingsCommon.isValidClothingSlot( clothingSlot ) then
            local itemWarmth = ratingsCommon.calculateItemWarmth( clothingStack.object )
            local itemCoverage = ratingsCommon.calculateItemCoverage( clothingStack.object )

            --Check slot type and remap values
            local slotWarmMax = armorClothingData.clothingData.warmth.slotRatios[slotName]
            local slotAdjustedWarmth = itemWarmth * slotWarmMax

            local slotCoverageMax = armorClothingData.clothingData.coverage.slotRatios[slotName]
            local slotAdjustedCoverage = itemCoverage * slotCoverageMax

            --Add to total warmth           
            totalWarmth = totalWarmth + slotAdjustedWarmth
            totalCoverage = totalCoverage + slotAdjustedCoverage
        end
    end
    --Update temp
    common.data.clothingTemp = totalWarmth
    common.data.clothingCoverage = totalCoverage
    --Update Ratings (player visible)
    common.data.clothingTempRating = ratingsCommon.getWarmthRating(totalWarmth)
    common.data.clothingCoverageRating =  ratingsCommon.getCoverageRating(totalCoverage)
end


local function calculate()
     updateArmorValues()
     updateClothingValues()
     ui.updateArmorRatings()
end

event.register("uiCreated", ui.createArmorRatings, { filter = "MenuInventory" } )

event.register("unequipped", calculate)
event.register("equipped", calculate)
event.register("Ashfall:dataLoaded", calculate)
--event.register("loaded", calculate)



return this