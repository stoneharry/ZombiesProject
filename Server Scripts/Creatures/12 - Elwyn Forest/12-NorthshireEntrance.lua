
local x1 = 9083
local x2 = 9107
local y1 = 67
local y2 = 32

--Escape Gossip--
local button = false
local xi = 0

local function RenewVisual(eventId, delay, repeats, pUnit)
	pUnit:CastSpell(pUnit, 55926, true)
end

local function RenewVisualOrb(eventId, delay, repeats, pUnit)
	pUnit:CastSpell(pUnit, 71706, true)
end

local function SpawnZombie(eventId, delay, repeats, pUnit)
	if not button then
		local x = -math.random(x1, x2)
		local y = -math.random(y2, y1)
		local map = pUnit:GetMap()
		pUnit:SpawnCreature(90011, x, y, map:GetHeight(x, y), 0, 6, 5000)
	else
		if xi == 8 then
			button = false
			xi = 0
		end
		xi = xi + 1
	end
end

local function VisualDummySpawn(event, pUnit)
	pUnit:SetUInt32Value(UNIT_FIELD_FLAGS, UNIT_FIELD_FLAG_UNTARGETABLE + UNIT_FIELD_FLAG_UNATTACKABLE) -- untargetable, unattackable
	if pUnit:GetEntry() == 90009 then
		pUnit:RegisterEvent(RenewVisual, 1000, 0)
		pUnit:RegisterEvent(SpawnZombie, 1500, 0)
	else
		pUnit:RegisterEvent(RenewVisualOrb, 5000, 0)
		pUnit:SetUInt32Value(0x0006 + 0x0035, 33554434)
	end
	pUnit:SetRooted(true)
end

RegisterCreatureEvent(90009, 5, VisualDummySpawn)
RegisterCreatureEvent(90012, 5, VisualDummySpawn)

local function ProtectorTick(eventId, delay, repeats, pUnit)
	pUnit:CastSpell(pUnit, 51361, true)
end

local function ProtectorSpawn(event, pUnit)
	pUnit:SetUInt32Value(UNIT_FIELD_FLAGS, UNIT_FIELD_FLAG_UNATTACKABLE) -- unattackable
	pUnit:RegisterEvent(ProtectorTick, 10000, 0)
	pUnit:SetRooted(true)
end

RegisterCreatureEvent(90010, 5, ProtectorSpawn)


local function SetHostile(eventId, delay, repeats, pUnit)
	pUnit:SetFaction(17)
	pUnit:SetUInt32Value(UNIT_FIELD_FLAGS, 0) -- attackable, targetable
	pUnit:MoveTo(0, -9053, -44, 88.35)
end

local function SetDisplay(eventId, delay, repeats, pUnit)
	pUnit:SetDisplayId(24991 + math.random(1, 7))
end

local function SpawnFromGround(eventId, delay, repeats, pUnit)
	pUnit:SetUInt32Value(UNIT_FIELD_BYTES_1, 0) -- above ground
	pUnit:RegisterEvent(SetHostile, 4000, 1)
end

local function ZombieMinion(event, pUnit, extra)
	pUnit:SetUInt32Value(UNIT_FIELD_FLAGS, UNIT_FIELD_FLAG_UNTARGETABLE + UNIT_FIELD_FLAG_UNATTACKABLE) -- unattackable, untargetable
	pUnit:SetUInt32Value(UNIT_FIELD_BYTES_1, 9) -- underground
	pUnit:RegisterEvent(SpawnFromGround, 2000, 1)
	pUnit:RegisterEvent(SetDisplay, 1000, 1)
end

RegisterCreatureEvent(90011, 5, ZombieMinion)

--KillerDummy--

local function CastSpellStarFall(eventID,delay,repeats,pUnit)
	pUnit:CastSpell(pUnit, 50286, true)
end

local function KillerDummy(event,pUnit,extra)
	pUnit:SetUInt32Value(UNIT_FIELD_FLAGS, UNIT_FIELD_FLAG_UNTARGETABLE + UNIT_FIELD_FLAG_UNATTACKABLE)
	pUnit:RegisterEvent(CastSpellStarFall,1000,0)
end

RegisterCreatureEvent(90007, 5, KillerDummy)


--Spiritwind--

local function SpiritwindOnGossip(event, player, pUnit)
    if (pUnit:IsQuestGiver()) then
        player:GossipAddQuests(pUnit)
    end
    if not button then
    	player:GossipMenuAddItem(0,"I'd like to pass.", 0, 1)
    end
    player:GossipSendMenu(player:GetGossipTextId(pUnit), pUnit)
end

local function SpiritwindOnSelect(event, player, pUnit, sender, initid, code)
	player:GossipComplete()
	if (initid == 1) then
		if player:HasQuest(90003) then
			player:QuestKillCredit(90006)
		end
		pUnit:SendUnitSay("By Elune, begone!",0)
		pUnit:CastSpell(pUnit, 53199)
		button = true
		xi = 0
		local killer = pUnit:SpawnCreature(90007, -9078,-48,88,0,2,8000)
	end
end

RegisterCreatureGossipEvent(90006, 1, SpiritwindOnGossip)
RegisterCreatureGossipEvent(90006, 2, SpiritwindOnSelect)
