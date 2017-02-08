--Create the Frame
local Addon, events = CreateFrame("Frame", "LegionHonor", UIParent), {};
Addon:SetWidth(175);
Addon:SetHeight(150);
Addon:SetPoint("CENTER", UIParent, "CENTER");
Addon:SetMovable(true);
Addon:EnableMouse(true);
Addon:RegisterForDrag("LeftButton");
Addon:SetScript("OnDragStart", Addon.StartMoving);
Addon:SetScript("OnDragStop", Addon.StopMovingOrSizing);
Addon:SetClampedToScreen(true);
Addon.Title = Addon:CreateFontString("LegionHonor_Title", "OVERLAY", "GameFontNormal");
Addon.Title:SetPoint("TOP");
Addon.Title:SetText("Legion Honor");
local tex = Addon:CreateTexture(nil, "BACKGROUND")
tex:SetAllPoints()
tex:SetColorTexture(0, 0, 0, 0.5)

--Add the text
Addon.PrestigeLevelText = Addon:CreateFontString("LegionHonor_PrestigeText", "OVERLAY", "GameFontNormal");
Addon.PrestigeLevelText:SetPoint("LEFT", 0, 37.5);
Addon.PrestigeLevelText:SetText("Prestige Level");
Addon.HonorLevelText = Addon:CreateFontString("LegionHonor_HonorLevelText", "OVERLAY", "GameFontNormal");
Addon.HonorLevelText:SetPoint("LEFT", 0, 0);
Addon.HonorLevelText:SetText("Honor Level");
Addon.HonorAmountText = Addon:CreateFontString("LegionHonor_HonorText", "OVERLAY", "GameFontNormal");
Addon.HonorAmountText:SetPoint("LEFT", 0, -37.5);
Addon.HonorAmountText:SetText("Current Honor");
Addon.PlayerPrestigeLevel = Addon:CreateFontString("LegionHonor_PlayerPrestigeLevel", "OVERLAY", "GameFontNormal");
Addon.PlayerPrestigeLevel:SetPoint("RIGHT", 0, 37.5);
Addon.PlayerHonorAmount = Addon:CreateFontString("LegionHonor_PlayerHonor", "OVERLAY", "GameFontNormal");
Addon.PlayerHonorAmount:SetPoint("RIGHT", 0, -37.5);
Addon.PlayerHonorLevel = Addon:CreateFontString("LegionHonor_PlayerHonorLevel", "OVERLAY", "GameFontNormal");
Addon.PlayerHonorLevel:SetPoint("RIGHT", 0, 0);

--Function to pull honor amounts
local function UpdateHonor(self)

	--Pull Honor Amounts
	local lhprestige, lhhonor, lhhonormax, lhhonorlevel, lhhonorlevelmax, lhprestigemax;
	lhprestige = UnitPrestige("Player");
	lhhonor = UnitHonor("player");
	lhhonormax = UnitHonorMax("player")
	lhhonorlevel = UnitHonorLevel("player")
	lhhonorlevelmax = GetMaxPlayerHonorLevel();
	lhprestigemax = GetMaxPrestigeLevel();
	
	-- Set the outputs
	self.PlayerPrestigeLevel:SetText(lhprestige .. "/" .. lhprestigemax);	
	self.PlayerHonorAmount:SetText(lhhonor .. "/" .. lhhonormax);	
	self.PlayerHonorLevel:SetText(lhhonorlevel .. "/" .. lhhonorlevelmax );	
		
end

function events:PLAYER_ENTERING_WORLD(...)
	UpdateHonor(self)	
end

function events:HONOR_XP_UPDATE(...)
	UpdateHonor(self)
end

Addon:SetScript("OnEvent", function(self, event, ...)
 events[event](self, ...); 
end);

for k, v in pairs(events) do
 Addon:RegisterEvent(k);
end
