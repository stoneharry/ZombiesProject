local Tileon = {
    RandomEmotes = {
        {"You there! Get me more resources!", 2},
        {"Do you peons not know how to work faster!", 2},
        {"You're all good for nothing!", 2},
        {"These boxes aren't stacked right...", 1},
        {"Seems like I've only got snails working for me...", 1},
        {"I could really use a chair...", 1}
    },
    QuestList = {
        [90010] = 5, -- Quest, resource point worth
        [90009] = 15,
    },
    entry = 90070
};

function Tileon.OnSpawn(event, creature)
    creature:SetUInt32Value(83, 69)
    creature:RegisterEvent(Tileon.RandomExpression, math.random(90000, 180000), 1) -- Only register once for the random timer. Re-register in the function itself.
end

function Tileon.RandomExpression(eventId, delay, repeats, creature)
    local key = math.random(#Tileon["RandomEmotes"])
    local eType = Tileon["RandomEmotes"][key][2]
    
    if(eType == 1) then
        creature:SendUnitSay(Tileon["RandomEmotes"][key][1], 0)
    elseif(eType == 2) then
        creature:SendUnitYell(Tileon["RandomEmotes"][key][1], 0)
    end
    
    creature:RegisterEvent(Tileon.RandomExpression, math.random(90000, 180000), 1)
end

function Tileon.OnQuestReward(event, player, creature, quest, opt)
    if(Tileon["QuestList"][quest:GetId()]) then
        ModifyCurrentResources(creature:GetZoneId(), Tileon["QuestList"][quest:GetId()])
    end
end

RegisterCreatureEvent(Tileon.entry, 5, Tileon.OnSpawn)
RegisterCreatureEvent(Tileon.entry, 34, Tileon.OnQuestReward)