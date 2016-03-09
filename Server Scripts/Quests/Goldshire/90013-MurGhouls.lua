local MurGhouls = {}

--MurGhouls Torch

local function TorchOnUse(event,plr,item,pUnit)
	if (pUnit ~= nil) then
		if (pUnit:GetEntry() == 90230) then
			if pUnit:IsDead() then
				if (MurGhouls[pUnit:GetGUIDLow()] == nil) then
					MurGhouls[pUnit:GetGUIDLow()] = 1
					return true
				else
					plr:SendAreaTriggerMessage("|cFFFF0000Your target has allready been burnt.|r")
				end
			else
				plr:SendAreaTriggerMessage("|cFFFF0000Your target has to be dead.|r")
			end
		else
			plr:SendAreaTriggerMessage("|cFFFF0000You cannot target this creature.|r")
		end
	else
		plr:SendAreaTriggerMessage("|cFFFF0000There is no target.|r")
	end
	return false
end

local function MurGhoulOnSpawn(event, pUnit)
	if (event == 5) then
		if (MurGhouls[pUnit:GetGUIDLow()] ~= nil) then
			MurGhouls[pUnit:GetGUIDLow()] = nil
		end
	end
end

RegisterCreatureEvent(90230, 5, MurGhoulOnSpawn)
RegisterItemEvent(90007, 2, TorchOnUse)