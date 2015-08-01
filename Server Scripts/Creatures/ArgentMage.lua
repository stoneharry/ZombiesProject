
local function argentAI(e, d, r, pUnit)
	local t = pUnit:GetAITarget(1)
	if t then
		pUnit:SetRooted(pUnit:GetDistance2d(t) < 20)
		local choice = math.random(1,3)
		if choice == 1 then
			pUnit:CastSpell(t, 205)
			pUnit:RegisterEvent(argentAI, 2000, 1)
		elseif choice == 2 then
			pUnit:CastSpell(t, 7800)
			pUnit:RegisterEvent(argentAI, 2500, 1)
		elseif choice == 3 then
			pUnit:CastSpellAoF(t:GetX(), t:GetY(), t:GetZ(), 10)
			pUnit:RegisterEvent(argentAI, 8500, 1)
		end
	end
end

local function argent(event, pUnit, extra)
	if event == 1 then
		pUnit:RegisterEvent(argentAI, 100, 1)
	else
		pUnit:SetRooted(false)
		pUnit:RemoveEvents()
	end
end

RegisterCreatureEvent(90066, 1, argent)
RegisterCreatureEvent(90066, 2, argent)
RegisterCreatureEvent(90066, 4, argent)
