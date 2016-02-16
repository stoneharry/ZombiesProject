local Utility = {}
local Roles = {}

local BattlePriest = 90004
local HighElf = 90021
local Dwarf = 90020
local Orc = 90022
local GenericBunny = 90097

--[[NORTHSHIRE ABBEY]]--

--90004 - Argent Battle Priest
function Utility.CastBlessing(eventId, delay, repeats, pUnit)
	if pUnit:IsAlive() then
		pUnit:CastSpell(pUnit, 58054)
	end
end

function Utility.BattlePriestBuff(event, pUnit, extra)
	if event == 4 then
		pUnit:RemoveEvents()
		return
	end
	pUnit:RegisterEvent(Utility.CastBlessing, 1800000, 0)
	pUnit:CastSpell(pUnit, 58054) -- Blessing of Kings
end

RegisterCreatureEvent(BattlePriest, 5, Utility.BattlePriestBuff)
RegisterCreatureEvent(BattlePriest, 4, Utility.BattlePriestBuff)

--90003 - Argent Priestess - Using her as dummy

--[[
(S) = Standstate
EMOTES:
1: Talk			6: Shrug	14: Rude	19: Chicken	24:Shy		29: Point(2)	37: HitSword	45:ReadyF(S)
2: Bow			7: Eat		15: Roar	20: Beg 	25: Point	33: Blow (2)	38: HitTwoH		48:ReadyF(S)
3: No 			8: Wipe		16: Kneel	21: Clap	26: Fight(S)34: Blow(2) 	39: Block		51:Hit(3)
4: Cheer		10: Dance	17: Kiss	22: Yell	27: Bow		35: Hit (1)		43: ShieldB		53:Berserk
5: Excited Talk	11: Laugh	18: Cry 	23: Flex	28: Mine(S) 36: Hit (2)		44:	ReadyF(S)	64:Dazed(S)

Roles:
1: Refugee
2: Prayer
3: Beggar
--]]

--Time between talking in MS. it's currently this low due to testing purposes.
local TS = 60000
local TE = 120000

function Utility.CryAndBogus(eventId, delay, repeats, pUnit)
	local tMSG --The Variable for the msg
	local tE --The variable for the emote
	local tGUID = tostring(pUnit:GetGUID())
	if Roles[tGUID] == 1 then
		local t = math.random(1,4) --Choose a random dialogue+emote
		if t == 1 then
			tMSG = "They came out of nowhere - I have nothing left now."
			tE = 18
		elseif t == 2 then
			tMSG = "We only travel during the day, for the night is dark and full of terrors."
			tE = 1
		elseif t == 3 then
			tMSG = "I will avenge my family. For Quel'thalas!" --Not exactly lore corret, since that area belongs to the blood elves... SHH!
			tE = 5
		elseif t == 4 then
			t = 18
		end
	elseif Roles[tGUID] == 2 then
		local t = math.random(1,5)
		if t == 1 then
			tMSG = "We've been through worse - you'll survive. You'll survive to fulfil a proper warriors death."
		elseif t == 2 then
			tMSG = "Don't you dare leave me now!"
		elseif t == 3 then
			tMSG = "You've brought honour to us all..."
		elseif t == 4 then
			tMSG = "All of these moments lost, like tears in rain."
		elseif t == 5 then
			if (pUnit:GetDisplayId() == 18559) then --Female
				tMSG = "You made your mother proud."
			else
				tMSG = "You made your brother proud"
			end
		end
	end
	if tMSG then
		pUnit:SendUnitSay(tMSG,0)
	end
	if tE then
		pUnit:Emote(tE)
	end
end



function Utility.MakeAWorld(eventId, delay, repeats, pUnit)
	if (pUnit:GetEntry() == GenericBunny) then
		pUnit:DespawnOrUnsummon(3000)
	else
		local Bunny = pUnit:SpawnCreature(GenericBunny, -8912.602539, -180.820923, 81.939263, 2.266010)
		if (Bunny:GetNearObject(1,0,HighElf) == nil) then
			local xUnit = pUnit:SpawnCreature(HighElf, -8912.602539, -180.820923, 81.939263, 2.266010) --Inside the Main Hall
			if (xUnit ~= nil) then
				xUnit:RegisterEvent(Utility.CryAndBogus, math.random(TS,TE),0)
				Roles[tostring(xUnit:GetGUID())] = 1
			end
		end
		local Bunny = pUnit:SpawnCreature(GenericBunny, -8916.900391, -166.688660, 81.939790, 5.932497)
		if (Bunny:GetNearObject(1,0,Orc) == nil) then
			xUnit = pUnit:SpawnCreature(Orc, -8916.900391, -166.688660, 81.939790, 5.932497) -- Orc kneeling in infirmary
			if (xUnit ~= nil) then
				xUnit:RegisterEvent(Utility.CryAndBogus, math.random(TS,TE),0) 
				xUnit:SetByteValue(UNIT_FIELD_BYTES_1, 0, 8)
				xUnit:SetByteValue(UNIT_FIELD_BYTES_2, 0, 1)
				Roles[tostring(xUnit:GetGUID())] = 2
			end
		end
	end
end

function Utility.SpawnRefugees(event, pUnit, extra)
	pUnit:RegisterEvent(Utility.MakeAWorld, 1000, 1)
end

RegisterCreatureEvent(90003, 5, Utility.SpawnRefugees)

function Utility.GenericBunnyOnSpawn(event,pUnit,extra )
	pUnit:RegisterEvent(Utility.MakeAWorld,1000,1)
end

RegisterCreatureEvent(GenericBunny, 5, Utility.GenericBunnyOnSpawn)

--Archmage Tervosh (90005) Quartermaster of past achivements

function Utility.TervoshOnGossip(event, player, pUnit)
--[[    player:GossipMenuAddItem(0,"I heard you can acquire certain... goods.", 0, 1)
    player:GossipMenuAddItem(0,"And your other goods?", 0, 2)
    player:GossipMenuAddItem(0,"Cookie!", 0, 3)]]--
    print("Event was triggered by plr")
    if plr then print("Plr found") end
    player:GossipSendMenu(player:GetGossipTextId(pUnit), pUnit)
end

--[[
function Utility.TervoshOnSelect(event, player, pUnit, sender, initid, code)
	if (initid == 1) then
		VendorRemoveAllItems(90005)
		AddVendorItem(90005,22667,0,0,0)
		player:SendListInventory(pUnit)
		AddVendorItem(90005,22666,0,0,0)
	elseif (initid == 2) then
		VendorRemoveAllItems(90005)
		AddVendorItem(90005,22666,0,0,0)
		player:SendListInventory(pUnit)
		AddVendorItem(90005,22667,0,0,0)
	elseif (initid == 3) then
		player:SendListInventory(pUnit)
	end
end]]

RegisterCreatureGossipEvent(90005, 1, Utility.TervoshOnGossip)
--RegisterCreatureGossipEvent(90005, 2, Utility.TervoshOnSelect)