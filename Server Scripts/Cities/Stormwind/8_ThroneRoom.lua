
local outro = false
local AI_TICKER = 0

-- Dummy Spawner

local function CheckForSpawn(_, _, _, pUnit)
	if GetSiegeStage() == 8 then
		pUnit:RemoveEvents()
		pUnit:SpawnCreature(90085, pUnit:GetX(), pUnit:GetY(), pUnit:GetZ(), pUnit:GetO())
	end
end

local function DummySpawn(event, pUnit)
	pUnit:RegisterEvent(CheckForSpawn, 5000, 0)
end

RegisterCreatureEvent(90084, 5, DummySpawn)

-- Boss

local function InitialDefile(_, _, _, pUnit)
	pUnit:SendUnitSay("This shattered ground shall swallow you for the vermin you are.")
	local _OOffset = 0
	for i=1,10 do
		local x,y,z = pUnit:GetRelativePoint(11.5, _OOffset)
		_OOffset = _OOffset + 36
		pUnit:SpawnCreature(90087, x, y, 121, 0, 3, 120000)
	end
end

local function SecondDefile(_, _, _, pUnit)
	local _OOffset = 0
	for i=1,10 do
		local x,y,z = pUnit:GetRelativePoint(9.3, _OOffset)
		_OOffset = _OOffset + 36
		pUnit:SpawnCreature(90087, x, y, 122, 0, 3, 120000)
	end
end

local function ThirdDefile(_, _, _, pUnit)
	local _OOffset = 0
	for i=1,10 do
		local x,y,z = pUnit:GetRelativePoint(5.5, _OOffset)
		_OOffset = _OOffset + 36
		pUnit:SpawnCreature(90087, x, y, 123, 0, 3, 120000)
	end
end

local function DefileStop(_, _, _, pUnit)
	for _,v in pairs(pUnit:GetCreaturesInRange(50, 90087)) do
		v:RemoveEvents()
		v:RemoveAura(72743)
		v:DespawnOrUnsummon(2000)
	end
end

local function DefileSetup(_, _, _, pUnit)
	pUnit:RegisterEvent(InitialDefile, 10000, 1)
	pUnit:RegisterEvent(SecondDefile, 15000, 1)
	pUnit:RegisterEvent(ThirdDefile, 20000, 1)
	pUnit:RegisterEvent(DefileStop, 35000, 1)
end

local function BecomeHostile(_, _, _, pUnit)
	pUnit:SetUInt32Value(UNIT_FIELD_FLAGS, 0)
end

local function KnockbackKick(_, _, _, pUnit)
	local plr = pUnit:GetAITarget(1)
	if plr and pUnit:GetDistance(plr) < 2 then
		pUnit:CastSpell(plr, 54899)
	end
end

local function SoulRibbon(_, _, _, pUnit)
	if not pUnit:IsCasting() then
		local chance = math.random(1,3)
		local plr = nil
		if chance < 3 then
			plr = pUnit:GetAITarget(1)
		else
			plr = pUnit:GetAITarget(0)
		end
		if plr then
			pUnit:CastSpell(plr, 32422)
		end
	end
end

local function SpawnMoreSouls(_, _, _, pUnit)
	if not pUnit:IsCasting() then
		local t = pUnit:GetCreaturesInRange(50, 90086)
		if not t or #t == 0 then
			pUnit:CastSpell(pUnit, 70498)
		end
	end
end

local function SpawnPortalCreature(_, _, _, pUnit)
	local c = pUnit:SpawnCreature(90090, pUnit:GetX(), pUnit:GetY(), pUnit:GetZ(), pUnit:GetO())
	local b = GetCreature(50, 90085, pUnit)
	if b then
		if b:IsInCombat() then
			c:MoveTo(0, b:GetX(), b:GetY(), b:GetZ())
		else
			c:DespawnOrUnsummon(1000)
		end
	end
end

