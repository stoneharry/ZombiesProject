
local bossSpawned = false

local function PerformSetup(_, _, _, pUnit)
	local x,y,z
	for i=0,360,40 do
		x, y, z = pUnit:GetRelativePoint(15, i)
		pUnit:SpawnCreature(90068, x, y, z, i):SetFacingToObject(pUnit)
	end
	-- boss bad guy
	x, y, z = pUnit:GetRelativePoint(6.5, pUnit:GetO())
	pUnit:SpawnCreature(90069, x, y, z + 3, 0):SetFacingToObject(pUnit)
end

local function KeepVisual(_, _, _, pUnit)
	local c = GetCreature(30, 90069, pUnit)
	if c and c:IsAlive() and not c:IsInCombat() then
		c:CastSpell(pUnit, 48185)
	end
	local t = pUnit:GetCreaturesInRange(50, 90068)
	for _,v in pairs(t) do
		if v:IsAlive() and v:GetPhaseMask() == pUnit:GetPhaseMask() then
			if not v:IsInCombat() then
				v:CastSpell(pUnit, 45104)
			end
		end
	end
	pUnit:RegisterEvent(KeepVisual, 30000, 1)
end

local function HandleEventFinish(_, _, _, pUnit)
	local t = pUnit:GetCreaturesInRange(50, 90068)
	for _,v in pairs(t) do
		if v:IsAlive() and v:GetPhaseMask() == pUnit:GetPhaseMask() then
			return
		end
	end
	if not bossSpawned then
		local c = GetCreature(30, 90069, pUnit)
		bossSpawned = true
		c:SetUInt32Value(UNIT_FIELD_FLAGS, 0)
		c:SendUnitSay("Fools! The cauldron will continue to run even without my minions.", 0)
		return
	end
end

local function event1handler(event, pUnit)
	bossSpawned = false
	pUnit:RegisterEvent(PerformSetup, 1000, 1)
	pUnit:RegisterEvent(KeepVisual, 3000, 1)
	pUnit:RegisterEvent(HandleEventFinish, 5000, 0)
end

RegisterCreatureEvent(90067, 5, event1handler)

local function FlamesChemical(_, _, _, pUnit)
	local t = pUnit:GetAITarget(0)
	if t then
		pUnit:CastSpell(t, 36253)
	end
end

local function putriDie(event, pUnit)
	if event == 4 or event == 2 then
		if event == 4 then
			pUnit:SendUnitSay("I will return! The dead do not stay dead for long.", 0)
			pUnit:RemoveEvents()
			EVENT_DONE = true
			for _,v in pairs(pUnit:GetPlayersInRange(40)) do
				v:AddItem(12844, 1) -- argent dawn valor token, 100 rep
				v:AddItem(44990, 25) -- Champion's Seal - currency
			end
			local despawnTime = 30
			local t = pUnit:GetGameObjectsInRange(40, 400000)
			for _,v in pairs(t) do
				v:Despawn(despawnTime)
			end
			local t = pUnit:GetGameObjectsInRange(40, 177289)
			for _,v in pairs(t) do
				v:Despawn(despawnTime)
			end
			local c = GetCreature(40, 90067, pUnit)
			if c then
				c:DespawnOrUnsummon(0)
			end
		end
		pUnit:RemoveEvents()
	else
		pUnit:RegisterEvent(FlamesChemical, 4000, 0)
	end
end

RegisterCreatureEvent(90069, 4, putriDie)
RegisterCreatureEvent(90069, 2, putriDie)
RegisterCreatureEvent(90069, 1, putriDie)
