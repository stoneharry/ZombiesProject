local GoldshireMisc = {}

--Water Totem in front of Inn

local function WaterCastVisual(event, delay, repeats, pUnit)
	if pUnit:IsAlive() then
		pUnit:CastSpell(pUnit, 69657)
	end
end

local function WaterVisualOnSpawn(event, pUnit, extra)
	if event == 4 then
		pUnit:RemoveEvents()
		return
	end
	pUnit:RegisterEvent(WaterCastVisual, math.random(5000,15000), 0)
end

RegisterCreatureEvent(90226, 5, WaterVisualOnSpawn)
RegisterCreatureEvent(90226, 4, WaterVisualOnSpawn)

--High Priest Sacerdos
local q = 0
local HighPriestEvent = 0 --Event 01 = Cassandra ; Event 02 = Holy Orb

function GoldshireMisc.CassandraRespawn_Event01(e, d, r, pUnit)
	pUnit:SetPhaseMask(1)
	pUnit:RemoveAllAuras()
end

function GoldshireMisc.GoldshireCitizen_Respawn(e, d, r, pUnit)
	if HighPriestEvent == 1 then
		pUnit:CastSpell(pUnit,90030,true)
	end
	pUnit:SetUInt32Value(83,0)
	pUnit:RemoveAllAuras()
	pUnit:MoveHome()
end

function GoldshireMisc.HighPriestAITick(event, delay, repeats, pUnit)
	q = q + 1
	--------------------------
	--		EVENT 01		--
	--------------------------
	if HighPriestEvent == 1 then
		if q == 1 then
			pUnit:SendUnitSay("Gather around my children, gather around!",0)
			pUnit:SetNPCFlags(0)
			pUnit:Emote(1)
		elseif q == 10 then
			pUnit:SendUnitSay("Though all hope may seem lost, we are not alone, my children.",0)
			pUnit:Emote(1)
		elseif q == 20 then
			pUnit:SendUnitSay("You see: The Light! It's brightness  shines down upon us, even in our most desperate hour!",0)
			pUnit:Emote(1)
		elseif q == 30 then
			pUnit:SendUnitSay("Through discipline, we will defeat-",0)
			pUnit:Emote(1)
		elseif q == 33 then
			local Cassandra = pUnit:GetNearestCreature(60, 90232)
			Cassandra:SendUnitSay("Oh, quit it Sacredos. We both know that you're filling these people with lies.",0)
			Cassandra:Emote(1)
			Cassandra:MoveTo(0, -9440, 54, 56.01)
			pUnit:SetFacing(3.91)
			local qq = pUnit:GetCreaturesInRange(10, 90233)
			if qq then
				for _,v in pairs(qq) do
					v:SetFacing(4.4)
				end
			end
		elseif q == 34 then
			pUnit:SendUnitSay("Cassandra...",0)
			pUnit:Emote(1)
		elseif q == 37 then
			pUnit:SendUnitSay("How are you - what... are you?",0)
			pUnit:Emote(1)
		elseif q == 45 then
			local Cassandra = pUnit:GetNearestCreature(15, 90232)
			Cassandra:SendUnitSay("The Light has not been kind to me, Sacerdos. I walk this earth. Cursed.",0)
			Cassandra:Emote(1)
		elseif q == 55 then
			pUnit:SendUnitSay("The Light did not do this to you Cassandra - The Lich King did.",0)
			pUnit:Emote(274)
		elseif q == 65 then
			local Cassandra = pUnit:GetNearestCreature(15, 90232)
			Cassandra:SendUnitSay("All my life, I have been faithful towards the light - but even that, did not save me...",0)
			Cassandra:Emote(1)
		elseif q == 75 then
			local Cassandra = pUnit:GetNearestCreature(15, 90232)
			Cassandra:SendUnitSay("In death, I found myself a new companion...",0)
			Cassandra:Emote(1)
			local qq = pUnit:GetCreaturesInRange(10, 90234)
			if qq then
				for _,v in pairs(qq) do
					v:SetFacing(4.4)
				end
			end
		elseif q == 82 then
			local Cassandra = pUnit:GetNearestCreature(15, 90232)
			Cassandra:SendUnitSay("The Shadows...",0)
			Cassandra:CastSpell(Cassandra, 50657, false) --Beam
			Cassandra:CastSpell(Cassandra, 37711, true) --Shadowform
			Cassandra:CastSpell(Cassandra,34256,true) --Explosion
			Cassandra:Emote(11)
			pUnit:CastSpell(pUnit,642,true)
			local qq = pUnit:GetCreaturesInRange(15, 90233)
			local qqq = pUnit:GetCreaturesInRange(15, 90234)
			if qq and qqq then
				for _,v in pairs(qq) do
					v:CastSpell(v,90040,true)
					v:RegisterEvent(GoldshireMisc.GoldshireCitizen_Respawn,10000,1)
					local qmsg = math.random(1,8)
					if qmsg == 1 then
						v:SendUnitSay("SHADOWS... THEY'RE MOVING IN ME!",0)
					elseif qmsg == 2 then
						v:SendUnitSay("THE SCOURGE ARE COMING!",0)
					elseif qmsg == 3 then
						v:SendUnitSay("AHHH!!!",0)
					end
				end
				for _,zz in pairs(qqq) do
					zz:CastSpell(zz,90040,true)
					zz:RegisterEvent(GoldshireMisc.GoldshireCitizen_Respawn,10000,1)
				end
			end
		elseif q == 83 then
			pUnit:SendUnitSay("By the light, Cassandra!",0)
			pUnit:Emote(5)
		elseif q == 85 then
			local Cassandra = pUnit:GetNearestCreature(15, 90232)
			Cassandra:SendUnitSay("Have fun regaining your followers, old man...",0)
			Cassandra:Emote(11)
		elseif q == 87 then
			local Cassandra = pUnit:GetNearestCreature(15, 90232)
			Cassandra:CastSpell(Cassandra, 39667, false) --Vanish
		elseif q == 89 then
			local Cassandra = pUnit:GetNearestCreature(25, 90232)
			Cassandra:SetPhaseMask(CREATURE_ONLY_PHASE)
			Cassandra:MoveHome()
			Cassandra:RegisterEvent(GoldshireMisc.CassandraRespawn_Event01,20000,1)	
		elseif q == 90 then
			pUnit:SendUnitSay("Calm down people! There's nothing to be afraid of!",0)
			pUnit:CastSpell(pUnit, 46564, false)
		elseif q == 92 then
			GoldshireMisc.HighPriestOnSpawn(5,pUnit,nil)
			q = 0
		end
	--------------------------
	--		EVENT 02		--
	--------------------------
	elseif HighPriestEvent == 2 then
		if q == 1 then
			local Orb = pUnit:SpawnCreature(90236, -9432, 62, 56.7, 3.12) --Glowing Orb :)
			Orb:DespawnOrUnsummon(20000)
		elseif q == 2 then
			local qq = pUnit:GetCreaturesInRange(15, 90233)
			if qq then
				for _,v in pairs(qq) do
					v:RegisterEvent(GoldshireMisc.GoldshireCitizen_Respawn,6000,1)
					v:SetUInt32Value(83, 430)
					local qmsg = math.random(1,8)
					if qmsg == 1 then
						v:SendUnitSay("What... What is that!?",0)
					elseif qmsg == 2 then
						v:SendUnitSay("A warlock! A warlock is here, I say!",0)
					elseif qmsg == 3 then
						v:SendUnitSay("AHHH!!!",0)
					end
				end
			end
		elseif q == 6 then
			pUnit:SendUnitSay("Calm, my children; It is nothing but a manifestation of the light.",0)
			pUnit:SetFacing(4.7)
			pUnit:Emote(1)
		elseif q == 11 then
			pUnit:SendUnitSay("This is proof, that the light has not abandoned us.",0)
			pUnit:Emote(1)
		elseif q == 18 then
			pUnit:SendUnitSay("Touch it and it shall heal your wounds and charge you with it's powers.")
			pUnit:Emote(1)
		elseif q == 24 then
			pUnit:SendUnitSay("There it goes... But fear not, it shall return.",0)
			pUnit:Emote(1)
			GoldshireMisc.HighPriestOnSpawn(5,pUnit,nil)
			q = 0
		end
	end
