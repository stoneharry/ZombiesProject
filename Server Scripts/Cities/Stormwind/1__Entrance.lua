
local _debug = true
local AI_COUNT = 0
local WALKING_SPEED = 0.4

-- Starting creatures

local function WaitForSpawn(_, _, _, pUnit)
	-- 90005
	local t = pUnit:GetPlayersInRange(60)
	if #t == 0 then
		return
	end
	PerformIngameSpawn(2, 90005, 0, 0, -9137, 412, 94, 5.055)
	PerformIngameSpawn(2, 90005, 0, 0, -9114.8, 352.9, 93, 1.98421)
	PerformIngameSpawn(2, 90005, 0, 0, -9126.4, 347.9, 93.4, 1.886035)
	local spawns = {
		{-9107.34,378.771,93.7351,1.19195},
		{-9148.14,381.923,90.8808,4.05001},
		{-9139.4,391.125,90.9324,5.54541},
		{-9124.53,379.778,90.9475,1.43307},
		{-9125.97,380.123,90.8001,1.22022},
		{-9126.15,352.181,93.5358,1.83677},
		{-9128.88,351.219,93.4407,1.64827},
		{-9114.75,357.097,93.3318,2.05747},
		{-9136.23,408.33,94.4238,5.17581},
		{-9134.04,408.899,94.3046,5.13514}
	}
	for _,t in pairs(spawns) do
		local entry
		if math.random(1,2) == 1 then
			entry = 90066
		else
			entry = 90064
		end
		pUnit:SpawnCreature(entry, t[1], t[2], t[3], t[4])
	end
	pUnit:RemoveEvents()
end

local function CheckCanSpawn(_, _, _, pUnit)
	if GetSiegeStage() == 1 then
		local a,b = GetResourceData(12)
		if a == b then
			pUnit:RemoveEvents()
			pUnit:SetFaction(814)
			pUnit:SetUInt32Value(UNIT_FIELD_FLAGS, 0)
			if pUnit:GetEntry() == 90072 then
				pUnit:SetDisplayId(16012)
				pUnit:SetEquipmentSlots(28905, 28754, 0)
			else
				pUnit:SetNPCFlags(1)
				pUnit:SetDisplayId(10469)
				pUnit:SetEquipmentSlots(13316, 0, 0)
				pUnit:RegisterEvent(WaitForSpawn, 1000, 0)
			end
			pUnit:Mount(28918)
		end
	end
end

local function StartSpawn(event, pUnit)
	pUnit:SetNPCFlags(0)
	pUnit:SetDisplayId(15294)
	pUnit:SetFaction(35)
	pUnit:SetEquipmentSlots(0, 0, 0)
	pUnit:SetUInt32Value(UNIT_FIELD_FLAGS, UNIT_FIELD_FLAG_UNTARGETABLE)
	pUnit:RegisterEvent(CheckCanSpawn, 10000, 0)
end

RegisterCreatureEvent(90071, 5, StartSpawn)
RegisterCreatureEvent(90072, 5, StartSpawn)

-- spawning scourge

local function ScourgeboltSpam(_, _, _, pUnit)
	local plr = pUnit:GetAITarget(0) -- random target
	if plr then
		pUnit:CastSpell(plr, 90032)
	end
end

local function CombatAbberation(event, pUnit)
	pUnit:RegisterEvent(ScourgeboltSpam, 8000, 0)
end

local function DespawnSelf(event, pUnit)
	pUnit:RemoveEvents()
	pUnit:DespawnOrUnsummon(5000)
end

local function LookingForPlayers(_, _, _, pUnit)
	if pUnit:IsInCombat() then
		return
	end
	local p = pUnit:GetNearestPlayer(40)
	if p then
		pUnit:AttackStart(p)
	end
end

local function ContinueMove(_,_,_, pUnit)
	pUnit:MoveTo(0, -math.random(9029, 9030), math.random(455,465), 93.8)
end

local function ScourgeSpawn(event, pUnit)
	pUnit:SetHomePosition(-math.random(9029, 9030), math.random(455,465), 93.8, 0)
	pUnit:MoveTo(0, -math.random(8942, 8965), math.random(513, 528), 96.4)
	pUnit:RegisterEvent(ContinueMove, 12000, 1)
	if pUnit:GetEntry() == 90075 then
		pUnit:RegisterEvent(LookingForPlayers, 1000, 0)
	end
end

