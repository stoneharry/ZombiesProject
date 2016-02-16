local npcId = 90110

local PATH_LENGTH = 0

local path = {
	-- [nodeId] = {x, y, z}
	[1] = {-9558.717773, -142.706924, 57.326931}, -- Spawn location of the Goblin.
	[2] = {-9575.228516, -160.3187622, 57.568001},
	[3] = {-9571.756836, -192.731369, 58.613216}
}

local function OnSpawn(event, creature)
	creature:SendUnitSay("OnSpawn", 7)

	-- Iterates over all paths to determine the total number
	-- of nodes in the path.
	local total = 0

	for i = 1, 1000, 1 do
		if(path[i] ~= nil) then
			total = total + 1
		else
			break
		end
	end

	PATH_LENGTH = total

	-- Order the creature to move to it's first position
	-- if a path exists.
	if(PATH_LENGTH > 0) then
		creature:SetWalk(false)
		creature:MoveTo(2, table.unpack(path[2]))
	else
		creature:SendUnitSay("No path has been specified.", 7)
	end
end

-- The creature will follow the defined path in a
-- circular way. Once the last point on the path is
-- reached, then it moves to the first point and repeats
-- forever.
local function OnReachWp(event, creature, type, id)
	--creature:SendUnitSay("WALKING", 7)
	--creature:SendUnitSay("Type = " .. type .. " id = " .. id, 7)
	creature:SetWalk(false)
	

	if (id == PATH_LENGTH) then
		creature:MoveTo(1, table.unpack(path[1]))
	else
		creature:MoveTo(id + 1, table.unpack(path[id + 1]))
	end
end


RegisterCreatureEvent(npcId, 5, OnSpawn)
RegisterCreatureEvent(npcId, 6, OnReachWp)