
local playersRequired = 1

local DEBUG = false

local function BugPrint(msg)
	if (DEBUG  == true) then
		if (msg ~= nil) then
			print(msg)
		else
			print("Msg was nil, unable to print")
		end
	end
end

-----------------------------
-----	TRAPS BELOW		-----
-----------------------------

--Geist Trap--

local Geist = 90238
local GeistTrigger01 = 90239
local Geist01Cooldown = 45000

--Looking for players--

local function GeistTrap_01_LFPlayers(event, delay, repeats, pUnit)
	local plrs = pUnit:GetPlayersInRange(5)
	BugPrint("Getting Plrs")
	if plrs and #plrs > 0 then
		BugPrint("Players nearby. Activating cooldown.")
		pUnit:RemoveEvents()
		pUnit:RegisterEvent(GeistTrapReload, Geist01Cooldown, 1)
		--SpawnShit
	end
end

function GeistTrapReload(event,delay,repeats,pUnit)
	local entry = pUnit:GetEntry()
		BugPrint("Cooldown triggered by entry: "..tostring(entry))
	if entry == GeistTrigger01 then
		BugPrint("Reloading Geist trap 01")
		pUnit:RegisterEvent(GeistTrap_01_LFPlayers, 3000, 0)
	end
end

local function GeistTrap_OnSpawn(event, pUnit, extra)
	local entry = pUnit:GetEntry()
	if entry == GeistTrigger01 then
		BugPrint("Loading Geist trap 01")
		pUnit:RegisterEvent(GeistTrap_01_LFPlayers, 3000, 0)
	end
end

RegisterCreatureEvent(90239, 5, GeistTrap_OnSpawn)


------------------------------
--------------BOULDER TRAP
---------

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
-- MINIBOSS ---------------
------ The Undying --------
---------------------------

-- 16734 "Death is all you will find here!"
-- 16736 "Choke on your suffering!"

local SoulFrenzyTimer = 13000

local function SoulFrenzySpawn(_, _, _, pUnit)
	local power = pUnit:GetPower(6)
	if power >= 100 then
		pUnit:SetPower(6, power - 100)
	else
		return
	end
	local x1 = 8791
	local y1 = 338
	local x2 = 8786
	local y2 = 371
	local x = -math.random(x2, x1)
	local y = math.random(y1, y2)
	pUnit:SpawnCreature(90241, x, y, 102, 0, 2, SoulFrenzyTimer)
end

local function RemoveFlags(_, _, _, pUnit)
	pUnit:SetUInt32Value(UNIT_FIELD_FLAGS, 0)
end

local function CheckForStart(_, _, _, pUnit)
	local plrs = pUnit:GetPlayersInRange(20)
	if plrs and #plrs >= playersRequired then
		local count = 0
		-- could be optimised
		for _,v in pairs(plrs) do
			if v:IsWithinLoS(pUnit) then
				count = count + 1
			end
		end
		if count >= playersRequired then
			pUnit:PlayMusic(9008)
			pUnit:RemoveEvents()
			pUnit:Emote(1)
			pUnit:SendUnitSay("The Master surveyed his kingdom and found it lacking. His judgement was swift and without mercy. Death to all!")
			pUnit:PlayDistanceSound(16738)
			pUnit:RegisterEvent(RemoveFlags, 7000, 1)
		end
	end
end

local function UndyingStrike(_, _, _, pUnit)
	local power = pUnit:GetPower(6)
	if power >= 50 then
		pUnit:SetPower(6, power - 50)
	else
		return
	end
	local plr = pUnit:GetAITarget(1)
	if plr then
		pUnit:CastSpell(plr, 70437)
	end
end

local function RegeneratePowerUndying(_, _, _, pUnit)
	pUnit:SetPower(6, pUnit:GetPower(6) + 18)
end

local function SilencePlayer(_, _, _, pUnit)
	local power = pUnit:GetPower(6)
	if power >= 100 then
		for _,v in pairs(pUnit:GetPlayersInRange(30)) do
			if v:IsCasting() then
				pUnit:CastSpell(v, 47476)
				pUnit:SetPower(6, power - 100)
				return
			end
		end
	end
end

local function HungeringCold(_, _, _, pUnit)
	local power = pUnit:GetPower(6)
	if power >= 400 then
		pUnit:CastSpell(pUnit, 49203)
	end
end

