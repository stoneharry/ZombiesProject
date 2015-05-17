
local newFrame = CreateFrame("frame", "invisibleEventFrame")
newFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
newFrame:RegisterEvent("CHAT_MSG_ADDON")

local links = {}

local function eventHandlerMainFrame(self, event, message, _, Type, Sender)
    if (event == "CHAT_MSG_ADDON" and Sender == UnitName("player")) then
		local packet, link, linkCount, MSG = message:match("(%d%d%d)(%d%d)(%d%d)(.+)");
		if not packet or not link or not linkCount or not MSG then
			return
		end
		packet, link, linkCount = tonumber(packet), tonumber(link), tonumber(linkCount);
		
		links[packet] = links[packet] or {count = 0};
		links[packet][link] = MSG;
		links[packet].count = links[packet].count + 1;
		
		if (links[packet].count ~= linkCount) then
			return
		end
		local fullMessage = table.concat(links[packet]);
		links[packet] = {count = 0};
		
        -- Handle addon messages
		if string.starts(fullMessage, "LEVELUP") then
			local t = scen_split(fullMessage)
			toggleSelectionFrame(t)
		end
	end
end

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

newFrame:SetScript("OnEvent", eventHandlerMainFrame)

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