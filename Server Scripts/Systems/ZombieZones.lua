--[[
SPELLS:
90005 - Sanctuary "Argent Controlled Zone"
90006 - Scourge "Scourge Controlled Zone"

ZONES:
12 - Elwyn Forest
1519 - Stormwind City

AREAS:
ELWYN (12)
9 - Northshire Valley
24 - Northshire Abbey
34 - Northshire Mines
59 - Northshire Vineyards
--]]


--[[Adds an entire zone as a sanctuary
safeZone = {[zoneID] = true}  --]]
local safeZone = {
	[1519] = false -- stormwind
}

--[[Adds an area within a zone as a sanctuary
uninfectedArea = {[zoneID] = {[areaID] = true, [areaID] = true} }  --]]

local uninfectedArea = {                 
	[12] = { --Elwyn Forest Sanctuaries
			[9] = true,
			[24] = true,
			[34] = true,
			[59] = true,
	}
}

local function PLAYER_EVENT_ON_UPDATE_ZONE(event, player, newZone, newArea)
	if not player:IsAlive() then
		return
	end
	if (uninfectedArea[newZone]) then --Check for sanctuary within a zone
		if (uninfectedArea[newZone][newArea]) then --Check if player is in the area
			player:RemoveAura(90006) -- Remove Scourge
			player:CastSpell(player, 90005, true) -- Add Sanctuary
			return --Stop script
		end --If not, continue  to scourge
	end 
	if (safeZone[newZone]) then --If the zone is a sanctuary (entire zone)
		player:RemoveAura(90006) -- Remove Scourge
		player:CastSpell(player, 90005, true) -- Add Sanctuary
		return --Stop Script here
	end
	player:RemoveAura(90005) -- Remove Sanctuary
	player:CastSpell(player, 90006, true) -- Add Scourge
end

RegisterPlayerEvent(27, PLAYER_EVENT_ON_UPDATE_ZONE)

local function PLAYER_EVENT_ON_RESURRECT(event, plr)
	PLAYER_EVENT_ON_UPDATE_ZONE(event, plr, plr:GetZoneId(), plr:GetAreaId())
end

RegisterPlayerEvent(36, PLAYER_EVENT_ON_RESURRECT)
