local this = {}
local common = require("mer.ashfall.common")

--Generic Tooltip with header and description
local function createTooltip(thisHeader, thisLabel)
    local tooltip = tes3ui.createTooltipMenu()
    
    local outerBlock = tooltip:createBlock({ id = tes3ui.registerID("Ashfall:temperatureIndicator_outerBlock") })
	outerBlock.flowDirection = "top_to_bottom"
	outerBlock.paddingTop = 6
	outerBlock.paddingBottom = 12
	outerBlock.paddingLeft = 6
	outerBlock.paddingRight = 6
	outerBlock.width = 300
	outerBlock.autoHeight = true    
    
    local headerText = thisHeader
    local headerLabel = outerBlock:createLabel({ id = tes3ui.registerID("Ashfall:temperatureIndicator_header"), text = headerText })
    headerLabel.autoHeight = true
    headerLabel.width = 285
    headerLabel.color = tes3ui.getPalette("header_color")
    headerLabel.wrapText = true
    --header.justifyText = "center"
    
    local descriptionText = thisLabel
    local descriptionLabel = outerBlock:createLabel({ id = tes3ui.registerID("Ashfall:temperatureIndicator_description"), text = descriptionText })
    descriptionLabel.autoHeight = true
    descriptionLabel.width = 285
    descriptionLabel.wrapText = true   
    
    tooltip:updateLayout()
end


function this.wetnessIndicator()
    if not common.data then return end
    if not common.wetnessValues[common.data.wetCondition] then return end

    local headerText = "Wet level: " .. common.wetnessValues[common.data.wetCondition].text--:lower()
    local labelText = "The wetter you are, the longer it takes to warm up, the quicker you cool down, and the more susceptible you are to shock damage."
    createTooltip(headerText, labelText)

end

function this.conditionIndicator()
    if not common.data then return end
    if not common.conditionValues[common.data.currentCondition] then return end 
    
    local headerText = "Condition: " .. common.conditionValues[common.data.currentCondition].text--:lower()
    local labelText = "The player's current condition, determined by Player Temperature."
    createTooltip(headerText, labelText)
end
function this.playerLeftIndicator()
    local headerText = "Player Temperature"
    local labelText = "The player's current temperature. This directly determines hot and cold condition effects."
    createTooltip(headerText, labelText)
end
function this.playerRightIndicator()
    local headerText = "Player Temperature"
    local labelText = "Directly determines hot and cold condition effects."
    createTooltip(headerText, labelText)  
end

function this.limitLeftIndicator()
    local headerText = "Temperature Limit"
    local labelText = "Represents the temperature the player will reach if the current conditions remain."
    createTooltip(headerText, labelText)
end

function this.limitRightIndicator()
    local headerText = "Temperature Limit"
    local labelText = "Represents the temperature the player will reach if the current conditions remain."
    createTooltip(headerText, labelText)
end

return this