end

function GoldshireMisc.HighPriestYell(event, delay, repeats, pUnit)
	if pUnit:IsAlive() then
		local Cassandra = pUnit:GetNearestCreature(40, 90232)
		if (Cassandra ~= nil) and (Cassandra:IsAlive()) then
			pUnit:RemoveEvents()
			HighPriestEvent = math.random(1,2)
			pUnit:RegisterEvent(GoldshireMisc.HighPriestAITick, 1000, 0)
		end
	end
end

function GoldshireMisc.HighPriestOnSpawn(event, pUnit, extra)
	if event == 4 then
		pUnit:RemoveEvents()
		return
	end
	pUnit:RemoveEvents()
	pUnit:MoveHome()
	pUnit:SetPower(0, 781)
	pUnit:SetNPCFlags(3)
	pUnit:RegisterEvent(GoldshireMisc.HighPriestYell, math.random(300000,600000), 0)
	--pUnit:RegisterEvent(GoldshireMisc.HighPriestYell, 5000, 0)
end


RegisterCreatureEvent(90231, 5, GoldshireMisc.HighPriestOnSpawn)
RegisterCreatureEvent(90231, 4, GoldshireMisc.HighPriestOnSpawn)

--[[function GoldshireMisc.MissKinndy(event,pUnit)
	pUnit:SetUInt32Value(83, 69)
end

RegisterCreatureEvent(90235, 5, GoldshireMisc.MissKinndy)]]--