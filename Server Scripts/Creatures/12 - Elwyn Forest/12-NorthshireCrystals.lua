
local zombieMinionID = 90015
local timePassed = {}

local function ZombieTicker(eventId, delay, repeats, pUnit)
	local map = pUnit:GetMap()
	local t = pUnit:GetNearObjects(40, 0, zombieMinionID)
	for _,v in pairs(t) do
		if v and v:IsStopped() and v:GetFaction() == 17 and not v:IsInCombat() and pUnit:GetDistance2d(v) < 35 then
			local x = pUnit:GetX() + math.random(-15, 15)
			local y = pUnit:GetY() + math.random(-15, 15)
			v:MoveTo(0, x, y, map:GetHeight(x, y))
		end
	end
	local currentTime = timePassed[tostring(pUnit:GetGUID())]
	if not currentTime then
		currentTime = 0
	end
	if currentTime > 10000 then
		currentTime = 0
		spawnZombies(pUnit, 1, zombieMinionID)
	else
		currentTime = currentTime + delay
	end
	--pUnit:SendUnitSay(tostring(currentTime) .. " | " .. tostring(delay) .. " | " .. tostring(pUnit:GetGUID()), 0)
	timePassed[tostring(pUnit:GetGUID())] = currentTime
	pUnit:RegisterEvent(ZombieTicker, math.random(1000, 3000), 1)
end

local function crystalEvents(event, pUnit, target)
	if event == 5 then
		pUnit:RegisterEvent(ZombieTicker, 1000, 1)
		pUnit:SetAggroEnabled(false)
		pUnit:SetReactState(0)
	elseif event == 4 then
		pUnit:RemoveEvents()
		pUnit:CastSpell(pUnit, 70509, true) -- visual
	else
		return false
	end
end

RegisterCreatureEvent(90014, 1, crystalEvents)
RegisterCreatureEvent(90014, 4, crystalEvents)
RegisterCreatureEvent(90014, 5, crystalEvents)

---------------------------
---------------------------
---------------------------

local function LoseHealth(eventId, delay, repeats, pUnit)
	pUnit:CastSpell(pUnit, 90021, true) -- DAMAGE SELF
end

local function SetHostile(eventId, delay, repeats, pUnit)
	pUnit:SetFaction(17)
	pUnit:SetUInt32Value(0x0006 + 0x0035, 0) -- attackable, targetable
end

local function SetDisplay(eventId, delay, repeats, pUnit)
	pUnit:SetDisplayId(24991 + math.random(1, 7))
end

local function SpawnFromGround(eventId, delay, repeats, pUnit)
	pUnit:SetUInt32Value(0x0006 + 0x0044, 0) -- above ground
	pUnit:RegisterEvent(SetHostile, 4000, 1)
end

local function ZombieMinion(event, pUnit, extra)
	pUnit:SetUInt32Value(0x0006 + 0x0035, 33554434) -- unattackable, untargetable
	pUnit:SetUInt32Value(0x0006 + 0x0044, 9) -- underground
	pUnit:RegisterEvent(SpawnFromGround, 2000, 1)
	pUnit:RegisterEvent(SetDisplay, 1000, 1)
	pUnit:RegisterEvent(LoseHealth, 1000, 0)
end

RegisterCreatureEvent(zombieMinionID, 5, ZombieMinion)
