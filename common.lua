--Common
local this = {}
local skillModule = include("OtherSkills.skillModule")


--[[------------------------------------------------------------------

	hourToClockTime()
	Take in a GameHour value and return a 12:00pm formatted string

]]-------------------------------------------------------------------
function this.hourToClockTime ( time )
	local gameTime = time or tes3.getGlobal("GameHour")
	local formattedTime
	
	local isPM = false
	if gameTime > 12 then
		isPM = true
		gameTime = gameTime - 12
	end
	
	local hourString
	if gameTime < 10 then 
		hourString = string.sub(gameTime, 1, 1)
	else
		hourString  = string.sub(gameTime, 1, 2)
	end

	local minuteTime = ( gameTime - hourString ) * 60
	local minuteString
	if minuteTime < 10 then
		minuteString = "0" .. string.sub( minuteTime, 1, 1 )
	else
		minuteString = string.sub ( minuteTime , 1, 2)
	end
	formattedTime = hourString .. ":" .. minuteString .. (isPM and " pm" or " am")
	return ( formattedTime )
end	

this.conditionValues = {
    scorching 	= { text = "Scorching"   , min = 80   , max = 100	, spell = "fw_cond_scorching" } ,
    veryHot 	= { text = "Very Hot"    , min = 60   , max = 80	, spell = "fw_cond_very_hot"  } ,
    hot 		= { text = "Hot"         , min = 40   , max = 60  	, spell = "fw_cond_hot"       } ,
    warm 		= { text = "Warm"        , min = 20   , max = 40	, spell = "fw_cond_warm"      } ,
    comfortable = { text = "Comfortable" , min = -20  , max = 20	, spell = nil               } ,
    chilly 		= { text = "Chilly"      , min = -40  , max = -20	, spell = "fw_cond_chilly"    } ,
    cold 		= { text = "Cold"        , min = -60  , max = -40	, spell = "fw_cond_cold"      } ,
    veryCold 	= { text = "Very Cold"   , min = -80  , max = -60	, spell = "fw_cond_very_cold" } ,
    freezing 	= { text = "Freezing"    , min = -100 , max = -80	, spell = "fw_cond_freezing"  }
}

this.wetnessValues = {
	soaked  =   { text = "Soaked"	, min = 75, max = 100  	, spell = "fw_wetcond_soaked" 	},
	wet     =   { text = "Wet"		, min = 50, max = 75  	, spell = "fw_wetcond_wet" 		},
	damp    =   { text = "Damp"	    , min = 25, max = 50  	, spell = "fw_wetcond_damp" 	},
	dry     =   { text = "Dry"		, min = 0, max = 25  	, spell = "NONE"			 	}
}


this.bedTemp = 20

local function onSkillsReady()
	skillModule.registerSkill("Survival", 
	{	name 			=		"Survival", 
		icon 			=		"Icons/Ashfall/survival.dds", 
		value			= 		30,
		attribute 		=		tes3.attribute.endurance,
		description 	= 		"The Survival skill determines your ability to deal with harsh weather conditions and perform actions such as chopping wood and creating campfires effectively.",
		specialization 	= 		tes3.specialization.stealth
		}
	)
	print("Ashfall skills registered")
end

if skillModule then
	event.register("OtherSkills:Ready", onSkillsReady)
end

local function onLoaded()
	--Persistent data stored on player reference 
	-- ensure data table exists
	local data = tes3.player.data
	data.Ashfall = data.Ashfall or {}
	-- create a public shortcut
	this.data = data.Ashfall
	print("Ashfall: Common.lua loaded successfully")
	
	event.trigger("Ashfall:dataLoaded")
end	
event.register("loaded", onLoaded)

return this
