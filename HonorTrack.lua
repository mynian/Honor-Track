--Create the Frame
local Addon, events = CreateFrame("Frame", "HonorTrack", UIParent, BackdropTemplateMixin and "BackdropTemplate"), {};
Addon:SetWidth(175);
Addon:SetHeight(100);
Addon:SetPoint("CENTER", UIParent, "CENTER");
Addon:SetMovable(true);
Addon:EnableMouse(true);
Addon:RegisterForDrag("LeftButton");
Addon:SetScript("OnDragStart", Addon.StartMoving);
Addon:SetScript("OnDragStop", Addon.StopMovingOrSizing);
Addon:SetClampedToScreen(true);
Addon.Title = Addon:CreateFontString("HonorTrack_Title", "OVERLAY", "GameFontNormal");
Addon.Title:SetPoint("TOP", 0, -2);
Addon.Title:SetText("Honor Tracking");
Addon:SetBackdrop({
    bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
    tile=false,
    tileSize=0,
    edgeSize=10,})
Addon:SetBackdropColor(0,0,0,.8)
Addon:SetBackdropBorderColor(1,1,1,1)

--Add the text
Addon.HonorLevelText = Addon:CreateFontString("HonorTrack_HonorLevelText", "OVERLAY", "GameFontNormal");
Addon.HonorLevelText:SetPoint("LEFT", 2, 28);
Addon.HonorLevelText:SetText("Honor Level");
Addon.HonorAmountText = Addon:CreateFontString("HonorTrack_HonorText", "OVERLAY", "GameFontNormal");
Addon.HonorAmountText:SetPoint("LEFT", 2, 8);
Addon.HonorAmountText:SetText("Current Honor");
Addon.HonorGoalText = Addon:CreateFontString("HonorTrack_HonorGoalText", "OVERLAY", "GameFontNormal");
Addon.HonorGoalText:SetPoint("LEFT", 2, -12);
Addon.HonorGoalText:SetText("Honor to Farm");
Addon.HonorPerHourText = Addon:CreateFontString("HonorTrack_HonorPerHourText", "OVERLAY", "GameFontNormal");
Addon.HonorPerHourText:SetPoint("LEFT", 2, -32);
Addon.HonorPerHourText:SetText("Honor per Hour");
Addon.PlayerHonorLevel = Addon:CreateFontString("HonorTrack_PlayerHonorLevel", "OVERLAY", "GameFontNormal");
Addon.PlayerHonorLevel:SetPoint("RIGHT", -2, 28);
Addon.PlayerHonorAmount = Addon:CreateFontString("HonorTrack_PlayerHonor", "OVERLAY", "GameFontNormal");
Addon.PlayerHonorAmount:SetPoint("RIGHT", -2, 8);
Addon.HonorGoalAmount = Addon:CreateFontString("HonorTrack_HonorGoalAmount", "OVERLAY", "GameFontNormal");
Addon.HonorGoalAmount:SetPoint("RIGHT", -2, -12);
Addon.HonorPerHourAmount = Addon:CreateFontString("HonorTrack_HonorPerHourAmount", "OVERLAY", "GameFontNormal");
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
hthonorgoal = 0

-- Goal Setting Function
local function UpdateGoal(self)
	Addon.HonorGoalAmount:SetText(hthonorgoal)
end

local hthonorgained = 0

--Create Slash Command 
SLASH_HONORTRACK1, SLASH_HONORTRACK2 = '/honortrack', '/ht';
function SlashCmdList.LEGIONHONOR(msg, editBox)
	local command, rest = msg:match("^(%S*)%s*(.-)$");
	if string.lower(command) == 'show' then
		Addon:Show();
	elseif string.lower(command) == 'hide' then
		Addon:Hide();		
	elseif string.lower(command) == 'goal' and string.match(rest, "%d*") ~= nil and string.match(rest, "%a") == nil then
		hthonorgoal = string.match(rest, "%d*")
		UpdateGoal(self)
		print("Honor Track: Honor Goal set to " .. string.match(rest, "%d*"))
	elseif string.lower(command) == 'goal' and string.lower(rest) == "reset" then
		hthonorgoal = 0
		UpdateGoal(self)
		print("Honor Track: Honor Goal reset")	
	else 
		print("Honor Track: Available commands are show, hide and goal")
		print("Honor Track: To set goal, use /legionhonor goal ####")
		print("Honor Track: To reset goal, use /legionhonor goal reset")
	end
end		

--Declare honor variable for multifunction use

local hthonor, hthonormax, hthonorlevel;
		
--Function to pull honor amounts
local function UpdateHonor(self)
	--Pull Honor Amounts
	local hthonorlevelmax;	
	hthonor = UnitHonor("player");
	hthonormax = UnitHonorMax("player")
	hthonorlevel = UnitHonorLevel("player")	
	-- Set the outputs		
	self.PlayerHonorAmount:SetText(hthonor .. "/" .. hthonormax);	
	self.PlayerHonorLevel:SetText(hthonorlevel);
	
		
end

--Function to update Honor Goal Progress
local function UpdateGoalProgress(self)
	
	local hthonorold, hthonornew, hthonordiff, hthonormaxold, hthonorremain, hthonorlevelnew;
	
	hthonorlevelnew = UnitHonorLevel("player")
	
	if hthonorlevelnew ~= lhhonorlevel then	
		hthonorold = hthonor
		hthonormaxold = hthonormax	
		hthonorremain = hthonormaxold - hthonorold
		hthonornew = UnitHonor("player")
		hthonordiff = hthonornew + hthonorremain
		hthonorgoal = hthonorgoal - hthonordiff
		hthonorgained = hthonorgained + hthonordiff
		if hthonorgoal >= 0 then
			Addon.HonorGoalAmount:SetText(hthonorgoal)			
		else
			hthonorgoal = 0
			Addon.HonorGoalAmount:SetText(hthonorgoal)
		end
	else	
		hthonorold = hthonor
		hthonornew = UnitHonor("player");
		hthonordiff = hthonornew - hthonorold
		hthonorgoal = hthonorgoal - hthonordiff	
		hthonorgained = hthonorgained + hthonordiff
		if hthonorgoal >= 0 then
			Addon.HonorGoalAmount:SetText(hthonorgoal)
		else
			hthonorgoal = 0
			Addon.HonorGoalAmount:SetText(hthonorgoal)
		end		
	end
end

--Honor Per Hour 
local htthrottle = 1
local htcounter = 0
local httimer = 0

local function OnUpdate(self, elapsed)
	local hthonorperhour	
	htcounter = htcounter + elapsed
	httimer = httimer + elapsed
	if htcounter >= htthrottle then
		htcounter = 0
		hthonorperhour = hthonorgained / httimer * 3600
		hthonorperhour = mathround(hthonorperhour, 2)
		Addon.HonorPerHourAmount:SetText(hthonorperhour)		
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
