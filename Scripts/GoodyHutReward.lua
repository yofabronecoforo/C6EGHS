--[[ =========================================================================
	Enhanced Goody Hut Setup (EGHS) for Civilization VI
    Copyright © 2020-2025 yofabronecoforo
    All rights reserved.

    Begin GoodyHutReward.lua gameplay script
=========================================================================== ]]
print("Loading gameplay script GoodyHutReward.lua . . .");

local g_sRuleset:string = GameConfiguration.GetValue("RULESET");

local g_iLoggingLevel:number = GameConfiguration.GetValue("GAME_ECFE_LOGGING") or -1;
g_iLoggingLevel = 3;
local vprint = (g_iLoggingLevel > 2) and print or function (s, ...) return; end;

--[[ =========================================================================
	function IsExpansionRuleset() 
=========================================================================== ]]
function IsExpansionRuleset() 
    return (g_sRuleset ~= "RULESET_STANDARD");
end

--[[ =========================================================================
	function IsGatheringStormRuleset() 
=========================================================================== ]]
function IsGatheringStormRuleset() 
    return (g_sRuleset == "RULESET_EXPANSION_2");
end

--[[ =========================================================================
	function IsStandardRuleset() 
=========================================================================== ]]
function IsStandardRuleset() 
    return (g_sRuleset == "RULESET_STANDARD");
end

--[[ =========================================================================
	function AbortInit() 
    should be called when any of the below pre-init checks fail
=========================================================================== ]]
function AbortInit() 
    print("Aborting configuration");
    return;
end

--[[ =========================================================================
	pre-init 
=========================================================================== ]]
local g_bNoGoodyHuts:boolean = GameConfiguration.GetValue("GAME_NO_GOODY_HUTS");
print("'No Tribal Villages':", g_bNoGoodyHuts);
if g_bNoGoodyHuts then return AbortInit(); end

local g_sHutType:string = "IMPROVEMENT_GOODY_HUT";
local g_iHutIndex:number = GameInfo.Improvements[g_sHutType].Index or -1;
print(string.format("GameInfo.Improvements[%s]: %d", g_sHutType, g_iHutIndex));
if (g_iHutIndex < 0) then return AbortInit(); end

local g_iHutFrequency:number = GameConfiguration.GetValue("GOODYHUT_FREQUENCY");
print("Tribal Village distribution:", ((g_iHutFrequency * 25) .. "%% of baseline"));
if (g_iHutFrequency == 0) then return AbortInit(); end

local g_bNoBarbarians:boolean = GameConfiguration.GetValue("GAME_NO_BARBARIANS");
print("'No Barbarians':", g_bNoBarbarians);
-- if g_bNoBarbarians then return AbortInit(); end

local g_sCampType:string = "IMPROVEMENT_BARBARIAN_CAMP";
local g_iCampIndex:number = GameInfo.Improvements[g_sCampType].Index or -1;
print(string.format("GameInfo.Improvements[%s]: %d", g_sCampType, g_iCampIndex));
-- if (g_iCampIndex < 0) then return AbortInit(); end

local g_bEqualizeTypes:boolean = GameConfiguration.GetValue("GAME_EQUALIZE_GOODYHUT_TYPES");
print("Equalize active Tribal Village Type Weights:", g_bEqualizeTypes);

local g_bEqualizeRewards:boolean = GameConfiguration.GetValue("GAME_EQUALIZE_GOODYHUT_REWARDS");
print("Equalize active Tribal Village Reward Weights:", g_bEqualizeRewards);

local g_bRemoveMinTurn:boolean = GameConfiguration.GetValue("GAME_REMOVE_MINTURN");
print("Remove minimum turn requirements for active Rewards:", g_bRemoveMinTurn);

local g_bDisableMeteorStrike:boolean = GameConfiguration.GetValue("GAME_DISABLE_METEOR_STRIKE") or false;
if IsGatheringStormRuleset() then 
    print("Disable Meteor Strike Goodies:", g_bDisableMeteorStrike);
end

-- local g_sNotification:string = Locale.Lookup("LOC_HOSTILE_VILLAGERS_NOTIFICATION_TITLE");
local g_sRowOfDashes:string = "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -";

