local hungerCommon = require("mer.ashfall.needs.hunger.hungerCommon")

local function onEquip(e)
    if e.item.objectType == tes3.objectType.ingredient then
        hungerCommon.eatAmount(hungerCommon.getFoodValue(e.item.id))
    end
end

event.register("equip", onEquip, { filter = tes3.player } )