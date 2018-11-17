local this = {}

this.data = {
    warmthRatingMultiplier = 10,
    coverageRatingMultiplier = 100,
    warmthRealMultiplier = 12,
    coverageRealMultiplier = 1.0,
    armorData = 
    {
        warmth = {
            type = "warmth",
            slotRatios = 
            {
                ["helmet"]          = 0.100,
                ["cuirass"]         = 0.200,
                ["leftPauldron"]    = 0.100,
                ["rightPauldron"]   = 0.100,
                ["greaves"]         = 0.150,
                ["boots"]           = 0.100,
                ["leftGauntlet"]    = 0.075,
                ["rightGauntlet"]   = 0.075,
                ["leftBracer"]      = 0.050,
                ["rightBracer"]     = 0.050,
            },
            default = 35,
            enchanted = 50,
            values = 
            {
                ["Adamantium "]     = 20,
                ["Bear "]           = 100,
                ["Bonemold "]       = 35,
                ["Chitin "]         = 30,
                ["Cloth "]          = 50,
                ["Colovian "]       = 60,
                ["Daedric "]        = 75,
                ["Dark B"]          = 35,
                ["Dreugh "]         = 30,
                ["Dwemer "]         = 20,
                ["Ebony "]          = 35,
                ["Fire "]           = 100,
                ["Frost "]           = 0,
                ["Glass " ]         = 10,
                ["Gondolier"]       = 20,
                ["Her Hand" ]       = 30,
                ["Ice Armor "]      = 0,
                ["Imperial Chain"]  = 20,
                ["Imperial Silv"]   = 25,
                ["Imperial Steel"]  = 30,
                ["Imperial Templ "] = 35,
                ["Indoril "]        = 40,
                ["Iron "]           = 15,
                ["Netch "]          = 45,
                ["Nordic Fur "]     = 30,
                ["Nordic Mail"]     = 45,
                ["Nordic Troll"]    = 50,
                ["Nordic Iron"]     = 40,
                ["Nordic leather"]  = 65,
                ["Orcich"]          = 25,
                ["Redoran"]         = 30,
                ["Royal G"]         = 35,
                ["Slave"]           = 25,
                ["Steel"]           = 20,
                ["Telvanni "]       = 60,
                ["Wolf "]           = 110,
            }
        },
        coverage = {
            type = "coverage",
            slotRatios = 
            {
                ["helmet"]          = 0.15,
                ["cuirass"]         = 0.20,
                ["leftPauldron"]    = 0.10,
                ["rightPauldron"]   = 0.10,
                ["greaves"]         = 0.20,
                ["boots"]           = 0.10,
                ["leftGauntlet"]    = 0.05,
                ["rightGauntlet"]   = 0.05,
                ["leftBracer"]      = 0.05,
                ["rightBracer"]     = 0.05,
            },
            default = 50,
            enchanted = 80,
            values = 
            {
                ["Adamantium "]     = 70,
                ["Bear "]           = 45,
                ["Bonemold "]       = 65,
                ["Chitin "]         = 40,
                ["Cloth "]          = 25,
                ["Colovian "]       = 30,
                ["Daedric "]        = 70,
                ["Dark B"]          = 65,
                ["Dreugh "]         = 95,
                ["Dwemer "]         = 80,
                ["Ebony "]          = 85,
                ["Glass " ]         = 85,
                ["Gondolier"]       = 100,
                ["Her Hand" ]       = 60,
                ["Ice Armor "]      = 85,
                ["Imperial Chain"]  = 30,
                ["Imperial Silv"]   = 75,
                ["Imperial Steel"]  = 70,
                ["Imperial Templ "] = 70,
                ["Indoril "]        = 60,
                ["Iron "]           = 65,
                ["Netch "]          = 50,
                ["Nordic Fur "]     = 30,
                ["Nordic Mail"]     = 35,
                ["Nordic Troll"]    = 60,
                ["Nordic Iron"]     = 65,
                ["Nordic leather"]  = 55,
                ["Orcich"]          = 75,
                ["Redoran"]         = 60,
                ["Royal G"]         = 75,
                ["Slave"]           = 10,
                ["Steel"]           = 75,
                ["Telvanni "]       = 85,
                ["Wolf "]           = 35,
            }
        }



    },
    clothingData = {
        warmth = {
            type = "warmth",
            slotRatios =  
            {   --These don't have to add up to 1.0 because of layering
                --"1.0" Total is like, a basic set of gear, not fully kitted out
                ["pants"]       = 0.30,
                ["shoes"]       = 0.15,
                ["shirt"]       = 0.30,
                ["robe"]        = 0.25,
                ["rightGlove"]  = 0.10,
                ["leftGlove"]   = 0.10,
                ["skirt"]       = 0.10,
            },
            default = 60,
            enchanted = 80,
            values = 
            {
                ["Common "]         = 50,
                ["Expensive "]      = 65,
                ["Extravagant "]    = 70,
                ["Exquisite "]      = 80,
                ["Fire"]           = 110,
                ["Flame"]           = 105,
                ["Frost"]           = 0,
            }
        },
        coverage = {
            type = "coverage",
            slotRatios =  
            {
                ["pants"]       = 0.10,
                ["shoes"]       = 0.10,
                ["shirt"]       = 0.15,
                ["robe"]        = 0.50,
                ["rightGlove"]  = 0.050,
                ["leftGlove"]   = 0.050,
                ["skirt"]       = 0.15,
            },
            default = 30,
            enchanted = 40,
            values  = {
                ["Common "]         = 30,
                ["Expensive "]      = 35,
                ["Extravagant "]    = 40,
                ["Exquisite "]      = 45,
            }
        }
    }
}

