
-- Starter

local spawnData = {
	{90078, -8874, 584.5, 92.9, 3.81},
	{90079, -8864.4, 591.8, 92.3, 3.79},
	{90078, -8830.2, 626.3, 94, 4},
	{90078, -8830.2, 626.3, 94, 4},
	{90079, -8830.2, 626.3, 94, 4},
	{90079, -8830.2, 626.3, 94, 4},
	{90078, -8797, 643, 94.4, 3.1},
	{90079, -8797, 643, 94.4, 3.1},
	{90078, -8854, 652.5, 96.4, 3},
	{90079, -8854, 652.5, 96.4, 3},
	{90079, -8803, 589, 97.2, 2.219},
	{90080, -8793.9, 684.2, 101.8, 5},
	{90080, -8793.9, 684.2, 101.8, 5},
	{90080, -8826.4, 558, 94.9, 3.8},
	{90080, -8826.4, 558, 94.9, 3.8},
	{90080, -8826.4, 558, 94.9, 3.8},
	{90080, -8826.4, 558, 94.9, 3.8},
	{90080, -8826.4, 558, 94.9, 3.8},
	{90080, -8826.4, 558, 94.9, 3.8}
}

local Scourge = nil
local BossKilled = 0
local function GetScourgeKilled()
	if Scourge == nil then
		return nil
	else
		local ScourgeKilled = #spawnData
		for _,_ in pairs(Scourge) do
			ScourgeKilled = ScourgeKilled - 1
		end
		return ScourgeKilled
	end
end

local function UpdateWorldStates(player)
	local killed = GetScourgeKilled()
	if not killed then
		return
	end
	local norm = #spawnData
	player:InitializeWorldState(901, 0, 0, 1)
	player:UpdateWorldState(9011, killed) -- Sets current scourge count
	player:UpdateWorldState(9012, norm) -- Sets max scourge count
	player:UpdateWorldState(9013, BossKilled) -- Sets current boss count
	player:UpdateWorldState(9014, 1) -- Sets max boss count
end

local function UpdateZonesWorldStates(bool)
	local killed = GetScourgeKilled()
	if not killed then
		return
	end
	local norm = #spawnData
	if killed == norm and BossKilled == 1 then
		SetSiegeStage(3)
	end
	for _,v in pairs(GetPlayersInMap(0, 0, 2)) do
		if v:GetZoneId() == 1519 then
			if bool then
				v:InitializeWorldState(901, 0, 0, 1)
			end
			v:UpdateWorldState(9011, killed) -- Sets current scourge count
			v:UpdateWorldState(9012, norm) -- Sets max scourge count
			v:UpdateWorldState(9013, BossKilled) -- Sets current boss count
			v:UpdateWorldState(9014, 1) -- Sets max boss count
		end
	end
end

local function DespawnEvent2(_, _, _, pUnit)
	if GetSiegeStage() >= 3 then
		pUnit:RemoveEvents()
		local t = {90077, 90066, 90064}
		for _,id in pairs(t) do
			for _,v in pairs(pUnit:GetCreaturesInRange(50, id)) do
				v:DespawnOrUnsummon(0)
			end
		end
	end
end

local function CanMarketEventStart(_, _, _, pUnit)
	local stage = GetSiegeStage()
	if stage >= 2 then
		for _,v in pairs(pUnit:GetGameObjectsInRange(40, 187809)) do
			v:SetByteValue(GAMEOBJECT_BYTES_1, 0, 0)
		end
		pUnit:RemoveEvents()
		if stage == 2 then
			Scourge = {}
			pUnit:SpawnCreature(90077, -8919, 549.2, 94, 0.656422)
			pUnit:SpawnCreature(90066, -8916.4, 557.3, 94, 0.67213)
			pUnit:SpawnCreature(90066, -8910.5, 549.945, 94, 0.668203)
			pUnit:SpawnCreature(90064, -8910.6, 552.8, 93.8, 0.668203)
			pUnit:SpawnCreature(90064, -8913.6, 556.7, 93.8, 0.617152)
			-- Hostile
			for _,t in pairs(spawnData) do
				-- What you see below is a DIRTY hackfix suggested by
				-- Trinity because there is no proper way to do it.
				local c = pUnit:SpawnCreature(t[1], t[2], t[3], t[4], t[5])
				c:SetWanderRadius(15)
				c:SetDefaultMovementType(1)
				c:SetDeathState(1)
				c:Respawn()
				table.insert(Scourge, tostring(c:GetGUID()))
			end
			pUnit:SpawnCreature(90081, -8833.2, 479.858, 109.7, 2.27) -- boss
			UpdateZonesWorldStates(true)
			pUnit:RegisterEvent(DespawnEvent2, 5000, 0)
		end
	end
end

local function DummySpawn(event, pUnit)
	pUnit:RegisterEvent(CanMarketEventStart, 5000, 0)
end

RegisterCreatureEvent(90076, 5, DummySpawn)

-- Gossip start

local function SiegeGossip1(event, player, pUnit, _, intid)
	player:GossipSendMenu(90001, pUnit)
end

RegisterCreatureGossipEvent(90077, 1, SiegeGossip1)

