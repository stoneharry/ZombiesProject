
local function PLAYER_EVENT_ON_LOGIN(event, plr)
	if plr then
		plr:CastSpell(plr, 90023, true) -- new target
	end
end

RegisterPlayerEvent(3, PLAYER_EVENT_ON_LOGIN)
