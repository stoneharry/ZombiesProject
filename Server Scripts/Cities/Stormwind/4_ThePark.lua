
-- Moonwell centre

local B_SPELL = 90036 --54306

local function PulseVisual(_, _, _, pUnit)
	if GetSiegeCanSpawn(2) then
		pUnit:RemoveEvents()
		return
	end
	pUnit:CastSpell(pUnit, 72036) -- pulse
	pUnit:CastSpell(pUnit, 45213) -- clouds
	for _,v in pairs(pUnit:GetPlayersInRange(70)) do
		if v:HasAura(B_SPELL) then
			pUnit:DealDamage(v, 1, false, 4)
			local aura = v:GetAura(B_SPELL)
			if not aura then
				return
			end
			local stacks = aura:GetCharges()
			if not stacks or (stacks - 1) == 0 then
				v:RemoveAura(B_SPELL)
			else
				aura:SetCharges(stacks - 1)
			end
		else
			pUnit:DealDamage(v, 100, false, 4)
		end
	end
end

local function Moonwell(event, pUnit)
	pUnit:RegisterEvent(PulseVisual, 6000, 0)
end

RegisterCreatureEvent(90099, 5, Moonwell)

-- Gossip

local function BuffGuy1(event, player, pUnit)
	if not GetSiegeCanSpawn(2) then
		player:GossipMenuAddItem(0, "Grant me protection.", 0, 1)
		--player:GossipMenuAddItem(0, "Nevermind.", 0, 0)
		player:GossipSendMenu(90007, pUnit)
	else
		player:GossipSendMenu(12960, pUnit)
	end
end

local function BuffGuy2(event, player, pUnit, sender, initid, code)
	if initid == 1 then
		if player:IsInCombat() then
			pUnit:SendChatMessageDirectlyToPlayer("I cannot help you while we are in combat!", 12, 0, player, player)
			return
		end
		pUnit:CastSpell(pUnit, 62398)
		player:CastSpell(player, B_SPELL)
	end
	player:GossipComplete()
end

RegisterCreatureGossipEvent(90100, 1, BuffGuy1)
RegisterCreatureGossipEvent(90100, 2, BuffGuy2)

local function CheckForEventStart(_, _, _, pUnit)
	local t = pUnit:GetCreaturesInRange(30, 90105)
	local boss = pUnit:GetCreature(90, 90101)
	if boss and #t >= 9 then
		for _,v in pairs(t) do
			v:SetHomePosition(-8756.3, 1106.7, 92.2, 4.87)
			v:AttackStart(boss)
		end
	end
end

local function KeepSpawningAD(_, _, _, pUnit)
	if GetSiegeCanSpawn(2) then
		pUnit:RemoveEvents()
		return
	end
	if pUnit:GetNearestPlayer(50) then
		local c = pUnit:SpawnCreature(90105, -8735.8, 968, 99.4, 1.5, 1, 180000)
		local x = -8732
		local y = 1014
		local z = 95.5
		c:MoveTo(0, x + (math.random(0, 10) - 5), y + (math.random(0, 10) - 5), z)
		pUnit:RegisterEvent(CheckForEventStart, 7000, 1)
	end
end

local function SpawnAddsetc(event, pUnit)
	pUnit:RegisterEvent(KeepSpawningAD, 8000, 0)
end

RegisterCreatureEvent(90100, 5, SpawnAddsetc)

-- Boss -----------

local function AttackEveryoneInRange(_, _, _, pUnit)
	for _,v in pairs(pUnit:GetPlayersInRange(70)) do
		if math.random(1,4) == 1 then
			pUnit:CastSpell(v, 71285, true)
			pUnit:SpawnCreature(38456, v:GetX(), v:GetY(), v:GetZ(), 0, 1, 30000)
		end
		if math.random(1,4) == 1 then
			pUnit:SpawnCreature(90108, v:GetX(), v:GetY(), v:GetZ(), 0, 1, 120000)
		end
		pUnit:CastSpell(v, 38052)
		return
	end
	for _,v in pairs(pUnit:GetCreaturesInRange(70)) do
		pUnit:CastSpell(v, 38052)
		return
	end
end

local function BossGuy(event, pUnit)
	if event == 1 then
		pUnit:SetRooted(true)
	elseif event == 2 then
		pUnit:SetRooted(false)
	elseif event == 4 then
		pUnit:RemoveEvents()
		SetSiegeStage(GetSiegeStage() + 1, 2)
	elseif event == 5 then
		if GetSiegeCanSpawn(2) then
			pUnit:DespawnOrUnsummon(0)
			return
		end
		pUnit:RegisterEvent(AttackEveryoneInRange, 15000, 0)
	end
end

RegisterCreatureEvent(90101, 1, BossGuy)
RegisterCreatureEvent(90101, 2, BossGuy)
RegisterCreatureEvent(90101, 4, BossGuy)
RegisterCreatureEvent(90101, 5, BossGuy)

-- AI

local function lightningVisual(_, _, _, pUnit)
	pUnit:CastSpell(pUnit, 64784)
end

local function StormboltAttack(_, _, _, pUnit)
	if not pUnit:IsCasting() then
		local plr = pUnit:GetAITarget(1)
		if plr then
			pUnit:CastSpell(plr, 74772)
		end
	end
end

local function MeleeStormAttack(_, _, _, pUnit)
	if not pUnit:IsCasting() then
		local plr = pUnit:GetAITarget(1)
		if plr then
			pUnit:CastSpell(plr, 64757)
		end
	end
end

local function MinionAI1(event, pUnit)
	if event == 1 then
		pUnit:RegisterEvent(StormboltAttack, 11000, 0)
		pUnit:RegisterEvent(MeleeStormAttack, 6000, 0)
	elseif event == 2 then
		pUnit:RemoveEvents()
		pUnit:RegisterEvent(lightningVisual, 100, 0)
	elseif event == 4 then
		pUnit:RemoveEvents()
		pUnit:CastSpell(pUnit, 45935) -- visual
		for _,v in pairs(pUnit:GetPlayersInRange(10)) do
			v:CastSpell(v, B_SPELL)
			v:CastSpell(v, 45935)
		end
		local boss = pUnit:GetCreature(100, 90101)
		if boss then
			local hp = boss:GetMaxHealth()
			local damage = hp / 10
			local healthRemaining = boss:GetHealth() - damage
			if healthRemaining < 0 then
				boss:Kill(boss)
			else
				boss:SetHealth(healthRemaining)
			end
		end
	elseif event == 5 then
		pUnit:RegisterEvent(lightningVisual, 100, 0)
		pUnit:CastSpell(pUnit, 62851)
	end
end

RegisterCreatureEvent(90108, 1, MinionAI1)
RegisterCreatureEvent(90108, 2, MinionAI1)
RegisterCreatureEvent(90108, 4, MinionAI1)
RegisterCreatureEvent(90108, 5, MinionAI1)