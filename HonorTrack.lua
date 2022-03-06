--Create the Frame
local Addon, events = CreateFrame("Frame", "HonorTrack", UIParent, BackdropTemplateMixin and "BackdropTemplate"), {};
--Frame Size
Addon:SetWidth(175);
Addon:SetHeight(100);
--Frame Anchor Point
Addon:SetPoint("CENTER", UIParent, "CENTER");
--Allow it to be moved
Addon:SetMovable(true);
--Let the mouse interact
Addon:EnableMouse(true);
Addon:RegisterForDrag("LeftButton");
Addon:SetScript("OnDragStart", Addon.StartMoving);
Addon:SetScript("OnDragStop", Addon.StopMovingOrSizing);
--Don't let it be dragged off the screen
Addon:SetClampedToScreen(true);
--Create the title bar
Addon.Title = Addon:CreateFontString("HonorTrack_Title", "OVERLAY", "GameFontNormal");
Addon.Title:SetPoint("TOP", 0, -2);
Addon.Title:SetText("Honor Tracking");
--Create the border
Addon:SetBackdrop({
    bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
    tile=false,
    tileSize=0,
    edgeSize=10,})
--Add a background
Addon:SetBackdropColor(0,0,0,.8)
Addon:SetBackdropBorderColor(1,1,1,1)
--Add the text
--Add text labels for the lines
Addon.HonorLevelText = Addon:CreateFontString("HonorTrack_HonorLevelText", "OVERLAY", "GameFontNormal");
Addon.HonorLevelText:SetPoint("LEFT", 2, 28);
Addon.HonorLevelText:SetText("Honor Level");
Addon.HonorAmountText = Addon:CreateFontString("HonorTrack_HonorAmountText", "OVERLAY", "GameFontNormal");
Addon.HonorAmountText:SetPoint("LEFT", 2, 8);
Addon.HonorAmountText:SetText("Current Honor");
Addon.HonorGoalText = Addon:CreateFontString("HonorTrack_HonorGoalText", "OVERLAY", "GameFontNormal");
Addon.HonorGoalText:SetPoint("LEFT", 2, -12);
Addon.HonorGoalText:SetText("Honor to Farm");
Addon.HonorPerHourText = Addon:CreateFontString("HonorTrack_HonorPerHourText", "OVERLAY", "GameFontNormal");
Addon.HonorPerHourText:SetPoint("LEFT", 2, -32);
Addon.HonorPerHourText:SetText("Honor per Hour");
--Add the locations of the outputs so we can add them to the right spots easier later
Addon.PlayerHonorLevel = Addon:CreateFontString("HonorTrack_PlayerHonorLevel", "OVERLAY", "GameFontNormal");
Addon.PlayerHonorLevel:SetPoint("RIGHT", -2, 28);
Addon.PlayerHonorAmount = Addon:CreateFontString("HonorTrack_PlayerHonor", "OVERLAY", "GameFontNormal");
Addon.PlayerHonorAmount:SetPoint("RIGHT", -2, 8);
Addon.HonorGoalAmount = Addon:CreateFontString("HonorTrack_HonorGoalAmount", "OVERLAY", "GameFontNormal");
Addon.HonorGoalAmount:SetPoint("RIGHT", -2, -12);
Addon.HonorPerHourAmount = Addon:CreateFontString("HonorTrack_HonorPerHourAmount", "OVERLAY", "GameFontNormal");
Addon.HonorPerHourAmount:SetPoint("RIGHT", -2, -32);

--Create a dummy frame for update function
local hthiddenframe = CreateFrame("Frame")

--Pull the ldb library into here
local ldb = LibStub:GetLibrary("LibDataBroker-1.1")

--Add a dataobject for the databrokers
local dataobj = ldb:NewDataObject("HonorTrack", {type = "data source",
												 text = "Honor Track",
												 OnClick = function(clickedframe, button)
													if button == "LeftButton" then
														if Addon:IsShown() then
															Addon:Hide()
															htvisible = false
														else
															Addon:Show()
															htvisible = true
														end
													elseif button == "RightButton" then
													end
												end,
												})

--Create Function to round the decimals. This is copy/pasted code/comments.
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
    -- convert number to string for formatting 
    number = tostring(number);    
    -- set cutoff
    local cutoff = number:sub(decimal + 1 + precision);      
    -- delete everything after the cutoff
    number = number:gsub(cutoff, "");
  else
    -- number is an integer
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

--Defaulting variables
hthonorgoal = 0
htgoalset = false
htvisible = true

--function to set the visibitity state when logging in based on what the user had previously Set
local function SetState(self)
	if htvisible == true then
		Addon:Show()
	else
		Addon:Hide()
	end
end

-- Create a confirmation box if trying to set a goal when one is already set
StaticPopupDialogs["HONORTRACK"] = {
	text = "You currently have a goal set. Do you want to start a new goal?",
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self)
		hthonorgoal = hthonorgoalnew
		Addon.HonorGoalAmount:SetText(hthonorgoal)
		--Let the user know it worked and what we set the goal to.
		print("Honor Track: Honor Goal set to " .. hthonorgoal)
		htgoalset = true
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = false,
	}

