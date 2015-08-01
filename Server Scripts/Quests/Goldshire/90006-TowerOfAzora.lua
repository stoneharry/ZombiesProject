
local AI_TICK = {}
local currentPhase = nil

-- channel visual 59069

local function CREATURE_EVENT_ON_QUEST_ACCEPT(event, plr, pUnit, quest)
	if plr and pUnit and quest:GetId() == 90006 then
		if not currentPhase then
			currentPhase = START_UNIQUE_PHASES
		end
		local phase = currentPhase
		currentPhase = currentPhase + 1
		plr:SetPhaseMask(phase)
		plr:SetCanSeePhaseOne(false)
		pUnit:SpawnCreature(90057, pUnit:GetX(), pUnit:GetY(), pUnit:GetZ(), pUnit:GetO()):SetPhaseMask(phase)
	end
end

RegisterCreatureEvent(90056, 31, CREATURE_EVENT_ON_QUEST_ACCEPT)

local function AI_TICKER(e, d, r, pUnit)
	local i = AI_TICK[tostring(pUnit:GetGUID())][1]
	i = i + 1
	if i == 2 then
		pUnit:SendUnitSay("Well you better follow me then.", 0)
		pUnit:Emote(1)
	elseif i == 5 then
		pUnit:SetSpeed(1, 0.3)
		pUnit:MoveTo(0, -9536.8, -697.9, 64.66)
	elseif i == 8 then
		pUnit:MoveTo(0, -9552.9, -712.5, 65.74)
	elseif i == 19 then
		pUnit:SendUnitSay("I can feel the demonic energies around us. Let me reveal them for your eyes to behold.", 0)
		pUnit:Emote(1)
	elseif i == 24 then
		local c = pUnit:SpawnCreature(90058, -9558.55, -718.234, 66.5, 0, 3, 30000)
		c:CastSpell(c, 64785)
		pUnit:CastSpell(c, 59069)
	elseif i == 28 then
		local c = pUnit:SpawnCreature(90059, -9554, -720, 64.8, 1.237)
		c:SetPhaseMask(pUnit:GetPhaseMask())
		c:CastSpell(c, 61456)
		c = pUnit:SpawnCreature(90059, -9559, -714, 64.8, 0.35598)
		c:SetPhaseMask(pUnit:GetPhaseMask())
		c:CastSpell(c, 61456)
	elseif i == 30 then
		pUnit:RemoveAura(59069)
	elseif i == 31 then
		local t = pUnit:GetCreaturesInRange(40, 90059)
		for _,v in pairs(t) do
			if v:IsAlive() and v:GetPhaseMask() == pUnit:GetPhaseMask() then
				i = i - 1
				break
			end
		end
	elseif i == 32 then
		pUnit:SendUnitSay("The Felhounds are trivial. It is the greater demons we must watch out for. I did warn you this place had become quite corrupt.", 0)
		pUnit:Emote(1)
	elseif i == 35 then
		pUnit:MoveTo(0, -9551.21, -711.866882, 75.1)
	elseif i == 61 then
		pUnit:SendUnitSay("There's something lingering here, let me search the shelf.", 0)
		pUnit:SetInt32Value(UNIT_NPC_EMOTESTATE, 381)
	elseif i == 65 then
		local c = pUnit:SpawnCreature(90060, -9558.5, -718.5, 75.4, 0.7)
		c:SetPhaseMask(pUnit:GetPhaseMask())
		c:CastSpell(c, 61456)
	elseif i == 66 then
		local c = GetCreature(40, 90060, pUnit)
		if c and c:IsAlive() and c:GetPhaseMask() == pUnit:GetPhaseMask() then
			i = i - 1
		end
	elseif i == 67 then
		pUnit:SetInt32Value(UNIT_NPC_EMOTESTATE, 0)
		pUnit:SendUnitSay("Now, where were we?", 0)
	elseif i == 70 then
		pUnit:MoveTo(0, -9560.8, -730.55, 90)
	elseif i == 100 then
		pUnit:SendUnitSay("Hmm. Considering how corrupt this tower has become we have not encountered that many demons.", 0)
		pUnit:Emote(1)
	elseif i == 109 then
		local coords = {
			{-9563, -711.8, 90.4, 2.61},
			{-9570.96, -708.6, 90.42, 5.913},
			{-9566, -731.6, 90.4, 0.282},
			{-9548, -714, 90.4, 0.3916}
		}
		for _,v in pairs(coords) do
			local c = pUnit:SpawnCreature(90059, v[1], v[2], v[3], v[4])
			c:SetPhaseMask(pUnit:GetPhaseMask())
			c:CastSpell(c, 61456)
			c:SetUInt32Value(UNIT_FIELD_FLAGS, UNIT_FIELD_FLAG_C_UNATTACKABLE)
		end
	elseif i == 110 then
		pUnit:SendUnitSay("Oh, there they are! I'm hiding until the demons on this level are destroyed.", 0)
		pUnit:CastSpell(pUnit, 45776)
	elseif i == 111 then
		local t = pUnit:GetCreaturesInRange(40, 90059)
		for _,v in pairs(t) do
			if v:IsAlive() and v:GetPhaseMask() == pUnit:GetPhaseMask() then
				v:SetUInt32Value(UNIT_FIELD_FLAGS, 0)
			end
		end
	elseif i == 112 then
		local t = pUnit:GetCreaturesInRange(40, 90059)
		for _,v in pairs(t) do
			if v:IsAlive() and v:GetPhaseMask() == pUnit:GetPhaseMask() then
				i = i - 1
				break
			end
		end
	elseif i == 113 then
		pUnit:RemoveAura(45776)
		pUnit:SendUnitSay("Oh, it's safe now? Let's carry on then.", 0)
	elseif i == 115 then
		pUnit:MoveTo(0, -9561, -731, 99.2)
		pUnit:SpawnCreature(90061, -9553, -727, 99.2, 3.394):SetPhaseMask(pUnit:GetPhaseMask())
		pUnit:SpawnCreature(90062, -9553, -732, 99.2, 3.1):SetPhaseMask(pUnit:GetPhaseMask())
	elseif i == 160 then
		pUnit:SetFacing(0.221804)
		pUnit:SendUnitSay("Theocritus! How are you alive up here? And Dawn, you too are up here? What is going on?", 0)
		pUnit:Emote(5)
	elseif i == 166 then
		local c = GetCreature(30, 90061, pUnit)
		c:SendUnitSay("Do you not see the power we can harness? We can repeat what Gul'dan brought the orcs: conquest. With this power we can defeat the Scourge once and for all.", 0)
		c:Emote(25)
	elseif i == 172 then
		pUnit:SendUnitSay("You fool! That power is not worth the risk. How can we serve the Argent Dawn if you are mindless servent of the Burning Legion?", 0)
		pUnit:Emote(1)
	elseif i == 180 then
		local c = GetCreature(30, 90062, pUnit)
		c:SendUnitSay("Enough of this. If you are not with us, you are against us.", 0)
	elseif i == 185 then
		local c = GetCreature(30, 90062, pUnit)
		c:SetFaction(17)
		c = GetCreature(30, 90061, pUnit)
		c:SetFaction(17)
		pUnit:CastSpell(pUnit, 45776)
	elseif i == 186 then
		local c = GetCreature(40, 90061, pUnit)
		if c and c:IsAlive() and c:GetPhaseMask() == pUnit:GetPhaseMask() then
			i = i - 1
		end
	elseif i == 187 then
		local c = GetCreature(40, 90062, pUnit)
		if c and c:IsAlive() and c:GetPhaseMask() == pUnit:GetPhaseMask() then
			i = i - 1
		end
	elseif i == 188 then
		pUnit:RemoveAura(45776)
		pUnit:SendUnitSay("Well done. Meet me at the bottom of the tower.", 0)
	elseif i == 191 then
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
			plr:QuestKillCredit(90057)
			pUnit:CastSpell(pUnit, 41232)
			plr:SetCanSeePhaseOne(true)
			plr:SetPhaseMask(1)
		end
	elseif i == 192 then
		pUnit:RemoveEvents()
		pUnit:DespawnOrUnsummon(0)
		AI_TICK[tostring(pUnit:GetGUID())] = nil
		return
	end
	AI_TICK[tostring(pUnit:GetGUID())][1] = i