local function UndyingEvents(event, pUnit)
	if event == 1 then
		pUnit:RegisterEvent(SoulFrenzySpawn, 5000, 0)
		pUnit:RegisterEvent(UndyingStrike, 6000, 0)
		pUnit:RegisterEvent(RegeneratePowerUndying, 500, 0)
		pUnit:RegisterEvent(SilencePlayer, 8000, 0)
		pUnit:RegisterEvent(HungeringCold, 18000, 0)
		for _,v in pairs(pUnit:GetGameObjectsInRange(50, 164726)) do
			v:SetByteValue(GAMEOBJECT_BYTES_1, 0, 1)
		end
	elseif event == 2 or event == 4 then
		pUnit:RemoveEvents()
		pUnit:SetMaxPower(6, 1000)
		pUnit:SetPower(6, 1000)
		for _,v in pairs(pUnit:GetCreaturesInRange(60, 90241)) do
			v:RemoveEvents()
			v:DespawnOrUnsummon(0)
		end
		for _,v in pairs(pUnit:GetGameObjectsInRange(50, 164726)) do
			v:SetByteValue(GAMEOBJECT_BYTES_1, 0, 0)
		end
		if event == 2 then
			pUnit:SetUInt32Value(UNIT_FIELD_FLAGS, UNIT_FIELD_FLAG_UNATTACKABLE + UNIT_FIELD_FLAG_C_UNATTACKABLE)
			pUnit:RegisterEvent(CheckForStart, 5000, 0)
		else
			pUnit:SendUnitSay("Yes... run... run to meet your destiny... its bitter cold embrace awaits you.")
			pUnit:PlayDistanceSound(16737)
		end
	elseif event == 5 then
		pUnit:SetPowerType(6)
		pUnit:SetMaxPower(6, 1000)
		pUnit:SetPower(6, 1000)
		pUnit:RegisterEvent(CheckForStart, 1000, 0)
	end
end

RegisterCreatureEvent(90240, 5, UndyingEvents)
RegisterCreatureEvent(90240, 1, UndyingEvents)
RegisterCreatureEvent(90240, 2, UndyingEvents)
RegisterCreatureEvent(90240, 4, UndyingEvents)

---------------------------
-- SOUL FRENZY ------------
---------------------------
---------------------------
-- 68855 well of souls ground visual
-- 72630 small AoE souls ground, needs repeating
-- 69859 cruciple of souls

local function SpinShoot(_, _, _, pUnit)
	pUnit:CastSpell(pUnit, 75956, true) -- visual
	local o = pUnit:GetO()
	o = (o * 180) / math.pi
	o = o + 10
	if (o >= 360) then
		o = 0
	end
	pUnit:SetFacing((o * math.pi) / 180)
	local plrs = pUnit:GetPlayersInRange(8)
	if plrs then
		for _,v in pairs(plrs) do
			if pUnit:IsWithinLoS(v) and pUnit:IsFacing(v, (60 * math.pi) / 180) then
				local distance = v:GetDistance2d(pUnit)
				pUnit:DealDamage(v, 22 - distance, false)
			end
		end
	end
end

local function SoulFrenzyTicker(_, _, _, pUnit)
	pUnit:CastSpell(pUnit, 68855)
end

local function ShutdownSoulFrenzy(_, _, _, pUnit)
	pUnit:RemoveEvents()
	--pUnit:RemoveAura(72630)
	pUnit:RemoveAura(68855)
	pUnit:RemoveAura(69859)
	pUnit:CastSpell(pUnit, 72130, true)
end

local function SoulFrenzySpawn(event, pUnit)
	pUnit:CastSpell(pUnit, 72630)
	pUnit:CastSpell(pUnit, 69859)
	pUnit:RegisterEvent(SoulFrenzyTicker, 1000, 0)
	pUnit:RegisterEvent(SpinShoot, 500, 0)
	pUnit:RegisterEvent(ShutdownSoulFrenzy, SoulFrenzyTimer - 1000, 1)
end

RegisterCreatureEvent(90241, 5, SoulFrenzySpawn)

---------------------------
-- Troth The Ambitious ----
---------------------------

local function TrothExplodeCast(_, _, _, pUnit)
	pUnit:SetUInt32Value(UNIT_FIELD_FLAGS, 0)
	pUnit:SetRooted(true)
	pUnit:CastSpell(pUnit, 69586)
end

local function DoSomeCrazyStuff(_, _, _, pUnit)
	pUnit:RemoveAura(50650)
	pUnit:SendUnitSay("Who disturbs Troth!?")
	pUnit:Emote(5)
	pUnit:RegisterEvent(TrothExplodeCast, 4000, 1) 
end

local function WaitForPlayersTroth(_, _,_ ,pUnit)
	local plrs = pUnit:GetPlayersInRange(4)
	if plrs and #plrs > 0 then
		pUnit:RemoveEvents()
		pUnit:RegisterEvent(DoSomeCrazyStuff, 5000, 1)
	else
		pUnit:CastSpell(pUnit, 50650)
	end
end

local function TrothEvents(event, pUnit)
	pUnit:RegisterEvent(WaitForPlayersTroth, 1000, 0)
end

RegisterCreatureEvent(90242, 5, TrothEvents)

---------------------------
-- Lothros (Dreadlord) ----
---------------------------

local function LothrosCarrionSwarm(_, _, _, pUnit)
	if pUnit:IsCasting() then
		return
	end
	local power = pUnit:GetPower(2)
	if power >= 20 then
		pUnit:SetPower(2, power - 20)
	else
		return
	end
	pUnit:CastSpell(pUnit, 90045)