-- Function to set the goal amount based on input from the slash command
local function UpdateNewGoal(self)
	--check if goal set
	if hthonorgoal ~= 0 then
		--Call confirmation box if one is already set
		StaticPopup_Show("HONORTRACK")
	else
		--Set goal if one is not already set
		hthonorgoal = hthonorgoalnew
		Addon.HonorGoalAmount:SetText(hthonorgoal)		
		print("Honor Track: Honor Goal set to " .. hthonorgoal)
		htgoalset = true
	end
end

--Function to set the text on login and when resetting goal
local function UpdateGoal(self)
	Addon.HonorGoalAmount:SetText(hthonorgoal)
end

--Create Slash Commands
--Define the slash commands
SLASH_HONORTRACK1, SLASH_HONORTRACK2 = '/honortrack', '/ht';
--Function to handle the context of the slash command arguements
function SlashCmdList.HONORTRACK(msg, editBox)
	--Capture the command and then the rest of whatever the user input then do things
	local command, rest = msg:match("^(%S*)%s*(.-)$");
	--Show the frame command check
	if string.lower(command) == 'show' then
		--Show it
		Addon:Show();
		--Set the visible variable to save between sessions
		htvisible = true
		--Let the user know it worked and how to hide it.
		print("Honor Track: Showing tracker. You can hide the tracker with /honortrack hide")
	--Hide the frame command check
	elseif string.lower(command) == 'hide' then
		--Hide it
		Addon:Hide();
		--set the variable
		htvisible = false
		--Let the user know it worked and how to show it.
		print("Honor Track: Hiding tracker. You can show the tracker again with /honortrack show")
	--Set the goal command check. This makes sure the user input only numbers and errors if they didn't
	elseif string.lower(command) == 'goal' and string.match(rest, "%d*") ~= nil and string.match(rest, "%a") == nil then
		--Grab the goal amount entered
		hthonorgoalnew = string.match(rest, "%d*")
		--Send the goal to the update function
		UpdateNewGoal(self)		
	--Reset the goal
	elseif string.lower(command) == 'goal' and string.lower(rest) == "reset" then
		--Set the goal to 0
		hthonorgoal = 0
		--Send that 0 to the frame update function
		UpdateGoal(self)
		htgoalset = false
		--Let the user know we reset the goal
		print("Honor Track: Honor Goal reset")
	--Reset the honor per hour tracker to zero
	elseif string.lower(command) == 'hprreset' then
		--set the honor per hour variable to 0
		hthonorgained = 0
		print("Honor Track: Your honor per hour statistic has been reset.")
	--Test slash function
	elseif string.lower(command) == 'test' and string.match(rest, "%d*") ~= nil and string.match(rest, "%a") == nil then
		hthonorgained = string.match(rest, "%d*")
		print("HonorTrack: Added honor to the functions for testing.")
	--User entered something that is not a valid command
	else
		--Let the user know what the proper slash command syntax is
		print("Honor Track: Available commands are show, hide, hprreset and goal")
		print("Honor Track: To set goal, use /honortrack goal ####")
		print("Honor Track: To reset goal, use /honortrack goal reset")
		print("Honor Track: To reset your honor per hour statistic, use /honortrack hprreset")
	end
end		

--Declare honor variables for multifunction use
local hthonor, hthonormax, hthonorlevel;
		
--Function to pull honor amounts
local function UpdateHonor(self)
	--Player's current honor amount in the current level
	hthonor = UnitHonor("player");
	--Total amount of Honor required to complete current honor level
	hthonormax = UnitHonorMax("player")
	--Player's current honor level
	hthonorlevel = UnitHonorLevel("player")	
	--Set the honor amounts in the frame
	self.PlayerHonorAmount:SetText(hthonor .. "/" .. hthonormax);	
	--Set the current honor level in the frame
	self.PlayerHonorLevel:SetText(hthonorlevel);		
end

