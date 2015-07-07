
local T = {};
local ArmorSlots = {0, 2, 3, 4, 5, 6, 7, 8, 9, 14, 18}; -- #11
local WeaponSlots = {15, 16, 17}; -- #3

local function PLAYER_EVENT_ON_REPOP(event, plr)
	if not plr then
		return
	end
	if plr:GetLevel() < 5 or plr:IsGM() then
		return
	end
	local mapID = plr:GetMap():GetMapId()
	local zombie = PerformIngameSpawn(1, 90008, mapID, 0, plr:GetX(), plr:GetY(), plr:GetZ(), plr:GetO(), true)
	local GUID = zombie:GetGUIDLow()
	local display = plr:GetDisplayId()
	local race = plr:GetRace()
	local gender = plr:GetGender()
	local class = plr:GetClass()
	local skin = plr:GetByteValue(153, 0) -- Skin Color
	local face = plr:GetByteValue(153, 1) -- Face
	local hair = plr:GetByteValue(153, 2) -- Hair Style
	local hairColour = plr:GetByteValue(153, 3) -- Hair Color
	local faceHair = plr:GetByteValue(154, 0) -- Facial Hair/Misc
	local guild = 0
	if plr:IsInGuild() then
		guild = plr:GetGuildId()
	end
	local name = plr:GetName()
	local level = plr:GetLevel()
	local query = "'" .. display .. "'" .. ", '" .. name .. "'" .. ", '" .. level .. "'" .. ", '" .. race .. "'" .. ", '" .. gender .. "'" .. ", '" .. class .. "'"
	query = query .. ", '" .. skin .. "'" .. ", '" .. face .. "'" .. ", '" .. hair .. "'" .. ", '" .. hairColour .. "'"
	query = query .. ", '" .. faceHair .. "'" .. ", '" .. guild .. "'"
	for _,v in ipairs(ArmorSlots) do
		local item = plr:GetEquippedItemBySlot(v)
		local display = 0
		if item then
			display = item:GetDisplayId()
		end
		query = query .. ", '" .. display .. "'"
	end
	for _,v in ipairs(WeaponSlots) do
		local item = plr:GetEquippedItemBySlot(v)
		local display = 0
		if item then
			display = item:GetEntry()
		end
		query = query .. ", '" .. display .. "'"
	end
	--[[print("--")
	print("INSERT INTO `zombies` VALUES ('" .. GUID .. "', " .. query .. ")")
	print("--")]]
	WorldDBQuery("INSERT INTO `zombies` VALUES ('" .. GUID .. "', " .. query .. ")")
end

RegisterPlayerEvent(35, PLAYER_EVENT_ON_REPOP)

local function ZombieCreatureOnLoad(event, target, player)
	local tGUID = tostring(target:GetGUID())
	if (player:GetObjectType() == "Player") then
		for k, v in pairs(T) do
			if k == tGUID then
				if v.PlayerCache[tostring(player:GetGUID())] ~= true then
					v.PlayerCache[tostring(player:GetGUID())] = true
					target:SetUInt32Value(60, 16) -- Set creature flag to Mirror Image flag
					local guid1 = player:GetGUID()
					local guid2 = tostring(target:GetGUID())
					CreateLuaEvent(function() SendMirrorPacket(guid1, guid2); end, player:GetLatency() + 100, 1) -- Delay sending of packet, required for display to change properly
					break;
				end
			end
		end
	end
end

local function PurgeFromCache(event, player)
	for i, v in pairs(T) do
		if v.PlayerCache[tostring(player:GetGUID())] then
			v.PlayerCache[tostring(player:GetGUID())] = nil -- When logging out of the game, clear player from cache. If not, NPC would not resend packet when logging back ingame.
		end
	end
end

function SendMirrorPacket(playerGUID, targetGUID)
	local plr = GetPlayerByGUID(playerGUID)
	if not plr then
		return
	end
	for _,v in pairs(plr:GetNearObjects(40, 0, 90008)) do
		if tostring(v:GetGUID()) == targetGUID then
			if not T[targetGUID].PacketStore then
				CREATURE_EVENT_ON_SPAWN(nil, v, nil, nil)
			else
				v:SendPacket(T[targetGUID].PacketStore)
			end
			return
		end
	end
end

RegisterPlayerEvent(4, PurgeFromCache)
RegisterCreatureEvent(90008, 27, ZombieCreatureOnLoad)

local function CREATURE_EVENT_ON_SPAWN(event, creature, repeats, pUnit)
	if pUnit then
		creature = pUnit
	end
	creature:SetUInt32Value(0x0006 + 0x0035, 33554434) -- unattackable, untargetable
	local query = WorldDBQuery("SELECT * FROM `zombies` WHERE `guid` = '" .. creature:GetGUIDLow() .. "'")
	if not query then
		creature:RegisterEvent(CREATURE_EVENT_ON_SPAWN, 1000, 1)
		return
	end
	local row = query:GetRow()
	if not row then
		creature:RegisterEvent(CREATURE_EVENT_ON_SPAWN, 1000, 1)
		return
	end
	
	local tGUID = creature:GetGUID()
	T[tostring(tGUID)] = {
		PacketStore = nil,
		DisplayIds = {},
		PlayerCache = {};
	};
	
	local display = row["display"]
	local race = row["race"]
	local gender = row["gender"]
	local class = row["class"]
	local skin = row["skin"]
	local face = row["face"]
	local hair = row["hair"]
	local hairColour = row["hairColour"]
	local faceHair = row["faceHair"]
	local guild = row["guild"]
	local name = row["name"]
	local level = row["level"]
	
	local packet = CreatePacket(0x402, 68) -- Create Mirror Image packet. 
	
	packet:WriteGUID(tGUID)
	packet:WriteULong(display)
	packet:WriteUByte(race)
	packet:WriteUByte(gender)
	packet:WriteUByte(6) -- DK
	packet:WriteUByte(14)
	packet:WriteUByte(face)
	packet:WriteUByte(hair)
	packet:WriteUByte(hairColour)
	packet:WriteUByte(faceHair)
	packet:WriteULong(guild)
	for i=1,11 do
		packet:WriteULong(tonumber(row["slot"..tostring(i)]))
	end
	local count = 12
	for i,v in ipairs(WeaponSlots) do
		creature:SetUInt32Value(56 + (i - 1), tonumber(row["slot"..tostring(count)]))
		count = count + 1
	end
	
	T[tostring(tGUID)].PacketStore = packet; -- Store packet to creature cace
	
	creature:SetUInt32Value(60, 16) -- Set creature flag to Mirror Image flag
	creature:SetDisplayId(display)
	creature:SetLevel(level)
	creature:SetName(name)
	
	creature:SendPacket(packet)
	
	creature:SetUInt32Value(0x0006 + 0x0035, 0)
	creature:SetFaction(17)
end

RegisterCreatureEvent(90008, 5, CREATURE_EVENT_ON_SPAWN)

local function DESPAWN_SELF(event, creature, repeats, pUnit)
	pUnit:DeleteFromDB()
end

local function CREATURE_EVENT_ON_DIED(event, creature, killer)
	WorldDBQuery("DELETE FROM `zombies` WHERE `guid` = '" .. creature:GetGUIDLow() .. "'")
	WorldDBQuery("DELETE FROM `creature` WHERE `guid` = '" .. creature:GetGUIDLow() .. "'")
	creature:RegisterEvent(DESPAWN_SELF, 20000, 1)
end

RegisterCreatureEvent(90008, 4, CREATURE_EVENT_ON_DIED)

