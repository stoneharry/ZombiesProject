
local playerDistance = 80
local minPlayerScaling = 5
local healthMap = {}

function Creature:GetScaledDamage(damage)
	local p = self:GetPlayersInRange(playerDistance)
	if not p or #p < 5 then
		return damage * 3.5
	end
	return damage * (1 + (#p / 2))
end

--[[
function Creature:GetMaxScaledHealth()
	local hp = maxHealthMap[self:GetGUIDLow()]
	local p = self:GetPlayersInRange(playerDistance)
	if not p or #p < 5 then
		return hp * 5
	end
	return hp * (1 + (#p / 2))
end
]]

function Creature:UpdateScaledHealth()
	local scaling = self:GetData("currentScaling") or 1.0
	--self:SendUnitSay("Updating ----")
	--self:SendUnitSay("Scaling: " .. scaling)
	local maxHealth = self:GetMaxHealth() / scaling;
	local currentHealth = self:GetHealth() / scaling;
	local players = #(self:GetPlayersInRange(playerDistance, 0, 0) or {}); -- both friendly and hostile players, both dead and alive players
	--self:SendUnitSay("Player count: " .. tostring(players))
	scaling = math.max(minPlayerScaling, 1.0 + players / 2.0);
	--self:SendUnitSay("Scaling: " .. scaling)
	self:SetMaxHealth(maxHealth * scaling);
	self:SetHealth(currentHealth * scaling);
	--self:SendUnitSay("New scaling: " .. scaling)
	self:SetData("currentScaling", scaling);
end

function Creature:RegisterScalingHealth()
	if self then
		local guid = self:GetGUID()
		table.insert(healthMap, guid)
	end
end

local function ScaleCreatureHealths(_, _, _)
	for _,v in pairs(healthMap) do
		local pUnit = GetCreatureByGUID(v)
		if pUnit and pUnit:IsAlive() then
			pUnit:UpdateScaledHealth()
		end
	end
end

CreateLuaEvent(ScaleCreatureHealths, 5000, 0)

----- DEBUG

local function ScalingHealthRegister(event, pUnit)
	pUnit:RegisterScalingHealth()
end

RegisterCreatureEvent(2809, 5, ScalingHealthRegister)