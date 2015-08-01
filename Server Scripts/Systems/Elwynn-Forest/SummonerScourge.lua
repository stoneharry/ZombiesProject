
local function scourgeAI(e, d, r, pUnit)
	local t = pUnit:GetAITarget(1)
	if t then
		pUnit:SetRooted(pUnit:GetDistance2d(t) < 20)
		local choice = math.random(1,4)
		if choice < 4 then
			pUnit:CastSpell(t, 695)
			pUnit:RegisterEvent(scourgeAI, 2500, 1)
		else
			pUnit:CastSpellAoF(t:GetX(), t:GetY(), t:GetZ(), 6219)
			pUnit:RegisterEvent(scourgeAI, 8500, 1)
		end
	end
end

local function scourge(event, pUnit, extra)
	if event == 1 then
		pUnit:RegisterEvent(scourgeAI, 100, 1)
	else
		pUnit:SetRooted(false)
		pUnit:RemoveEvents()
	end
end

RegisterCreatureEvent(90068, 1, scourge)
RegisterCreatureEvent(90068, 2, scourge)
RegisterCreatureEvent(90068, 4, scourge)
