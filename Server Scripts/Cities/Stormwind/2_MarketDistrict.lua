
-- Starter

local function CanMarketEventStart(_, _, _, pUnit)
	if GetSiegeStage() == 2 then
		for _,v in pairs(pUnit:GetGameObjectsInRange(40, 187809)) do
			v:SetByteValue(GAMEOBJECT_BYTES_1, 0, 0)
		end
		pUnit:SpawnCreature(90077, -8919, 549.2, 94, 0.656422)
		pUnit:SpawnCreature(90066, -8916.4, 557.3, 94, 0.67213)
		pUnit:SpawnCreature(90066, -8910.5, 549.945, 94, 0.668203)
		pUnit:SpawnCreature(90064, -8910.6, 552.8, 93.8, 0.668203)
		pUnit:SpawnCreature(90064, -8913.6, 556.7, 93.8, 0.617152)
		pUnit:RemoveEvents()
	end
end

local function DummySpawn(event, pUnit)
	pUnit:RegisterEvent(CanMarketEventStart, 5000, 0)
end

RegisterCreatureEvent(90076, 5, DummySpawn)

-- Gossip start

local function SiegeGossip1(event, player, pUnit, _, intid)
	player:GossipSendMenu(90001, pUnit)
end

RegisterCreatureGossipEvent(90077, 1, SiegeGossip1)
