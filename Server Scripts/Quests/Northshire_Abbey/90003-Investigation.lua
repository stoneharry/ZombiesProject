
local AI_TICK = {}
local currentPhase = nil

local DWARF = 90035
local MAIN = 90032
local MAGE = 90033
local GUNNER = 90034

local function CREATURE_EVENT_ON_QUEST_ACCEPT(event, plr, pUnit, quest)
	if plr and pUnit and quest:GetId() == 90003 then
		if not currentPhase then
			currentPhase = START_UNIQUE_PHASES
		end
		local phase = currentPhase
		currentPhase = currentPhase + 1
		plr:SetPhaseMask(phase)
		pUnit:SpawnCreature(DWARF, -9070, -389, 73.5, 1.53):SetPhaseMask(phase)
		pUnit:SpawnCreature(GUNNER, -9066, -382, 73.5, 4.2):SetPhaseMask(phase)
		pUnit:SpawnCreature(MAGE, -9073, -382, 73.5, 5.1):SetPhaseMask(phase)
		pUnit:SpawnCreature(MAIN, -9070, -381, 73.5, 4.69):SetPhaseMask(phase)
	end
end

RegisterCreatureEvent(90003, 31, CREATURE_EVENT_ON_QUEST_ACCEPT)

local function AI_TICKER(e, d, r, pUnit)
	local i = AI_TICK[tostring(pUnit:GetGUID())]
	i = i + 1
	if i == 3 then
		i = 0
		for _,v in pairs(pUnit:GetPlayersInRange(10)) do
			if v:GetPhaseMask() == pUnit:GetPhaseMask() then
				i = 3
				break
			end
		end
	elseif i == 4 then
		pUnit:SendUnitSay("Stay back! My axe is sharp and my temper is fuelled.", 0)
		pUnit:Emote(5)
	elseif i == 9 then
		local c = GetCreature(10, MAIN, pUnit)
		c:SendUnitSay("Now now master dwarf, we don't need to end this quickly. That would spoil the fun.", 0)
		c:Emote(1)
	elseif i == 15 then
		local c = GetCreature(10, GUNNER, pUnit)
		c:SetFacing(3)
		c:SendUnitSay("Come on, Darryll. Stop playing and finish it.", 0)
	elseif i == 19 then
		local c = GetCreature(10, MAGE, pUnit)
		c:SetFacing(6.11)
		c:SendUnitSay("You always were boring, Packard.", 0)
	elseif i == 24 then
		pUnit:SetInt32Value(UNIT_NPC_EMOTESTATE, 0)
		pUnit:Emote(3)
		pUnit:SendUnitSay("Some luck at last! Help has arrived and you'd dare not do anything in front of a witness.", 0)
	elseif i == 30 then
		local c = GetCreature(10, MAIN, pUnit)
		c:SendUnitSay("See - that's where you're wrong, dwarf. We will just kill you both.", 0)
		c:Emote(1)
	elseif i == 36 then
		local c = GetCreature(10, GUNNER, pUnit)
		c:Emote(5)
		c:SendUnitSay("Finally!", 0)
	elseif i == 39 then
		local a = GetCreature(10, GUNNER, pUnit)
		local b = GetCreature(10, MAGE, pUnit)
		local c = GetCreature(10, MAIN, pUnit)
		a:MoveTo(0, -9070.686, -393.672, 73)
	elseif i == 42 then
		pUnit:SetUInt32Value(UNIT_FIELD_FLAGS, 0)
		local a = GetCreature(10, GUNNER, pUnit)
		local b = GetCreature(10, MAGE, pUnit)
		local c = GetCreature(10, MAIN, pUnit)
		a:SetUInt32Value(UNIT_FIELD_FLAGS, 0)
		b:SetUInt32Value(UNIT_FIELD_FLAGS, 0)
		c:SetUInt32Value(UNIT_FIELD_FLAGS, 0)
		--[[pUnit:SetFaction(814)
		a:SetFaction(17)
		b:SetFaction(17)
		c:SetFaction(17)]]
		pUnit:AttackStart(c)
		local plr = nil
		for _,v in pairs(pUnit:GetPlayersInRange(40)) do
			if v:GetPhaseMask() == pUnit:GetPhaseMask() then
				plr = v
				break
			end
		end
		if plr then
			a:AttackStart(plr)
			b:AttackStart(plr)
			c:AttackStart(pUnit)
		end
	elseif i == 45 then
		if pUnit:GetHealthPct() < 20 then
			pUnit:SetHealth(pUnit:GetMaxHealth())
		end
		local NotPass = true
		local a = GetCreature(15, GUNNER, pUnit)
		local b = GetCreature(15, MAGE, pUnit)
		local c = GetCreature(15, MAIN, pUnit)
		if (not a or not a:IsAlive()) and
			(not b or not b:IsAlive()) and
			(not c or not c:IsAlive()) then
			NotPass = false
		end
		if NotPass then
			i = i - 1
		else
			local plr = nil
			for _,v in pairs(pUnit:GetPlayersInRange(40)) do
				if v:GetPhaseMask() == pUnit:GetPhaseMask() then
					plr = v
					break
				end
			end
			if not plr then
				i = i - 1
			else
				pUnit:SendUnitSay("Thank you, "..plr:GetName()..". I don't want to think about what would have happened if you hadn't shown up.", 0)
				pUnit:Emote(1)
				plr:QuestKillCredit(90035)
			end
		end
	elseif i == 48 then
		pUnit:MoveTo(0, -8903, -159, 82)
	elseif i == 54 then
		for _,v in pairs(pUnit:GetPlayersInRange(50)) do
			if v:GetPhaseMask() == pUnit:GetPhaseMask() then
				v:SetPhaseMask(1)
				break
			end
		end
		pUnit:RemoveEvents()
		pUnit:DespawnOrUnsummon(0)
		AI_TICK[tostring(pUnit:GetGUID())] = nil
		return
	end
	AI_TICK[tostring(pUnit:GetGUID())] = i