local function RemovePortalVisual(_, _, _, pUnit)
	pUnit:RemoveAura(60284)
end

local function OpenDemonPortal(_, _, _, pUnit)
	local t = pUnit:GetCreaturesInRange(50, 90089)
	local n = #t
	if not n or n == 0 then
		return
	end
	local c = t[math.random(1, n)]
	if c then
		pUnit:CastSpell(c, 72313, true)
		c:CastSpell(c, 60284)
		c:RegisterEvent(SpawnPortalCreature, 5000, 1)
		c:RegisterEvent(RemovePortalVisual, 9000, 1)
	end
end

local function StormSpiritThing(_, _, _, pUnit)
	pUnit:SendUnitSay("The Lich King grants me unrelenting power!")
	pUnit:CastSpell(pUnit, 68872, true)
end

local function ResetRoom(pUnit)
	pUnit:RemoveEvents()
	pUnit:SetRooted(false)
	local spawnedUnits = {90090, 90086, 90087, 90088}
	for _,u in pairs(spawnedUnits) do
		for _,v in pairs(pUnit:GetCreaturesInRange(50, u)) do
			v:DespawnOrUnsummon(0)
		end
	end
	_CurrentPosition = {}
	pUnit:SetUInt32Value(UNIT_FIELD_FLAGS, UNIT_FIELD_FLAG_C_UNATTACKABLE)
end

local function AI_TICK(_, _, _, pUnit)
	AI_TICKER = AI_TICKER + 1
	if AI_TICKER == 1 then
		if pUnit:GetDistance(-8439.48, 330.75, 122.6) > 1 then
			AI_TICKER = AI_TICKER - 1
		end
	elseif AI_TICKER == 3 then
		pUnit:SetFacing(2.174541)
		pUnit:SetUInt32Value(UNIT_FIELD_BYTES_1, 8)
	elseif AI_TICKER == 5 then
		local c = pUnit:SpawnCreature(90092, -8450.2, 344.2, 120.9, 5.4)
		c:CastSpell(c, 42048)
	elseif AI_TICKER == 6 then
		local c = pUnit:SpawnCreature(90091, -8450.2, 344.2, 120.9, 5.4)
		c:SetSpeed(1, 0.25)
		c:MoveTo(0, -8448.5, 341.6, 120.9)
	elseif AI_TICKER == 10 then
		local c = GetCreature(40, 90091, pUnit)
		c:SendUnitSay("You have failed me, Diodor. Your soul shall return to Frostmourne.")	
		c:Emote(1)
	elseif AI_TICKER == 15 then
		local c = GetCreature(40, 90091, pUnit)
		c:ChannelSpell(pUnit, 69397)
		pUnit:SetUInt32Value(UNIT_FIELD_BYTES_1, 0)
		pUnit:SetInt32Value(UNIT_NPC_EMOTESTATE, 383)
	elseif AI_TICKER == 22 then
		pUnit:CastSpell(pUnit, 73806)
		pUnit:SetFaction(35)
		pUnit:SetUInt32Value(UNIT_FIELD_FLAGS, UNIT_FIELD_FLAG_UNTARGETABLE)
		pUnit:SetEquipmentSlots(0, 0, 0)
		local c = GetCreature(40, 90091, pUnit)
		c:StopChannel()
	elseif AI_TICKER == 25 then
		local c = GetCreature(40, 90091, pUnit)
		c:SendUnitSay("Stormwind is yours... for now.")
		c:Emote(1)
	elseif AI_TICKER == 29 then
		local c = GetCreature(40, 90091, pUnit)
		c:MoveTo(0, -8450.2, 344.2, 120.9)
		c:DespawnOrUnsummon(2000)
	elseif AI_TICKER == 33 then
		pUnit:RemoveEvents()
		local v = GetCreature(40, 90092, pUnit)
		v:RemoveAura(42048)
		v:DespawnOrUnsummon(1000)
		pUnit:DespawnOrUnsummon(0)
	end
