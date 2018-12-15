--Updates condition spell effect strength based on player stats
--Uses base version of spell as a reference to get attribute  values without multiplier
local this = {}

local ignoreList = {
    "fw_cond_warm"
}

function this.setSpellStrength(spellID)
    mwse.log("Entering setSpellStrength")
    --No effect for comfortable
    if not spellID then
        mwse.log("no spell ID sent")
        return
    end
    
    local baseID = spellID .. "_BASE"
    local baseSpell = tes3.getObject(baseID)
    local realSpell = tes3.getObject(spellID)
    
    --Warm has a special case
    for _, id in ipairs(ignoreList) do
        if spellID == id then
            return
        end
    end
    --all others

    for i=1, #realSpell.effects do

        local effect = realSpell.effects[i]
        if effect.id ~= -1 then
            local baseEffect = baseSpell.effects[i]
            --Attributes: scale by matching player attribute
            local attribute  = effect.attribute
            if attribute ~= -1 then
                effect.min = baseEffect.min * ( tes3.mobilePlayer.attributes[attribute + 1].base / 40 ) --40 average starting stat
                effect.max = effect.min
            else
                --Other: scale by level
                effect.min = baseEffect.min * ( tes3.player.object.level / 20 )
                effect.max = effect.min
            end
            mwse.log("%s: %s", spellID, effect.min)
        end
    end
end

return this