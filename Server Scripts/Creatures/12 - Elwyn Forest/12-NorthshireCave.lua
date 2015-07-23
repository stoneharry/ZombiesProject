
local spawnPlaces = {}

local function KeepVisualUp(event, delay, repeats, pUnit)
	pUnit:CastSpell(pUnit, 39947, true)
	pUnit:SetStandState(8)
end

local function TrappedUnit(event, pUnit, extra)
	pUnit:RegisterEvent(KeepVisualUp, 2000, 0)
	pUnit:SetHealth(pUnit:GetMaxHealth() - math.random(30, 50))
	pUnit:SetNPCFlags(1)
	spawnPlaces[tostring(pUnit:GetGUID())] = {pUnit:GetX(), pUnit:GetY(), pUnit:GetZ(), pUnit:GetO()}
end

RegisterCreatureEvent(90016, 5, TrappedUnit)

local function SetVisibleNormalPhase(e, d, r, pUnit)
	pUnit:SetPhaseMask(1)
	pUnit:RegisterEvent(KeepVisualUp, 2000, 0)
	local t = spawnPlaces[tostring(pUnit:GetGUID())]
	pUnit:SetFacing(t[4])
	pUnit:SetNPCFlags(1)
end

local function RespawnSoon(e, d, r, pUnit)
	pUnit:SetPhaseMask(CREATURE_ONLY_PHASE)
	local t = spawnPlaces[tostring(pUnit:GetGUID())]
	pUnit:MoveTo(0, t[1], t[2], t[3])
	pUnit:RegisterEvent(SetVisibleNormalPhase, 20000, 1)
end

local function MoveOutOfCave(event, delay, repeats, pUnit)
	pUnit:MoveTo(0, -8680, -117, 90.77)
	pUnit:RegisterEvent(RespawnSoon, 6000, 1)
end

local function AdvanceQuestCredit(e, d, r, pUnit)
	local plr = pUnit:GetNearestPlayer(15)
	if plr then
		plr:QuestKillCredit(90016)
	end
end

local function QuestGossipCont(event, player, pUnit)
	if player:HasQuest(90001) then
		pUnit:SetNPCFlags(0)
		pUnit:RemoveEvents()
		pUnit:RemoveAura(39947)
		pUnit:SetStandState(0)
		local choice = math.random(1,5)
		local message
		if choice == 1 then
			message = "Thank you, " .. player:GetName() .. "."
		elseif choice == 2 then
			message = "Free, at last!"
		elseif choice == 3 then
			message = "I am... alive."
		elseif choice == 4 then
			message = "Light be praised!"
		elseif choice == 5 then
			message = "Darkness begone!"
		end
		pUnit:SendChatMessageDirectlyToPlayer(message, 12, 0, player, player)
		pUnit:RegisterEvent(MoveOutOfCave, 3000, 1)
		pUnit:RegisterEvent(AdvanceQuestCredit, 1000, 1)
	else
		local message
		local choice = math.random(1,3)
		if choice == 1 then
			message = "I can see... only darkness..."
		elseif choice == 2 then
			message = "Save me!"
		elseif choice == 3 then
			message = "Help... me..."
		end
		pUnit:SendChatMessageDirectlyToPlayer(message, 12, 0, player, player)
	end
end

RegisterCreatureGossipEvent(90016, 1, QuestGossipCont)

local function ShadowBoltSpam(e, d, r, pUnit)
	local plr = pUnit:GetAITarget(1)
	if plr then
		pUnit:CastSpell(plr, 90022)
	end
	pUnit:RegisterEvent(ShadowBoltSpam, 6000, 1)
end

local function NecromancerAI(event, pUnit, extra)
	if event == 1 then
		pUnit:RegisterEvent(ShadowBoltSpam, 1000, 1)
	else
		pUnit:RemoveEvents()
	end
end

RegisterCreatureEvent(90017, 1, NecromancerAI)
RegisterCreatureEvent(90017, 2, NecromancerAI)
RegisterCreatureEvent(90017, 4, NecromancerAI)
