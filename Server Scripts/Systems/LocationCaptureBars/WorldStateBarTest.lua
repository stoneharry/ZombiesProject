 local function RunCommand(event, player, cmd)
    if cmd == "bartest" then
        player:InitializeMultiWorldState(566, 0, 2720, 0, 2719, 0, 2718, 0)
		player:UpdateWorldState(2720, 90)
		player:UpdateWorldState(2719, 100)
		player:UpdateWorldState(2718, 1)
        return false
    end
end
 
RegisterPlayerEvent(42, RunCommand)