end

local function FixGunner(e, d, r, pUnit)
	local c = GetCreature(10, GUNNER, pUnit)
	c:SetUInt32Value(UNIT_FIELD_BYTES_2, 2)
	c:SetUInt32Value(UNIT_FIELD_FLAGS, UNIT_FIELD_FLAG_C_UNATTACKABLE)
	c:SetFaction(17)
end

local function CREATURE_SPAWN(event, pUnit)
	local entry = pUnit:GetEntry()
	pUnit:SetFaction(17)
	pUnit:SetUInt32Value(UNIT_FIELD_FLAGS, UNIT_FIELD_FLAG_C_UNATTACKABLE)
	if entry == DWARF then
		pUnit:SetFaction(814)
		AI_TICK[tostring(pUnit:GetGUID())] = 0
		pUnit:RegisterEvent(AI_TICKER, 1000, 0)
		pUnit:RegisterEvent(FixGunner, 3000, 1)
		pUnit:SetInt32Value(UNIT_NPC_EMOTESTATE, 375)
	elseif entry == GUNNER then
		pUnit:SetUInt32Value(UNIT_FIELD_BYTES_2, 2)
	elseif entry == MAGE then
		pUnit:CastSpell(pUnit, 1459, true) -- arcane intellect
	end
end

RegisterCreatureEvent(MAIN, 5, CREATURE_SPAWN)
RegisterCreatureEvent(MAGE, 5, CREATURE_SPAWN)
RegisterCreatureEvent(DWARF, 5, CREATURE_SPAWN)

local function PLAYER_EVENT_ON_QUEST_ABANDON(event, plr, questId)
	if questId == 90003 then
		plr:SetPhaseMask(1)
	end
end

RegisterPlayerEvent(38, PLAYER_EVENT_ON_QUEST_ABANDON)

local function FireBoltSpam(e, d, r, pUnit)
	local plr = pUnit:GetAITarget(1)
	if plr then
		pUnit:CastSpell(plr, 90027)
	end
	pUnit:RegisterEvent(FireBoltSpam, 6000, 1)
end

local function MageAI(event, pUnit, extra)
	if event == 1 then
		pUnit:RegisterEvent(FireBoltSpam, 100, 1)
	else
		pUnit:RemoveEvents()
	end
end

RegisterCreatureEvent(MAGE, 1, MageAI)
RegisterCreatureEvent(MAGE, 2, MageAI)
RegisterCreatureEvent(MAGE, 4, MageAI)
