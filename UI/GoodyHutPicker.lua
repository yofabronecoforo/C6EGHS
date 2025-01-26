--[[ =========================================================================
	Enhanced Goody Hut Setup (EGHS) for Civilization VI
    Copyright © 2020-2025 yofabronecoforo
    All rights reserved.

    Begin GoodyHutPicker.lua frontend script
	This started life as the official CityStatePicker.lua
	It has since seen extensive modifications
=========================================================================== ]]
ECFE = ExposedMembers;

include("InstanceManager");
include("PlayerSetupLogic");
include("Civ6Common");

print(string.format("Enhanced Goody Hut Setup (EGHS) v%s: Loading GoodyHutPicker.lua . . .", ECFE.Content.EGHS and ECFE.Content.EGHS.Version or "0"));

--[[ =========================================================================
	Members
=========================================================================== ]]
local m_pItemIM:table = InstanceManager:new("ItemInstance",	"Button", Controls.ItemsPanel);

local m_kParameter:table = nil;			-- Reference to the parameter being used
local m_kSelectedValues:table = nil;	-- Table of string --> number that represents selected Weight values
local m_kItemList:table = nil;			-- Table of controls for select default/disabled for all items

local m_bIsGoodyHutTypes:boolean = false;
local m_bIsGoodyHutRewards:boolean = false;

local m_GlobalConfig:number = -1;

local m_kGoodyHutDataCache:table = {};
local m_kDomainsByRuleset:table = {};
local m_kSortEntryTags:table = {};
local m_kWeights:table = {};
local m_numWeights:number = 0;

local m_kGoodyHutFrequencyParam:table = nil;

local m_ParameterId:string = nil;
local m_RulesetType:string = nil;

-- Track the frequency of goody huts to spawn when opening the picker
-- Used to revert to that frequency when the user modifies the parameter then backs out of the picker
local m_OriginalGoodyHutFrequency:number = 0;

-- Track the ConfigurationValue of each item when opening the picker
-- Used to revert items to those values when the user backs out of the picker
local m_kOriginalSelectedValues:table = {};

--[[ =========================================================================
	Clears any temporary global variables
	Hides the picker window
=========================================================================== ]]
function Close() 
	m_kParameter = nil;
	m_kSelectedValues = nil;

	ContextPtr:SetHide(true);
end

--[[ =========================================================================
	Reverts selections to their values when the picker was opened
	Calls Close()
	Resets the value of the frequency slider
=========================================================================== ]]
function OnBackButton() 
	local numReversions:number = 0;
	for i, v in ipairs(m_kParameter.Values) do 
		local item:string = v.Value;
		local current:number = m_kSelectedValues[item];
		local original:number = m_kOriginalSelectedValues[item]
		if current and original and (current ~= original) then 
			GameConfiguration.SetValue(item, original);
			numReversions = numReversions + 1;
		end
	end
	if (numReversions > 0) then 
		print(string.format("%s: Reverting %d selection%s", m_ParameterId, numReversions, (numReversions ~= 1) and "s" or ""));
	end
	Close();
	LuaEvents.GoodyHutPicker_SetParameterValue(m_kGoodyHutFrequencyParam.ParameterId, m_OriginalGoodyHutFrequency);
end

--[[ =========================================================================
	Does exactly what it says on the tin
=========================================================================== ]]
function LogSelections( t:table, bIndent:boolean ) 
	local indent:string = bIndent and "    " or "";
	for i = 1, (m_numWeights - 2) do 
		if (t[i] > 0) then 
			local tier:string = m_kWeights[i].Name;
			print(string.format("%s%d %s", indent, t[i], tier));
		end
	end
	if (t[0] > 0) then 
		print(string.format("%s%d 'DISABLED'", indent, t[0]));
	end
end

