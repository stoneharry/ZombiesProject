--[[
SPELLS:
90005 - Sanctuary "Argent Controlled Zone"
90006 - Scourge "Scourge Controlled Zone"

--]]

local infectedZones = { [12] = true } -- 12 = Elwynn Forest
local uninfectedAreas = { 
	[9] = true, [24] = true, [34] = true, [59] = true --[[9 = Northshire Valley, 24 = Northshire Abbey, 34 = Northishire Mines, 59 = Northshire Vineyards ]]
	}
local function PLAYER_EVENT_ON_UPDATE_ZONE(event, player, newZone, newArea)
	if (infectedZones[newZone]) then
		if not(uninfectedAreas[newArea]) then
			player:RemoveAura(90005) -- Remove Sanctuary
			player:CastSpell(player, 90006, true) -- Add Scourge
			return --Stop here
		end
	end
	player:RemoveAura(90006) -- Remove Scourge
	player:CastSpell(player, 90005, true) -- Add Sanctuary
end

RegisterPlayerEvent(27, PLAYER_EVENT_ON_UPDATE_ZONE)