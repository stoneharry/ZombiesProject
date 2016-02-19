--Todo: Implemt quests, add timer for limited items, or somehow limit items that be bought. 
--I'd like to keep the vendor interface, but a vendor can be made through gossip as well.

local ElenorStock = {0,1,1,0} --If value is = 1 then true, 0 = false. 
--[1] = Dust, [2] = bread, [3] = water, [4] NeedSup = false

local function ElenorOnGossip(event, player, pUnit)
	player:GossipMenuAddItem(1,"I would like to trade", 0, 1)
	player:GossipMenuAddItem(7,"How can I help you?", 0, 2)
	player:GossipAddQuests(pUnit)
    player:GossipSendMenu(player:GetGossipTextId(pUnit), pUnit)
end


local function ElenorOnSelect(event, player, pUnit, sender, initid, code)
	if (initid == 1) then
		player:SendListInventory(pUnit)
	elseif (initid == 2) then
		ElenorStock[4] = 0 --Resetting before checking values
		if ElenorStock[1] == 0 then --Holy Dust
			player:GossipMenuAddItem(0,"A Holy Mission", 0, 3) --Quest for Holy Dust
			ElenorStock[4] = 1 --We need more supplies
		end
		if ElenorStock[2] == 0 then --Bread
			player:GossipMenuAddItem(0,"Rotten Bread", 0, 4) --Quest for bread
			ElenorStock[4] = 1 --We need more supplies
		end
		if ElenorStock[3] == 0 then --Water
			player:GossipMenuAddItem(0,"Rotten Bread", 0, 5) --Quest for water
			ElenorStock[4] = 1 --We need more supplies
		end
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
	elseif (initid == 9) then
		player:GossipComplete()
	end
end

RegisterCreatureGossipEvent(90118, 1, ElenorOnGossip)
RegisterCreatureGossipEvent(90118, 2, ElenorOnSelect)