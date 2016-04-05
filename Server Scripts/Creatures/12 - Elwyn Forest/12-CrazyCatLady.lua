--Donni Anthania, The Crazy Cat Lady. Thought it would be fun to add her back.
--Plan is to let her drop a quest item, that'll upgrade to a butchers knife :)
--Exported sound files from https://www.youtube.com/watch?v=BcmM4PJiT-w   - 90010, 90011, 90012

local CatLadyEvent = 0
local CatLadyActive = 0
local CatLadyCooldown = 0

local DEBUG = true

local function BugPrint(msg)
	if (DEBUG  == true) then
		if (msg ~= nil) then
			print(msg)
		else
			print("Msg was nil, unable to print")
		end
	end
end

local function CatLadyAI_Jump(event, delay, repeats, pUnit)
	if (repeats == 2) then
		local x,y,z = pUnit:GetRelativePoint(5, math.random(1,360))
		BugPrint("x:"..tostring(x).." y: "..tostring(y).." z: "..tostring(z))
		pUnit:MoveJump(x,y,z, 9, 8)
	else
		pUnit:CastSpell(pUnit, 11, true)
	end
end

local function CatLadyAI_SPELLS(event,delay,repeats,pUnit)
	BugPrint("Delay: "..tostring(delay).." Repeats: "..tostring(repeats).." Active or not?: "..tostring(CatLadyActive))
	if (delay == 16000) then --After 16 seconds, allow CatLady to cast other spells
		CatLadyActive = 0
		pUnit:SetRooted(false)
		BugPrint("CatLadyActive: "..tostring(CatLadyActive))
	elseif (delay == 20000) or (delay == 2000) then --Apply corruption to random target
		if CatLadyActive == 0 then
			BugPrint("Cursed!")
			local plr = pUnit:GetAITarget(1)
			if plr then
				pUnit:CastSpell(plr, 172, true)
			end
		end
	elseif (delay == 24000) then --Attempt to cast whirlwind - only triggers every 2nd time. 
		BugPrint("Calling Whirlwind. Cooldown status: "..tostring(CatLadyCooldown))
		if CatLadyCooldown == 0 then
			pUnit:SendUnitSay("DARREYAHEHE EDDEGHIKE TJIAH DJAEHEPHEP HUWAREDEHE")
			pUnit:PlayDistanceSound(90011)
			pUnit:CastSpell(pUnit,90042,true)
			pUnit:SetRooted(true)
			CatLadyCooldown = 1
			CatLadyActive = 1
			pUnit:RegisterEvent(CatLadyAI_SPELLS, 16000, 1) --Allow her to cast other spells
			pUnit:RegisterEvent(CatLadyAI_SPELLS, 2100, 5)
		else
			CatLadyCooldown = 0
		end
	elseif (delay == 2100) then
		local x, y, z = pUnit:GetLocation()
		local c = pUnit:SpawnCreature(2442, x,y,z, 0, 7)
		c:RegisterEvent(CatLadyAI_Jump, 100, 2)
	end
end

local function CatLady(event, pUnit, extra)
	pUnit:RemoveEvents()
	pUnit:SetRooted(false)
	CatLadyCooldown = 0
	CatLadyActive = 0
	CatLadyEvent = 0
	if event == 1 then --OnCombat
		pUnit:SendUnitSay("MAWHAGARBLE CAT AGWGWGE")
		pUnit:PlayDistanceSound(90010)
		pUnit:RegisterEvent(CatLadyAI_SPELLS, 20000, 0)
		pUnit:RegisterEvent(CatLadyAI_SPELLS, 24000, 0)
		pUnit:RegisterEvent(CatLadyAI_SPELLS, 2000, 1)
	end
end

RegisterCreatureEvent(90106, 1, CatLady) --OnCombat
RegisterCreatureEvent(90106, 2, CatLady) --OnLeaveCombat
RegisterCreatureEvent(90106, 4, CatLady) --OnDeath
RegisterCreatureEvent(90106, 5, CatLady) --OnSpawn
