local SpellDisplayCreatures = {
    MAP = 900,
    NWX = 14300,
    NWY = 14300,
    SEX = 13100,
    SEY = 13100
};

local function SplitString(str)
    local t = {}
    local i = 1
    for p in str:gmatch("[%S]+") do
        t[i] = p
        i = i+1
    end
    return t
end

function SpellDisplayCreatures.Fetch()
    local cT = SpellDisplayCreatures
    if not(cT["CreatureCache"]) then
        cT["CreatureCache"] = {};
    end
    
    local counter = 0;
	local Query = WorldDBQuery("SELECT entry, name, modelid1 FROM creature_template where entry >= 150000;");
    if(Query)then
        repeat
            counter = counter+1
            cT["CreatureCache"][counter] = {
                entry = Query:GetUInt32(0),
                name = Query:GetString(1),
                modelid1 = Query:GetUInt32(2),
            };
        until not Query:NextRow()
    end
    
    print("[SpellDisplayCreatures]: Loaded "..Query:GetRowCount().." creatures.")
end

function SpellDisplayCreatures.Spawn(minkey, maxkey)
    local cT = SpellDisplayCreatures
    
    if minkey < 1 then
        minkey = 1
    end
    
    if maxkey > #cT["CreatureCache"] then
        maxkey = #cT["CreatureCache"]
    end

    local distance = math.sqrt((cT.NWX-cT.SEX)*(cT.NWY-cT.SEY)/#cT["CreatureCache"])
    
    local perRow = math.floor((cT.NWY-cT.SEY)/distance)

    for j = 0, math.ceil(#cT["CreatureCache"]/(perRow+1)) do
        for i = 0, perRow do
            local idx = ((j*perRow)+i) +1
            if idx >= minkey and idx <= maxkey then
                if cT["CreatureCache"][idx] then
                    print("[SpellDisplayCreatures]: Spawned creature: "..cT["CreatureCache"][idx]["entry"].." at X: "..cT.NWX-(i*distance).." Y: "..cT.NWY-(j*distance))
                    PerformIngameSpawn(1, cT["CreatureCache"][idx]["entry"], cT.MAP, 0, cT.NWX-(i*distance), cT.NWY-(j*distance), 1, 0, 1)
                end
            end
        end
    end
end

function SpellDisplayCreatures.OnChatCommand(event, player, command)
    local commPrefix = "spelldisplay"
    if(string.lower(command):find(commPrefix) == 1) and player:IsGM() then
        local strT = SplitString(command)
        local minkey, maxkey = tonumber(strT[2]), tonumber(strT[3])
        if(minkey and maxkey) then
            SpellDisplayCreatures.Spawn(minkey, maxkey)
        else
            print("[SpellDisplayCreatures]: Please provide a valid min and max key")
        end
        return false;
    end
end

-- SpellDisplayCreatures.Fetch()
-- RegisterPlayerEvent(42, SpellDisplayCreatures.OnChatCommand) Uncomment for regenerating the spell display spawn command