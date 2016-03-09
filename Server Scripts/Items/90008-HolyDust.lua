local function HolyDust_OnUse(event,plr,item,pUnit)
	print("Dust used")
	if (plr:GetAura(90038) == true) then
		print("Dust is allready active")
		plr:SendAreaTriggerMessage("|cFFFF0000A more powerfull spell is allready active!|r")
		return false
	end
	return true
end

RegisterItemEvent(90008, 2, HolyDust_OnUse)