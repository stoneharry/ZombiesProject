
--[[

	GossipSendPOI
	x, y, icon, flags, data, text

	400000, 177289
]]

EVENT_DONE = true
local currentEvent = nil
local lastEvent = nil

local function Event1()
	PerformIngameSpawn(2, 400000, 0, 0, -9558.034, 83.45, 58.3, 5.998550)
	PerformIngameSpawn(2, 177289, 0, 0, -9558.034, 83.45, 58.3, 5.998550)
	PerformIngameSpawn(1, 90067, 0, 0, -9558.034, 83.45, 62, 5.998550)
end

local function Event2()
	PerformIngameSpawn(2, 400000, 0, 0, -9449.98, -692.62, 63.6, 2.527031)
	PerformIngameSpawn(2, 177289, 0, 0, -9449.98, -692.62, 63.6, 2.527031)
	PerformIngameSpawn(1, 90067, 0, 0, -9449.98, -692.62, 66.6, 2.527031)
end

local POIS = {
	{-9558.034, 83.45, 7, 6, 0, "Scourge Cauldron", "A Scourge Cauldron needs to be stopped!", Event1},
	{-9449.98, -692.62, 7, 6, 0, "Scourge Cauldron", "A Scourge Cauldron needs to be stopped!", Event2}
}

local function zoneEvent(_, _, _)
	if EVENT_DONE then	
		if #POIS == 0 then
			return
		end
		local index = math.random(1, #POIS)
		while index == lastEvent and #POIS > 1 do
			index = math.random(1, #POIS)
		end
		local POI = POIS[index]
		
		EVENT_DONE = false
		currentEvent = index
		lastEvent = currentEvent
		
		POI[8]()
		
		local plrs = GetPlayersInMap(0, 0, 2)
		for _,v in pairs(plrs) do
			if v and v:GetZoneId() == 12 and not v:GetAreaId() == 24 then -- not in Northshire
				v:GossipSendPOI(POI[1], POI[2], POI[3], POI[4], POI[5], POI[6])
				v:SendChatMessageDirectlyToPlayer(POI[7], 41, 0, v, v)
			end
		end
	end
end

CreateLuaEvent(zoneEvent, 60000, 0)

local function PLAYER_EVENT_ON_UPDATE_ZONE(event, plr, newZone, newArea)
	if newZone == 12 then
		if currentEvent and not EVENT_DONE then
			local POI = POIS[currentEvent]
			plr:GossipSendPOI(POI[1], POI[2], POI[3], POI[4], POI[5], POI[6])
		end
	end
end

RegisterPlayerEvent(27, PLAYER_EVENT_ON_UPDATE_ZONE)

local function UpdateEvent(_, _, _, plr)
	if currentEvent and not EVENT_DONE then
		local POI = POIS[currentEvent]
		plr:GossipSendPOI(POI[1], POI[2], POI[3], POI[4], POI[5], POI[6])
		plr:SendChatMessageDirectlyToPlayer(POI[7], 41, 0, plr, plr)
	end
end

local function PLAYER_EVENT_ON_LOGIN(event, plr)
	if plr then
		plr:RegisterEvent(UpdateEvent, 5000, 1)
	end
end

RegisterPlayerEvent(3, PLAYER_EVENT_ON_LOGIN)