--Function to update Honor Goal Progress
local function UpdateGoalProgress(self)
	--declare local function variables
	local hthonorold, hthonornew, hthonordiff, hthonormaxold, hthonorremain, hthonorlevelnew;
	--Grab the current honor level
	hthonorlevelnew = UnitHonorLevel("player")
	--Check if the honor level changed from what it was before, so we can accurately update the goal
	if hthonorlevelnew ~= hthonorlevel then	
		--Set the old honor amount to a new variable so we can grab the new amount so we can properly track progress
		hthonorold = hthonor
		--Set the old honor level required amount to a new variable also
		hthonormaxold = hthonormax
		--How much honor did we get in the previous honor level
		hthonorremain = hthonormaxold - hthonorold
		--How much honor did we get in the current honor level
		hthonornew = UnitHonor("player")
		--Add them together to total how much we actually recieved
		hthonordiff = hthonornew + hthonorremain
		--Update the goal with the correct amount of honor gained
		hthonorgoal = hthonorgoal - hthonordiff
		--Add the amount of honor we gained to the total amount of honor the user has gained to the variable outside the function for honor per hour tracking
		hthonorgained = hthonorgained + hthonordiff
		--Check goal progress
		if hthonorgoal > 0 then
			--Update the goal amount in the frame to current amount
			Addon.HonorGoalAmount:SetText(hthonorgoal)			
		else
			--Set the goal amount to 0 cause we reached the goal
			hthonorgoal = 0
			--Update the goal amount in the frame to 0
			Addon.HonorGoalAmount:SetText(hthonorgoal)
			--Let the user know they reached their goal
			if htgoalset == true then
				htgoalset = false
				print("Honor Track: Congratulations! You have reached your goal!")
			else
			end
		end
	else
		--Set the old honor amount to a new variable so we can grab the new amount so we can properly track progress
		hthonorold = hthonor
		--Grab the current amount of honor
		hthonornew = UnitHonor("player");
		--How much honor did we get
		hthonordiff = hthonornew - hthonorold
		--Update the progress of the goal
		hthonorgoal = hthonorgoal - hthonordiff	
		--Add the amount of honor gained to the variable outside the function for honor per hour tracking
		hthonorgained = hthonorgained + hthonordiff
		--Check goal progress
		if hthonorgoal > 0 then
			--Update the goal amount in the frame to the current progress
			Addon.HonorGoalAmount:SetText(hthonorgoal)
		else
			--Set the goal to 0 cause we reached it
			hthonorgoal = 0
			--Update the goal amount in the frame
			Addon.HonorGoalAmount:SetText(hthonorgoal)
			--Let the user know we reached the goal
			print("Honor Track: Congratulations! You have reached your goal!")
		end		
	end
end

--Set the time in seconds that we want to throttle down the screen updates to
local htthrottle = 1

--Honor per hour calculation function. This runs every screen update so we need to throttle the updates down to something slower so the output in the frame isn't updating visually at whatever the user's fps is
local function OnUpdate(self, elapsed)
	--count the screen refresh time for the throttle
	htcounter = htcounter + elapsed
	--time the refreshes so we can see how much time has passed for the per hour calculation
	httimer = httimer + elapsed
	--check to see that the amount of time that has passed is what we want to throttle the updates down to
	if htcounter >= htthrottle then
		--reset the counter
		htcounter = 0
		--Check to see if we have any honor gained to allow for accurate honor per hour calculations
		if hthonorgained == 0 then
			--set the timer to 0
			httimer = 0
			--set the hpr stat to 0
			hthonorperhour = 0
			--Update the amount in the frame
			Addon.HonorPerHourAmount:SetText(hthonorperhour)
			--Send the amount to the databrokers
			dataobj.text = string.format("%.2f Honor Per Hour", hthonorperhour)
		else
			--caculate the honor per hour
			hthonorperhour = hthonorgained / httimer * 3600
			--send the amount to the rounding function at 2 decimal places
			hthonorperhour = mathround(hthonorperhour, 2)
			--Update the amount in the frame
			Addon.HonorPerHourAmount:SetText(hthonorperhour)
			--Send the amount to the databrokers
			dataobj.text = string.format("%.2f Honor Per Hour", hthonorperhour)
		end
	end	
end

--[[Databroker click handler
function dataobj:OnClick()	
	if Addon:IsShown() then
		Addon:Hide()
		htvisible = false
	else
		Addon:Show()
		htvisible = true
	end	
end
]]
--Databroker tooltip creation
function dataobj:OnTooltipShow()
	self:AddLine("Honor Track")
	self:AddLine(" ")
	self:AddLine("Honor Level: " .. hthonorlevel)
	self:AddLine("Current Honor: " .. hthonor .. "/" .. hthonormax)
	self:AddLine("Honor to Farm: " .. hthonorgoal)
end

--Databroker mouseover handler
function dataobj:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
	GameTooltip:ClearLines()
	dataobj.OnTooltipShow(GameTooltip)
	GameTooltip:Show()
end

--Databroker mouseover leave handler
function dataobj:OnLeave()
	GameTooltip:Hide()
end

--Tell the client to run the honor per hour function on every refresh
hthiddenframe:SetScript("OnUpdate", OnUpdate)

--Tell the client that we want to run these functions when the player logs in
function events:PLAYER_ENTERING_WORLD(...)
	UpdateHonor(self)	
	UpdateGoal(self)
	SetState(self)	
end

--Tell the client that we want to run these functions when the player's honor amount updates
function events:HONOR_XP_UPDATE(...)
	UpdateGoalProgress(self)
	UpdateHonor(self)
end

--Check to see if we have data in the saved variables, if not set them to 0 on load for stuff to work
function events:ADDON_LOADED(...)
	if hthonorgained == nil then
		hthonorgained = 0
		Addon.HonorPerHourAmount:SetText(hthonorperhour)
		dataobj.text = string.format("%.2f Honor Per Hour", hthonorperhour)	
	end
	
	if htcounter == nil then
		htcounter = 0
	end
	
	if httimer == nil then
		httimer = 0
	end
end

--These functions register the addon's functions with the client events so it knows that we want to monitor for these events. This is copy/pasted code.
Addon:SetScript("OnEvent", function(self, event, ...)
 events[event](self, ...); 
end);

for k, v in pairs(events) do
 Addon:RegisterEvent(k);
end
