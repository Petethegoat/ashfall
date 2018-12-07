local this = {}

local common = require("mer.ashfall.common")
local tooltips = require("mer.ashfall.ui.hudTooltips")

local outerFrame
local tempIndicatorBlock
local conditionLabel
local condIcon

local leftTempPlayerBar
local leftTempLimitBar

local rightTempPlayerBar
local rightTempLimitBar

local wetnessBar

local IDs = {
	mainHUDBlock = tes3ui.registerID("Ashfall:HUD_mainHUDBlock"),
	topHUDBlock = tes3ui.registerID("Ashfall:HUD_topHUDBlock"),
	wetnessBlock = tes3ui.registerID("Ashfall:HUD_wetnessBlock"),
	conditionLabelBlock = tes3ui.registerID("Ashfall:conditionLabelBlock"),


}

function this.updateHUD()
	if not common.data then return end
	if outerFrame and leftTempPlayerBar and conditionLabel then
		local tempPlayer = math.clamp(common.data.tempPlayer, -100, 100) or 0
		local tempLimit =  math.clamp(common.data.tempLimit, -100, 100) or 0
		local condition = common.tempConditions[( common.data.currentCondition  or "comfortable" )].text
		local wetness = common.data.wetness or 0
		wetness = math.clamp(wetness, 0, 100) or 0

		conditionLabel.text = condition
		--Cold
		if tempPlayer < 0 then

			leftTempPlayerBar.widget.fillColor = {0.3, 0.5, (0.75 + tempPlayer/400)} --Bluish
			leftTempPlayerBar.widget.current = tempPlayer
			--hack
			local bar = leftTempPlayerBar:findChild(tes3ui.registerID("PartFillbar_colorbar_ptr"))
			bar.width = (tempPlayer / 100) * leftTempPlayerBar.width		
			rightTempPlayerBar.widget.current = 0
		--Hot:
		else
			rightTempPlayerBar.widget.fillColor = {(0.75 + tempPlayer/400), 0.3, 0.2}
			rightTempPlayerBar.widget.current = tempPlayer
			local bar = leftTempPlayerBar:findChild(tes3ui.registerID("PartFillbar_colorbar_ptr"))
			bar.width = 0
		end

		if tempLimit < 0 then
			leftTempLimitBar.widget.fillColor = {0.3, 0.5, (0.75 + tempLimit/400)} --Bluish
			leftTempLimitBar.widget.current = tempLimit
			--hack
			local bar = leftTempLimitBar:findChild(tes3ui.registerID("PartFillbar_colorbar_ptr"))
			bar.width = (tempLimit / 100) * leftTempLimitBar.width		
			rightTempLimitBar.widget.current = 0
		--Hot:
		else
			rightTempLimitBar.widget.fillColor = {(0.75 + tempLimit/400), 0.3, 0.2}
			rightTempLimitBar.widget.current = tempLimit
			local bar = leftTempLimitBar:findChild(tes3ui.registerID("PartFillbar_colorbar_ptr"))
			bar.width = 0
		end
		
		wetnessBar.widget.current = wetness
		
		outerFrame:updateLayout()
	end
end


local function quickFormat(element, padding)
	element.paddingAllSides = padding
	element.autoHeight = true
	element.autoWidth = true
	return element
end




