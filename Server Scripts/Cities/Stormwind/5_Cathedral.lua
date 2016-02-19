
local chatCounter = 0
local AI_COUNTER = 0
local PlayersRequired = 1
local spirit_counter = 0 - 1

local CheckBeamCollisionTime = 250 -- ms

local SPECIAL_EVENT_AI = 0

local SPIRIT_LOCATIONS = {
	{90111, -8549.5, 824.9, 106.52, 2.248327},
	{90111, -8557, 834.54, 106.52, 5.38992},
	{90112, -8542.3, 830.6, 106.52, 2.319010},
	{90112, -8549.97, 840.33, 106.52, 5.389134},
	{90113, -8535, 836.2, 106.5, 2.196495},
	{90113, -8542.81, 846, 106.52, 5.338087},
	{90114, -8527.95, 841.99, 106.52, 2.300164},
	{90114, -8535.6, 851.75, 106.52, 5.363214},
	{90115, -8520.865, 847.64, 106.52, 2.280528},
	{90115, -8528.52, 857.4, 106.52, 5.339655}
}
local EVENT_A_POSITIONS = {
	{
		{-8506.28, 841.45, 106.54}, -- position A
		{-8518.34, 831.98, 106.54},
		{-8571.70, 840.73, 106.54}, -- B
		{-8559.89, 849.97, 106.54},
		{-8534.92, 820.24, 106.53}, -- C
		{-8558.5, 849.94, 106.54},
		{-8559.125, 822.15, 106.54}, -- D
		{-8561.9, 826.03, 106.54},
		{-8515.3, 856.277, 109.99},	-- E
		{-8519.3, 860.1, 109.99}
	},
	{
		{-8543.17, 863.44, 106.52}, -- position A
		{-8531.18, 873, 106.52},
		{-8546.91, 809.6, 106.53}, -- B
		{-8535, 818.83, 106.54},
		{-8520, 831.06, 107}, -- C
		{-8545, 861, 106.5},
		{-8527.3, 856.8, 106.52}, -- D
		{-8520.85, 848.9, 106.6},
		{-8515.3, 856.277, 109.99},	-- E
		{-8519.3, 860.1, 109.99}
	}
}

local function checkBeamCrossovers(_, _, _, pUnit)
	for i=1,9,2 do
		local creatures = pUnit:GetCreaturesInRange(100, SPIRIT_LOCATIONS[i][1])
		if creatures and #creatures == 2 then
			local plrs = pUnit:GetPlayersInRange(75)
			if creatures[1] and creatures[2] and plrs then
				local x1 = creatures[1]:GetX()
				local x2 = creatures[2]:GetX()
				local y1 = creatures[1]:GetY()
				local y2 = creatures[2]:GetY()
				for _,v in pairs(plrs) do
					if v then
						local dist = lineIntersects(v:GetX(), v:GetY(), x1, y1, x2, y2)
						if dist < 1 then
							local damage = 12
							if v:HasAura(43556) then
								damage = 24
							end
							pUnit:DealDamage(v, damage, false, 5)
							pUnit:CastSpell(v, 43556) -- curse
						end
					end
				end
			end
		end
	end
end

