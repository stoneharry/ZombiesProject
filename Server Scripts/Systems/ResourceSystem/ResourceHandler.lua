local ResourceSystem = {
    -- Config stuff
    SaveTimer = 300, -- 5 minutes
    ConsoleOutput = false, -- Set to false to disable Resource System console output
    MaxUnsavedChanges = 50, -- Maximum amount of unsaved changes before 
    
    -- Do not change.
    UnsavedChangeCount = 0 -- Unsaved change 
};
-- Start helper functions

    -- This updates the visual score of all the players in the specific zone
function UpdateZoneVisualScore(zone)
    if(ResourceSystem["ActiveResourceZones"][zone]) then
        -- Update the WorldState score for all players in the zone.
        for _, v in pairs(GetPlayersInWorld()) do
            if v:GetZoneId() == zone then
                v:UpdateWorldState(9000, ResourceSystem["ActiveResourceZones"][zone]["currResource"])
            end
        end
        
        -- Increment the save override counter
        ResourceSystem.UnsavedChangeCount = ResourceSystem.UnsavedChangeCount+1
        if(ResourceSystem.ConsoleOutput) then
            print("[ResourceSystem]: "..ResourceSystem.UnsavedChangeCount.." unsaved changes to the WorldState cache.")
        end
        
        -- If a set amount of changes have been done to the cache before the save timer has happened, force save.
        local UpdateMax = 50
        if(ResourceSystem.UnsavedChangeCount >= ResourceSystem.MaxUnsavedChanges) then
            print("[ResourceSystem]: WorldState changes exceeding Save Override. Forcing save...")
            ResourceSystem.SaveResourceData()
        end
    end
end

    -- This returns the current and max resources in the selected zone.
function GetResourceData(zone)
    if(ResourceSystem["ActiveResourceZones"][zone]) then
        return ResourceSystem["ActiveResourceZones"][zone]["currResource"], ResourceSystem["ActiveResourceZones"][zone]["maxResource"] -- currResources, maxResources
    else
        return nil
    end
end

    -- This modifies the current resource in the selected zone. Additive or subtractive.
function ModifyCurrentResources(zone, value)
    if(ResourceSystem["ActiveResourceZones"][zone]) then
        local newValue = ResourceSystem["ActiveResourceZones"][zone]["currResource"] + value
        
        if(newValue < 0) then
            newValue = 0
        elseif(newValue > ResourceSystem["ActiveResourceZones"][zone]["maxResource"]) then
            newValue = ResourceSystem["ActiveResourceZones"][zone]["maxResource"]
        end

        ResourceSystem["ActiveResourceZones"][zone]["currResource"] = newValue;
        UpdateZoneVisualScore(zone)
    end
end

function SetCurrentResources(zone, value)
    if(ResourceSystem["ActiveResourceZones"][zone]) then
        ResourceSystem["ActiveResourceZones"][zone]["currResource"] = value;
        UpdateZoneVisualScore(zone)
    end
end

-- End helper functions


-- Start caching and saving

function ResourceSystem.FetchResourceData()
    ResourceSystem["ActiveResourceZones"] = {};
    
    local Query = WorldDBQuery("SELECT * FROM resourcetable;");
    if(Query)then
        repeat
            ResourceSystem["ActiveResourceZones"][Query:GetUInt32(0)] = {
                -- Zone
                currResource = Query:GetUInt32(1),
                maxResource = Query:GetUInt32(2),
            };
        until not Query:NextRow()
    end
    
    if(ResourceSystem.ConsoleOutput) then
        print("[ResourceSystem]: Initializing cache. Loaded "..Query:GetRowCount().." Zones")
    end
end

function ResourceSystem.SaveResourceData()
    if(ResourceSystem["ActiveResourceZones"]) then
        ResourceSystem.UnsavedChangeCount = 0 -- Reset the override count.
        for k, v in pairs(ResourceSystem["ActiveResourceZones"]) do
            WorldDBQuery("REPLACE INTO resourcetable (zone, currResource, maxResource) VALUES ("..k..", "..v["currResource"]..", "..v["maxResource"].."); ")
        end
    end
    
    if(ResourceSystem.ConsoleOutput) then
        print("[ResourceSystem]: Saved Data. Refreshing cache...")
    end
    
    ResourceSystem.FetchResourceData()
end

-- End caching and saving


-- Start initialization and updating

function ResourceSystem.OnUpdateZone(event, player, newZone, newArea)
    local playerZone = player:GetZoneId()
	if(ResourceSystem["ActiveResourceZones"][playerZone]) then
		player:InitializeWorldState(900, 0, 0, 1) -- Initialize world state, resources at 0/0
		player:UpdateWorldState(9001, ResourceSystem["ActiveResourceZones"][playerZone]["maxResource"]) -- Sets correct maxResource count
		player:UpdateWorldState(9000, ResourceSystem["ActiveResourceZones"][playerZone]["currResource"]) -- Sets correct currResource count
	end
end

function TempOnChat(event, player, msg, Type, lang)
	if not player:IsGM() then
		return
	end
    local playerZone = player:GetZoneId()
    if(msg == "inc") then
        ModifyCurrentResources(playerZone, 1)
		return false
    end
    if(msg == "incmax") then
        ModifyCurrentResources(playerZone, ResourceSystem["ActiveResourceZones"][playerZone]["maxResource"])
		return false
	end
    if(msg == "dec") then
        ModifyCurrentResources(playerZone, -1)
		return false
    end
end

-- End initialization and updating

ResourceSystem.FetchResourceData()
CreateLuaEvent(ResourceSystem.SaveResourceData, ResourceSystem.SaveTimer*1000, 0)
RegisterPlayerEvent(27, ResourceSystem.OnUpdateZone)
RegisterPlayerEvent(18, TempOnChat)