end

local function CREATURE_SPAWN(event, pUnit)
	AI_TICK[tostring(pUnit:GetGUID())] = {0, {}}
	pUnit:RegisterEvent(AI_TICKER, 1000, 0)
end

RegisterCreatureEvent(90057, 5, CREATURE_SPAWN)

local function PLAYER_EVENT_ON_QUEST_ABANDON(event, plr, questId)
	if questId == 90006 then
		plr:SetPhaseMask(1)
		plr:SetCanSeePhaseOne(true)
	end
end

RegisterPlayerEvent(38, PLAYER_EVENT_ON_QUEST_ABANDON)

local function knockdown(e, d, r, pUnit)
	local t = pUnit:GetAITarget(1)
	if t then
		pUnit:CastSpell(t, 18812)
	end
	pUnit:RegisterEvent(knockdown, 8000, 1)
end

local function felguard(event, pUnit, extra)
	if event == 1 then
		pUnit:RegisterEvent(knockdown, 1000, 1)
	else
		pUnit:RemoveEvents()
	end
end

RegisterCreatureEvent(90060, 1, felguard)
RegisterCreatureEvent(90060, 2, felguard)
RegisterCreatureEvent(90060, 4, felguard)

local function spell(e, d, r, pUnit)
	local t = pUnit:GetAITarget(1)
	if t then
		pUnit:CastSpell(t, 35913)
	end
	pUnit:RegisterEvent(spell, math.random(4000, 12000), 1)
end

local function wizardz(event, pUnit, extra)
	if event == 1 then
		pUnit:RegisterEvent(spell, 100, 1)
	else
		pUnit:RemoveEvents()
	end
end

RegisterCreatureEvent(90061, 1, wizardz)
RegisterCreatureEvent(90061, 2, wizardz)
RegisterCreatureEvent(90061, 4, wizardz)
RegisterCreatureEvent(90062, 1, wizardz)
RegisterCreatureEvent(90062, 2, wizardz)
RegisterCreatureEvent(90062, 4, wizardz)