local function AIUpdater(_, _, _, pUnit)
	AI_COUNTER = AI_COUNTER + 1
	--pUnit:SendUnitSay(AI_COUNTER) -- debug
	if AI_COUNTER == 4 then
		pUnit:RemoveAura(63772)
		pUnit:SetSpeed(1, 0.4)
		pUnit:MoveTo(0, -8581, 807.62, 106.52)
	elseif AI_COUNTER == 7 then
		pUnit:SendUnitSay("The Cathedral of Light will always be a safe haven for all that serve.")
		pUnit:Emote(1)
		pUnit:MoveTo(0, -8575, 800, 106.5)
	elseif AI_COUNTER == 10 then
		pUnit:MoveTo(0, -8560, 811, 106.5)
	elseif AI_COUNTER == 15 then
		pUnit:SendUnitSay("Come to the front, come. There is so much to be excited for.")
		pUnit:Emote(1)
		pUnit:MoveTo(0, -8566, 819, 106.5)
	elseif AI_COUNTER == 20 then
		pUnit:MoveTo(0, -8524, 852.8, 106.52)
	elseif AI_COUNTER == 36 then
		pUnit:MoveTo(0, -8512, 862, 109.9)
	elseif AI_COUNTER == 41 then
		pUnit:SetFacing(3.765921)
		pUnit:Emote(1)
		pUnit:SendUnitSay("Are we all here? Gather round gather round...")
		chatCounter = 52
	elseif AI_COUNTER == 45 then
		local plrs = pUnit:GetPlayersInRange(20)
		if not plrs then
			return
		end
		local count = #plrs
		if count < PlayersRequired then -- debug
			chatCounter = chatCounter + 2
			if chatCounter > 60 then
				pUnit:SendUnitSay("Bring more heroes, maybe then you will pose a threat to me.")
				chatCounter = 0
			end
			AI_COUNTER = AI_COUNTER - 1
		end
	elseif AI_COUNTER == 46 then
		pUnit:SendUnitYell("Heroes!", 0)
		pUnit:Emote(5)
		spirit_counter = 0 - 1
	elseif spirit_counter < 10 and (AI_COUNTER == 25 or AI_COUNTER == 28 or AI_COUNTER == 30 or AI_COUNTER == 33 or AI_COUNTER == 35) then
		spirit_counter = spirit_counter + 2
		local s1 = SPIRIT_LOCATIONS[spirit_counter]
		local s2 = SPIRIT_LOCATIONS[spirit_counter + 1]
		local c = pUnit:SpawnCreature(s1[1], s1[2], s1[3], s1[4], s1[5], 7)
		c:CastSpell(c, 62003)
		c = pUnit:SpawnCreature(s2[1], s2[2], s2[3], s2[4], s2[5], 7)
		c:CastSpell(c, 62003)
	elseif AI_COUNTER == 50 then
		pUnit:ChannelSpell(pUnit, 54988)
		pUnit:SetFaction(17)
		pUnit:SendUnitYell("Lay down your weapons, the dark lord will accept willing followers!", 0)
		pUnit:Emote(5)
	elseif AI_COUNTER == 56 then
		pUnit:Emote(5)
		pUnit:SendUnitYell("Heroes - I gave you a chance but the Lich King is unforgiving. Now you must die.", 0)
		for i=1,9,2 do
			local creatures = pUnit:GetCreaturesInRange(100, SPIRIT_LOCATIONS[i][1])
			if creatures and #creatures == 2 then
				creatures[1]:ChannelSpell(creatures[2], 54491)
				creatures[2]:ChannelSpell(creatures[1], 54491)
				creatures[1]:SetScale(0.6)
				creatures[2]:SetScale(0.6)
			else
				creatures = {}
				local id, x, y, z, o = table.unpack(SPIRIT_LOCATIONS[i])
				creatures[1] = pUnit:SpawnCreature(id, x, y, z, o, 7)
				creatures[2] = pUnit:SpawnCreature(id, x, y, z, o, 7)
				creatures[1]:ChannelSpell(creatures[2], 54491)
				creatures[2]:ChannelSpell(creatures[1], 54491)
				creatures[1]:SetScale(0.6)
				creatures[2]:SetScale(0.6)
			end
		end
		pUnit:StopChannel()
		pUnit:SetDisplayId(18919)
		pUnit:CastSpell(pUnit, 62003)
		SPECIAL_EVENT_AI = 0
		pUnit:RegisterEvent(checkBeamCrossovers, CheckBeamCollisionTime, 0)
	elseif AI_COUNTER > 57 then
		if pUnit:GetHealthPct() < 80 and SPECIAL_EVENT_AI < 30 then
			if SPECIAL_EVENT_AI == 0 then
				pUnit:SendUnitYell("Let darkness consume you.", 0)
				for i=1,9,2 do
					local creatures = pUnit:GetCreaturesInRange(100, SPIRIT_LOCATIONS[i][1])
					if creatures and #creatures == 2 then
						creatures[1]:SetSpeed(1, 1.2)
						creatures[2]:SetSpeed(1, 1.2)
						creatures[1]:MoveTo(0, table.unpack(EVENT_A_POSITIONS[1][i]))
						creatures[2]:MoveTo(0, table.unpack(EVENT_A_POSITIONS[1][i + 1]))
					end
				end
			elseif SPECIAL_EVENT_AI == 6 then
				for i=1,9,2 do
					local creatures = pUnit:GetCreaturesInRange(100, SPIRIT_LOCATIONS[i][1])
					if creatures and #creatures == 2 then
						creatures[1]:SetSpeed(1, 0.5)
						creatures[2]:SetSpeed(1, 0.5)
						creatures[1]:MoveTo(0, table.unpack(EVENT_A_POSITIONS[2][i]))
						creatures[2]:MoveTo(0, table.unpack(EVENT_A_POSITIONS[2][i + 1]))
					end
				end
			elseif SPECIAL_EVENT_AI == 18 then
				for i=1,9,2 do
					local creatures = pUnit:GetCreaturesInRange(100, SPIRIT_LOCATIONS[i][1])
					if creatures and #creatures == 2 then
						creatures[1]:SetSpeed(1, 0.5)
						creatures[2]:SetSpeed(1, 0.5)
						creatures[1]:MoveTo(0, table.unpack(EVENT_A_POSITIONS[1][i]))
						creatures[2]:MoveTo(0, table.unpack(EVENT_A_POSITIONS[1][i + 1]))
					end
				end
			end
			SPECIAL_EVENT_AI = SPECIAL_EVENT_AI + 1
			return
		elseif pUnit:GetHealthPct() < 40 then
			if (SPECIAL_EVENT_AI > 29 and SPECIAL_EVENT_AI < 99999) then
				SPECIAL_EVENT_AI = 100000
			elseif SPECIAL_EVENT_AI > 99999 then
				SPECIAL_EVENT_AI = SPECIAL_EVENT_AI + 1
				if SPECIAL_EVENT_AI % 15 == 0 then
					for i=1,math.random(2, 4) do
						local plr = pUnit:GetAITarget(0)
						if plr and plr:IsAlive() and plr:GetDistance2d(plr) < 80 then
							local x = (math.random(3, 17) - 10) + plr:GetX()
							local y = (math.random(3, 17) - 10) + plr:GetY()
							pUnit:SpawnCreature(90116, x, y, plr:GetZ(), 0, 3, 30000)
						end
					end
				end
			end
			local PointsAroundBoss = {}
			local _OOffset = 0
			for i=1,10 do
				local x,y,z = pUnit:GetRelativePoint(5.5, _OOffset)
				_OOffset = _OOffset + 36
				table.insert(PointsAroundBoss, {x, y, z})
			end
			for i=1,9,2 do
				local creatures = pUnit:GetCreaturesInRange(100, SPIRIT_LOCATIONS[i][1])
				if creatures then
					creatures[1]:MoveTo(0, table.unpack(PointsAroundBoss[i]))
					creatures[2]:MoveTo(0, table.unpack(PointsAroundBoss[i + 1]))
				end
			end
			return
		end
		for i=1,9,2 do
			local creatures = pUnit:GetCreaturesInRange(100, SPIRIT_LOCATIONS[i][1])
			if creatures then
				for _,v in pairs(creatures) do
					if math.random(1,4) == 1 then
						local x1 = 8546.86
						local y1 = 808.98
						local x2 = 8531.28
						local y2 = 873
						local x3 = -math.random(x2, x1)
						local y3 = math.random(y1, y2)
						local z = 106.5
						v:SetSpeed(1, math.random(10, 75) / 100)
						if v:IsWithinLoS(x3, y3, z) then
							v:MoveTo(0, x3, y3, z)
						end
					end
				end
			end
		end
		if AI_COUNTER == 60 then
			pUnit:SetSpeed(1, 1)
			pUnit:MoveTo(0, -8539, 840.5, 106.52)
		elseif AI_COUNTER == 66 then
			pUnit:SetHomePosition(-8539, 840.5, 106.52, 0)
			pUnit:SetUInt32Value(UNIT_FIELD_FLAGS, 0)
		elseif AI_COUNTER > 500 then
			AI_COUNTER = 100
		end
	end
