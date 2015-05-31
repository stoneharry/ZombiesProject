function sendAddonMessage(plr, msg, packet)
	local splitLength = 240
	local splits = math.ceil(msg:len() / splitLength)
	local send
	local counter = 1
	for i=1, msg:len(), splitLength do
		send = string.format("%03d", packet)
		send = send .. string.format("%02d", counter)
		send = send .. string.format("%02d", splits)
		if ((i + splitLength) > msg:len()) then
			send = send .. msg:sub(i, msg:len())
		else
			send = send .. msg:sub(i, i + splitLength)
		end
		counter = counter + 1

		if _DEBUG then print("[SENT] " .. send) end
		plr:SendAddonMessage(send, "", 7, plr)
	end
end

function scen_split(str)
	local b = {}
	local c = 1
	local d = {}
	string.gsub(str, "[%w%s-]", function(a)
		if (a == "-") then
			c = c + 1
		else
			if (not b[c]) then
				b[c] = {}
			end
			table.insert(b[c], a)
		end
	end)
	for k, v in pairs (b) do
		table.insert(d, table.concat(v))
	end
	return d
end

-----------------------------
--Testing deletion of spell--
--------Spell: 90003---------
--[[
local function PLAYER_EVENT_ON_SPELL_CAST(event,plr,spell,skipCheck)
	if spell == 90003 then
		if plr ~= nil then
			plr:RemoveSpell(90003)
		end
	end
end

RegisterPlayerEvent(5, PLAYER_EVENT_ON_SPELL_CAST)
--]]