end

local function LothrosSleep(_, _, _, pUnit)
	if pUnit:IsCasting() then
		return
	end
	local plr = pUnit:GetAITarget(0)
	local plrB = pUnit:GetAITarget(1)
	if plr == plrB then
		-- have another go
		plr = pUnit:GetAITarget(0)
	end
	if plr then
		local power = pUnit:GetPower(2)
		if power >= 3 then
			pUnit:SetPower(2, power - 3)
		else
			return
		end
		pUnit:CastSpell(plr, 53045)
	end
end

local function LothrosCorruptionSpawn(_, _, _, pUnit)
	local power = pUnit:GetPower(2)
	if power >= 3 then
		pUnit:SetPower(2, power - 3)
	else
		return
	end
	local x = 0
	local y = 0
	local z = pUnit:GetZ()
	local done = false
	local maxTries = 10
	local count = 0
	while not done do
		x = -math.random(math.abs(pUnit:GetX()) - 10, math.abs(pUnit:GetX()) + 10)
		y = math.random(pUnit:GetY() - 10, pUnit:GetY() + 10)
		done = pUnit:IsWithinLoS(x, y, z)
		count = count + 1
		if (count >= maxTries) then
			break
		end
	end
	pUnit:SpawnCreature(90245, x, y, z, 0, 3, 20000)
end

local function LothrosRegeneratePower(_, _, _, pUnit)
	pUnit:SetPower(2, pUnit:GetPower(2) + 2)
end

local function LothrosBecomeHostile(_, _, _, pUnit)
	pUnit:SetUInt32Value(UNIT_FIELD_FLAGS, 0)
end

local function LothrosStartCheck(_, _, _, pUnit)
	local plrs = pUnit:GetPlayersInRange(7)
	if plrs and #plrs >= playersRequired then
		local count = 0
		-- could be optimised
		for _,v in pairs(plrs) do
			if v:IsWithinLoS(pUnit) then
				count = count + 1
			end
		end
		if count >= playersRequired then
			pUnit:RemoveEvents()
			-- start boss event
			pUnit:SendUnitSay("[PLACEHOLDER]")
			pUnit:Emote(1)
			pUnit:StopChannel()
			pUnit:RegisterEvent(LothrosBecomeHostile, 4000, 1)
		end
	end
end

local function LothrosEvents(event, pUnit)
	if event == 5 then
		pUnit:ChannelSpell(pUnit, 51795)
		pUnit:RegisterEvent(LothrosStartCheck, 5000, 0)
		pUnit:SetPowerType(2)
		pUnit:SetMaxPower(2, 100)
		pUnit:SetPower(2, 100)
	elseif event == 4 or event == 2 then
		pUnit:RemoveEvents()
		pUnit:SetUInt32Value(UNIT_FIELD_FLAGS, UNIT_FIELD_FLAG_UNATTACKABLE + UNIT_FIELD_FLAG_C_UNATTACKABLE)
		pUnit:RegisterEvent(ResetLothros, 10000, 1)
	elseif event == 1 then
		pUnit:RegisterEvent(LothrosRegeneratePower, 1500, 0)
		pUnit:RegisterEvent(LothrosCarrionSwarm, 9000, 0)
		pUnit:RegisterEvent(LothrosSleep, 6000, 0)
		pUnit:RegisterEvent(LothrosCorruptionSpawn, 5000, 0)
	end
end

function ResetLothros(_, _, _, pUnit)
	LothrosEvents(5, pUnit)
end

RegisterCreatureEvent(90244, 5, LothrosEvents)
RegisterCreatureEvent(90244, 4, LothrosEvents)
RegisterCreatureEvent(90244, 2, LothrosEvents)
RegisterCreatureEvent(90244, 1, LothrosEvents)

local function LothrosCorruptionVisual(_, _, _, pUnit)
	pUnit:CastSpell(pUnit, 56571)
end

local function DespawnSelfCorruption(_ ,_, _, pUnit)
	pUnit:RemoveEvents()
	pUnit:RemoveAura(56571)
end

local function LothrosCorruption(event, pUnit)
	pUnit:CastSpell(pUnit, 56571)
	pUnit:RegisterEvent(LothrosCorruptionVisual, 3000, 0)
	pUnit:RegisterEvent(DespawnSelfCorruption, 18000, 1)
end

RegisterCreatureEvent(90245, 5, LothrosCorruption)

---------------------------
-- Baron Rivermead --------
---------------------------

-- free precast visual 67040
-- 59463 break bonds

local function KneelVisual(_, _, _, pUnit)
	pUnit:CastSpell(pUnit, 68442)
end

local function BaronSpawn(event, pUnit)
	pUnit:SetHealth(pUnit:GetMaxHealth() / 2.5)
	pUnit:SetPower(0, pUnit:GetMaxPower(0) / 1.5)
	pUnit:RegisterEvent(KneelVisual, 5000, 0)
end

RegisterCreatureEvent(90243, 5, BaronSpawn)

---------------------------