local topBlockID = tes3ui.registerID("Ashfall:topBlock")
local function createHUD(e)
	if not e.newlyCreated then return end
	local tempBarWidth = 70
	local tempBarHeight = 10
	local limitBarHeight = 12

    local multiMenu = e.element

    -- Find the UI element that holds the sneak icon indicator.
    local bottomLeftBar = multiMenu:findChild(tes3ui.registerID("MenuMulti_sneak_icon")).parent:createBlock({id = IDs.mainHUDBlock})
	
	bottomLeftBar = quickFormat(bottomLeftBar, 2)
	bottomLeftBar.flowDirection = "top_to_bottom"

	---\
		---TOPBLOCK - Wetness Indicator and Condition state---
		local topBlock = bottomLeftBar:createBlock({id = IDs.topHUDBlock})

		topBlock.flowDirection = "left_to_right"
		topBlock = quickFormat(topBlock, 0)
		---\
			---WETNESS INDICATOR---	
			local wetnessBlock = topBlock:createBlock({id = IDs.wetnessBlock})
            --Register Tooltip
            wetnessBlock:register("help", tooltips.wetnessIndicator )
			wetnessBlock = quickFormat(wetnessBlock, 0)
			---\
				local wetnessBackground = wetnessBlock:createRect({color = {0.0, 0.3, 0.3} })
				wetnessBackground.height = 20
				wetnessBackground.width = 36
				wetnessBackground.layoutOriginFractionX = 0.0
			
			---\
				wetnessBar = wetnessBlock:createFillBar({current = 50, max = 100})
				wetnessBar.widget.fillColor = {0.5, 1.0, 1.0}
				wetnessBar.widget.showText = false
				wetnessBar.height = 20
				wetnessBar.width = 36
				wetnessBar.layoutOriginFractionX = 0.0
	
			---\
				local wetnessIcon = wetnessBlock:createImage({path="Textures/Ashfall/indicators/wetness.dds"})
				wetnessIcon.height = 16
				wetnessIcon.width = 32
				wetnessIcon.borderAllSides = 2
				wetnessBar.layoutOriginFractionX = 0.0
			
			
			---CONDITION STATE---	
			local conditionLabelBlock = topBlock:createBlock({id = IDs.conditionLabelBlock})

			conditionLabelBlock = quickFormat(conditionLabelBlock, 0)
			conditionLabelBlock.paddingLeft = 2
			---\
				conditionLabel = conditionLabelBlock:createLabel({text = "Comfortable" })
                --register tooltip
                conditionLabel:register("help", tooltips.conditionIndicator )

				
	---\		
		---OUTER FRAME - sits below wetness and condition, houses temperature fillbars---
		outerFrame = bottomLeftBar:createThinBorder()
		outerFrame.flowDirection = "top_to_bottom"
		outerFrame = quickFormat(outerFrame, 0)

		---\
			--fill background of outerframe with blackj
			local colorBlock = outerFrame:createRect({color = tes3ui.getPalette("black_color")})
			colorBlock.flowDirection = "top_to_bottom"
			colorBlock = quickFormat(colorBlock, 0)
		
			---\
				---MID BLOCK
				tempIndicatorBlock = colorBlock:createBlock()
				tempIndicatorBlock.flowDirection = "left_to_right"
				tempIndicatorBlock = quickFormat(tempIndicatorBlock, 0)
				---\	
					local leftTempIndicatorBlock = tempIndicatorBlock:createBlock()
					leftTempIndicatorBlock.flowDirection = "top_to_bottom"
					leftTempIndicatorBlock = quickFormat(leftTempIndicatorBlock, 0)
					---\
						--Left Player Bar
						leftTempPlayerBar = leftTempIndicatorBlock:createFillBar({current = 50, max = 100})
                        leftTempPlayerBar:register( "help", tooltips.playerLeftIndicator )
						leftTempPlayerBar.widget.showText = false
						leftTempPlayerBar.height = tempBarHeight
						leftTempPlayerBar.width = tempBarWidth
						leftTempPlayerBar.borderBottom = 0
						--Reverse direction of left bar
						leftTempPlayerBar.paddingAllSides = 2
						local bar = leftTempPlayerBar:findChild(tes3ui.registerID("PartFillbar_colorbar_ptr"))
						bar.layoutOriginFractionX = 1.0	
						
					---\	
						--Left tempLimit bar
						leftTempLimitBar = leftTempIndicatorBlock:createFillBar({current = 50, max = 100})
                        leftTempLimitBar:register( "help", tooltips.limitLeftIndicator )
						leftTempLimitBar.widget.showText = false
						leftTempLimitBar.height = limitBarHeight
						leftTempLimitBar.width = tempBarWidth
						--Reverse direction of left bar
						leftTempLimitBar.paddingAllSides = 2
						bar = leftTempLimitBar:findChild(tes3ui.registerID("PartFillbar_colorbar_ptr"))
						bar.layoutOriginFractionX = 1.0				
						
				---\		
					local centretempIndicatorBlock = tempIndicatorBlock:createThinBorder({"Ashfall:centretempIndicatorBlock"})
					--centretempIndicatorBlock.flowDirection = "top_to_bottom"
					centretempIndicatorBlock = quickFormat(centretempIndicatorBlock, 2)
					
					--cond icon: color based on player condition
					condIcon = centretempIndicatorBlock:createImage({path="Textures/Ashfall/indicators/chilly.tga"})
					condIcon.height = tempBarHeight + limitBarHeight - 4
					condIcon.width = 5
					condIcon.scaleMode = true
					
				---\		
					local righttempIndicatorBlock = tempIndicatorBlock:createBlock({tes3ui.registerID("Ashfall:righttempIndicatorBlock")})
					righttempIndicatorBlock.flowDirection = "top_to_bottom"
					righttempIndicatorBlock = quickFormat(righttempIndicatorBlock, 0)		
					---\
						--Right Color Bar
						rightTempPlayerBar = righttempIndicatorBlock:createFillBar({max = 100})
                        rightTempPlayerBar:register( "help", tooltips.playerRightIndicator )
						rightTempPlayerBar.widget.showText = false
						rightTempPlayerBar.height = tempBarHeight
						rightTempPlayerBar.width = tempBarWidth
						rightTempPlayerBar.borderBottom = 0
						
					--\	
						--Right tempLimit bar
						rightTempLimitBar = righttempIndicatorBlock:createFillBar({current = 50, max = 100})
                        rightTempLimitBar:register( "help", tooltips.limitRightIndicator )
						rightTempLimitBar.widget.showText = false
						rightTempLimitBar.height = limitBarHeight
						rightTempLimitBar.width = tempBarWidth

end

event.register("uiActivated", createHUD, { filter = "MenuMulti" })

return this