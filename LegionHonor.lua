--Create the Frame
local Addon, events = CreateFrame("Frame", "LegionHonor", UIParent), {};
Addon:SetWidth(175);
Addon:SetHeight(100);
Addon:SetPoint("CENTER", UIParent, "CENTER");
Addon:SetMovable(true);
Addon:EnableMouse(true);
Addon:RegisterForDrag("LeftButton");
Addon:SetScript("OnDragStart", Addon.StartMoving);
Addon:SetScript("OnDragStop", Addon.StopMovingOrSizing);
Addon:SetClampedToScreen(true);
Addon.Title = Addon:CreateFontString("LegionHonor_Title", "OVERLAY", "GameFontNormal");
Addon.Title:SetPoint("TOP", 0, -2);
Addon.Title:SetText("Honor Display");
Addon:SetBackdrop({
    bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
    tile=false,
    tileSize=0,
    edgeSize=10,})
Addon:SetBackdropColor(0,0,0,.8)
Addon:SetBackdropBorderColor(1,1,1,1)

--Add the text
Addon.HonorLevelText = Addon:CreateFontString("LegionHonor_HonorLevelText", "OVERLAY", "GameFontNormal");
Addon.HonorLevelText:SetPoint("LEFT", 2, 28);
Addon.HonorLevelText:SetText("Honor Level");
Addon.HonorAmountText = Addon:CreateFontString("LegionHonor_HonorText", "OVERLAY", "GameFontNormal");
Addon.HonorAmountText:SetPoint("LEFT", 2, 8);
Addon.HonorAmountText:SetText("Current Honor");
Addon.HonorGoalText = Addon:CreateFontString("LegionHonor_HonorGoalText", "OVERLAY", "GameFontNormal");
Addon.HonorGoalText:SetPoint("LEFT", 2, -12);
Addon.HonorGoalText:SetText("Honor to Farm");
Addon.HonorPerHourText = Addon:CreateFontString("LegionHonor_HonorPerHourText", "OVERLAY", "GameFontNormal");
Addon.HonorPerHourText:SetPoint("LEFT", 2, -32);
Addon.HonorPerHourText:SetText("Honor per Hour");
Addon.PlayerHonorLevel = Addon:CreateFontString("LegionHonor_PlayerHonorLevel", "OVERLAY", "GameFontNormal");
Addon.PlayerHonorLevel:SetPoint("RIGHT", -2, 28);
Addon.PlayerHonorAmount = Addon:CreateFontString("LegionHonor_PlayerHonor", "OVERLAY", "GameFontNormal");
Addon.PlayerHonorAmount:SetPoint("RIGHT", -2, 8);
Addon.HonorGoalAmount = Addon:CreateFontString("LegionHonor_HonorGoalAmount", "OVERLAY", "GameFontNormal");
Addon.HonorGoalAmount:SetPoint("RIGHT", -2, -12);
Addon.HonorPerHourAmount = Addon:CreateFontString("LegionHonor_HonorPerHourAmount", "OVERLAY", "GameFontNormal");
Addon.HonorPerHourAmount:SetPoint("RIGHT", -2, -32);


--Create Function to round the decimals
local function mathround(number, precision)
  precision = precision or 0

  local decimal = string.find(tostring(number), ".", nil, true);
  
  if ( decimal ) then  
    local power = 10 ^ precision;
    
    if ( number >= 0 ) then 
      number = math.floor(number * power + 0.5) / power;
    else 
      number = math.ceil(number * power - 0.5) / power;    
    end
    
    -- convert number to string for formatting :M
    number = tostring(number);      
    
    -- set cutoff :M
    local cutoff = number:sub(decimal + 1 + precision);
      
    -- delete everything after the cutoff :M
    number = number:gsub(cutoff, "");
  else
    -- number is an integer :M
    if ( precision > 0 ) then
      number = tostring(number);
      
      number = number .. ".";
      
      for i = 1,precision
      do
        number = number .. "0";
      end
    end
  end    
  return number;
end

--Goal Variables Default
lhhonorgoal = 0

-- Goal Setting Function
local function UpdateGoal(self)
	Addon.HonorGoalAmount:SetText(lhhonorgoal)
end

local lhhonorgained = 0

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

local lhhonor, lhhonormax, lhhonorlevel;
		
--Function to pull honor amounts
local function UpdateHonor(self)
	--Pull Honor Amounts
	local lhhonorlevelmax, lhprestigemax;	
	lhhonor = UnitHonor("player");
	lhhonormax = UnitHonorMax("player")
	lhhonorlevel = UnitHonorLevel("player")	
	-- Set the outputs		
	self.PlayerHonorAmount:SetText(lhhonor .. "/" .. lhhonormax);	
	self.PlayerHonorLevel:SetText(lhhonorlevel);
	
		
end

--Function to update Honor Goal Progress
local function UpdateGoalProgress(self)
	
	local lhhonorold, lhhonornew, lhhonordiff, lhhonormaxold, lhhonorremain, lhhonorlevelnew;
	
	lhhonorlevelnew = UnitHonorLevel("player")
	
	if lhhonorlevelnew ~= lhhonorlevel then	
		lhhonorold = lhhonor
		lhhonormaxold = lhhonormax	
		lhhonorremain = lhhonormaxold - lhhonorold
		lhhonornew = UnitHonor("player")
		lhhonordiff = lhhonornew + lhhonorremain
		lhhonorgoal = lhhonorgoal - lhhonordiff
		lhhonorgained = lhhonorgained + lhhonordiff
		if lhhonorgoal >= 0 then
			Addon.HonorGoalAmount:SetText(lhhonorgoal)			
		else
			lhhonorgoal = 0
			Addon.HonorGoalAmount:SetText(lhhonorgoal)
		end
	else	
		lhhonorold = lhhonor
		lhhonornew = UnitHonor("player");
		lhhonordiff = lhhonornew - lhhonorold
		lhhonorgoal = lhhonorgoal - lhhonordiff	
		lhhonorgained = lhhonorgained + lhhonordiff
		if lhhonorgoal >= 0 then
			Addon.HonorGoalAmount:SetText(lhhonorgoal)
		else
			lhhonorgoal = 0
			Addon.HonorGoalAmount:SetText(lhhonorgoal)
		end		
	end
end

--Honor Per Hour 
local lhthrottle = 1
local lhcounter = 0
local lhtimer = 0

local function OnUpdate(self, elapsed)
	local lhhonorperhour	
	lhcounter = lhcounter + elapsed
	lhtimer = lhtimer + elapsed
	if lhcounter >= lhthrottle then
		lhcounter = 0
		lhhonorperhour = lhhonorgained / lhtimer * 3600
		lhhonorperhour = mathround(lhhonorperhour, 2)
		Addon.HonorPerHourAmount:SetText(lhhonorperhour)		
	end	
end

Addon:SetScript("OnUpdate", OnUpdate)

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
