local SAN = 90005 -- Sanctuary "Argent Controlled Zone"
local SCO = 90006 -- Scourge "Scourge Controlled Zone"

--[[Adds an entire zone as a sanctuary
safeZone = {[zoneID] = true}  --]]
local safeZone = {
	[1519] = false -- Stormwind City
}

--[[Adds an area within a zone as a sanctuary
uninfectedArea = {[zoneID] = {[areaID] = true, [areaID] = true} }  --]]

local uninfectedArea = {                 
	[12] = { --Elwyn Forest Sanctuaries
			[9] = true, -- Northshire Valley
			[24] = true, -- Northshire Abbey
			[34] = true, -- Northshire Mines
			[59] = true, -- Northshire Vineyards
	}
}

local function PLAYER_EVENT_ON_UPDATE_ZONE(event, player, newZone, newArea)
	if not player:IsAlive() then
		return
	end
	if (uninfectedArea[newZone]) then --Check for sanctuary within a zone
		if (uninfectedArea[newZone][newArea]) then --Check if player is in the area
			player:RemoveAura(SCO) -- Remove Scourge
			player:CastSpell(player, SAN, true) -- Add Sanctuary
			return --Stop script
		end --If not, continue  to scourge
	end 
	if (safeZone[newZone]) then --If the zone is a sanctuary (entire zone)
		player:RemoveAura(SCO) -- Remove Scourge
		player:CastSpell(player, SAN, true) -- Add Sanctuary
		return --Stop Script here
	end
	player:RemoveAura(SAN) -- Remove Sanctuary
	player:CastSpell(player, SCO, true) -- Add Scourge
end

RegisterPlayerEvent(27, PLAYER_EVENT_ON_UPDATE_ZONE)

local function PLAYER_EVENT_ON_RESURRECT(event, plr)
	PLAYER_EVENT_ON_UPDATE_ZONE(event, plr, plr:GetZoneId(), plr:GetAreaId())
end

RegisterPlayerEvent(36, PLAYER_EVENT_ON_RESURRECT)