--[[ =========================================================================
	Configures the parameter's exclusion list with any disabled items
		This includes items that are disabled-by-default
		Such items will be reflected as "not selected" in the button's UI
	Logs amount of selections of each Weight
	Resets the parameter's exclusion list to the current values
	Calls Close()
=========================================================================== ]]
function OnConfirmChanges() 
	local selections:table         = {};
	local defaultSelections:table  = {};
	local values:table             = {};

	for i = -1, (m_numWeights - 2) do selections[i] = 0; end
	for i = 0, (m_numWeights - 2) do defaultSelections[i] = 0; end

	for k, v in pairs(m_kSelectedValues) do 
		selections[v] = selections[v] + 1;
		if (v == -1) then 
			local defaultWeight:number = GetGoodyHutData(k).DefaultWeight;
			local uiConfig:number = GetUIConfigurationValue(v, defaultWeight);
			defaultSelections[uiConfig] = defaultSelections[uiConfig] + 1;
			if (uiConfig == 0) then table.insert(values, k); end
		elseif (v == 0) then 
			table.insert(values, k);
		end
	end

	print(string.format("%s: Confirming %d selection%s:", m_ParameterId, #m_kItemList, (#m_kItemList ~= 1) and "s" or ""));
	
	if (selections[-1] > 0) then 
		print(string.format("%d Default:", selections[-1]));
		LogSelections(defaultSelections, true);
	end

	LogSelections(selections, false);

	LuaEvents.GoodyHutPicker_SetParameterValues(m_ParameterId, values);
	Close();
end

--[[ =========================================================================
	Changes the contents of the info panel when a new item gains focus
=========================================================================== ]]
function OnItemFocus( kItem:table ) 
	if (kItem) then 
		Controls.FocusedItemName:SetText(kItem.Name);

		local kItemData:table = GetGoodyHutData(kItem.Value);
		local defWeight:string = Locale.Lookup("LOC_EGHS_DEFAULT_WEIGHT", kItemData.DefaultWeight or 0);
		local uiConfig:number = GetUIConfigurationValue(-1, kItemData.DefaultWeight);
		local tier:string = m_kWeights[uiConfig].Name;
		if uiConfig == 0 then 
			tier = string.format("[COLOR_Red]%s[ENDCOLOR]", tier);
		end
		defWeight = string.format("%s (%s)", defWeight, tier);
		local notice:string = kItemData.Notice or "";
		local description:string = Locale.Lookup(kItem.RawDescription);
		
		if m_bIsGoodyHutRewards then 
			local hut:string = Locale.Lookup("LOC_EGHS_GOODYHUT_TYPE", Locale.Lookup(string.format("LOC_EGHS_%s_NAME", kItemData.GoodyHut)));
			local minTurn:number = (kItemData.Turn > 0) and kItemData.Turn or 1;
			local turn:string = Locale.Lookup("LOC_EGHS_MINIMUM_TURN",  minTurn);
			local minOneCity:string = Locale.Lookup("LOC_EGHS_ONE_CITY", kItemData.MinOneCity and "Yes" or "No");
			local requiresUnit:string = Locale.Lookup("LOC_EGHS_REQUIRES_UNIT", kItemData.RequiresUnit and "Yes" or "No");
			description = Locale.Lookup("LOC_EGHS_PICKER_REWARD", hut, defWeight, description, turn, minOneCity, requiresUnit, notice);
		elseif m_bIsGoodyHutTypes then 
			local xp1:string = kItemData.ChangesXP1 or "";
			local xp2:string = kItemData.ChangesXP2 or "";
			local numRewards:string = Locale.Lookup("LOC_EGHS_NUM_REWARDS", kItemData.NumRewards or 0);
			description = Locale.Lookup("LOC_EGHS_PICKER_TYPE", description, xp1, xp2, defWeight, numRewards, notice);
		end

		Controls.FocusedItemDescription:LocalizeAndSetText(description);

		if ((kItem.Icon and Controls.FocusedItemIcon:SetIcon(kItem.Icon)) or Controls.FocusedItemIcon:SetIcon("ICON_" .. kItem.Value)) then 
			Controls.FocusedItemIcon:SetHide(false);
		else 
			Controls.FocusedItemIcon:SetHide(true);
		end

		if ((kItemData.IconFG and Controls.FocusedItemIconFG:SetIcon(kItemData.IconFG)) or Controls.FocusedItemIconFG:SetIcon("ICON_IMPROVEMENT_GOODY_HUT")) then 
			Controls.FocusedItemIconFG:SetHide(false);
		else 
			Controls.FocusedItemIconFG:SetHide(true);
		end
	end
end

--[[ =========================================================================
	Creates the goody hut type/reward item cache
		Items are cached by ruleset
			This allows the UI to reflect ruleset-based differences in the items
		Initializes a GameConfiguration object for each item if one does not already exist
			Otherwise updates the item's cached Weight value based on the value of this object
	Returns a table containing the cached data
=========================================================================== ]]
function GetGoodyHutData( item:string ) 
	if m_kGoodyHutDataCache[m_RulesetType][item] == nil then

		m_kGoodyHutDataCache[m_RulesetType][item] = {};

		local domain:string = m_kDomainsByRuleset[m_RulesetType];
		local dbTable:string = m_bIsGoodyHutRewards and "TribalVillageRewards WHERE SubTypeGoodyHut =" or "TribalVillageTypes WHERE GoodyHut =";
		local query:string = string.format("SELECT * FROM %s '%s' AND Domain = '%s' LIMIT 1", dbTable, item, domain);
		local kResults:table = DB.ConfigurationQuery(query);
		if (kResults) then 
			for i, v in ipairs(kResults) do 
				for name, value in pairs(v) do 
					m_kGoodyHutDataCache[m_RulesetType][item][name] = value;
				end
			end
		end

		local config:number = GameConfiguration.GetValue(item);
		if config == nil then 
			GameConfiguration.SetValue(item, -1);
		elseif config == -1 then 
			m_kGoodyHutDataCache[m_RulesetType][item].Weight = m_kGoodyHutDataCache[m_RulesetType][item].DefaultWeight;
		else 
			m_kGoodyHutDataCache[m_RulesetType][item].Weight = m_kWeights[config].Weight;
		end
	end
	return m_kGoodyHutDataCache[m_RulesetType][item];
end

--[[ =========================================================================
	(Re)sets all items' GameConfiguration object values
	(Re)sets all items' Weight pulldowns
	Logs this action
=========================================================================== ]]
function SetAllItems( config: number ) 
	local tier:string = m_kWeights[config].Name;
	tier = (config == 0) and string.format("'%s'", tier) or tier;
	for _, node in ipairs(m_kItemList) do 
		local item:string = node["item"].Value;
		local pulldown:table = node["pulldown"];
		GameConfiguration.SetValue(item, config);
		pulldown:GetButton():SetText(UpdateUISelectedWeight(item));
		pulldown:GetButton():SetToolTipString(UpdateUISelectedWeight(item, true));
	end
	print(string.format("%s: Setting %d item%s to %s (ConfigurationValue %d)", m_ParameterId, #m_kItemList, (#m_kItemList ~= 1) and "s" or "", tier, config));
end

--[[ =========================================================================
	Calls SetAllItems() to (re)set all items
=========================================================================== ]]
function OnSelectAll( config:number ) 
	SetAllItems(config);
end

--[[ =========================================================================
	Calls SetAllItems() to (re)set all items to disabled
=========================================================================== ]]
function OnSelectNone() 
	SetAllItems(0);
end

--[[ =========================================================================
	Initializes the item selection panel
	Initializes controls for each
		Stores the current value of each item's GameConfiguration object
	Initializes the in-picker frequency slider
	Initializes the sort-by filter
	Resets the focused item panel
=========================================================================== ]]
function ParameterInitialize( parameter:table, pGameParameters:table ) 
	m_kParameter = parameter;
	m_ParameterId = m_kParameter.ParameterId;

	m_bIsGoodyHutTypes = (m_ParameterId == "GoodyHutTypes");
	m_bIsGoodyHutRewards = (m_ParameterId == "GoodyHutRewards");

	m_kSelectedValues = {};
	m_kWeights = {};
	m_numWeights = 0;
	
	local kRulesetParam = pGameParameters.Parameters["Ruleset"];
	m_RulesetType = kRulesetParam.Value.Value;

	local domainQuery:string = string.format("SELECT DISTINCT Key2 AS 'Ruleset', Domain FROM Parameters WHERE ParameterId = '%s'", m_ParameterId);
	for _, v in ipairs(DB.ConfigurationQuery(domainQuery)) do 
		m_kDomainsByRuleset[v.Ruleset] = v.Domain;
	end

	local weightQuery:string = string.format("SELECT * FROM %s", m_bIsGoodyHutTypes and "EGHS_TypeWeights" or "EGHS_RewardWeights");
	for _, v in ipairs(DB.ConfigurationQuery(weightQuery)) do 
		m_kWeights[v.Tier] = { Name = Locale.Lookup(v.Name), Description = Locale.Lookup(v.Description), Weight = v.Weight };
		m_numWeights = m_numWeights + 1;
	end

	for _, v in ipairs(DB.ConfigurationQuery("SELECT * FROM EGHS_SortPulldownTags")) do 
		m_kSortEntryTags[v.Name] = Locale.Lookup(v.Description);
	end

	m_kGoodyHutDataCache[m_RulesetType] = {};
	
	m_kGoodyHutFrequencyParam = pGameParameters.Parameters["GoodyHutFrequency"];
	m_OriginalGoodyHutFrequency = m_kGoodyHutFrequencyParam.Value;

	m_kOriginalSelectedValues = {};

	m_GlobalConfig = -1;

	local uiButton:object = Controls.ResetAllPulldown:GetButton();
	uiButton:SetText(Locale.Lookup("LOC_WEIGHT_DEFAULT_NAME"));
	uiButton:SetToolTipString(Locale.Lookup("LOC_WEIGHT_DEFAULT_DESCRIPTION"));

	Controls.ResetAllPulldown:ClearEntries();

	local pDefaultEntryInst:object = GetGlobalWeightEntryInstance(uiButton, -1);
	
	if m_bIsGoodyHutTypes then 
		local pQuadrupleEntryInst:object = GetGlobalWeightEntryInstance(uiButton, 1);
		local pDoubleEntryInst:object = GetGlobalWeightEntryInstance(uiButton, 2);
		local pNormalEntryInst:object = GetGlobalWeightEntryInstance(uiButton, 3);
		local pHalfEntryInst:object = GetGlobalWeightEntryInstance(uiButton, 4);
		local pQuarterEntryInst:object = GetGlobalWeightEntryInstance(uiButton, 5);
	elseif m_bIsGoodyHutRewards then 
		local pUbiquitousEntryInst:object = GetGlobalWeightEntryInstance(uiButton, 1);
		local pCommonEntryInst:object = GetGlobalWeightEntryInstance(uiButton, 2);
		local pUncommonEntryInst:object = GetGlobalWeightEntryInstance(uiButton, 3);
		local pRareEntryInst:object = GetGlobalWeightEntryInstance(uiButton, 4);
		local pLegendaryEntryInst:object = GetGlobalWeightEntryInstance(uiButton, 5);
		local pMythicEntryInst:object = GetGlobalWeightEntryInstance(uiButton, 6);
	else 
	end

	local pDisabledEntryInst:object = GetGlobalWeightEntryInstance(uiButton, 0);
	
	Controls.ResetAllPulldown:CalculateInternals();

	Controls.ResetAllButton:RegisterCallback( Mouse.eLClick, function() 
		SetAllItems(m_GlobalConfig);
	end );

	Controls.TopDescription:SetText(parameter.Description);
	Controls.WindowTitle:SetText(parameter.Name);
	m_pItemIM:ResetInstances();

	m_kItemList = {};
	for i, v in ipairs(parameter.Values) do 
		m_kOriginalSelectedValues[v.Value] = GameConfiguration.GetValue(v.Value);
		InitializeItem(v);
	end

	RefreshList();

	InitGoodyHutFrequencySlider(pGameParameters);
	InitSortByFilter();

	OnItemFocus(parameter.Values[1]);
end

--[[ =========================================================================
	Rebuilds and updates UI after sorting operation
	Always sort by Name (A to Z) first
		This should ensure consistent appearance of items in the picker
=========================================================================== ]]
function RefreshList( sortByFunc ) 
	m_kItemList = {};

	if sortByFunc ~= nil and sortByFunc ~= SortByNameAZ then 
		table.sort(m_kParameter.Values, SortByNameAZ);
	end

	table.sort(m_kParameter.Values, sortByFunc ~= nil and sortByFunc or SortByNameAZ);

	m_pItemIM:ResetInstances();
	for i, v in ipairs(m_kParameter.Values) do 
		InitializeItem(v);
	end
end

--[[ =========================================================================
	Sorts items by Name in ascending alphabetical order	
=========================================================================== ]]
function SortByNameAZ( kItemA:table, kItemB:table ) 
	return Locale.Compare(kItemA.Name, kItemB.Name) == -1;
end

--[[ =========================================================================
	Sorts items by Name in descending alphabetical order
=========================================================================== ]]
function SortByNameZA( kItemA:table, kItemB:table ) 
	return Locale.Compare(kItemB.Name, kItemA.Name) == -1;
end

--[[ =========================================================================
	Sorts items by currently selected Weight value from lowest to highest
	Items will be displayed in descending order of rarity
	Disabled items will be filtered to the top of the list
=========================================================================== ]]
function SortBySelectedWeightLH( kItemA:table, kItemB:table ) 
	local kItemDataA:table = GetGoodyHutData(kItemA.Value);
	local kItemDataB:table = GetGoodyHutData(kItemB.Value);

	if kItemDataA.Weight ~= nil and kItemDataB.Weight ~= nil then 
		return (kItemDataA.Weight < kItemDataB.Weight);
	else 
		return false;
	end
end

--[[ =========================================================================
	Sorts items by currently selected Weight value from highest to lowest
	Items will be displayed in ascending order of rarity
	Disabled items will be filtered to the bottom of the list
=========================================================================== ]]
function SortBySelectedWeightHL( kItemA:table, kItemB:table ) 
	local kItemDataA:table = GetGoodyHutData(kItemA.Value);
	local kItemDataB:table = GetGoodyHutData(kItemB.Value);

	if kItemDataA.Weight ~= nil and kItemDataB.Weight ~= nil then 
		return (kItemDataA.Weight > kItemDataB.Weight);
	else 
		return false;
	end
end

--[[ =========================================================================
	Sorts items by Type in ascending alphabetical order
	This groups reward items by their parent type
	Applies to GoodyHutRewards parameter
=========================================================================== ]]
function SortByTypeAZ( kItemA:table, kItemB:table ) 
	local kItemDataA:table = GetGoodyHutData(kItemA.Value);
	local kItemDataB:table = GetGoodyHutData(kItemB.Value);

	if kItemDataA.GoodyHut ~= nil and kItemDataB.GoodyHut ~= nil then 
		local hutA:string = Locale.Lookup(string.format("LOC_EGHS_%s_NAME", kItemDataA.GoodyHut));
		local hutB:string = Locale.Lookup(string.format("LOC_EGHS_%s_NAME", kItemDataB.GoodyHut));
		return Locale.Compare(hutA, hutB) == -1;
	else
		return false;
	end
end

--[[ =========================================================================
	Sorts items by Type in descending alphabetical order
	This groups reward items by their parent type
	Applies to GoodyHutRewards parameter
=========================================================================== ]]
function SortByTypeZA( kItemA:table, kItemB:table ) 
	local kItemDataA:table = GetGoodyHutData(kItemA.Value);
	local kItemDataB:table = GetGoodyHutData(kItemB.Value);

	if kItemDataA.GoodyHut ~= nil and kItemDataB.GoodyHut ~= nil then
		local hutA:string = Locale.Lookup(string.format("LOC_EGHS_%s_NAME", kItemDataA.GoodyHut));
		local hutB:string = Locale.Lookup(string.format("LOC_EGHS_%s_NAME", kItemDataB.GoodyHut));
		return Locale.Compare(hutB, hutA) == -1;
	else
		return false;
	end
end

--[[ =========================================================================
	Sorts items by default Weight value from lowest to highest
	Items will be displayed in descending order of rarity
	Disabled items will be filtered to the top of the list
=========================================================================== ]]
function SortByDefaultWeightLH( kItemA:table, kItemB:table ) 
	local kItemDataA:table = GetGoodyHutData(kItemA.Value);
	local kItemDataB:table = GetGoodyHutData(kItemB.Value);

	if kItemDataA.DefaultWeight ~= nil and kItemDataB.DefaultWeight ~= nil then 
		return (kItemDataA.DefaultWeight < kItemDataB.DefaultWeight);
	else 
		return false;
	end
end

--[[ =========================================================================
	Sorts items by default Weight value from highest to lowest
	Items will be displayed in ascending order of rarity
	Disabled items will be filtered to the bottom of the list
=========================================================================== ]]
function SortByDefaultWeightHL( kItemA:table, kItemB:table ) 
	local kItemDataA:table = GetGoodyHutData(kItemA.Value);
	local kItemDataB:table = GetGoodyHutData(kItemB.Value);

	if kItemDataA.DefaultWeight ~= nil and kItemDataB.DefaultWeight ~= nil then 
		return (kItemDataA.DefaultWeight > kItemDataB.DefaultWeight);
	else 
		return false;
	end
end

--[[ =========================================================================
	Initializes the in-picker frequency slider
	2024/11/30:
		This was overthought to the point of stupidity
		All it needs to do differently is update the parameter UI text value
		This should be the current slider value multiplied by the per-step value
=========================================================================== ]]
function InitGoodyHutFrequencySlider( pGameParameters:table ) 
	local kValues:table = m_kGoodyHutFrequencyParam.Values;

	Controls.GoodyHutFrequencyNumber:SetText(tostring(m_kGoodyHutFrequencyParam.Value * 25) .. "%");
	Controls.GoodyHutFrequencySlider:SetNumSteps(kValues.MaximumValue - kValues.MinimumValue);
	Controls.GoodyHutFrequencySlider:SetStep(m_kGoodyHutFrequencyParam.Value - kValues.MinimumValue);

	Controls.GoodyHutFrequencySlider:RegisterSliderCallback(function() 
		local stepNum:number = Controls.GoodyHutFrequencySlider:GetStep();
		local value:number = m_kGoodyHutFrequencyParam.Values.MinimumValue + stepNum;
			
		-- This method can get called pretty frequently, try and throttle it.
		if(m_kGoodyHutFrequencyParam.Value ~= value) then
			pGameParameters:SetParameterValue(m_kGoodyHutFrequencyParam, value);
			Controls.GoodyHutFrequencyNumber:SetText(tostring(value * 25) .. "%");
			Network.BroadcastGameConfig();
			-- RefreshCountWarning();
		end
	end);
end

--[[ =========================================================================
	Creates, configures, and returns a new Sort pulldown entry instance
=========================================================================== ]]
function GetSortEntryInstance( tag:string, uiButton:object, sortByFunc ) 
	local pEntryInst:object = {};
	Controls.SortByPulldown:BuildEntry( "InstanceOne", pEntryInst );
	pEntryInst.Button:SetText(tag);
	pEntryInst.Button:RegisterCallback( Mouse.eLClick, 
		function() 
			uiButton:SetText(tag);
			RefreshList(sortByFunc);
		end );
	return pEntryInst;
end

--[[ =========================================================================
	Initializes the Sort pulldown
=========================================================================== ]]
function InitSortByFilter() 
	local uiButton:object = Controls.SortByPulldown:GetButton();
	uiButton:SetText(m_kSortEntryTags.NameAZ);

	Controls.SortByPulldown:ClearEntries();

	local pNameAZEntryInst:object = GetSortEntryInstance(m_kSortEntryTags.NameAZ, uiButton, SortByNameAZ);
	local pNameZAEntryInst:object = GetSortEntryInstance(m_kSortEntryTags.NameZA, uiButton, SortByNameZA);

	local pSelectedWeightLHEntryInst:object = GetSortEntryInstance(m_kSortEntryTags.SelectedWeightLH, uiButton, SortBySelectedWeightLH);
	local pSelectedWeightHLEntryInst:object = GetSortEntryInstance(m_kSortEntryTags.SelectedWeightHL, uiButton, SortBySelectedWeightHL);
	
	if m_bIsGoodyHutRewards then 
		local pTypeAZEntryInst:object = GetSortEntryInstance(m_kSortEntryTags.TypeAZ, uiButton, SortByTypeAZ);
		local pTypeZAEntryInst:object = GetSortEntryInstance(m_kSortEntryTags.TypeZA, uiButton, SortByTypeZA);
	end

	local pDefaultWeightLHEntryInst:object = GetSortEntryInstance(m_kSortEntryTags.DefaultWeightLH, uiButton, SortByDefaultWeightLH);
	local pDefaultWeightHLEntryInst:object = GetSortEntryInstance(m_kSortEntryTags.DefaultWeightHL, uiButton, SortByDefaultWeightHL);
	
	Controls.SortByPulldown:CalculateInternals();
end

--[[ =========================================================================
	Returns an item's UI ConfigurationValue
	Used when its real ConfigurationValue is its default
	Allows the Weight pulldown UI to reflect the item's default tier
	Also for logging
	This is ugly as sin but works for now
=========================================================================== ]]
function GetUIConfigurationValue( config:number, default:number ) 
	if (config == -1) then 
		if (default == 0) then 
			return 0;
		elseif (default == 400) then 
			return 1;
		elseif (default == 200) then 
			return 2;
		elseif (default == 100) then 
			return m_bIsGoodyHutTypes and 3 or 1;
		elseif (default > 39) then 
			return m_bIsGoodyHutTypes and 4 or 2;
		elseif (default > 19) then 
			return m_bIsGoodyHutTypes and 5 or 3;
		elseif (default > 5) then 
			return 4;
		elseif (default > 3) then 
			return 5;
		elseif (default > 0) then 
			return 6;
		end
	end
	return config;
end

--[[ =========================================================================
	This updates the UI when a Weight selection is made
	It also allows the current UI state to be restored when selections are confirmed and the picker is relaunched
	Updates the value of an item's GameConfiguration object
	Updates an item's cached Weight
	Returns updated text for the item's Weight pulldown
=========================================================================== ]]
function UpdateUISelectedWeight( item:string, bTooltip:boolean ) 
	local config:number = GameConfiguration.GetValue(item);
	if bTooltip then return m_kWeights[config].Description; end
	local kItemData:table = GetGoodyHutData(item);
	local defaultWeight:number = kItemData.DefaultWeight;
	local uiConfig:number = GetUIConfigurationValue(config, defaultWeight);
	local tier:string = m_kWeights[uiConfig].Name;
	m_kGoodyHutDataCache[m_RulesetType][item].Tier = tier;
	m_kGoodyHutDataCache[m_RulesetType][item].Weight = m_kWeights[uiConfig].Weight;
	if uiConfig == 0 then 
		tier = string.format("[COLOR_Red]%s[ENDCOLOR]", tier);
	end
	local uiTier:string = (config == -1) and string.format("%s (%s)", m_kWeights[config].Name, tier) or tier;
	m_kSelectedValues[item] = config;
	return uiTier;
end

--[[ =========================================================================
	Does exactly what it says on the tin
=========================================================================== ]]
function LogWeightSelection( item:string ) 
	local kItemData:table = GetGoodyHutData(item);
	local tier:string = kItemData.Tier;
	local weight:number = kItemData.Weight;
	local config:number = GameConfiguration.GetValue(item);
	tier = (config == 0) and string.format("'%s'", tier) or tier;
	print(string.format("%s: Setting %s to %s (%d, ConfigurationValue %d)", m_ParameterId, item, tier, weight, config));
end

--[[ =========================================================================
	Creates, configures, and returns a new Weight pulldown entry instance
=========================================================================== ]]
function GetGlobalWeightEntryInstance( uiButton:object, config:number ) 
	local button:string = m_kWeights[config].Name;
	if (config == 0) then 
		button = string.format("[COLOR_Red]%s[ENDCOLOR]", button);
	end
	local tooltip:string = m_kWeights[config].Description;
	local pEntryInst:object = {};
	Controls.ResetAllPulldown:BuildEntry( "InstanceOne", pEntryInst );
	pEntryInst.Button:SetText(button);
	pEntryInst.Button:SetToolTipString(tooltip);
	pEntryInst.Button:RegisterCallback( Mouse.eLClick, 
		function() 
			uiButton:SetText(button);
			uiButton:SetToolTipString(tooltip);
			m_GlobalConfig = config;
		end );
	return pEntryInst;
end

--[[ =========================================================================
	Creates, configures, and returns a new Weight pulldown entry instance
=========================================================================== ]]
function GetWeightEntryInstance( c:table, item:string, uiButton:object, config:number ) 
	local button:string = m_kWeights[config].Name;
	if (config == 0) then 
		button = string.format("[COLOR_Red]%s[ENDCOLOR]", button);
	end
	local tooltip:string = m_kWeights[config].Description;
	local pEntryInst:object = {};
	c.WeightPulldown:BuildEntry( "InstanceOne", pEntryInst );
	pEntryInst.Button:SetText(button);
	pEntryInst.Button:SetToolTipString(tooltip);
	pEntryInst.Button:RegisterCallback( Mouse.eLClick, 
		function() 
			GameConfiguration.SetValue(item, config);
			uiButton:SetText(UpdateUISelectedWeight(item));
			uiButton:SetToolTipString(UpdateUISelectedWeight(item, true));
			LogWeightSelection(item);
		end );
	return pEntryInst;
end

--[[ =========================================================================
	Builds the UI button for an item
	Creates entry instances for each of the item's Weight pulldown options
	Configures the item's button
	Stores the item's database row and pulldown control
		This facilitates SetAllItems()
=========================================================================== ]]
function InitializeItem( kItem:table ) 
	local item:string = kItem.Value;
	local kItemData:table = GetGoodyHutData(kItem.Value);
	local c:table = m_pItemIM:GetInstance();
	c.Name:SetText(kItem.Name);

	if not kItem.Icon or not c.Icon:SetIcon(kItem.Icon) then 
		c.Icon:SetIcon("ICON_" .. kItem.Value);
	end

	if not kItemData.IconFG or not c.IconFG:SetIcon(kItemData.IconFG) then 
		c.IconFG:SetIcon("ICON_IMPROVEMENT_GOODY_HUT");
	end

	local uiButton:object = c.WeightPulldown:GetButton();
	uiButton:SetText(UpdateUISelectedWeight(item));
	uiButton:SetToolTipString(UpdateUISelectedWeight(item, true));

	c.WeightPulldown:ClearEntries();

	local pDefaultEntryInst:object = GetWeightEntryInstance(c, item, uiButton, -1);
	
	if m_bIsGoodyHutTypes then 
		local pQuadrupleEntryInst:object = GetWeightEntryInstance(c, item, uiButton, 1);
		local pDoubleEntryInst:object = GetWeightEntryInstance(c, item, uiButton, 2);
		local pNormalEntryInst:object = GetWeightEntryInstance(c, item, uiButton, 3);
		local pHalfEntryInst:object = GetWeightEntryInstance(c, item, uiButton, 4);
		local pQuarterEntryInst:object = GetWeightEntryInstance(c, item, uiButton, 5);
	elseif m_bIsGoodyHutRewards then 
		local pUbiquitousEntryInst:object = GetWeightEntryInstance(c, item, uiButton, 1);
		local pCommonEntryInst:object = GetWeightEntryInstance(c, item, uiButton, 2);
		local pUncommonEntryInst:object = GetWeightEntryInstance(c, item, uiButton, 3);
		local pRareEntryInst:object = GetWeightEntryInstance(c, item, uiButton, 4);
		local pLegendaryEntryInst:object = GetWeightEntryInstance(c, item, uiButton, 5);
		local pMythicEntryInst:object = GetWeightEntryInstance(c, item, uiButton, 6);
	else 
	end

	local pDisabledEntryInst:object = GetWeightEntryInstance(c, item, uiButton, 0);
	
	c.WeightPulldown:CalculateInternals();

	c.Button:SetToolTipString(Locale.Lookup("LOC_GOODYHUT_BUTTON_TT_TEXT"));
	c.Button:RegisterCallback( Mouse.eMouseEnter, function() OnItemFocus(kItem); end );
	c.Button:RegisterCallback( Mouse.eLClick, 
		function() 
			local config:number = GameConfiguration.GetValue(item);
			if (config < (m_numWeights - 2)) then 
				config = config + 1;
			else 
				config = -1;
			end
			GameConfiguration.SetValue(item, config);
			uiButton:SetText(UpdateUISelectedWeight(item));
			uiButton:SetToolTipString(UpdateUISelectedWeight(item, true));
			LogWeightSelection(item);
		end );

	local listItem:table = {};
	listItem["item"] = kItem;
	listItem["pulldown"] = c.WeightPulldown;
	table.insert(m_kItemList, listItem);
end

--[[ =========================================================================
	Calls Close()
	Destroys item instances
	Removes the picker's Initialize handler
=========================================================================== ]]
function OnShutdown() 
	Close();
	m_pItemIM:DestroyInstances();
	LuaEvents.GoodyHutPicker_Initialize.Remove( ParameterInitialize );
end

--[[ =========================================================================
	Calls Close() when user presses the Escape key
=========================================================================== ]]
function OnInputHandler( pInputStruct:table ) 
	local uiMsg = pInputStruct:GetMessageType();
	if uiMsg == KeyEvents.KeyUp then 
		local key:number = pInputStruct:GetKey();
		if key == Keys.VK_ESCAPE then 
			Close();
		end
	end
	return true;
end

--[[ =========================================================================
	Master picker initialization routine
=========================================================================== ]]
function Initialize() 
	ContextPtr:SetShutdown( OnShutdown );
	ContextPtr:SetInputHandler( OnInputHandler, true );

	local OnMouseEnter = function() UI.PlaySound("Main_Menu_Mouse_Over"); end;

	Controls.CloseButton:RegisterCallback( Mouse.eLClick, OnBackButton );
	Controls.CloseButton:RegisterCallback( Mouse.eMouseEnter, OnMouseEnter);
	Controls.ConfirmButton:RegisterCallback( Mouse.eLClick, OnConfirmChanges );
	Controls.ConfirmButton:RegisterCallback( Mouse.eMouseEnter, OnMouseEnter);

	Controls.ResetAllButton:RegisterCallback( Mouse.eMouseEnter, OnMouseEnter);

	LuaEvents.GoodyHutPicker_Initialize.Add( ParameterInitialize );
end
Initialize();

--[[ =========================================================================
	End GoodyHutPicker.lua frontend script
=========================================================================== ]]