end

local function Outro(_, _, _, pUnit)
	if pUnit:GetHealthPct() < 20 then
		outro = true
		ResetRoom(pUnit)
		pUnit:AttackStop()
		pUnit:SendUnitSay("I cannot be defeated...")
		pUnit:CastSpell(pUnit, 65256)
		for _,v in pairs(pUnit:GetPlayersInRange(60)) do
			v:AttackStop()
			v:CastSpell(v, 65256)
		end
		pUnit:MoveTo(0, -8439.48, 330.75, 122.6)
		AI_TICKER = 0
		pUnit:RegisterEvent(AI_TICK, 1000, 0)
	end
end

local function SummonSpirits(_, _, _, pUnit)
	pUnit:CastSpell(pUnit, 70498)
	pUnit:RegisterEvent(BecomeHostile, 5000, 1)
	pUnit:RegisterEvent(DefileSetup, 30000, 1)
	pUnit:RegisterEvent(KnockbackKick, 10000, 0)
	pUnit:RegisterEvent(SoulRibbon, 3000, 0)
	pUnit:RegisterEvent(SpawnMoreSouls, 4000, 0)
	pUnit:RegisterEvent(OpenDemonPortal, 28000, 0)
	pUnit:RegisterEvent(StormSpiritThing, 90100, 0)
	pUnit:RegisterEvent(Outro, 1000, 0)
end

local function StartBattleSoon(_, _, _, pUnit)
	local plr = pUnit:GetNearestPlayer()
	if plr and plr:GetDistance(pUnit) < 40 and plr:IsAlive() then
		pUnit:RemoveEvents()
		pUnit:SendUnitSay("Valiant heroes arrive at my doorstep hoping to bring glory to their beloved faction. It is all in vain - your advance ends here.")
		pUnit:Emote(1)
		pUnit:RegisterEvent(SummonSpirits, 8000, 1)
	end
end

local function BossEvents(event, pUnit)
	if outro then
		return
	end
	if event == 2 or event == 4 then
		ResetRoom(pUnit)
	end
	if event == 1 then
		pUnit:PlayMusic(20002) --15853) -- long battle music
		pUnit:SetRooted(true)
		pUnit:SpawnCreature(90088, -8453.8, 352.42, 120.9, 0)
		pUnit:SpawnCreature(90088, -8456.9, 349.8, 120.9, 0)
	elseif event == 2 then
		pUnit:RegisterEvent(StartBattleSoon, 5000, 0)
	elseif event == 3 then
		-- killed somebody
	elseif event == 5 then
		pUnit:RegisterEvent(StartBattleSoon, 5000, 0)
	end
end

for i=1,5 do
	RegisterCreatureEvent(90085, i, BossEvents)
end
i = nil

-- Vile spirits

local _EdgeThronePoints = nil
local _EdgeIndex = 0
local _CurrentPosition = {}

local function BlowUp(_, _, _, pUnit)
	pUnit:Kill(pUnit)
	pUnit:DespawnOrUnsummon(5000)
end

local function MoveAroundPointsSpirit(_, _, _, pUnit)
	local plr = pUnit:GetNearestPlayer()
	if plr and plr:IsAlive() and plr:GetDistance(pUnit) < 1.3 then
		pUnit:SetFaction(17)
		pUnit:SetUInt32Value(UNIT_FIELD_FLAGS, 0)
		pUnit:CastSpell(pUnit, 8438, true)
		pUnit:RemoveEvents()
		pUnit:RegisterEvent(BlowUp, 100, 1)
		return
	end
	local index = _CurrentPosition[tostring(pUnit:GetGUID())]
	local x = _EdgeThronePoints[index][1]
	local y = _EdgeThronePoints[index][2]
	local z = 121
	if pUnit:GetDistance(x, y, z) < 2.5 then
		index = index + 1
		if index >= 9 then
			index = index - 8
		end
		_CurrentPosition[tostring(pUnit:GetGUID())] = index
		x = _EdgeThronePoints[index][1]
		y = _EdgeThronePoints[index][2]
		pUnit:MoveTo(0, x, y, z)
	end
