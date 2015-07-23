
function GetCreature(range, id, pUnit)
	local t = pUnit:GetCreaturesInRange(range, id)
	if not t or #t == 0 then
		return nil
	end
	if #t > 1 then
		for _,v in pairs(t) do
			if v:GetPhaseMask() == pUnit:GetPhaseMask() then
				return v
			end
		end
	end
	return t[1]
end

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
