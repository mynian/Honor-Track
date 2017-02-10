--Create the Frame
local Addon, events = CreateFrame("Frame", "LegionHonor", UIParent), {};
Addon:SetWidth(175);
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

--Add the text
Addon.PrestigeLevelText = Addon:CreateFontString("LegionHonor_PrestigeText", "OVERLAY", "GameFontNormal");
Addon.PrestigeLevelText:SetPoint("LEFT", 0, 75);
Addon.PrestigeLevelText:SetText("Prestige Level");
Addon.HonorLevelText = Addon:CreateFontString("LegionHonor_HonorLevelText", "OVERLAY", "GameFontNormal");
Addon.HonorLevelText:SetPoint("LEFT", 0, 25);
Addon.HonorLevelText:SetText("Honor Level");
Addon.HonorAmountText = Addon:CreateFontString("LegionHonor_HonorText", "OVERLAY", "GameFontNormal");
Addon.HonorAmountText:SetPoint("LEFT", 0, -25);
Addon.HonorAmountText:SetText("Current Honor");
Addon.HonorGoalText = Addon:CreateFontString("LegionHonor_HonorGoalText", "OVERLAY", "GameFontNormal");
Addon.HonorGoalText:SetPoint("LEFT", 0, -75);
Addon.HonorGoalText:SetText("Honor Goal");
Addon.PlayerPrestigeLevel = Addon:CreateFontString("LegionHonor_PlayerPrestigeLevel", "OVERLAY", "GameFontNormal");
Addon.PlayerPrestigeLevel:SetPoint("RIGHT", 0, 75);
Addon.PlayerHonorLevel = Addon:CreateFontString("LegionHonor_PlayerHonorLevel", "OVERLAY", "GameFontNormal");
Addon.PlayerHonorLevel:SetPoint("RIGHT", 0, 25);
Addon.PlayerHonorAmount = Addon:CreateFontString("LegionHonor_PlayerHonor", "OVERLAY", "GameFontNormal");
Addon.PlayerHonorAmount:SetPoint("RIGHT", 0, -25);
Addon.HonorGoalAmount = Addon:CreateFontString("LegionHonor_HonorGoalAmount", "OVERLAY", "GameFontNormal");
Addon.HonorGoalAmount:SetPoint("RIGHT", 0, -75)


--Goal Variables Default
lhhonorgoal = 0
lhhonorgoalprog = 0

-- Goal Setting Function
local function UpdateGoal(self)
	Addon.HonorGoalAmount:SetText(lhhonorgoal)
end

--Create Slash Command 
SLASH_LEGIONHONOR1, SLASH_LEGIONHONOR2 = '/legionhonor', '/lghr';
function SlashCmdList.LEGIONHONOR(msg, editBox)
	local command, rest = msg:match("^(%S*)%s*(.-)$");
	if string.lower(command) == 'show' then
		Addon:Show();
	elseif string.lower(command) == 'hide' then
		Addon:Hide();		
	elseif string.lower(command) == 'goal' and string.match(rest, "%d*") ~= nil and string.match(rest, "%a") == nil then
		lhhonorgoal = string.match(rest, "%d*")
		UpdateGoal(self)
		print("Legion Honor: Honor Goal set to " .. string.match(rest, "%d*"))
	elseif string.lower(command) == 'goal' and string.lower(rest) == "reset" then
		lhhonorgoal = 0
		UpdateGoal(self)
		print("Legion Honor: Honor Goal reset")
	else 
		print("Legion Honor: Available commands are show, hide and goal")
		print("Legion Honor: To set goal, use /legionhonor goal ####")
		print("Legion Honor: To reset goal, use /legionhonor goal reset")
	end
end
		

--Declare honor variable for multifunction use

local lhhonor
		
--Function to pull honor amounts
local function UpdateHonor(self)

	--Pull Honor Amounts
	local lhprestige, lhhonormax, lhhonorlevel, lhhonorlevelmax, lhprestigemax;
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

--Function to update Honor Goal Progress
local function UpdateGoalProgress(self)

	local lhhonorold, lhhonornew, lhhonordiff;
	lhhonorold = lhhonor
	lhhonornew = UnitHonor("player");
	lhhonordiff = lhhonornew - lhhonorold
	lhhonorprogress = lhhonorprogress + lhhonordiff

end

function events:PLAYER_ENTERING_WORLD(...)
	UpdateHonor(self)
	UpdateGoal(self)
end

function events:HONOR_XP_UPDATE(...)
	UpdateGoalProgress(self)
	UpdateHonor(self)
end

Addon:SetScript("OnEvent", function(self, event, ...)
 events[event](self, ...); 
end);

for k, v in pairs(events) do
 Addon:RegisterEvent(k);
end
