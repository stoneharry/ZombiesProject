
local CHOICE_TABLE = {
	-- TYPES:
	--		1: Spell
	--		2: Item
	-- Each set of values must contain at least 3 unique values
	-- level = { number of types, type1, set of values for type1, ... }
	-- each value in set of values MUST be unique
	[2] = {2, 1, {1752, 2983, 1908}, 2, {50055, 23368, 26029}},
	[3] = {2, 1, {1752, 2983, 1908}, 2, {50055, 23368, 26029}},
	[4] = {2, 1, {1752, 2983, 1908}, 2, {50055, 23368, 26029}},
	[5] = {2, 1, {1752, 2983, 1908}, 2, {50055, 23368, 26029}},
	[6] = {2, 1, {1752, 2983, 1908}, 2, {50055, 23368, 26029}}
	
}

local function PLAYER_EVENT_ON_LEVEL_CHANGE(event, player, oldLevel)
	local t = CHOICE_TABLE[oldLevel + 1]
	if not t then
		return
	end
	local numTypes = t[1];
	local results = {}
	for i=1,3 do
		local _type = math.random(1, t[1])
		local values = t[(_type * 2) + 1]
		local inserted = false
		while not inserted do
			local val = values[math.random(1, #values)]
			local valid = true
			for _,v in pairs(results) do
				if (v[1] == _type and v[2] == val) then
					valid = false
				end
			end
			if valid then
				table.insert(results, {_type, val})
				inserted = true
			end
		end
	end
	
	local query = "INSERT INTO `spellselectionsystem` (guid, `level`, type1, option1, type2, option2, type3, option3) VALUES "
		.. "('" .. player:GetGUIDLow() .. "', '" .. (oldLevel + 1) .. "'"
	local message = "LEVELUP-" .. string.format("%02d", oldLevel + 1)
	for i=1,3 do
		query = query .. ", '" .. results[i][1] .. "'"
		message = message .. "-" ..  string.format("%01d", results[i][1])
		query = query .. ", '" .. results[i][2] .. "'"
		message = message .. "-" ..  string.format("%06d", results[i][2])
	end
	
	CharDBQuery(query .. ")")
	
	sendAddonMessage(player, message, 1)
end

RegisterPlayerEvent(13, PLAYER_EVENT_ON_LEVEL_CHANGE)

-----------
----------- receiving
-----------
local _DEBUG = false

-- Prototypes
local functionLookup

-- Handle addon messages
local function onReceiveAddonMsg(event, plr, Type, prefix, msg, receiver)
	if receiver ~= plr then return end
	if not msg or not prefix or not plr then return end
	if _DEBUG then print("[GOT] " .. prefix .. " | " .. msg) end
	local func = functionLookup[prefix]
	if func then
		func(plr, msg)
	end
end

RegisterServerEvent(30, onReceiveAddonMsg)

function SelectLevelReward(plr, msg)
	local option = tonumber(msg)
	if not option or option < 1 or option > 3 then
		return
	end
	local level = plr:GetLevel()
	local result = CharDBQuery("SELECT * FROM `spellselectionsystem` WHERE `guid` = '"..plr:GetGUIDLow().."' AND `level` = '"..level.."'")
	if result then
		local t = result:GetRow()
		if t["selected"] then
			return
		end
		local optionVal = t["option"..tostring(option)]
		local optionType = t["type"..tostring(option)]
		if (optionType == 1) then
			plr:LearnSpell(optionVal)
		elseif (optionType == 2) then
			plr:AddItem(optionVal, 1)
		end
		CharDBQuery("UPDATE `spellselectionsystem` SET `selectedType` = '"..tostring(optionType).."', `selected` = '"..tostring(optionVal).."' WHERE `guid` = '"..plr:GetGUIDLow().."' AND `level` = '"..level.."'")
	end
end

-- function lookup
functionLookup = {
	["SELECT"] = SelectLevelReward
}