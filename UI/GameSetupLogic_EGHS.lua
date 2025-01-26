--[[ =========================================================================
	Enhanced Goody Hut Setup (EGHS) for Civilization VI
    Copyright © 2020-2025 yofabronecoforo
    All rights reserved.

    Begin GameSetupLogic_EGHS.lua configuration script
=========================================================================== ]]
print("[+]: Loading GameSetupLogic_EGHS.lua UI script . . .");

--[[ =========================================================================
	NEW: this is a hack that prepopulates a picker's exclusion list with any items that are disabled-by-default
	this ensures the UI reflects these items when AS or HG context loads
	if the exclusion list is NOT nil, do nothing
=========================================================================== ]]
function SetPickerListToDefault( parameterId:string ) 
	local configurationId:string = DB.ConfigurationQuery(string.format("SELECT ConfigurationId FROM Parameters WHERE ParameterId = '%s' LIMIT 1", parameterId))[1].ConfigurationId;
	if (GameConfiguration.GetValue(configurationId) ~= nil) then 
		return;
	end
	local values:table = {};
	print(string.format("%s: Configuring %s with any items that are 'DISABLED' by default . . .", parameterId, configurationId));
	local bIsGoodyHutRewards:boolean = (parameterId == "GoodyHutRewards");
	local dbTable:string = bIsGoodyHutRewards and "TribalVillageRewards" or "TribalVillageTypes";
	local dbColumn:string = bIsGoodyHutRewards and "SubTypeGoodyHut" or "GoodyHut";
	local query:string = string.format("SELECT DISTINCT %s AS Value, DefaultWeight FROM %s", dbColumn, dbTable);
	local kResults:table = DB.ConfigurationQuery(query);
	if (kResults and #kResults > 0) then 
		for _, item in ipairs(kResults) do 
			local config:number = GameConfiguration.GetValue(item.Value);
			if config == nil then 
				GameConfiguration.SetValue(item.Value, -1);
			end
			if (item.DefaultWeight == 0) then 
				table.insert(values, item.Value);
			end
		end
	end
	print(string.format("%s: Configured %s with %d item%s that are 'DISABLED' by default", parameterId, configurationId, #values, (#values ~= 1) and "s" or ""));
	GameConfiguration.SetValue(configurationId, values);
	Network.BroadcastGameConfig();
end

--[[ =========================================================================
	NEW: does exactly what it says on the tin
=========================================================================== ]]
function LogGameStartProceed() 
	print("Proceeding with game start . . .");
	return nil;
end

--[[ =========================================================================
	NEW: does exactly what it says on the tin
=========================================================================== ]]
function DisableTribalVillages() 
	print("Setup option 'No Tribal Villages' will be enabled");
	GameConfiguration.SetValue("GAME_NO_GOODY_HUTS", true);
	return LogGameStartProceed();
end

--[[ =========================================================================
	NEW: performs a count of the contents of a parameter's exclusion list
	returns:
		-1, -1 when the exclusion list does not exist, or 
		0, 0 when the exclusion list exists but is empty, or
		the amount of excluded items and the amount of total items
=========================================================================== ]]
function ParsePickerSelections( parameterId:string, ruleset:string ) 
	local configurationId:string = DB.ConfigurationQuery(string.format("SELECT ConfigurationId FROM Parameters WHERE ParameterId = '%s' LIMIT 1", parameterId))[1].ConfigurationId;
	local disabled:table = GameConfiguration.GetValue(configurationId);
	if (disabled == nil) then 
		print(string.format("%s: %s is 'NOT' configured; strange things are afoot at the Circle K", parameterId, configurationId));
		return -1, -1;
	elseif (#disabled == 0) then 
		print(string.format("%s: %s contains '0' items", parameterId, configurationId));
		return 0, 0;
	end

	local domains:table = {};
	local domainsQuery:string = string.format("SELECT DISTINCT Key2 AS 'Ruleset', Domain FROM Parameters WHERE ParameterId = '%s'", parameterId);
	for _, v in ipairs(DB.ConfigurationQuery(domainsQuery)) do 
		domains[v.Ruleset] = v.Domain;
	end
	
	local bIsGoodyHutRewards:boolean = (parameterId == "GoodyHutRewards");
	local dbTable:string = bIsGoodyHutRewards and "TribalVillageRewards" or "TribalVillageTypes";
	local dbColumn:string = bIsGoodyHutRewards and "SubTypeGoodyHut" or "GoodyHut";
	local values:table = {};
	local valuesQuery:string = string.format("SELECT %s AS Value FROM %s WHERE Domain = '%s'", dbColumn, dbTable, domains[ruleset]);
	for _, v in ipairs(DB.ConfigurationQuery(valuesQuery)) do 
		values[(#values + 1)] = v.Value;
	end
	
	return #disabled, #values;
end

--[[ =========================================================================
	NEW: this makes any necessary last-minute configuration changes
	when 'No Tribal Villages' is enabled, no changes are made
	enables 'No Tribal Villages' when:
		(1) the goody hut frequency slider is set to 0%, or
		(2) all goody hut types for the selected ruleset are disabled, or 
		(3) all goody hut rewards for the selected ruleset are disabled
	logs pertinent info and any actions taken
=========================================================================== ]]
function BeforeHostGame() 
	if GameConfiguration.GetValue("GAME_NO_GOODY_HUTS") then 
		print("Setup option 'No Tribal Villages' is enabled");
		return LogGameStartProceed();
	end
	
	if GameConfiguration.GetValue("GOODYHUT_FREQUENCY") == 0 then 
		print("Tribal Village distribution is set to '0%%' of map baseline");
		return DisableTribalVillages();
	end
	
	local ruleset:string = GameConfiguration.GetValue("RULESET");
	for _, parameterId in ipairs({"GoodyHutTypes", "GoodyHutRewards"}) do 
		local numDisabled:number = 0;
		local numItems:number = 0;
		numDisabled, numItems = ParsePickerSelections(parameterId, ruleset);
		if (numDisabled > 0) then 
			print(string.format("%s: %d of %d total item%s will be 'DISABLED'", parameterId, numDisabled, numItems, (numItems ~= 1) and "s" or ""));
			if (numDisabled == numItems) then 
				return DisableTribalVillages();
			end
		end
	end

	return LogGameStartProceed();
end

--[[ =========================================================================
	OVERRIDE: pass arguments to pre-EGHS CreatePickerDriverByParameter() if parameter is not the Goody Hut picker
	otherwise create and return a driver for the Goody Hut picker
=========================================================================== ]]
Pre_EGHS_CreatePickerDriverByParameter = CreatePickerDriverByParameter;
function CreatePickerDriverByParameter(o, parameter, parent) 
	if parameter.ParameterId ~= "GoodyHutTypes" and parameter.ParameterId ~= "GoodyHutRewards" then 
		return Pre_EGHS_CreatePickerDriverByParameter(o, parameter, parent);
	end

	if(parent == nil) then
		parent = GetControlStack(parameter.GroupId);
	end
			
	-- Get the UI instance
	local c :object = g_ButtonParameterManager:GetInstance();	

	local parameterId = parameter.ParameterId;
	local button = c.Button;

	-- print(string.format("%s: Creating picker driver . . .", parameterId));
	
	button:RegisterCallback( Mouse.eLClick, function()
		LuaEvents.GoodyHutPicker_Initialize(o.Parameters[parameterId], g_GameParameters);
		Controls.GoodyHutPicker:SetHide(false);
	end);
	button:SetToolTipString(parameter.Description .. ECFE.Content.Tooltips[GameConfiguration.GetValue("RULESET")][parameterId]);    -- show content sources in tooltip text

	-- Store the root control, NOT the instance table.
	g_SortingMap[tostring(c.ButtonRoot)] = parameter;

	c.ButtonRoot:ChangeParent(parent);
	if c.StringName ~= nil then
		c.StringName:SetText(parameter.Name);
	end

	local cache = {};

	local kDriver :table = {
		Control = c,
		Cache = cache,
		UpdateValue = function(value, p) 
			local valueText = value and value.Name or nil;
			local valueAmount :number = 0;

			-- only amounts displayed by valueText change now so updates to it have been removed here; can this be further simplified?
			if(valueText == nil) then 
				if(value == nil) then 
					if (parameter.UxHint ~= nil and parameter.UxHint == "InvertSelection") then 
						valueAmount = #p.Values;    -- all available items
					end
				elseif(type(value) == "table") then 
					local count = #value;
					if (parameter.UxHint ~= nil and parameter.UxHint == "InvertSelection") then 
						if(count == 0) then 
							valueAmount = #p.Values;    -- all available items
						else 
							valueAmount = #p.Values - count;
						end
					else 
						if(count == #p.Values) then 
							valueAmount = #p.Values;    -- all available items
						else 
							valueAmount = count;
						end
					end
				end
			end

			-- update valueText here
			valueText = string.format("%s %d of %d", Locale.Lookup("LOC_PICKER_SELECTED_TEXT"), valueAmount, #p.Values);

			-- add update to tooltip text here
			if(cache.ValueText ~= valueText) or (cache.ValueAmount ~= valueAmount) then 
				local button = c.Button;
				button:LocalizeAndSetText(valueText);
				cache.ValueText = valueText;
				cache.ValueAmount = valueAmount;
				button:SetToolTipString(parameter.Description .. ECFE.Content.Tooltips[GameConfiguration.GetValue("RULESET")][parameterId]);    -- show content sources in tooltip text
			end
		end,
		UpdateValues = function(values, p) 
			-- Values are refreshed when the window is open.
		end,
		SetEnabled = function(enabled, p) 
			c.Button:SetDisabled(not enabled or #p.Values <= 1);
		end,
		SetVisible = function(visible) 
			c.ButtonRoot:SetHide(not visible);
		end,
		Destroy = function() 
			g_ButtonParameterManager:ReleaseInstance(c);
		end,
	};

	-- if this picker's exclusion list is nil, create it and populate it with any items that are disabled-by-default
	SetPickerListToDefault(parameterId);
	
	return kDriver;
end

--[[ =========================================================================
	OVERRIDE: pass arguments to pre-EGHS GameParameters_UI_DefaultCreateParameterDriver() if parameter is not the Goody Hut frequency slider
	otherwise create and return a control for the Goody Hut frequency slider
	2024/11/30: this was overthought to the point of stupidity
	all it needs to do is multiply the parameter text value by the per-step value
=========================================================================== ]]
Pre_EGHS_GameParameters_UI_DefaultCreateParameterDriver = GameParameters_UI_DefaultCreateParameterDriver;
function GameParameters_UI_DefaultCreateParameterDriver(o, parameter, parent) 
	if (parameter.ParameterId ~= "GoodyHutFrequency") then 
		return Pre_EGHS_GameParameters_UI_DefaultCreateParameterDriver(o, parameter, parent);
	end

	if (parent == nil) then 
		parent = GetControlStack(parameter.GroupId);
	end

	local control;
	
	-- If there is no parent, don't visualize the control.  This is most likely a player parameter.
	if (parent == nil) then 
		return;
	end;

	local minimumValue = parameter.Values.MinimumValue;
	local maximumValue = parameter.Values.MaximumValue;
	-- local perStepValue = 25;
	
	-- Get the UI instance
	local c = g_SliderParameterManager:GetInstance();	
	
	-- Store the root control, NOT the instance table.
	g_SortingMap[tostring(c.Root)] = parameter;
	
	c.Root:ChangeParent(parent);
	if c.StringName ~= nil then 
		c.StringName:SetText(parameter.Name);
	end
	
	c.OptionTitle:SetText(parameter.Name);
	c.Root:SetToolTipString(parameter.Description);
	c.OptionSlider:RegisterSliderCallback(function()
		local stepNum = c.OptionSlider:GetStep();
		-- local value = perStepValue * stepNum;
				
		-- This method can get called pretty frequently, try and throttle it.
		-- if(parameter.Value ~= perStepValue * stepNum) then
		-- 	o:SetParameterValue(parameter, value);
		-- 	BroadcastGameConfigChanges();
		-- end
		if(parameter.Value ~= minimumValue + stepNum) then
			o:SetParameterValue(parameter, minimumValue + stepNum);
			BroadcastGameConfigChanges();
		end
	end);

	control = {
		Control = c,
		UpdateValue = function(value)
			if (value) then 
				-- c.OptionSlider:SetStep(value / perStepValue);
				c.OptionSlider:SetStep(value - minimumValue);
				c.NumberDisplay:SetText(tostring(value * 25) .. "%");
			end
		end,
		UpdateValues = function(values)
			-- c.OptionSlider:SetNumSteps(values.MaximumValue / perStepValue);
			c.OptionSlider:SetNumSteps(values.MaximumValue - values.MinimumValue);
			minimumValue = values.MinimumValue;
			maximumValue = values.MaximumValue;
		end,
		SetEnabled = function(enabled, parameter)
			c.OptionSlider:SetHide(not enabled or parameter.Values == nil or parameter.Values.MinimumValue == parameter.Values.MaximumValue);
		end,
		SetVisible = function(visible, parameter)
			c.Root:SetHide(not visible or parameter.Value == nil );
		end,
		Destroy = function()
			g_SliderParameterManager:ReleaseInstance(c);
		end,
	};

	return control;
end

--[[ =========================================================================
	OVERRIDE: pass arguments to pre-EGHS CreateSimpleParameterDriver() if parameter is not the Goody Hut frequency slider
	otherwise create and return a control for the Goody Hut frequency slider
	2024/11/30: this was overthought to the point of stupidity
	all it needs to do is multiply the parameter text value by the per-step value
=========================================================================== ]]
Pre_EGHS_CreateSimpleParameterDriver = CreateSimpleParameterDriver;
function CreateSimpleParameterDriver(o, parameter, parent) 
	if (parameter.ParameterId ~= "GoodyHutFrequency") then 
		return Pre_EGHS_CreateSimpleParameterDriver(o, parameter, parent);
	end

	if (parent == nil) then 
		parent = GetControlStack(parameter.GroupId);
	end

	local control;
	
	-- If there is no parent, don't visualize the control.  This is most likely a player parameter.
	if (parent == nil) then 
		return;
	end;

	local minimumValue = parameter.Values.MinimumValue;
	local maximumValue = parameter.Values.MaximumValue;
	-- local perStepValue = 25;

	-- Get the UI instance
	local c = g_SimpleSliderParameterManager:GetInstance();	
		
	-- Store the root control, NOT the instance table.
	g_SortingMap[tostring(c.Root)] = parameter;
		
	c.Root:ChangeParent(parent);

	local name = Locale.ToUpper(parameter.Name);
	if c.StringName ~= nil then 
		c.StringName:SetText(name);
	end
			
	c.OptionTitle:SetText(name);
	c.Root:SetToolTipString(parameter.Description);

	c.OptionSlider:RegisterSliderCallback(function() 
		local stepNum = c.OptionSlider:GetStep();
		-- local value = minimumValue * stepNum;
			
		-- This method can get called pretty frequently, try and throttle it.
		-- if(parameter.Value ~= perStepValue * stepNum) then
		-- 	o:SetParameterValue(parameter, value);
		-- 	Network.BroadcastGameConfig();
		-- end
		if (parameter.Value ~= minimumValue + stepNum) then 
			o:SetParameterValue(parameter, minimumValue + stepNum);
			Network.BroadcastGameConfig();
		end
	end);

	control = {
		Control = c,
		UpdateValue = function(value)
			if (value) then 
				-- c.OptionSlider:SetStep(value / perStepValue);
				c.OptionSlider:SetStep(value - minimumValue);
				c.NumberDisplay:SetText(tostring(value * 25) .. "%");
			end
		end,
		UpdateValues = function(values)
			-- c.OptionSlider:SetNumSteps(values.MaximumValue / perStepValue);
			c.OptionSlider:SetNumSteps(values.MaximumValue - values.MinimumValue);
		end,
		SetEnabled = function(enabled, parameter)
			c.OptionSlider:SetHide(not enabled or parameter.Values == nil or parameter.Values.MinimumValue == parameter.Values.MaximumValue);
		end,
		SetVisible = function(visible, parameter)
			c.Root:SetHide(not visible or parameter.Value == nil );
		end,
		Destroy = function()
			g_SimpleSliderParameterManager:ReleaseInstance(c);
		end,
	};
	
	return control;
end

--[[ =========================================================================
	OVERRIDE: call pre-EGHS OnShutdown() and remove LuaEvent listeners for the Goody Hut picker
=========================================================================== ]]
Pre_EGHS_OnShutdown = OnShutdown;
function OnShutdown()
    Pre_EGHS_OnShutdown();
	LuaEvents.GoodyHutPicker_SetParameterValues.Remove(OnSetParameterValues);
	LuaEvents.GoodyHutPicker_SetParameterValue.Remove(OnSetParameterValue);
end

--[[ =========================================================================
	reset context pointers with modified functions
=========================================================================== ]]
ContextPtr:SetShutdown( OnShutdown );

--[[ =========================================================================
	add new LuaEvent listeners for the Goody Hut picker
=========================================================================== ]]
LuaEvents.GoodyHutPicker_SetParameterValues.Add(OnSetParameterValues);
LuaEvents.GoodyHutPicker_SetParameterValue.Add(OnSetParameterValue);

--[[ =========================================================================
	End GameSetupLogic_EGHS.lua configuration script
=========================================================================== ]]
