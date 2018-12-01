
local this = {}
local common = require("mer.ashfall.common")
local needsUI = require("mer.ashfall.needs.needsUI")
this.containerList = {
    bottles = {
        "misc_com_bottle_01",
        "misc_com_bottle_02",
        "Misc_Com_Bottle_04",
        "misc_com_bottle_05",
        "misc_com_bottle_06",
        "Misc_Com_Bottle_08",
        "misc_com_bottle_09",
        "misc_com_bottle_10",
        "misc_com_bottle_11",
        "misc_com_bottle_13",
        "Misc_Com_Bottle_14",
        "misc_com_bottle_14_float",
        "misc_com_bottle_15",
    },
    flasks = {
        "misc_flask_01",
        "misc_flask_02",
        "misc_flask_03",
        "misc_flask_04",
    },
    partialFilled = {
        bottleHalf = "fw_water_bottle_half",
        bottleLow = "fw_water_bottle_low",
        flaskHalf = "fw_water_flask_half",
        flaskLow = "fw_water_flask_low",
    },
    filledBottles = {
        bottleFull = "fw_water_bottle_full",
        bottleHalf = "fw_water_bottle_half",
        bottleLow = "fw_water_bottle_low",       
    },
    filledFlasks = {
        flaskFull = "fw_water_flask_full",
        flaskHalf = "fw_water_flask_half",
        flaskLow = "fw_water_flask_low",
    }
}


function this.drinkAmount( amount )
    common.data.thirst = common.data.thirst -  math.clamp( amount, 0, common.data.thirst  )
    needsUI.updateNeedsUI()
end

return this