-- Boss1 - Flight Master

local function AggroGryphons(_, _, _, pUnit)
	for _,v in pairs(pUnit:GetCreaturesInRange(50, 90082)) do
		if not v:IsInCombat() then
			v:MoveTo(0, pUnit:GetX(), pUnit:GetY(), pUnit:GetZ())
		end
	end
end

local function FearStrike(_, _, _, pUnit)
	local plr = pUnit:GetAITarget(0)
	if plr then
		pUnit:CastSpell(plr, 72426)
	end
end

local function DeathAndDecay(_, _, _, pUnit)
	local plr = pUnit:GetAITarget(4)
	if plr and plr:GetDistance(pUnit) < 50 then
		pUnit:CastSpellAoF(plr:GetX(), plr:GetY(), plr:GetZ(), 60160)
	else
		plr = pUnit:GetAITarget(0)
		if plr and plr:GetDistance(pUnit) < 50 then
			pUnit:CastSpellAoF(plr:GetX(), plr:GetY(), plr:GetZ(), 60160)
		end
	end
end

local function FuseArmor(_, _, _, pUnit)
	local plr = pUnit:GetAITarget(1)
	if plr then
		pUnit:CastSpell(plr, 54578) -- visual
		plr:CastSpell(plr, 64774, true) -- stun
	end
end

local function Phase3(_, _, _, pUnit)
	if pUnit:GetHealthPct() < 40 then
		pUnit:RemoveEvents()
		pUnit:SendUnitSay("Despair, so delicious.")
		pUnit:PlayDirectSound(16715)
		pUnit:SpawnCreature(90082, -8883, 455, 121, 0.7, 1, 120000)
		pUnit:SpawnCreature(90082, -8883, 455, 121, 0.7, 1, 120000)
		pUnit:RegisterEvent(AggroGryphons, 10000, 0)
		pUnit:RegisterEvent(FearStrike, 10000, 0)
		pUnit:RegisterEvent(DeathAndDecay, 15000, 0)
		pUnit:RegisterEvent(FuseArmor, 20000, 0)
	end
end

local function Phase2(_, _, _, pUnit)
	if pUnit:GetHealthPct() < 75 then
		pUnit:RemoveEvents()
		pUnit:SendUnitSay("Fear, so exhilarating.")
		pUnit:PlayDirectSound(16716)
		pUnit:SpawnCreature(90082, -8883, 455, 121, 0.7, 1, 120000)
		pUnit:SpawnCreature(90082, -8883, 455, 121, 0.7, 1, 120000)
		pUnit:RegisterEvent(AggroGryphons, 10000, 0)
		pUnit:RegisterEvent(FearStrike, 10000, 0)
		pUnit:RegisterEvent(DeathAndDecay, 15000, 0)
		pUnit:RegisterEvent(Phase3, 1000, 0)
	end
end

local function Boss1(event, pUnit)
	if event == 1 then
		pUnit:SendUnitSay("Men, women, and children. None were spared the masters wrath. Your death will be no different.")
		pUnit:PlayDirectSound(16710)
		pUnit:PlayMusic(14930)
		pUnit:RegisterEvent(FearStrike, 10000, 0)
		pUnit:RegisterEvent(Phase2, 1000, 0)
		pUnit:RegisterEvent(DeathAndDecay, 15000, 0)
		for _,v in pairs(pUnit:GetGameObjectsInRange(40, 187809)) do
			v:SetByteValue(GAMEOBJECT_BYTES_1, 0, 1)
		end
	elseif event == 5 then
		local o = PerformIngameSpawn(2, 187809, 0, 0, -8854.57, 509.94, 109.6, 3.802461)
		o:SetByteValue(GAMEOBJECT_BYTES_1, 0, 0)
		pUnit:RegisterScalingHealth()
	else
		for _,v in pairs(pUnit:GetGameObjectsInRange(40, 187809)) do
			v:SetByteValue(GAMEOBJECT_BYTES_1, 0, 0)
		end
		pUnit:RemoveEvents()
		if event == 4 then
			BossKilled = 1
			UpdateZonesWorldStates()
			pUnit:SetData("currentScaling", 1.0)
		end
	end
end

RegisterCreatureEvent(90081, 1, Boss1)
RegisterCreatureEvent(90081, 2, Boss1)
RegisterCreatureEvent(90081, 4, Boss1)
RegisterCreatureEvent(90081, 5, Boss1)

local switch = true

local function GryphonSunder(_, _, _, pUnit)
	local plr = pUnit:GetAITarget(1)
	if plr then
		pUnit:CastSpell(plr, 58461)
	end
end

local function GryphonFly(event, pUnit)
	if event == 5 then
		pUnit:RegisterScalingHealth()
		switch = not switch
		if switch then
			pUnit:MoveTo(0, -8860.1, 491.3, 109.7)
		else
			pUnit:MoveTo(0, -8842.2, 471.3, 109.7)
		end
	elseif event == 1 then
		pUnit:RegisterEvent(GryphonSunder, 9000, 0)
	else
		pUnit:RemoveEvents()
		pUnit:DespawnOrUnsummon(5000)
		if event == 4 then
			pUnit:SetData("currentScaling", 1.0)
		end
	end
