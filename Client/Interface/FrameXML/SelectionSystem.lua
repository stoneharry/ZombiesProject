
local function OnClickedFrame(self, button)
	if not self.option then
		self:Hide()
		return
	end
	if self.selected then
		return
	end
	self.selected = true
	SendAddonMessage("SELECT", tostring(self.option), "WHISPER", UnitName("player"))
	ChainFrame(self:GetParent(), 0)
	PlaySoundFile("Interface\\FrameXML\\up.wav") 
end

local function OnEnterFrame(self, motion)
	GameTooltip:Hide()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	if (self.type == 1) then
		GameTooltip:SetHyperlink("spell:"..self.id)
	elseif (self.type == 2) then
		GameTooltip:SetHyperlink("item:"..self.id)
		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType,
			itemStackCount, itemEquipLoc, itemTexture, itemSellPrice =
			GetItemInfo(self.id)
		self:SetBackdrop({bgFile = itemTexture, 
			edgeFile = "", 
			tile = false, tileSize = 68, edgeSize = 16, 
			insets = { left = 4, right = 4, top = 4, bottom = 4 }});
	end
	GameTooltip:SetFrameLevel(5)
	GameTooltip:Show()
end

local function OnLeaveFrame(self, motion)
	GameTooltip:Hide()
end

function toggleSelectionFrame(data)
	local frame = CreateFrame("Frame", "SelectionFrame", UIParent)
	frame:SetWidth(400)
	frame:SetHeight(400)
	frame.texture = frame:CreateTexture()
	frame.texture:SetAllPoints(frame)
	frame.texture:SetTexture("Interface/FrameXML/selectionBLP")
	frame:SetFrameLevel(3)
	
	local pos = -12
	
	local level = tonumber(data[2])
	local position = 3
	
	for i=1,3 do
		local texture = CreateFrame("Button", "SelectionSlot"..tostring(i), frame, nil)
		texture:SetWidth(52)
		texture:SetHeight(52)
		texture:SetPoint("CENTER", frame, "CENTER", pos, -2)
		texture:SetFrameLevel(4)
		texture:SetScript("OnEnter", OnEnterFrame)
		texture:SetScript("OnLeave", OnLeaveFrame)
		texture:SetScript("OnClick", OnClickedFrame)
		
		local _type = tonumber(data[position])
		local ID = tonumber(data[position + 1])
		position = position + 2
		
		local name, icon, description
		
		if _type == 1 then -- spell
			name, _, icon, _, _, _ = GetSpellInfo(ID)
			description = ""--GetSpellDescription(ID)
		elseif _type == 2 then -- item
			local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType,
				itemStackCount, itemEquipLoc, itemTexture, itemSellPrice =
				GetItemInfo(ID)
			name = itemName
			icon = itemTexture
			description = itemLink
			texture.link = itemLink
		end
		
		texture.id = ID
		texture.type = _type
		texture.option = i
		
		texture:SetBackdrop({bgFile = icon, 
							edgeFile = "", 
							tile = false, tileSize = 68, edgeSize = 16, 
							insets = { left = 4, right = 4, top = 4, bottom = 4 }});
		
		pos = pos + 64
	end
	
	frame:SetPoint("BOTTOM", UIParent, "TOP", 0, 10);

	local chainLeft = CreateFrame("Frame", "ChainFrameLeft", frame)
	chainLeft:SetPoint("CENTER", frame, "CENTER", -130, 250)
	chainLeft:SetWidth(180)
	chainLeft:SetHeight(470)
	chainLeft:SetBackdrop({bgFile = "Interface/FrameXML/chain", 
					edgeFile = "", 
					tile = false, tileSize = 100, edgeSize = 16, 
					insets = { left = 4, right = 4, top = 4, bottom = 4 }});
	chainLeft:SetFrameLevel(3)
	
	local chainRight = CreateFrame("Frame", "ChainFrameRight", frame)
	chainRight:SetPoint("CENTER", frame, "CENTER", 130, 250)
	chainRight:SetWidth(180)
	chainRight:SetHeight(470)
	chainRight:SetBackdrop({bgFile = "Interface/FrameXML/chain", 
					edgeFile = "", 
					tile = false, tileSize = 100, edgeSize = 16, 
					insets = { left = 4, right = 4, top = 4, bottom = 4 }});
	chainRight:SetFrameLevel(3)
	
	frame:Show();
	ChainFrame(frame, -450)
	PlaySoundFile("Interface\\FrameXML\\down.wav")
end

local function Chain_OnUpdate(self, elapsed)
	if (self.chainPause) then
		return;
	end
	
	local rev = self.chainRev;
	local e = self.chainElapsed + elapsed;
	self.chainElapsed = e;
	
	local points = 3;
	local off = {self.chainY+20, -30, 10};
	local dur = {self.chainY/400, 0.2, 0.3};
	
	local tDur = 0;
	for i = 1, points do
		tDur = tDur + dur[i];
	end
	
	e = math.min(e, tDur);
	if (rev) then
		e = math.max(0, tDur - e);
	end
	
	local aDur = 0;
	local y = -10;
	
	if (e > 0) then
		for i = 1, points do
			if (e < aDur + dur[i]) then
				y = y + off[i] * ((e - aDur) / dur[i]);
				pause = false;
				break;
			else
				y = y + off[i];
			end
			aDur = aDur + dur[i];
		end
	end
	
	self:SetPoint("BOTTOMLEFT", UIParent, "TOPLEFT", self:GetLeft(), -y);
	
	if ((rev and e == 0) or (not rev and e == tDur)) then
		self.chainRev = not rev;
		self.chainPause = true;
		self.chainElapsed = 0;
	end
end

function ChainFrame(frame, y)
	y = tonumber(y);
	if (not frame or not y) then
		return;
	end
	
	if (frame.chainHas) then
		if (frame.chainPause) then
			frame.chainPause = false;
		end
		return;
	end
	
	frame.chainHas = true;
	frame.chainRev = false;
	frame.chainPause = false;
	frame.chainElapsed = 0;
	frame.chainY = math.abs(y) + 10;
	
	frame:SetPoint("BOTTOMLEFT", UIParent, "TOPLEFT", frame:GetLeft(), -10);
	frame:HookScript("OnUpdate", Chain_OnUpdate);
end
