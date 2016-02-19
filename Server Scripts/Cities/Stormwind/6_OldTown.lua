

---------------------------
-- BOULDER TRAPS ----------
---------------------------

local function BuilderCollisionOne(_, _, _, pUnit)
	pUnit:RemoveEvents()
	pUnit:RemoveAura(55766)
	pUnit:CastSpell(pUnit, 42427)
	pUnit:PlayDistanceSound(14341)
end

local function HandleTrapOneSetup(_, _, _, pUnit)
	local plrs = pUnit:GetPlayersInRange(30)
	if plrs and #plrs > 0 then
		local b = pUnit:SpawnCreature(90120, -8640.87, 417, 103.7, 0, 8) -- MANUAL Spawn
		b:MoveTo(0, -8680.34, 460.45, 99.67)
		b:RegisterEvent(BuilderCollisionOne, 7500, 0)
		b:DespawnOrUnsummon(2500 + 7500) -- SHOULD ensure that it goes away
		pUnit:RemoveEvents()
		pUnit:RegisterEvent(registerHandlerOne, 5000, 1)
	end		
end

function registerHandlerOne(_, _, _, pUnit)
	pUnit:RegisterEvent(HandleTrapOneSetup, 3000, 0)
end

local function BoulderTrapSpawn(event, pUnit)
	local entry = pUnit:GetEntry()
	if entry == 90119 then
		pUnit:RegisterEvent(HandleTrapOneSetup, 3000, 0)
	elseif entry == 90121 then
		
	end
end

RegisterCreatureEvent(90119, 5, BoulderTrapSpawn)
RegisterCreatureEvent(90121, 5, BoulderTrapSpawn)

---------------------------
-- BOULDER ----------------
------ EXPENSIVE UNIT -----
---------------------------

local function BoulderTicker(_, _, _, pUnit)
	pUnit:CastSpell(pUnit, 55766) -- Visual
	pUnit:PlayDistanceSound(14342) -- rumbling
	local plrs = pUnit:GetPlayersInRange(1.35)
	if plrs then
		for _,v in pairs(plrs) do
			local distance = v:GetDistance2d(pUnit)
			pUnit:DealDamage(v, 50 - distance, false)
			pUnit:CastSpell(v, 43556) -- curse
			pUnit:PlayDistanceSound(14341, v) -- hit noise to just player
					
			local x2 = pUnit:GetX()
			local y2 = pUnit:GetY()
			local x1 = v:GetX()
			local y1 = v:GetY()

			local x = x2 - x1
			local y = y2 - y1
					
			local angle = math.pi + math.atan2(-y, -x)

			local x = x1 - ((math.random(1,2) - distance) * math.cos(angle))
			local y = y1 - ((math.random(1,2) - distance) * math.sin(angle))
			--local z = pUnit:GetMap():GetHeight(x, y) -- It does not detect WMO height, stormwind is a WMO
			--if not z then
			z = v:GetZ()
			--end
			if v:IsWithinLoS(x, y, z) then
				v:MoveJump(x, y, z, 9, 2.1)
			end
		end
	end
end

local function BoulderSpawn(event, pUnit)
	pUnit:RegisterEvent(BoulderTicker, 250, 0)
end

RegisterCreatureEvent(90120, 5, BoulderSpawn)

---------------------------
