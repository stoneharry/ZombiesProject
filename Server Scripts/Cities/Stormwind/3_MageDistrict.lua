
local healthPct = nil

local function KillSelfAndDespawn(_, _, _, pUnit)
	pUnit:Kill(pUnit)
	pUnit:DespawnOrUnsummon(10000)
end

local function MoveToBossAndConsume(_, _, _, pUnit)
	local c = pUnit:GetCreature(50, 90093)
	if c then
		pUnit:MoveTo(0, c:GetX(), c:GetY(), c:GetZ())
		if pUnit:GetDistance(c) < 1 then
			pUnit:CastSpell(pUnit, 72130, true)
			pUnit:RemoveEvents()
			pUnit:RegisterEvent(KillSelfAndDespawn, 1000, 1)
			c:CastSpell(c, 90035, true)
		end
	end
end

local function consumeSoul(_, _, _, pUnit)
	if pUnit:GetHealthPct() < healthPct then
		local c = pUnit:GetCreature(50, 90094)
		if c then
			healthPct = healthPct - 20
			c:SetSpeed(1, 0.2)
			c:RegisterEvent(MoveToBossAndConsume, 1000, 0)	
		end
	end
end

local function blueFireVisual(_, _, _, pUnit)
	pUnit:CastSpell(pUnit, 42706, true)
end

local function setupArgentDummys(pUnit)
	for _,v in pairs(pUnit:GetCreaturesInRange(70, 90094)) do
		v:DespawnOrUnsummon(0)
	end
	pUnit:SpawnCreature(90094, -8991.46, 860.75, 29, 4.918545)
	pUnit:SpawnCreature(90094, -8996.6, 864.5, 29, 5.184792)
	pUnit:SpawnCreature(90094, -9001.1, 862.98, 29, 5.479314)
	pUnit:SpawnCreature(90094, -8997.9, 854.2, 29, 5.793471)
end

local function GROGS_ANGRY(_, _, _, pUnit)
	local plr = pUnit:GetAITarget(4)
	if not plr or not plr:IsWithinLoS(pUnit) then
		for i=1,3 do
			plr = pUnit:GetAITarget(0)
			if plr and plr:IsWithinLoS(pUnit) then
				break
			end
		end
	end
	if plr then
		pUnit:CastSpell(plr, 90034)
	end
end

local function stompFire(_, _, _, pUnit)
	pUnit:CastSpell(pUnit, 68771)
	local x = pUnit:GetX()
	local y = pUnit:GetY()
	local z = pUnit:GetZ()
	pUnit:SpawnCreature(90095, x + 3, y, z, 0)
	pUnit:SpawnCreature(90095, x, y + 3, z, 0)
	pUnit:SpawnCreature(90095, x - 3, y, z, 0)
	pUnit:SpawnCreature(90095, x, y - 3, z, 0)
	pUnit:SpawnCreature(90095, x - 3, y - 3, z, 0)
	pUnit:SpawnCreature(90095, x + 3, y + 3, z, 0)
	pUnit:SpawnCreature(90095, x + 3, y - 3, z, 0)
	pUnit:SpawnCreature(90095, x - 3, y + 3, z, 0)
end

local function BOSS_AI(event, pUnit)
	if event == 1 then
		healthPct = 80
		pUnit:RegisterEvent(GROGS_ANGRY, 10000, 0)
		pUnit:RegisterEvent(consumeSoul, 1000, 0)
		pUnit:RegisterEvent(stompFire, 18000, 0)
	elseif event == 2 then
		pUnit:RemoveEvents()
		pUnit:RegisterEvent(blueFireVisual, 400, 0)
		setupArgentDummys(pUnit)
		for _,v in pairs(pUnit:GetCreaturesInRange(70, 90095)) do
			v:RemoveAura(47972)
			v:RemoveEvents()
			v:DespawnOrUnsummon(2000)
		end
	elseif event == 3 then
		pUnit:CastSpell(pUnit, 90035, true)
	elseif event == 4 then
		pUnit:RemoveEvents()
		for _,v in pairs(pUnit:GetCreaturesInRange(70, 90094)) do
			v:Kill(v)
			v:DespawnOrUnsummon(10000)
		end
		for _,v in pairs(pUnit:GetCreaturesInRange(70, 90095)) do
			v:RemoveAura(47972)
			v:RemoveEvents()
			v:DespawnOrUnsummon(2000)
		end
		SetSiegeStage(GetSiegeStage() + 1, 1)
	elseif event == 5 then
		if not GetSiegeCanSpawn(1) then
			pUnit:DespawnOrUnsummon(0)
			return
		end
		pUnit:RegisterEvent(blueFireVisual, 400, 0)
		setupArgentDummys(pUnit)
	end
end

for i=1,5 do
	RegisterCreatureEvent(90093, i, BOSS_AI)
end
i = nil

-- Blue fire

local function DamageNearbyPlayers(_, _, _, pUnit)
	for _,v in pairs(pUnit:GetPlayersInRange(2)) do
		pUnit:DealDamage(v, 5, false, 5)
	end
end

local function DespawnSelf(_, _, _, pUnit)
	pUnit:RemoveAura(47972)
	pUnit:RemoveEvents()
	pUnit:DespawnOrUnsummon(2000)
end

local function BlueFire(event, pUnit)
	pUnit:CastSpell(pUnit, 47972)
	pUnit:RegisterEvent(DamageNearbyPlayers, 1000, 0)
	pUnit:RegisterEvent(DespawnSelf, 30000, 1)
end

RegisterCreatureEvent(90095, 5, BlueFire)

-- Flying adds

local function STRANGLE_SELF(event, pUnit)
	pUnit:SetUInt32Value(UNIT_FIELD_FLAGS, UNIT_FIELD_FLAG_UNTARGETABLE)
	pUnit:CastSpell(pUnit, 69413, true)
	pUnit:MoveTo(0, pUnit:GetX(), pUnit:GetY(), pUnit:GetZ() + 5)
	pUnit:SetHealth(pUnit:GetMaxHealth() - math.random(40, 80))
end

RegisterCreatureEvent(90094, 5, STRANGLE_SELF)