this.armorWarmthCache = mwse.loadConfig("ashfall/armor_warmth") or {}
this.clothingWarmthCache = mwse.loadConfig("ashfall/clothing_warmth") or {}
this.armorCoverageCache = mwse.loadConfig("ashfall/armor_coverage") or {}
this.clothingCoverageCache = mwse.loadConfig("ashfall/clothing_coverage") or {}

this.armorSlotDict = {}
for name, slot in pairs(tes3.armorSlot) do
    this.armorSlotDict[slot] = name
end
this.clothingSlotDict = {}
for name, slot in pairs(tes3.clothingSlot) do
    this.clothingSlotDict[slot] = name
end

--Get ratings from raw values for individual items
function this.getWarmthRating( rawValue )
    return math.floor( rawValue * this.data.warmthRatingMultiplier )
end

function this.getCoverageRating( rawValue )
    return math.floor( rawValue * this.data.coverageRatingMultiplier )
end

function this.isValidArmorSlot( armorSlot )
    return armorSlot ~= tes3.armorSlot.shield
end
function this.isValidClothingSlot( clothingSlot )
    return clothingSlot ~= tes3.clothingSlot.ring and clothingSlot ~= tes3.clothingSlot.amulet and clothingSlot ~= tes3.clothingSlot.belt
end

function this.calculateItemValue( item, slotName, thisData, cache )
    local itemId = item.id
    local itemName = item.name   
    local newValue
    local multiplier
    if thisData.type == "warmth" then
        multiplier = this.data.warmthRealMultiplier
    else
        multiplier = this.data.coverageRealMultiplier
    end
    --Check if warmth value exists in config file
    for id, val in pairs(cache) do
        if itemId == id then
            newValue = val
            break
        end
    end
    --Otherwise calculate
    if not newValue then
        --Check name patterns
        for pattern, val in pairs(thisData.values) do
            if string.find(itemName, pattern) then
                newValue = val
                break
            end
        end
        --No pattern, default
        if not newValue then
            if item.enchantment then
                newValue = thisData.enchanted
            else
                newValue = thisData.default
            end
        end
        --Check slot type and remap values
        local slotMax = thisData.slotRatios[slotName]
        newValue = math.remap( newValue, 0, 100, 0, slotMax ) * multiplier
        print("Final warmth: " .. newValue )
    end
    return newValue
end


return this