--[[ =========================================================================
	table Goodies 
    each key is a hash of an active Goody Hut (sub)type
        its corresponding value is the (sub)type
=========================================================================== ]]
print("Configuring Goody Hut (sub)type hash lookup table . . .");
local Goodies:table = {};
for _, v in ipairs({"type", "reward"}) do 
    local dbColumn:string = (v == "type") and "GoodyHutType" or "SubTypeGoodyHut";
    local dbTable:string = (v == "type") and "GoodyHuts" or "GoodyHutSubTypes";
    local dbExclude:string = (v == "type") and "GoodyHutType" or "GoodyHut";
    local totalQuery:string = string.format("SELECT %s AS Value FROM %s WHERE NOT %s = 'METEOR_GOODIES'", dbColumn, dbTable, dbExclude);
    local total:table = DB.Query(totalQuery);
    local activeQuery:string = string.format("SELECT %s AS Value FROM %s WHERE Weight > 0 AND NOT %s = 'METEOR_GOODIES'", dbColumn, dbTable, dbExclude);
    local active:table = DB.Query(activeQuery);
    for _, row in ipairs(active) do 
        local hash:number = DB.MakeHash(row.Value);
        Goodies[hash] = row.Value;
    end
    Goodies[dbTable] = { Active = #active, Total = #total};
end

--[[ =========================================================================
	listener function OnGoodyHutReward() 
=========================================================================== ]]
function EGHS_OnGoodyHutReward( player:number, unit:number, goodyhut:number, subtype:number ) 
    if not Goodies[goodyhut] or not Goodies[subtype] then return; end
    vprint(player, unit, goodyhut, subtype);
    return;
end

--[[ =========================================================================
	configure required components
=========================================================================== ]]
function EGHS_Initialize() 
    print("Validating Goody Hut (sub)type hash lookup table . . .");
    for _, v in ipairs({"type", "reward"}) do 
        local dbColumn:string = (v == "type") and "GoodyHutType" or "SubTypeGoodyHut";
        local dbTable:string = (v == "type") and "GoodyHuts" or "GoodyHutSubTypes";
        for row in GameInfo[dbTable]() do 
            local hash:number = DB.MakeHash(row[dbColumn]);
            if Goodies[hash] then 
                vprint(string.format("[%d] =", hash), Goodies[hash]);
            end
        end
        print("Identified", Goodies[dbTable].Active, "active of", Goodies[dbTable].Total, dbTable);
    end
    print("Configuring listener for Events.GoodyHutReward . . .");
    Events.GoodyHutReward.Add(EGHS_OnGoodyHutReward);
    -- Events.ImprovementActivated.Add(EGHS_OnImprovementActivated);
    -- Events.TurnEnd.Add(EGHS_OnTurnEnd);
    print("Initialization complete");
    return;
end

--[[ =========================================================================
	defer execution of Initialize() to LoadScreenClose
=========================================================================== ]]
print(string.format("Deferring additional configuration for %s to LoadScreenClose", g_sRuleset));
Events.LoadScreenClose.Add(EGHS_Initialize);

--[[ =========================================================================
	End GoodyHutReward.lua gameplay script
=========================================================================== ]]

--[[ =========================================================================
	listener function OnImprovementActivated() 
=========================================================================== ]]
-- function EGHS_OnImprovementActivated( x:number, y:number, player:number, unit:number, improvement:number, owner:number, activation:number ) 
--     local bIsCamp:boolean = (improvementIndex == g_iCampIndex);
--     local bIsHut:boolean = (improvementIndex == g_iHutIndex);
--     if not bIsCamp and not bIsHut then return; end
--     local player:number = (owner > -1) and owner or improvementOwner;
--     local pPlayerConfig:object = PlayerConfigurations[player];
--     local civTypeName:string = pPlayerConfig:GetCivilizationTypeName();
--     if (bIsCamp and civTypeName ~= "CIVILIZATION_SUMERIA") then return; end
--     vprint(x, y, player, unit, improvement, owner, activation);
--     return;
-- end

--[[ =========================================================================
	listener function OnTurnEnd() 
=========================================================================== ]]
-- function EGHS_OnTurnEnd() 
--     if (Goodies.iNumGoodyHuts < 1) then return; end
--     local currentTurn:number = Game.GetCurrentGameTurn();
--     local total:number = 0;
--     for _, pPlayer in ipairs(Game.GetPlayers()) do 
--         local count:number = pPlayer:GetProperty("HUTS_THIS_TURN") or 0;
--         if (count > 0) then 
--             total = total + count;
--         end
--         pPlayer:SetProperty("HUTS_THIS_TURN", 0);
--     end
--     print(string.format("Turn %d: %d total goody hut%s activated", currentTurn, total, (total ~= 1) and "s" or ""));
--     Goodies.iNumGoodyHuts = Goodies:GetNumGoodyHuts();
--     print(string.format("%d goody hut%s remain", Goodies.iNumGoodyHuts, (Goodies.iNumGoodyHuts ~= 1) and "s" or ""));
--     return;
-- end
