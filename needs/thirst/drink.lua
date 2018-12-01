
local thirstCommon = require("mer.ashfall.needs.thirst.thirstCommon")

local function onEquip(e)
    local newContaionerId 
    --bottles
    local bottles = thirstCommon.containerList.filledBottles
    local flasks = thirstCommon.containerList.filledFlasks
    if e.item.id == bottles.bottleFull then
        newContaionerId = bottles.bottleHalf
    elseif e.item.id == bottles.bottleHalf then
        newContaionerId = bottles.bottleLow
    elseif e.item.id == bottles.bottleLow then
        newContaionerId = thirstCommon.containerList.bottles[ math.random( #thirstCommon.containerList.bottles) ]

    --flasks
    elseif e.item.id == flasks.flaskFull then
        newContaionerId = flasks.flaskHalf
    elseif e.item.id == flasks.flaskHalf then
        newContaionerId = flasks.flaskLow
    elseif e.item.id == flasks.flaskLow then
        newContaionerId = thirstCommon.containerList.flasks[ math.random( #thirstCommon.containerList.flasks) ]
    end
    if newContaionerId then
        thirstCommon.drinkAmount(40)
        timer.frame.delayOneFrame(
            function ()
                mwscript.addItem({reference = tes3.player, item = newContaionerId})
                --tes3.messageBox("%s has been added to your inventory", tes3.getObject(newContaionerId).name)
            end
        )
    end
end

event.register("equip", onEquip, {filter = tes3.player } )
