
local AI_TICKER = {}
local STATES = {}
local STORE = {}

local F_RANGE = 90036
local F_MELEE = 90037
local H_RANGE = 90039
local H_MELEE = 90040
local ALL_NPC = {F_RANGE, F_MELEE, H_RANGE, H_MELEE}

local JUST_SPAWNED = 0
local HEADING_ARM = 1
local ARMING_1 = 2
local ARMING_2 = 3
local ARMING_3 = 4
local READY_FOR_BATTLE = 5

local ARMY_COUNT_PER_TEAM = 12

local ARMORY_POS = {
	{-9463.6, 87.4},
	{-9455.5, 88},
	{-9465.6, 99.2},
	{-9456.98, 98.8}
}

local function SpawnMoreFriendly(e, b, c, pUnit)
	local c = 0
	local m = pUnit:GetCreaturesInRange(50, F_MELEE)
	local r = pUnit:GetCreaturesInRange(50, F_RANGE)
	local phase = pUnit:GetPhaseMask()
	for _,v in pairs(m) do
		if v:GetPhaseMask() == phase then
			c = c + 1
		end
	end
	for _,v in pairs(r) do
		if v:GetPhaseMask() == phase then
			c = c + 1
		end
	end
	if c > ARMY_COUNT_PER_TEAM then
		return
	end
	for i=c,ARMY_COUNT_PER_TEAM do
		if math.random(1,2) == 1 then
			pUnit:SpawnCreature(F_MELEE, -9466, 24, 56.4, 1.48):SetPhaseMask(pUnit:GetPhaseMask())
		else
			pUnit:SpawnCreature(F_RANGE, -9468, 18, 57, 1.46):SetPhaseMask(pUnit:GetPhaseMask())
		end
	end
end

local function SpawnMoreHostile(e, b, c, pUnit)
	local c = 0
	local m = pUnit:GetCreaturesInRange(50, H_MELEE)
	local r = pUnit:GetCreaturesInRange(50, H_RANGE)
	for _,_ in pairs(m) do
		c = c + 1
	end
	for _,_ in pairs(r) do
		c = c + 1
	end
	if c > ARMY_COUNT_PER_TEAM then
		return
	end
	for i=c,ARMY_COUNT_PER_TEAM do
		local sp = math.random(H_RANGE, H_MELEE)
		local x = -math.random(9424, 9494)
		local y = math.random(44, 77)
		if math.random(1,2) == 1 then
			local c = pUnit:SpawnCreature(sp, x, y, pUnit:GetMap():GetHeight(x, y), 6.16)
			c:SetPhaseMask(pUnit:GetPhaseMask())
			c:CastSpell(pUnit, 41232, true)
		else
			local c = pUnit:SpawnCreature(sp, x, y, pUnit:GetMap():GetHeight(x, y), 3.25)
			c:SetPhaseMask(pUnit:GetPhaseMask())
			c:CastSpell(pUnit, 41232, true)
		end
	end
end

local function handleState(state, pUnit, id)
	if not pUnit:IsAlive() then
		return
	end
	if state == JUST_SPAWNED then
		if id < H_RANGE then
			local p = math.random(1,4)
			pUnit:MoveTo(0, ARMORY_POS[p][1], ARMORY_POS[p][2], 58.4)
			STORE[tostring(pUnit:GetGUID())] = ARMORY_POS[p]
			STATES[tostring(pUnit:GetGUID())] = HEADING_ARM
		else
			STATES[tostring(pUnit:GetGUID())] = READY_FOR_BATTLE
		end
	elseif state == HEADING_ARM then
		local pos = STORE[tostring(pUnit:GetGUID())]
		if pUnit:GetDistance2d(pos[1], pos[2]) < 1 then
			pUnit:SetUInt32Value(UNIT_FIELD_BYTES_1, 9)
			STATES[tostring(pUnit:GetGUID())] = ARMING_1
		end
	elseif state == ARMING_1 then
		if id == F_MELEE then
			pUnit:SetEquipmentSlots(2481, 28153, 0)
			pUnit:SetUInt32Value(UNIT_FIELD_BYTES_2, 1)
		elseif id == F_RANGE then
			pUnit:SetEquipmentSlots(4965, 0, 2778)
			pUnit:SetUInt32Value(UNIT_FIELD_BYTES_2, 2)
		end
		--pUnit:SetUInt32Value(UNIT_FIELD_BYTES_1, 8)
		pUnit:Emote(381)
		STATES[tostring(pUnit:GetGUID())] = ARMING_2
	elseif state == ARMING_2 then
		local offset = -9461 + (math.random(0, 22) - 10)
		local offset2 = 64 + (math.random(0, 22) - 10)
		pUnit:MoveTo(0, offset, offset2, 56)
		STORE[tostring(pUnit:GetGUID())] = {offset, offset2}
		pUnit:SetHomePosition(offset, offset2, 56, 3)
		STATES[tostring(pUnit:GetGUID())] = ARMING_3
	elseif state == ARMING_3 then
		local pos = STORE[tostring(pUnit:GetGUID())]
		if pUnit:GetDistance2d(pos[1], pos[2]) < 1 then
			pUnit:SetFaction(814)
			STATES[tostring(pUnit:GetGUID())] = READY_FOR_BATTLE
		end
	elseif state == READY_FOR_BATTLE then
		if not pUnit:IsInCombat() then
			if id >= H_RANGE then
				local offset = math.random(0, 22) - 10
				local offset2 = math.random(0, 22) - 10
				pUnit:MoveTo(0, -9461 + offset, 64 + offset2, 56)
			end
			--[[if id >= H_RANGE then
				local choice = math.random(F_RANGE, F_MELEE)
				local targets = pUnit:GetCreaturesInRange(50, choice)
				local amntTargets = #targets
				if amntTargets == 0 then
					return
				end
				local target = targets[math.random(1, amntTargets)]
				if target and target:IsAlive() then
					local state = STATES[tostring(target:GetGUID())]
					if state == READY_FOR_BATTLE then
						pUnit:AttackStart(target)
						if not target:IsInCombat() then
							target:AttackStart(pUnit)
						end
					end
				end
			else
				local choice = math.random(H_RANGE, H_MELEE)
				local targets = pUnit:GetCreaturesInRange(50, choice)
				local amntTargets = #targets
				if amntTargets == 0 then
					return
				end
				local target = targets[math.random(1, amntTargets)]
				if target and target:IsAlive() then
					pUnit:AttackStart(target)
					if not target:IsInCombat() then
						target:AttackStart(pUnit)
					end
				end
			end]]
		end
	end
