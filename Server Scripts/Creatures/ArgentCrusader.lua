
local function argentAI(e, d, r, pUnit)
	local healed = false
	if pUnit:GetPowerPct(0) > 15 then
		local t = pUnit:GetCreaturesInRange(30, 90064)
		for _,v in pairs(t) do
			if v:IsAlive() and v:GetPhaseMask() == pUnit:GetPhaseMask() and v:GetHealthPct() < 60 then
				pUnit:CastSpell(v, 639)
				healed = true
				break
			end
		end
		local t = pUnit:GetCreaturesInRange(30, 90066)
		for _,v in pairs(t) do
			if v:IsAlive() and v:GetPhaseMask() == pUnit:GetPhaseMask() and v:GetHealthPct() < 60 then
				pUnit:CastSpell(v, 639)
				healed = true
				break
			end
		end
	end
	if not healed then
		local t = pUnit:GetAITarget(1)
		if t then
			if math.random(1,2) == 1 then
				pUnit:CastSpell(t, 90028)
			else
				pUnit:CastSpellAoF(t:GetX(), t:GetY(), t:GetZ(), 90010)
			end
		end
	end
	pUnit:RegisterEvent(argentAI, math.random(5, 8) * 1000, 1)
end

local function argent(event, pUnit, extra)
	if event == 1 then
		if not pUnit:HasAura(19742) then
			pUnit:CastSpell(pUnit, 19742)
		end
		pUnit:RegisterEvent(argentAI, math.random(1,3) * 1000, 1)
	else
		pUnit:RemoveEvents()
	end
end

RegisterCreatureEvent(90064, 1, argent)
RegisterCreatureEvent(90064, 2, argent)
RegisterCreatureEvent(90064, 4, argent)