end

RegisterCreatureEvent(90082, 5, GryphonFly)
RegisterCreatureEvent(90082, 1, GryphonFly)
RegisterCreatureEvent(90082, 2, GryphonFly)
RegisterCreatureEvent(90082, 4, GryphonFly)

-- Trash

local function RangedAI(_, _, _, pUnit)
	local plr = pUnit:GetAITarget(1)
	if plr then
		if pUnit:GetDistance(plr) < 30 and pUnit:IsWithinLoS(plr) then
			for _,v in pairs(pUnit:GetCreaturesInRange(30, 90078)) do
				if v:IsAlive() and v:GetHealthPct() <= 28 then
					pUnit:SetRooted(true)
					pUnit:ChannelSpell(v, 58847)
					v:CastSpell(v, 37729, true)
					v:CastSpell(v, 8699, true)
					v:SetRooted(true)
					pUnit:RegisterEvent(ConvertToScourge, 5000, 1)
					return
				end
			end
			if pUnit:GetPowerPct(0) <= 8 then
				pUnit:SetRooted(false)
				return
			end
			pUnit:SetRooted(true)
			pUnit:CastSpell(plr, 90033)
			pUnit:RegisterEvent(RangedAI, 4000, 1)
			return
		else
			pUnit:SetRooted(false)
		end
	end
	pUnit:RegisterEvent(RangedAI, 1000, 1)
end

function ConvertToScourge(_, _, _, pUnit)
	for _,v in pairs(pUnit:GetCreaturesInRange(30, 90078)) do
		if v:IsAlive() and v:GetHealthPct() <= 28 then
			v:CastSpell(v, 17616, true)
			v:Kill(v)
			for i=-2,4,2 do
				pUnit:SpawnCreature(90080, v:GetX()+i, v:GetY(), v:GetZ(), v:GetO(), 1, 120000)
			end
			break
		end
	end
	pUnit:StopChannel()
	pUnit:RegisterEvent(RangedAI, 1000, 1)
end

local function TrashHandler(event, pUnit)
	if event == 5 then
		pUnit:CallForHelp(25)
		pUnit:RegisterScalingHealth()
	elseif event == 1 then
		if pUnit:GetEntry() == 90079 then
			pUnit:RegisterEvent(RangedAI, 1000, 1)
		end
	else
		pUnit:SetRooted(false)
		pUnit:RemoveEvents()
		if event == 4 then
			local g = tostring(pUnit:GetGUID())
			local index = 0
			for k,v in pairs(Scourge) do
				if v == g then
					index = k
					break
				end
			end
			if index ~= 0 then
				table.remove(Scourge, index)
				UpdateZonesWorldStates()
			end
			pUnit:SetData("currentScaling", 1.0)
		end
	end
end

RegisterCreatureEvent(90078, 5, TrashHandler)
RegisterCreatureEvent(90079, 5, TrashHandler)
RegisterCreatureEvent(90080, 5, TrashHandler)
RegisterCreatureEvent(90079, 1, TrashHandler)
RegisterCreatureEvent(90079, 2, TrashHandler)
RegisterCreatureEvent(90079, 4, TrashHandler)
RegisterCreatureEvent(90080, 4, TrashHandler)
RegisterCreatureEvent(90078, 4, TrashHandler)

-- Worldstates

local function OnUpdateZone(event, player)
    if (player:GetMapId() == 0) and (player:GetZoneId() == 1519) then
		if GetSiegeStage() == 2 then
			UpdateWorldStates(player)
		end
    end
end

RegisterPlayerEvent(27, OnUpdateZone)

-- End stage 2 dummy

local function CanMarketEndEvent(_, _, _, pUnit)
	if GetSiegeStage() >= 3 then
		for _,v in pairs(pUnit:GetGameObjectsInRange(150, 187809)) do
			v:SetByteValue(GAMEOBJECT_BYTES_1, 0, 0)
		end
		PerformIngameSpawn(2, 190237, 0, 0, -8824.18457, 630.956543, 94.06414, 3.792606)
		pUnit:SpawnCreature(90096, -8825.91, 629.5, 94.1, 3.882143)
		for _,t in pairs(spawnData) do
			-- What you see below is a DIRTY hackfix suggested by
			-- Trinity because there is no proper way to do it.
			local id
			if math.random(1,2) == 1 then
				id = 90064
			else
				id = 90066
			end
			local c = pUnit:SpawnCreature(id, t[2], t[3], t[4], t[5])
			c:SetWanderRadius(15)
			c:SetDefaultMovementType(1)
			c:SetDeathState(1)
			c:Respawn()
		end
		pUnit:RemoveEvents()
	end
end

local function DummySpawn2(event, pUnit)
	pUnit:RegisterEvent(CanMarketEndEvent, 5000, 0)
end

RegisterCreatureEvent(90083, 5, DummySpawn2)

local function SiegeGossip2(event, player, pUnit, _, intid)
	player:GossipSendMenu(90002, pUnit)
end

RegisterCreatureGossipEvent(90096, 1, SiegeGossip2)