RegisterCreatureEvent(90073, 5, ScourgeSpawn)
RegisterCreatureEvent(90075, 5, ScourgeSpawn)
RegisterCreatureEvent(90075, 4, DespawnSelf)
RegisterCreatureEvent(90075, 1, CombatAbberation)

-- Event start

local function KillSelf(_, _, _, pUnit)
	pUnit:Kill(pUnit)
	pUnit:DespawnOrUnsummon(5000)
end

local function SpawnScourgeSpam(_, _, _, pUnit)
	local x,y
	local z = 95
	for i=1,math.random(1,6) do
		x = -math.random(8928, 8929)
		y = math.random(530, 549)
		pUnit:SpawnCreature(90073, x, y, z, 0, 1, 60000)
	end
	local t = pUnit:GetCreaturesInRange(10, 90073)
	for _,v in pairs(t) do
		pUnit:CastSpell(v, 10689)
		v:SetHealth(1)
		v:RegisterEvent(KillSelf, 1900, 1)
	end
end

local function BeginAIMarch(_, _, _, pUnit)
	if AI_COUNT == 5 then
		pUnit:Emote(5)
		pUnit:SendUnitYell("Today we take back Stormwind from the Scourge!", 0)
	elseif AI_COUNT == 12 then
		pUnit:SendUnitYell("For the Argent Dawn!", 0)
		pUnit:Emote(25)
		pUnit:SetSpeed(1, WALKING_SPEED)
		pUnit:MoveTo(0, -9043.7, 451.1, 93.06)
		local entry
		for _,v in pairs(pUnit:GetNearObjects(30)) do
			entry = v:GetEntry()
			if entry == 90064 or entry == 90066 then
				v:MoveFollow(pUnit, math.random(4, 10), math.random(0, 360))
			end
		end
		local c = GetCreature(10, 90072, pUnit)
		c:SetSpeed(1, WALKING_SPEED)
		c:MoveTo(0, -9041.56, 448.5, 93.06)
	elseif AI_COUNT == 45 then
		pUnit:PlayMusic(17313)
		local c = GetCreature(10, 90072, pUnit)
		c:SendUnitSay("Where are the Scourge? Why has the bloodshed not begun?")
		c:Emote(1)
	elseif AI_COUNT == 51 then
		pUnit:Emote(1)
		pUnit:SendUnitSay("I don't know, but I don't like it.")
		pUnit:RegisterEvent(SpawnScourgeSpam, 1000, 0)
	elseif AI_COUNT == 53 then
		local c = pUnit:SpawnCreature(90074, -9004.24, 481.14, 96.57, 3.84628)
		c:CastSpell(c, 26638)
	elseif AI_COUNT == 54 then
		local c = GetCreature(55, 90074, pUnit)
		c:SendUnitYell("You have foolishly waltzed straight into my lair. Now watch as your bravery leads to your demise!", 0)
		c:Emote(5)
	elseif AI_COUNT == 60 then
		pUnit:SendUnitSay("Quick! Defend me and I'll hold them off. The light shall prevail!")
		pUnit:Dismount()
		local c = GetCreature(10, 90072, pUnit)
		c:Dismount()
		pUnit:MoveTo(0, -9032.7, 458.8, 93)
	elseif AI_COUNT == 62 then
		local c = GetCreature(55, 90074, pUnit)
		c:CastSpell(c, 26638)
		c:DespawnOrUnsummon(1000)
		local entry
		local x = -9042.4
		local y = 460.8
		for _,v in pairs(pUnit:GetNearObjects(30)) do
			entry = v:GetEntry()
			if entry == 90064 or entry == 90066 then
				v:SetSpeed(1, 1)
				v:MoveTo(0, x, y, 93.3)
				x = x + 1.1
				y = y - 1.1
			end
		end
	elseif AI_COUNT == 65 then
		pUnit:SpawnCreature(90075, -8927.5, 541.2, 94.31, 0, 1, 300000)
		pUnit:CastSpell(pUnit, 63772)
		pUnit:SetRooted(true)
		local entry
		for _,v in pairs(pUnit:GetNearObjects(20)) do
			entry = v:GetEntry()
			if entry == 90064 or entry == 90066 then
				v:SetInt32Value(UNIT_NPC_EMOTESTATE, 375)
				v:SetFacing(0.943)
				v:SetRooted(true)
				v:SetHomePosition(v:GetX(), v:GetY(), v:GetZ(), v:GetO())
			end
		end
		local c = GetCreature(20, 90072, pUnit)
		c:SendUnitSay("Hold back heroes, the Argent Dawn can take this fight. I fear that this is merely a distraction. Be on alert.")
		c:Emote(1)
		c:SetFaction(35)
	elseif AI_COUNT == 74 then
		pUnit:SendUnitSay("Heroes, I cannot stop that aberration - it is too big!")
	elseif AI_COUNT == 80 then
		local c = GetCreature(80, 90075, pUnit)
		if c and c:IsAlive() then
			AI_COUNT = AI_COUNT - 1
		end
	elseif AI_COUNT == 81 then
		pUnit:SendUnitSay("One aberration dead, they cannot have the resources to send another.")
		pUnit:SpawnCreature(90075, -8927.5, 541.2, 94.31, 0, 1, 300000)
	elseif AI_COUNT == 88 then
		pUnit:SendUnitSay("Blast, I see another coming. Watch out heroes!")
	elseif AI_COUNT == 95 then
		local c = GetCreature(80, 90075, pUnit)
		if c and c:IsAlive() then
			AI_COUNT = AI_COUNT - 1
		end
	elseif AI_COUNT == 96 then
		pUnit:RemoveEvents()
		pUnit:RegisterEvent(BeginAIMarch, 1000, 0)
		pUnit:SendUnitSay("Let us hope that is the last of the aberrations.")
		local t = pUnit:GetCreaturesInRange(10, 90073)
		for _,v in pairs(t) do
			pUnit:CastSpell(v, 10689)
			v:SetHealth(1)
			v:RegisterEvent(KillSelf, 1900, 1)
		end
	elseif AI_COUNT > 96 and AI_COUNT < 122 then
		local t = pUnit:GetCreaturesInRange(10, 90073)
		for _,v in pairs(t) do
			pUnit:CastSpell(v, 10689)
			v:SetHealth(1)
			v:RegisterEvent(KillSelf, 1900, 1)
		end
	elseif AI_COUNT == 123 then
		pUnit:RemoveAura(63772)
		pUnit:SendUnitSay("That was exhausting. It makes the undead really seem endless.")
		pUnit:Emote(1)
	elseif AI_COUNT == 127 then
		pUnit:SendUnitSay("Heroes, meet me near the trade district when you are ready to continue our assault on Stormwind.")
		pUnit:Emote(1)
	elseif AI_COUNT == 134 then
		local entry
		for _,v in pairs(pUnit:GetNearObjects(30)) do
			entry = v:GetEntry()
			if entry == 90064 or entry == 90066 or entry == 90072 then
				v:DespawnOrUnsummon(0)
			end
		end
		pUnit:DespawnOrUnsummon(0)
		pUnit:RemoveEvents()
		SetSiegeStage(2)
		return
	end
	AI_COUNT = AI_COUNT + 1