end

function lineIntersects(x, y, x1, y1, x2, y2)
	local A = x - x1;
	local B = y - y1;
	local C = x2 - x1;
	local D = y2 - y1;

	local dot = A * C + B * D;
	local len_sq = C * C + D * D;
	local param = -1;
	if (len_sq ~= 0) then --in case of 0 length line
		param = dot / len_sq;
	end

	local xx, yy;

	if (param < 0) then
		xx = x1;
		yy = y1;
	elseif (param > 1) then
		xx = x2;
		yy = y2;
	else
		xx = x1 + param * C;
		yy = y1 + param * D;
	end

	local dx = x - xx;
	local dy = y - yy;
	return math.sqrt(dx * dx + dy * dy);
end

local function CheckForNearbyPlayers(_, _, _, pUnit)
	if GetSiegeCanSpawn(3) then
		pUnit:DespawnOrUnsummon(0)
		return
	end
	pUnit:CastSpell(pUnit, 63772) -- visual
	local plrs = pUnit:GetPlayersInRange(9)
	if not plrs then
		return
	end
	local count = #plrs
	if count < PlayersRequired then
		chatCounter = chatCounter + 2
		if chatCounter > 30 then
			pUnit:SendUnitSay("Bring more heroes, maybe then you will pose a threat to me.")
			chatCounter = 0
		end
	else
		pUnit:RemoveEvents()
		pUnit:SendUnitSay("Hello brave heroes, welcome. Your visit is quite pleasantly timed.")
		pUnit:Emote(1)
		AI_COUNTER = 0
		pUnit:RegisterEvent(AIUpdater, 1000, 0)
	end