end

local function VileSpiritSpawn(event, pUnit)
	if not _EdgeThronePoints then
		local c = GetCreature(40, 90085, pUnit)
		if not c then
			return
		end
		_EdgeThronePoints = {}
		local _OOffset = 0
		for i=1,10 do
			local x,y,z = c:GetRelativePoint(11.5, _OOffset)
			_OOffset = _OOffset + 36
			table.insert(_EdgeThronePoints, {x, y})
		end
	end
	_EdgeIndex = _EdgeIndex + 1
	if _EdgeIndex > 10 then
		_EdgeIndex = 1
	end
	_CurrentPosition[tostring(pUnit:GetGUID())] = _EdgeIndex
	pUnit:MoveTo(0, _EdgeThronePoints[_EdgeIndex][1], _EdgeThronePoints[_EdgeIndex][2], 121)
	pUnit:RegisterEvent(MoveAroundPointsSpirit, 100, 0)
end

RegisterCreatureEvent(90086, 5, VileSpiritSpawn)

-- defile

local function DefileGrow(_, _, _, pUnit)
	local scale = _CurrentPosition[tostring(pUnit:GetGUID())]
	if scale < 0.7 then
		scale = scale + 0.1
		_CurrentPosition[tostring(pUnit:GetGUID())] = scale
		pUnit:SetScale(scale)
		pUnit:CastSpell(pUnit, 72743, true)
	end
	for _,v in pairs(pUnit:GetPlayersInRange(8 * scale)) do
		if v:GetZ() < 122.4 then
			pUnit:DealDamage(v, 5, false, 5)
		end
	end
end

local function DefileSpawn(event, pUnit)
	pUnit:CastSpell(pUnit, 72743)
	_CurrentPosition[tostring(pUnit:GetGUID())] = 0.1
	pUnit:RegisterEvent(DefileGrow, 1000, 0)
end

RegisterCreatureEvent(90087, 5, DefileSpawn)

-- fire

local function FireDamage(_, _, _, pUnit)
	for _,v in pairs(pUnit:GetPlayersInRange(5)) do
		pUnit:DealDamage(v, 250, false, 5)
	end
end

local function FireSpawn(event, pUnit)
	pUnit:CastSpell(pUnit, 71025)
	pUnit:RegisterEvent(FireDamage, 1000, 0)
end

RegisterCreatureEvent(90088, 5, FireSpawn)

-- DK

local function DeathCoil(_, _, _, pUnit)
	local plr = pUnit:GetAITarget(0)
	if plr and plr:GetDistance(pUnit) < 30 then
		pUnit:CastSpell(plr, 38065)
	end
end

local function MortalStrike(_, _, _, pUnit)
	local plr = pUnit:GetAITarget(1)
	if plr then
		pUnit:CastSpell(plr, 59455)
	end
end

local function WarlockAI(event, pUnit)
	if event == 1 then
		if not pUnit:HasAura(90090) then
			pUnit:CastSpell(pUnit, 90090, true)
		end
		pUnit:RegisterEvent(DeathCoil, 10000, 0)
		pUnit:RegisterEvent(MortalStrike, 7000, 0)
	else
		pUnit:RemoveEvents()
		if event == 4 then
			pUnit:DespawnOrUnsummon(5000)
		elseif event == 5 then
			pUnit:CastSpell(pUnit, 706, true)
			pUnit:Mount(28605)
		end
	end
end

RegisterCreatureEvent(90090, 1, WarlockAI)
RegisterCreatureEvent(90090, 2, WarlockAI)
RegisterCreatureEvent(90090, 4, WarlockAI)
RegisterCreatureEvent(90090, 5, WarlockAI)

