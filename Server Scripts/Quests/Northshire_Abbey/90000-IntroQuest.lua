
local AI_TICK = {}
local currentPhase = nil

local function CREATURE_EVENT_ON_QUEST_ACCEPT(event, plr, pUnit, quest)
	if plr and pUnit and quest:GetId() == 90000 then
		if not currentPhase then
			currentPhase = START_UNIQUE_PHASES
		end
		local phase = currentPhase
		currentPhase = currentPhase + 1
		plr:SetPhaseMask(phase)
		pUnit:SendChatMessageDirectlyToPlayer("The Marshal approaches now.", 12, 0, plr, plr)
		pUnit:Emote(1)
		local m = pUnit:SpawnCreature(90030, -8883, -165, 82, 3.596, 8)
		m:SetPhaseMask(phase)
		m:SetSpeed(1, 0.25)
		m:MoveTo(0, -8894, -171, 81.6)
		m:CastSpell(m, 8990)
	end
end

RegisterCreatureEvent(90003, 31, CREATURE_EVENT_ON_QUEST_ACCEPT)

local function MARSHAL_AI_TICKER(e, d, r, pUnit)
	local i = AI_TICK[tostring(pUnit:GetGUID())]
	i = i + 1
	if i == 3 then
		pUnit:Emote(1)
		pUnit:SendUnitSay("A new initiate has arrived I see, let's see where you stand.", 0)
	elseif i == 7 then
		pUnit:SendUnitSay("Come on then, let's duel!", 0)
		pUnit:SetInt32Value(UNIT_NPC_EMOTESTATE, 375)
	elseif i == 9 then
		pUnit:SetFaction(17)
		pUnit:SetSpeed(1, 1)
		pUnit:RemoveEvents()
	elseif i == 13 then
		pUnit:SendUnitSay("Impressive for a initiate but we are going to need to find out your limits.", 0)
		pUnit:Emote(1)
		pUnit:SetSpeed(1, 0.25)
		pUnit:MoveTo(0, -8897.9, -173.3, 81.6)
	elseif i == 17 then
		-- check distance
		if pUnit:GetDistance2d(-8897.9, -173.3) > 1 then
			i = i - 1
		else
			pUnit:SetUInt32Value(UNIT_FIELD_BYTES_1, 8)
		end
	elseif i == 21 then
		pUnit:CastSpell(pUnit, 58054)
		pUnit:SetMaxHealth(pUnit:GetMaxHealth() * 1.75)
		pUnit:SetHealth(pUnit:GetMaxHealth())
	elseif i == 24 then
		pUnit:SetUInt32Value(UNIT_FIELD_BYTES_1, 0)
		pUnit:SendUnitSay("This time you will find me a much more challenging opponent.", 0)
	elseif i == 26 then
		pUnit:SetInt32Value(UNIT_NPC_EMOTESTATE, 375)
	elseif i == 29 then
		pUnit:SetFaction(17)
		pUnit:SetSpeed(1, 1)
		pUnit:RemoveEvents()	
	elseif i == 32 then
		pUnit:SetSpeed(1, 0.3)
		pUnit:MoveTo(0, -8866, -192, 82)
	elseif i == 35 then
		for _,v in pairs(pUnit:GetPlayersInRange(40)) do
			if v:GetPhaseMask() == pUnit:GetPhaseMask() then
				v:SetPhaseMask(1)
				break
			end
		end
		pUnit:RemoveEvents()
		pUnit:DespawnOrUnsummon(0)
	end
	AI_TICK[tostring(pUnit:GetGUID())] = i
end

local function CREATURE_SPAWN_MARSHAL(event, pUnit)
	AI_TICK[tostring(pUnit:GetGUID())] = 0
	pUnit:RegisterEvent(MARSHAL_AI_TICKER, 1000, 0)
end

RegisterCreatureEvent(90030, 5, CREATURE_SPAWN_MARSHAL)

local function CREATURE_EVENT_ON_DAMAGE_TAKEN(event, pUnit, attacker, damage)
	if pUnit:GetHealth() - damage < 1 then
		if AI_TICK[tostring(pUnit:GetGUID())] < 15 then
			pUnit:SendUnitSay("That's enough!", 0)
		else
			pUnit:SendUnitSay("Most impressive. Your strength is beyond anything we could hope from a new initiate. We can bypass most of the training. I'll leave you with Ellen.", 0)
			if attacker:HasQuest(90000) then
				attacker:QuestKillCredit(90030)
			end
		end
		pUnit:SetFaction(814)
		pUnit:SetHealth(pUnit:GetMaxHealth())
		pUnit:CastSpell(pUnit, 8990)
		pUnit:SetInt32Value(UNIT_NPC_EMOTESTATE, 0)
		pUnit:AttackStop()
		pUnit:CastSpell(pUnit, 65256)
		attacker:AttackStop()
		attacker:CastSpell(attacker, 65256)
		pUnit:RegisterEvent(MARSHAL_AI_TICKER, 1000, 0)
		damage = 0
		return 0
	end
end

RegisterCreatureEvent(90030, 9, CREATURE_EVENT_ON_DAMAGE_TAKEN)

local function PLAYER_EVENT_ON_QUEST_ABANDON(event, plr, questId)
	if questId == 90000 then
		plr:SetPhaseMask(1)
	end
end

RegisterPlayerEvent(38, PLAYER_EVENT_ON_QUEST_ABANDON)