end

local function EvilBrotherSpawn(event, pUnit)
	if event == 5 then
		pUnit:RegisterEvent(CheckForNearbyPlayers, 2000, 0)
		pUnit:SetDisplayId(1501)
	elseif event == 4 or event == 2 then
		if event == 2 then
			-- Check players are actually dead
			local plrs = pUnit:GetPlayersInRange(50)
			if plrs then
				local count = 0
				for _,v in pairs(plrs) do
					if v and v:IsAlive() then
						count = count + 1
						break
					end
				end
				if count > 0 then
					return
				end
			end
		end
		pUnit:SetHomePosition(-8588.87, 801.5, 106.52, 3.79072)
		pUnit:RemoveEvents()
		for i=1,9,2 do
			for _,v in pairs(pUnit:GetCreaturesInRange(100, SPIRIT_LOCATIONS[i][1])) do
				v:RemoveEvents()
				v:DespawnOrUnsummon(0)
			end
			for _,v in pairs(pUnit:GetCreaturesInRange(100, 90116)) do
				v:RemoveEvents()
				v:DespawnOrUnsummon(0)
			end
		end
		if event == 2 then
			EvilBrotherSpawn(5, pUnit)
		end
	end
end

RegisterCreatureEvent(90109, 5, EvilBrotherSpawn)
--RegisterCreatureEvent(90109, 1, EvilBrotherSpawn)
RegisterCreatureEvent(90109, 2, EvilBrotherSpawn)
RegisterCreatureEvent(90109, 4, EvilBrotherSpawn)

-- Adds

local function DamageNearbyPlayersBlaze(_, _, _, pUnit)
	for _,v in pairs(pUnit:GetPlayersInRange(6)) do
		if v and v:IsAlive() then
			local damage = 10
			if v:HasAura(43556) then
				damage = 25
			end
			pUnit:DealDamage(v, damage, false, 5)
		end
	end
end

local function CastFieryBlazeVisual(_, _, _, pUnit)
	pUnit:RemoveAura(74543)
	pUnit:CastSpell(pUnit, 46309)
	pUnit:SetScale(0.5)
	for _,v in pairs(pUnit:GetPlayersInRange(6)) do
		if v and v:IsAlive() then
			local damage = 50
			if v:HasAura(43556) then
				damage = 75
			end
			pUnit:DealDamage(v, damage, false, 5)
		end
	end
	pUnit:RegisterEvent(DamageNearbyPlayersBlaze, 500, 0)
end

local function CastSpawningSelfVisual(_, _, _, pUnit)
	pUnit:CastSpell(pUnit, 74543)
end

local function FieryBlazeSpawner(event, pUnit)
	pUnit:RegisterEvent(CastFieryBlazeVisual, 5000, 1)
	pUnit:RegisterEvent(CastSpawningSelfVisual, 1000, 1)
end

RegisterCreatureEvent(90116, 5, FieryBlazeSpawner)

--[[local function CastSpawnVisual(_, _, _, pUnit)
	pUnit:CastSpell(pUnit, 62003)
end

local function TorturedSpiritEvents(event, pUnit)
	pUnit:RegisterEvent(CastSpawnVisual, 500, 1)
end

RegisterCreatureEvent(90111, 5, TorturedSpiritEvents)]]
