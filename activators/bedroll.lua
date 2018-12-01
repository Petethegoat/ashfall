local sleepButton = "Sleep"
local pickUpButton = "Pick up"
local cancelButton = "Cancel"
local menuButtons = {}

local bedRef

local function onMenuSelect(e)
	local result = menuButtons[e.button + 1]
	if result == sleepButton then
		tes3.showRestMenu()
	elseif result == pickUpButton then
		if bedRef and bedRef.id then
			tes3.messageBox("pick up! : " .. bedRef.id)
		else
			tes3.messageBox("No bed ref?")
		end
		--tes3.player:activate(bedRef)
	elseif result == cancelButton then
		return
	end
end

local function onActivate(e)
	if ( e.target.object.id == "fw_bedroll" ) then
		bedRef = e.target
		menuButtons = {pickUpButton, cancelButton}
		if not tes3.getPlayerCell().restingIsIllegal then
			table.insert(menuButtons, 1, sleepButton)
		end
		tes3.messageBox({
			message = "A portable bedroll",
			buttons = menuButtons,
			callback = onMenuSelect
		})
	end
end

event.register("activate", onActivate )