end

local function StartEvent(_, _, _, pUnit)
	pUnit:PlayMusic(17314)
	pUnit:SendUnitYell("Men, form up!", 0)
	pUnit:Emote(25)
	local entry
	for _,v in pairs(pUnit:GetNearObjects(50)) do
		entry = v:GetEntry()
		if entry == 90064 or entry == 90066 then
			v:SetSpeed(1, WALKING_SPEED)
			v:MoveTo(0, pUnit:GetRelativePoint(math.random(4, 10), math.random(0, 360)))
		end
	end
	AI_COUNT = 0
	pUnit:RegisterEvent(BeginAIMarch, 1000, 0)
end

-- Gossip start

local function SiegeGossip1(event, player, pUnit)
    player:GossipMenuAddItem(9, "We are ready.", 0, 1)
	player:GossipMenuAddItem(0, "Nevermind.", 0, 0)
    player:GossipSendMenu(90000, pUnit)
end

local function SiegeGossip2(event, player, pUnit, sender, initid, code)
	if initid == 1 then
		local t = pUnit:GetPlayersInRange(40)
		if #t >= 5 or _debug then
			pUnit:SetNPCFlags(0)
			pUnit:RegisterEvent(StartEvent, 1000, 1)
		else
			player:SendBroadcastMessage("There are not enough players nearby to start the event. There needs to be five people minimum.")
		end
	end
	player:GossipComplete()
end

RegisterCreatureGossipEvent(90071, 1, SiegeGossip1)
RegisterCreatureGossipEvent(90071, 2, SiegeGossip2)
