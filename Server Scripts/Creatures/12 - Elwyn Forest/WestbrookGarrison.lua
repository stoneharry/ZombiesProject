
local function FindTargetToKill(_, _, _, pUnit)
	if not pUnit:IsInCombat() then
		local t = pUnit:GetCreaturesInRange(30, 90064)
		if t then
			for _,v in pairs(t) do
				if pUnit:GetDistance2d(v) < 20 then
					pUnit:AttackStart(v)
					break
				end
			end
		end
	end
end

local function MoveToBarracks(_, _, _, pUnit)
	pUnit:SetHomePosition(-9661.4, 686.9, 37.5, 2.752316)
	pUnit:MoveTo(0, -9649.3, 681.8, 37.5)
	pUnit:SetFaction(17)
	pUnit:SetSpeed(1, 0.5)
	pUnit:RegisterEvent(FindTargetToKill, 5000, 0)
end

local function SpawnAttackingThing(_, _, _, pUnit)
	local t = pUnit:GetCreaturesInRange(10, 90001)
	if t then
		for _,v in pairs(t) do
			v:DespawnOrUnsummon(0)
		end
	end
	local c = pUnit:SpawnCreature(90001, pUnit:GetX(), pUnit:GetY(), pUnit:GetZ(), pUnit:GetO(), 3, 120000)
	c:CastSpell(c, 41232, true)
	c:RegisterEvent(MoveToBarracks, 10000, 1)
	pUnit:RegisterEvent(SpawnAttackingThing, math.random(5, 15) * (60 * 1000), 1)
end

local function dummyspawn(event, pUnit)
	SpawnAttackingThing(nil, nil, nil, pUnit)
	pUnit:RegisterEvent(SpawnAttackingThing, math.random(10, 15) * (60 * 1000), 1)
end

RegisterCreatureEvent(90065, 5, dummyspawn)
