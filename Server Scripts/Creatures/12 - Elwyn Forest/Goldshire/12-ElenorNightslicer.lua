--VARIABLES--
local ElenorStock = {}
local timer = 3600 --How long stock stays in vendor in seconds (3600 = 1 hour)

--STOCK REFILL--
local function ElenorOnQuestReward(event,plr,pUnit,quest,opt)
	ElenorStock[quest:GetId()] = os.clock()
	if (quest:GetId() == 90011) then
		if (pUnit:GetNearestGameObject(3, 188225) == nil) then
			PerformIngameSpawn(2, 188225, 0, 0, -9457, 34.0185, 56.9672, 4.58313)
		end
	elseif (quest:GetId() == 90012) then
		if (pUnit:GetNearestGameObject(3, 90008) == nil) then
			PerformIngameSpawn(2, 90008, 0, 0, -9455.22, 33.1978, 56.9666, 1.18476)
		end
	end
end

--GOSSIP--
local function ElenorOnGossip(event, player, pUnit)
	player:GossipMenuAddItem(1,"I would like to trade", 0, 1)
	if (player:GetGMRank() > 0) then
		player:GossipMenuAddItem(1,"Event 1", 0, 11)
		player:GossipMenuAddItem(1,"Event 2", 0, 12)
		player:GossipMenuAddItem(1,"Event 3", 0, 13)
	end
	player:GossipMenuAddItem(0,"How can I help you?", 0, 2)
	player:GossipAddQuests(pUnit)
    player:GossipSendMenu(player:GetGossipTextId(pUnit), pUnit)
    --Update stock--
    VendorRemoveAllItems(90118)
	if ElenorStock[90011] ~= nil and ((os.clock()-ElenorStock[90011])) <= timer then
		AddVendorItem(90118,90008,0,0,0)
	else
		local zzObj = pUnit:GetNearestGameObject(3, 188225)
		if (zzObj ~= nil) then
			zzObj:Despawn()
			print("Depsawning chest")
		end
	end
	if ElenorStock[90012] ~= nil and ((os.clock()-ElenorStock[90012])) <= timer then
		AddVendorItem(90118,90010,0,0,0)
	else
		local zzObj = pUnit:GetNearestGameObject(3, 90008)
		if (zzObj ~= nil) then
			zzObj:Despawn()
			print("Despawning gunpowder")
		end
	end
end


local function ElenorOnSelect(event, player, pUnit, sender, initid, code)
	if (initid == 1) then
		player:SendListInventory(pUnit)
	elseif (initid == 2) then
		ElenorStock[4] = 0 --Resetting before checking values
		if ElenorStock[90011] == nil or ((os.clock()-ElenorStock[90011])) > timer then
			player:GossipMenuAddItem(0,"A Holy Mission", 0, 3) --Quest for Holy Dust
			ElenorStock[4] = 1 --We need more supplies
		end
		--[[if ElenorStock[3] == 0 then --Water
			player:GossipMenuAddItem(0,"Rotten Bread", 0, 5) --Quest for water
			ElenorStock[4] = 1 --We need more supplies
		end]]--
		if ElenorStock[4] == 1 then
			player:GossipMenuAddItem(0,"Nevermind", 0, 9) --To prevent bugging q_Q
			player:GossipSendMenu(90005, pUnit) --We need MOAR SUPPLIES
		else
			player:GossipSendMenu(90008, pUnit) --We got a full stock boys!
		end
	elseif (initid == 3) then --Dust quest
		player:SendQuestTemplate(90011)
	elseif (initid == 4) then --Bread quest
		--player:SendQuestTemplate(WATER)
	elseif (initid == 5) then --Water quest
		--player:SendQuestTemplate(BREAD)
	elseif (initid == 11) then
		pUnit:PlayDistanceSound(90010)
	elseif (initid == 12) then
		pUnit:PlayDistanceSound(90011)
	elseif (initid == 13) then
		pUnit:PlayDistanceSound(90012)
		local xyz = pUnit:GetRelativePoint(4, math.random(1,360) )
		print("X: "..tostring(xyz[1]).." y: "..tostring(xyz[2]).. " z: "..tostring(xyz[3]))
	elseif (initid == 9) then
		player:GossipComplete()
	end
end



RegisterCreatureGossipEvent(90118, 1, ElenorOnGossip)
RegisterCreatureGossipEvent(90118, 2, ElenorOnSelect)
RegisterCreatureEvent(90118, 34, ElenorOnQuestReward)
