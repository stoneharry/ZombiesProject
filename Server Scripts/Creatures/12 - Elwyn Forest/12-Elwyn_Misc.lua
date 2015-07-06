local Utility = {}

--[[NORTHSHIRE ABBEY]]--

--90004 - Argent Battle Priest
function Utility.CastBlessing(eventId, delay, repeats, pUnit)
	if pUnit:IsAlive() then
		pUnit:CastSpell(pUnit, 58054)
	end
end

function Utility.BattlePriestBuff(event, pUnit, extra)
	if event == 4 then
		pUnit:RemoveEvents()
		return
	end
	pUnit:RegisterEvent(Utility.CastBlessing, 1800000, 0)
	pUnit:CastSpell(pUnit, 58054) -- Blessing of Kings
end

RegisterCreatureEvent(90004, 5, Utility.BattlePriestBuff)
RegisterCreatureEvent(90004, 4, Utility.BattlePriestBuff)

--90006 - Juni Spiritwind

function Utility.CastHover(eventId, delay, repeats, pUnit)
	if pUnit:IsAlive() then
		pUnit:CastSpell(pUnit,75333)
	end
end

function Utility.SpiritwindHover(event, pUnit, extra)
	--pUnit:RegisterEvent(Utility.CastHover, 1000, 1)
end

RegisterCreatureEvent(90006, 5, Utility.SpiritwindHover)