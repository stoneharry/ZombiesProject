
local AI_TICK = {}
local currentPhase = nil

local function CREATURE_EVENT_ON_QUEST_ACCEPT(event, plr, pUnit, quest)
	if plr and pUnit and quest:GetId() == 90005 then
		if not currentPhase then
			currentPhase = START_UNIQUE_PHASES
		end
		local phase = currentPhase
		currentPhase = currentPhase + 1
		plr:SetPhaseMask(phase)
		plr:SetCanSeePhaseOne(false)
		pUnit:SpawnCreature(90038, -9470.6, 64.5, 56.1, 0):SetPhaseMask(phase)
		pUnit:SpawnCreature(90050, -9463.29, 16.491, 56.963, 2.904757):SetPhaseMask(phase)
		local c = pUnit:SpawnCreature(90041, -9470.6, 64.5, 56.1, 0)
		c:SetPhaseMask(phase)
		c:MoveTo(0, -9459, 64, 70)
	end
end

RegisterCreatureEvent(90042, 31, CREATURE_EVENT_ON_QUEST_ACCEPT)

local function SPAM_VISUAL(e, d, r, pUnit)
	pUnit:CastSpell(pUnit, 55949, true)
end

local function AI_TICKER(e, d, r, pUnit)
	local i = AI_TICK[tostring(pUnit:GetGUID())][1]
	i = i + 1
	if i == 2 then
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
			pUnit:SendUnitSay("Right then, looks like it's me and you that are going to save this village, "..plr:GetName()..".", 0)
			pUnit:Emote(1)
		end
	elseif i == 7 then
		pUnit:SendUnitSay("Good thing they call me...", 0)
		pUnit:Emote(1)
		local phase = pUnit:GetPhaseMask()
		PerformIngameSpawn(2, 189300, 0, 0, -9517.3, 67.846, 59.7, 6.11, false, 0, phase)
		--pUnit:SummonGameObject(189300, -9517.3, 67.846, 59.7, 6.11)--:SetPhaseMask(phase)
		pUnit:SpawnCreature(90051, -9517.3, 67.846, 59.7, 0):SetPhaseMask(phase)
		PerformIngameSpawn(2, 189300, 0, 0, -9515.8, 77.7, 59.6, 6.11, false, 0, phase)
		--pUnit:SummonGameObject(189300, -9515.8, 77.7, 59.6, 6.1)--:SetPhaseMask(phase)
		pUnit:SpawnCreature(90052, -9515.8, 77.7, 59.6, 0):SetPhaseMask(phase)
		PerformIngameSpawn(2, 189300, 0, 0, -9507, 69.66, 57.36, 6.11, false, 0, phase)
		--pUnit:SummonGameObject(189300, -9507, 69.66, 57.36, 6.11)--:SetPhaseMask(phase)
		pUnit:SpawnCreature(90053, -9507, 69.66, 57.36, 0):SetPhaseMask(phase)
	elseif i == 10 then
		pUnit:SendUnitSay("Grandmaster Flash!", 0)
		pUnit:CastSpell(pUnit, 68002)
	elseif i == 13 then
		pUnit:SendUnitSay("Let's suss out the situation outside.", 0)
		pUnit:Emote(1)
		pUnit:MoveTo(0, -9458.9, 48, 56.6)
	elseif i == 20 then
		pUnit:SendUnitSay("Well this doesn't look good does it?", 0)
		pUnit:Emote(1)
	elseif i == 24 then
		pUnit:SendUnitSay("Good thing I know what to do!", 0)
		pUnit:Emote(5)
	elseif i == 28 then
		pUnit:SendUnitSay("For I am...", 0)
		pUnit:Emote(1)
	elseif i == 31 then
		pUnit:SendUnitSay("Grandmaster Flash!", 0)
		pUnit:CastSpell(pUnit, 68002)
	elseif i == 34 then
		pUnit:SendUnitSay("See that Necropolis in the sky above us? That's where the Scourge is getting their power. If we disable that then they will be forced to retreat and regather their strength.", 0)
		pUnit:Emote(1)
	elseif i == 42 then
		pUnit:SendUnitSay("Follow me. I think I can drive it back if you protect me while I channel an ancient ritual. But we will have to set up several points of focus.", 0)
		pUnit:Emote(1)
		pUnit:MoveTo(0, -9510.6, 66, 58)
	elseif i == 52 then
		pUnit:SendUnitSay("Okay, I will begin the first ritual here. Protect me from any Scourge that try and attack us.", 0)
		pUnit:Emote(1)
	elseif i == 55 then
		pUnit:CastSpell(pUnit, 52993)
	elseif i == 59 then
		pUnit:SendUnitSay("I can sense a portal opening - look sharp!", 0)
	elseif i == 64 then
		local c = pUnit:SpawnCreature(90054, -9522, 57.6, 59.8, 0.7)
		c:SetPhaseMask(pUnit:GetPhaseMask())
		c:SetUInt32Value(UNIT_FIELD_FLAGS, UNIT_FIELD_FLAG_C_UNATTACKABLE)
		c:CastSpell(pUnit, 41232, true)
	elseif i == 65 then
		local c = GetCreature(30, 90054, pUnit)
		c:SendUnitSay("Give up hope. Despair in my presence. You will be punished for your actions.", 0)
		c:SetSpeed(1, 0.25)
		c:MoveTo(0, -9517.9, 60.77, 59.5)
	elseif i == 69 then
		local c = GetCreature(30, 90054, pUnit)
		c:SetSpeed(1, 1)
		c:SetUInt32Value(UNIT_FIELD_FLAGS, 0)
	elseif i == 70 then
		local c = GetCreature(60, 90054, pUnit)
		if not c or not c:IsAlive() then
			pUnit:SendUnitSay("Well done! I have almost finished with this ritual.", 0)
		else
			i = i - 1
		end
	elseif i == 76 then
		pUnit:RemoveAura(52993)
		local t = pUnit:GetGameObjectsInRange(20, 189300)
		for _,v in pairs(t) do
			if v:GetPhaseMask() == pUnit:GetPhaseMask() and not AI_TICK[tostring(pUnit:GetGUID())][tostring(v:GetGUID())] then
				AI_TICK[tostring(pUnit:GetGUID())][tostring(v:GetGUID())] = true
				local c = v:GetNearestCreature(5)
				c:RegisterEvent(SPAM_VISUAL, 3000, 0)
				v:UseDoorOrButton(86000)
				break
			end
		end
	elseif i == 79 then
		pUnit:SendUnitSay("Just two more to go.", 0)
		pUnit:Emote(1)
		pUnit:SetSpeed(1, 0.25)
		pUnit:MoveTo(0, -9513, 71.8, 59.2)
	elseif i == 84 then
		pUnit:SendUnitSay("Here we go again.", 0)
		pUnit:CastSpell(pUnit, 52993)
	elseif i == 88 then
		local c = pUnit:SpawnCreature(90055, -9522.5, 73.5, 59.3, 6.084955)
		c:SetPhaseMask(pUnit:GetPhaseMask())
		c:CastSpell(c, 41232, true)
	elseif i == 90 then
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
			local c = GetCreature(30, 90055, pUnit)
			c:Emote(1)
			local race = plr:GetRaceAsString(0)
			c:SendUnitSay("Now what do we have here? A mage living in the past trying to gain glory where there is none for him. And a "..race.." who is taking the first few steps into the real world. And would you look at this. They are trying to disrupt our advance on Goldshire? How very futile.", 0)
		end
	elseif i == 105 then
		GetCreature(30, 90055, pUnit):CastSpell(pUnit, 42650)
	elseif i == 107 then
		local t = pUnit:GetCreaturesInRange(40, 24207)
		for _,v in pairs(t) do
			if v:IsAlive() and v:GetPhaseMask() == pUnit:GetPhaseMask() then
				i = i - 1
				break
			end
		end
	elseif i == 108 then
		local c = GetCreature(30, 90055, pUnit)
		c:Emote(1)
		c:SendUnitSay("The dead are endless. Give up. Die.", 0)
	elseif i == 111 then
		GetCreature(30, 90055, pUnit):CastSpell(pUnit, 42650)
	elseif i == 113 then
		local t = pUnit:GetCreaturesInRange(40, 24207)
		for _,v in pairs(t) do
			if v:IsAlive() and v:GetPhaseMask() == pUnit:GetPhaseMask() then
				i = i - 1
				break
			end
		end
	elseif i == 114 then
		local c = GetCreature(30, 90055, pUnit)
		c:SendUnitSay("I grow impatient.", 0)
		c:Emote(1)
	elseif i == 116 then
		pUnit:RemoveAura(52993)
		local t = pUnit:GetGameObjectsInRange(20, 189300)
		for _,v in pairs(t) do
			if v:GetPhaseMask() == pUnit:GetPhaseMask() and not AI_TICK[tostring(pUnit:GetGUID())][tostring(v:GetGUID())] then
				AI_TICK[tostring(pUnit:GetGUID())][tostring(v:GetGUID())] = true
				local c = v:GetNearestCreature(5)
				c:RegisterEvent(SPAM_VISUAL, 3000, 0)
				v:UseDoorOrButton(46000)
				break
			end
		end
		pUnit:SetFacing(2.928)
		pUnit:Emote(5)
		pUnit:SendUnitSay("Another focus point is now active! We can do this!", 0)
	elseif i == 121 then
		local c = GetCreature(30, 90055, pUnit)
		c:SendUnitSay("You think I will allow you to activate all three? Think again, mage.", 0)
		c:Emote(1)
	elseif i == 123 then
		pUnit:SetFaction(814)
		pUnit:SetUInt32Value(UNIT_FIELD_FLAGS, 0)
		local c = GetCreature(30, 90055, pUnit)
		c:SetUInt32Value(UNIT_FIELD_FLAGS, 0)
		c:CastSpell(pUnit, 90031)
	elseif i == 127 then
		local c = GetCreature(30, 90055, pUnit)
		c:SendUnitSay("Do you abandon hope yet?", 0)
		c:CastSpell(pUnit, 42650)
	elseif i == 130 then
		local c = GetCreature(30, 90055, pUnit)
		if c:GetHealthPct() < 60 then
			c:SendUnitSay("Minions, come to me!", 0)
			c:CastSpell(pUnit, 42650)
		else
			i = i - 1
		end
	elseif i == 131 then
		local c = GetCreature(30, 90055, pUnit)
		if c:GetHealthPct() < 25 then
			pUnit:SetFaction(35)
			pUnit:RemoveAura(90055)
			c:SetUInt32Value(UNIT_FIELD_FLAGS, UNIT_FIELD_FLAG_C_UNATTACKABLE)
			c:AttackStop()
			c:CastSpell(c, 65256)
			local plr = c:GetAITarget(1)
			if plr then
				plr:AttackStop()
				plr:CastSpell(plr, 65256)
			end
			pUnit:CastSpell(pUnit, 52993)
			c:Emote(5)
			c:SendUnitSay("Don't think this is the end. Next time we fight it shall not be on your holy ground.", 0)
		else
			i = i - 1
		end
	elseif i == 135 then
		local c = GetCreature(30, 90055, pUnit)
		c:CastSpell(c, 41232, true)
		c:DespawnOrUnsummon(1000)
	elseif i == 140 then
		pUnit:RemoveAura(52993)
		pUnit:SetFacing(6.127)
		pUnit:SendUnitSay("We've done it! Now watch an old bit of magic take effect. Magic from before the construction of Goldshire.", 0)
		pUnit:Emote(5)
		local t = pUnit:GetGameObjectsInRange(20, 189300)
		for _,v in pairs(t) do
			if v:GetPhaseMask() == pUnit:GetPhaseMask() and not AI_TICK[tostring(pUnit:GetGUID())][tostring(v:GetGUID())] then
				AI_TICK[tostring(pUnit:GetGUID())][tostring(v:GetGUID())] = true
				local c = v:GetNearestCreature(5)
				c:RegisterEvent(SPAM_VISUAL, 3000, 0)
				v:UseDoorOrButton(22000)
				break
			end
		end
	elseif i == 147 then
		pUnit:CastSpell(pUnit, 63773)
		local t = pUnit:GetGameObjectsInRange(20, 189300)
		for _,v in pairs(t) do
			if v:GetPhaseMask() == pUnit:GetPhaseMask() then
				local c = v:GetNearestCreature(5)
				c:CastSpell(pUnit, 39857)--48316)
			end
		end
	elseif i == 148 then
		pUnit:CastSpell(GetCreature(70, 90041, pUnit), 45537)
	elseif i == 164 then
		local c = GetCreature(70, 90041, pUnit)
		--c:SetCanFly(false)
		--c:Kill(c)
		c:SetUInt32Value(UNIT_FIELD_BYTES_1, 7)
		c:SetUInt32Value(UNIT_FIELD_FLAGS, UNIT_FIELD_FLAG_UNTARGETABLE)
		c:DespawnOrUnsummon(10000)
		pUnit:RemoveAura(63773)
		pUnit:RemoveAura(45537)
		local t = pUnit:GetGameObjectsInRange(20, 189300)
		for _,v in pairs(t) do
			if v:GetPhaseMask() == pUnit:GetPhaseMask() then
				local c = v:GetNearestCreature(5)
				--c:CastSpell(pUnit, 39857)--48316)
				if c and c:GetEntry() ~= pUnit:GetEntry() then
					c:DespawnOrUnsummon(0)
				end
			end
		end
		local c = GetCreature(70, 90038, pUnit)
		if c then
			cRemoveEvents()
			c:DespawnOrUnsummon(0)
		end
		pUnit:Emote(1)
		pUnit:SendUnitsay("Look at that, isn't it beautiful?", 0)
	elseif i == 170 then
		pUnit:SendUnitSay("Well, my work here is done. I'll see you back in the inn.", 0)
		pUnit:Emote(1)
	elseif i == 176 then
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
			plr:QuestKillCredit(90041)
			pUnit:CastSpell(pUnit, 41232)
			plr:SetCanSeePhaseOne(true)
			plr:SetPhaseMask(1)
			local t = pUnit:GetCreaturesInRange(70, 90036)
			for _,v in pairs(t) do
				if v:IsAlive() and v:GetPhaseMask() == pUnit:GetPhaseMask() then
					v:DespawnOrUnsummon(0)
				end
			end
			local t = pUnit:GetCreaturesInRange(70, 90037)
			for _,v in pairs(t) do
				if v:IsAlive() and v:GetPhaseMask() == pUnit:GetPhaseMask() then
					v:DespawnOrUnsummon(0)
				end
			end
			pUnit:RemoveEvents()
			pUnit:DespawnOrUnsummon(0)
			AI_TICK[tostring(pUnit:GetGUID())] = nil
			return
		end
	end
	AI_TICK[tostring(pUnit:GetGUID())][1] = i
end

local function CREATURE_SPAWN(event, pUnit)
	AI_TICK[tostring(pUnit:GetGUID())] = {0, {}}
	pUnit:RegisterEvent(AI_TICKER, 1000, 0)
end

RegisterCreatureEvent(90050, 5, CREATURE_SPAWN)

local function PLAYER_EVENT_ON_QUEST_ABANDON(event, plr, questId)
	if questId == 90005 then
		plr:SetPhaseMask(1)
		plr:SetCanSeePhaseOne(true)
	end
end

RegisterPlayerEvent(38, PLAYER_EVENT_ON_QUEST_ABANDON)

local function scourge_thing(event, pUnit, target)
	if target then
		pUnit:CastSpell(target, 980)
	end
end

RegisterCreatureEvent(90054, 1, scourge_thing)

local function CREATURE_EVENT_ON_DAMAGE_TAKEN(event, pUnit, attacker, damage)
	if pUnit:GetHealth() - damage < 1 then
		pUnit:SetHealth(((pUnit:GetMaxHealth() / 4) - 1) + damage)
		damage = 0
		return 0
	end
end

RegisterCreatureEvent(90055, 9, CREATURE_EVENT_ON_DAMAGE_TAKEN)
