local Addon, events = CreateFrame("Frame", "LegionHonor", UIParent), {};
Addon:SetWidth(150);
Addon:SetHeight(200);
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
Addon.PrestigeLevelText = Addon:CreateFontString("LegionHonor_PrestigeText", "OVERLAY", "GameFontNormal");
Addon.PrestigeLevelText:SetPoint("LEFT", 0, 75);
Addon.PrestigeLevelText:SetText("Prestige Level");
Addon.HonorLevelText = Addon:CreateFontString("LegionHonor_HonorLevelText", "OVERLAY", "GameFontNormal");
Addon.HonorLevelText:SetPoint("LEFT", 0, 25);
Addon.HonorLevelText:SetText("Honor Level");
Addon.HonorAmountText = Addon:CreateFontString("LegionHonor_HonorText", "OVERLAY", "GameFontNormal");
Addon.HonorAmountText:SetPoint("LEFT", 0, -25);
Addon.HonorAmountText:SetText("Current Honor");
Addon.HonorNeededText = Addon:CreateFontString("LegionHonor_HonorNeeded", "OVERLAY", "GameFontNormal");
Addon.HonorNeededText:SetPoint("LEFT", 0, -75);
Addon.HonorNeededText:SetText("Honor to Level");


local lhprestige, lhhonor, lhhonormax, lhhonorlevel, lhhonorneeded;

function events:PLAYER_ENTERING_WORLD(...)
	Addon:Show()
	lhprestige = UnitPrestige("Player");
	lhhonor = UnitHonor("player");
	lhhonormax = UnitHonorMax("player")
	lhhonorlevel = UnitHonorLevel("player")
	lhhonorneeded = lhhonormax - lhhonor;
	Addon.PlayerPrestigeLevel = Addon:CreateFontString("LegionHonor_PlayerPrestigeLevel", "OVERLAY", "GameFontNormal");
	Addon.PlayerPrestigeLevel:SetPoint("RIGHT", 0, 75);
	Addon.PlayerPrestigeLevel:SetText(lhprestige);
	Addon.PlayerHonorAmount = Addon:CreateFontString("LegionHonor_PlayerHonor", "OVERLAY", "GameFontNormal");
	Addon.PlayerHonorAmount:SetPoint("RIGHT", 0, -25);
	Addon.PlayerHonorAmount:SetText(lhhonor);
	Addon.PlayerHonorLevel = Addon:CreateFontString("LegionHonor_PlayerHonorLevel", "OVERLAY", "GameFontNormal");
	Addon.PlayerHonorLevel:SetPoint("RIGHT", 0, 25);
	Addon.PlayerHonorLevel:SetText(lhhonorlevel);
	Addon.PlayerHonorNeeded = Addon:CreateFontString("LegionHonor_PlayerHonorNeeded", "OVERLAY", "GameFontNormal");
	Addon.PlayerHonorNeeded:SetPoint("RIGHT", 0, -75);
	Addon.PlayerHonorNeeded:SetText(lhhonorneeded);
end

function events:PLAYER_PVP_KILLS_CHANGED(...)
	lhprestige = UnitPrestige("Player");
	lhhonor = UnitHonor("player");
	lhhonormax = UnitHonorMax("player")
	lhhonorlevel = UnitHonorLevel("player")
	lhhonorneeded = lhhonormax - lhhonor;
	Addon:Hide();
	Addon:Show();
	Addon.PlayerPrestigeLevel = Addon:CreateFontString("LegionHonor_PlayerPrestigeLevel", "OVERLAY", "GameFontNormal");
	Addon.PlayerPrestigeLevel:SetPoint("RIGHT", 0, 75);
	Addon.PlayerPrestigeLevel:SetText(lhprestige);
	Addon.PlayerHonorAmount = Addon:CreateFontString("LegionHonor_PlayerHonor", "OVERLAY", "GameFontNormal");
	Addon.PlayerHonorAmount:SetPoint("RIGHT", 0, -25);
	Addon.PlayerHonorAmount:SetText(lhhonor);
	Addon.PlayerHonorLevel = Addon:CreateFontString("LegionHonor_PlayerHonorLevel", "OVERLAY", "GameFontNormal");
	Addon.PlayerHonorLevel:SetPoint("RIGHT", 0, 25);
	Addon.PlayerHonorLevel:SetText(lhhonorlevel);
	Addon.PlayerHonorNeeded = Addon:CreateFontString("LegionHonor_PlayerHonorNeeded", "OVERLAY", "GameFontNormal");
	Addon.PlayerHonorNeeded:SetPoint("RIGHT", 0, -75);
	Addon.PlayerHonorNeeded:SetText(lhhonorneeded);
end

Addon:SetScript("OnEvent", function(self, event, ...)
 events[event](self, ...); 
end);

for k, v in pairs(events) do
 Addon:RegisterEvent(k);
end