end

local function handleAI(pUnit)
	for _,id in pairs(ALL_NPC) do
		for _,v in pairs(pUnit:GetCreaturesInRange(50, id)) do
			if v:GetPhaseMask() == pUnit:GetPhaseMask() then
				local state = STATES[tostring(v:GetGUID())]
				if not state then
					state = JUST_SPAWNED
				end
				handleState(state, v, id)
			end
		end
	end
end

local function BattleAIChecker(e, b, c, pUnit)
	local i = AI_TICKER[tostring(pUnit:GetGUID())]
	i = i + 1
	if i % 2 == 0 then
		handleAI(pUnit)
	end
	if i % 8 == 0 then
		SpawnMoreFriendly(nil, nil, nil, pUnit)
		SpawnMoreHostile(nil, nil, nil, pUnit)
	end
	--[[if i % 10 == 0 then
		local state_size = 0
		local store_size = 0
		for _,_ in pairs(STATES) do state_size = state_size + 1 end
		for _,_ in pairs(STORE) do store_size = store_size + 1 end
		pUnit:SendUnitSay(tostring(i) .. " | " .. tostring(state_size) .. " | " .. tostring(store_size), 0)
	end]]
	if i % 60 == 0 then
		-- clean up
		local states_copy = STATES
		local store_copy = STORE
		STATES = {}
		STORE = {}
		for _,id in pairs(ALL_NPC) do
			for _,v in pairs(pUnit:GetCreaturesInRange(50, id)) do
				if v:IsAlive() and v:GetPhaseMask() == pUnit:GetPhaseMask() then
					STATES[tostring(v:GetGUID())] = states_copy[tostring(v:GetGUID())]
					STORE[tostring(v:GetGUID())] = store_copy[tostring(v:GetGUID())]
				end
			end
		end
	end
	if i > 5000 then
		i = 0
	end
	AI_TICKER[tostring(pUnit:GetGUID())] = i
end

local function GoldshireHandler(event, pUnit)
	local phase = pUnit:GetPhaseMask()
	pUnit:SetUInt32Value(UNIT_FIELD_FLAGS, UNIT_FIELD_FLAG_C_UNATTACKABLE + UNIT_FIELD_FLAG_UNTARGETABLE)
	for _,id in pairs(ALL_NPC) do
		for _,v in pairs(pUnit:GetCreaturesInRange(50, id)) do
			if v:GetPhaseMask() == phase then
				v:Kill(v)
				v:DespawnOrUnsummon(1000)
			end
		end
	end
	AI_TICKER[tostring(pUnit:GetGUID())] = 0
	pUnit:RegisterEvent(SpawnMoreFriendly, 1000, 1)
	pUnit:RegisterEvent(BattleAIChecker, 1000, 0)
end

RegisterCreatureEvent(90038, 5, GoldshireHandler)

local function taunt(e, d, r, pUnit)
	local t = pUnit:GetAITarget(1)
	if t then
		pUnit:CastSpell(t, 355, true)
	end
	pUnit:RegisterEvent(taunt, 8000, 1)
end

local function f_friendly_ai(event, pUnit, extra)
	if event == 1 then
		pUnit:RegisterEvent(taunt, 1000, 1)
	else
		pUnit:RemoveEvents()
	end
end

RegisterCreatureEvent(F_MELEE, 1, f_friendly_ai)
RegisterCreatureEvent(F_MELEE, 2, f_friendly_ai)
RegisterCreatureEvent(F_MELEE, 4, f_friendly_ai)
