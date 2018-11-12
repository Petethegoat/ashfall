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
--Data
local armorClothingData = require ("mer.ashfall.tempEffects.armorClothingData")
--Caches
local armorWarmthCache = mwse.loadConfig("ashfall/armor_warmth") or {}
local clothingWarmthCache = mwse.loadConfig("ashfall/clothing_warmth") or {}
local armorCoverageCache = mwse.loadConfig("ashfall/armor_coverage") or {}
local clothingCoverageCache = mwse.loadConfig("ashfall/clothing_coverage") or {}

local function calculateItemWarmth( itemStack, slotName, thisData, cache )
    local itemId = itemStack.object.id
    local itemName = itemStack.object.name   
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

local function calculateItemCoverage( itemStack, slotName, data, cache )
    local itemId = itemStack.object.id
    local itemName = itemStack.object.name   
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
    local totalWarmth = 0
    local totalCoverage = 0.0
    
    for slotName, armorSlot in pairs(tes3.armorSlot) do
        local armorStack = tes3.getEquippedItem({ actor = tes3.player, objectType = tes3.objectType.armor, slot = armorSlot })
        if armorStack 
        and armorSlot ~= tes3.armorSlot.shield 
        then
            local itemWarmth = calculateItemWarmth( armorStack, slotName, armorClothingData.armorData, armorWarmthCache )
            local itemCoverage = calculateItemCoverage(  armorStack, slotName, armorClothingData.armorData, armorCoverageCache )
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
    
    --For player to see
    common.data.armorTempRating = totalWarmth * armorClothingData.warmthRatingMultiplier
    common.data.armorCoverageRating = totalCoverage * armorClothingData.coverageRatingMultiplier
    
end

local function updateClothingValues()
    local totalWarmth = 0
    local totalCoverage = 0.0
    
    for slotName, clothingSlot in pairs(tes3.clothingSlot) do
        local clothingStack = tes3.getEquippedItem({ actor = tes3.player, objectType = tes3.objectType.clothing, slot = clothingSlot })
        if  clothingStack 
        and clothingSlot ~= tes3.clothingSlot.ring 
        and clothingSlot ~= tes3.clothingSlot.amulet
        and clothingSlot ~= tes3.clothingSlot.belt 
        then
            local itemWarmth = calculateItemWarmth( clothingStack, slotName, armorClothingData.clothingData, clothingWarmthCache )
            local itemCoverage = calculateItemCoverage(  clothingStack, slotName, armorClothingData.clothingData, clothingCoverageCache )
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
        tes3.messageBox("Warmth: " .. ( ( armorWarmthCache[e.item.id] or 0)  * armorClothingData.warmthRatingMultiplier ) 
            .. ", Coverage: " .. ( ( armorCoverageCache[e.item.id] or 0 ) * armorClothingData.coverageRatingMultiplier) )
    elseif e.item.objectType == tes3.objectType.clothing then
        tes3.messageBox("Warmth: " .. ( ( clothingWarmthCache[e.item.id] or 0)  * armorClothingData.warmthRatingMultiplier ) 
            .. ", Coverage: " .. ( ( clothingCoverageCache[e.item.id] or 0 ) * armorClothingData.coverageRatingMultiplier) )
    end
end


event.register("unequipped", calculate)
event.register("equipped", calculateEquipped)
event.register("Ashfall:dataLoaded", calculate)



return this