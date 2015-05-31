
local infectedZones = { 12 } -- 12 = Elwynn Forest

local function PLAYER_EVENT_ON_UPDATE_ZONE(event, player, newZone, newArea)
	for _,v in pairs(infectedZones) do
		if v == newZone then
			player:RemoveAura(90005)
			player:CastSpell(player, 90006, true)
			return
		end
	end
	player:RemoveAura(90006)
	player:CastSpell(player, 90005, true)
end

RegisterPlayerEvent(27, PLAYER_EVENT_ON_UPDATE_ZONE)
