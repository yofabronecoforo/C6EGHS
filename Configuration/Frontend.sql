/* ===========================================================================
    Enhanced Goody Hut Setup (EGHS) for Civilization VI
    Copyright © 2020-2025 yofabronecoforo
    All rights reserved.

    Begin frontend setup
=========================================================================== */

-- content flags for picker tooltips
REPLACE INTO ContentFlags 
    (Id, Name, Tooltip, Frontend, CityStates, GoodyHuts, Leaders, NaturalWonders, RULESET_STANDARD, RULESET_EXPANSION_1, RULESET_EXPANSION_2)
VALUES 
    ('ed183371-82ee-488f-8e8d-53d5c48082d0', 'EGHS', 'LOC_EGHS_TT', 1, 0, 0, 0, 0, 1, 1, 1);

-- configure types for Standard
REPLACE INTO TribalVillageTypes (GoodyHut, NumRewards, Name, Description, Notice, Icon)
VALUES 
    -- culture type is provided by Firaxis
    ('GOODYHUT_CULTURE', 3, 'LOC_EGHS_GOODYHUT_CULTURE_NAME', 'LOC_EGHS_GOODYHUT_CULTURE_DESCRIPTION', NULL, 'ICON_DISTRICT_THEATER'), 
    -- faith type is provided by Firaxis
    ('GOODYHUT_FAITH', 3, 'LOC_EGHS_GOODYHUT_FAITH_NAME', 'LOC_EGHS_GOODYHUT_FAITH_DESCRIPTION', NULL, 'ICON_DISTRICT_HOLY_SITE'), 
    -- gold type is provided by Firaxis
    ('GOODYHUT_GOLD', 3, 'LOC_EGHS_GOODYHUT_GOLD_NAME', 'LOC_EGHS_GOODYHUT_GOLD_DESCRIPTION', NULL, 'ICON_DISTRICT_COMMERCIAL_HUB'), 
    -- military type is provided by Firaxis
    ('GOODYHUT_MILITARY', 3, 'LOC_EGHS_GOODYHUT_MILITARY_NAME', 'LOC_EGHS_GOODYHUT_MILITARY_DESCRIPTION', NULL, 'ICON_DISTRICT_ENCAMPMENT'), 
    -- science type is provided by Firaxis
    ('GOODYHUT_SCIENCE', 3, 'LOC_EGHS_GOODYHUT_SCIENCE_NAME', 'LOC_EGHS_GOODYHUT_SCIENCE_DESCRIPTION', NULL, 'ICON_DISTRICT_CAMPUS'), 
    -- survivors type is provided by Firaxis
    ('GOODYHUT_SURVIVORS', 4, 'LOC_EGHS_GOODYHUT_SURVIVORS_NAME', 'LOC_EGHS_GOODYHUT_SURVIVORS_DESCRIPTION', NULL, 'ICON_DISTRICT_NEIGHBORHOOD'); 

-- configure rewards for Standard
REPLACE INTO TribalVillageRewards (GoodyHut, SubTypeGoodyHut, Turn, MinOneCity, RequiresUnit, Name, Description, Notice, Icon, IconFG, Weight, DefaultWeight)
VALUES 
    -- culture type
    ('GOODYHUT_CULTURE', 'GOODYHUT_ONE_CIVIC_BOOST', 0, 0, 0, 'LOC_EGHS_GOODYHUT_ONE_CIVIC_BOOST_NAME', 'LOC_EGHS_GOODYHUT_ONE_CIVIC_BOOST_DESCRIPTION', NULL, 'ICON_DISTRICT_THEATER', 'ICON_NOTIFICATION_CIVIC_BOOST', 55, 55), 
    ('GOODYHUT_CULTURE', 'GOODYHUT_TWO_CIVIC_BOOSTS', 30, 0, 0, 'LOC_EGHS_GOODYHUT_TWO_CIVIC_BOOSTS_NAME', 'LOC_EGHS_GOODYHUT_TWO_CIVIC_BOOSTS_DESCRIPTION', NULL, 'ICON_DISTRICT_THEATER', 'ICON_NOTIFICATION_CIVIC_BOOST', 30, 30), 
    ('GOODYHUT_CULTURE', 'GOODYHUT_ONE_RELIC', 0, 1, 0, 'LOC_EGHS_GOODYHUT_ONE_RELIC_NAME', 'LOC_EGHS_GOODYHUT_ONE_RELIC_DESCRIPTION', NULL, 'ICON_DISTRICT_THEATER', 'ICON_NOTIFICATION_RELIC_CREATED', 15, 15), 
    -- faith type
    ('GOODYHUT_FAITH', 'GOODYHUT_SMALL_FAITH', 20, 1, 0, 'LOC_EGHS_GOODYHUT_SMALL_FAITH_NAME', 'LOC_EGHS_GOODYHUT_SMALL_FAITH_DESCRIPTION', NULL, 'ICON_DISTRICT_HOLY_SITE', NULL, 55, 55), 
    ('GOODYHUT_FAITH', 'GOODYHUT_MEDIUM_FAITH', 40, 1, 0, 'LOC_EGHS_GOODYHUT_MEDIUM_FAITH_NAME', 'LOC_EGHS_GOODYHUT_MEDIUM_FAITH_DESCRIPTION', NULL, 'ICON_DISTRICT_HOLY_SITE', NULL, 30, 30), 
    ('GOODYHUT_FAITH', 'GOODYHUT_LARGE_FAITH', 60, 1, 0, 'LOC_EGHS_GOODYHUT_LARGE_FAITH_NAME', 'LOC_EGHS_GOODYHUT_LARGE_FAITH_DESCRIPTION', NULL, 'ICON_DISTRICT_HOLY_SITE', NULL, 15, 15), 
    -- gold type
    ('GOODYHUT_GOLD', 'GOODYHUT_SMALL_GOLD', 0, 1, 0, 'LOC_EGHS_GOODYHUT_SMALL_GOLD_NAME', 'LOC_EGHS_GOODYHUT_SMALL_GOLD_DESCRIPTION', NULL, 'ICON_DISTRICT_COMMERCIAL_HUB', 'ICON_YIELD_GOLD_1', 55, 55), 
    ('GOODYHUT_GOLD', 'GOODYHUT_MEDIUM_GOLD', 20, 1, 0, 'LOC_EGHS_GOODYHUT_MEDIUM_GOLD_NAME', 'LOC_EGHS_GOODYHUT_MEDIUM_GOLD_DESCRIPTION', NULL, 'ICON_DISTRICT_COMMERCIAL_HUB', 'ICON_YIELD_GOLD_2', 30, 30), 
    ('GOODYHUT_GOLD', 'GOODYHUT_LARGE_GOLD', 40, 1, 0, 'LOC_EGHS_GOODYHUT_LARGE_GOLD_NAME', 'LOC_EGHS_GOODYHUT_LARGE_GOLD_DESCRIPTION', NULL, 'ICON_DISTRICT_COMMERCIAL_HUB', 'ICON_YIELD_GOLD_3', 15, 15), 
    -- military type
    ('GOODYHUT_MILITARY', 'GOODYHUT_GRANT_SCOUT', 0, 1, 1, 'LOC_EGHS_GOODYHUT_GRANT_SCOUT_NAME', 'LOC_EGHS_GOODYHUT_GRANT_SCOUT_DESCRIPTION', NULL, 'ICON_DISTRICT_ENCAMPMENT', 'ICON_UNIT_SCOUT', 40, 40), 
    ('GOODYHUT_MILITARY', 'GOODYHUT_GRANT_EXPERIENCE', 0, 0, 1, 'LOC_EGHS_GOODYHUT_GRANT_EXPERIENCE_NAME', 'LOC_EGHS_GOODYHUT_GRANT_EXPERIENCE_DESCRIPTION', NULL, 'ICON_DISTRICT_ENCAMPMENT', 'ICON_UNITCOMMAND_PROMOTE', 30, 30), 
    ('GOODYHUT_MILITARY', 'GOODYHUT_HEAL', 0, 0, 1, 'LOC_EGHS_GOODYHUT_HEAL_NAME', 'LOC_EGHS_GOODYHUT_HEAL_DESCRIPTION', NULL, 'ICON_DISTRICT_ENCAMPMENT', 'ICON_UNITOPERATION_HEAL', 30, 30), 
    -- 2024/12/21: grant upgrade is *BROKEN*
    -- ('GOODYHUT_MILITARY', 'GOODYHUT_GRANT_UPGRADE', 0, 0, 1, 'LOC_EGHS_GOODYHUT_GRANT_UPGRADE_NAME', 'LOC_EGHS_GOODYHUT_GRANT_UPGRADE_DESCRIPTION', NULL, 'ICON_DISTRICT_ENCAMPMENT', 'ICON_UNITCOMMAND_UPGRADE', 0, 0), 
    -- science type
    ('GOODYHUT_SCIENCE', 'GOODYHUT_ONE_TECH_BOOST', 0, 0, 0, 'LOC_EGHS_GOODYHUT_ONE_TECH_BOOST_NAME', 'LOC_EGHS_GOODYHUT_ONE_TECH_BOOST_DESCRIPTION', NULL, 'ICON_DISTRICT_CAMPUS', 'ICON_NOTIFICATION_TECH_BOOST', 55, 55), 
    ('GOODYHUT_SCIENCE', 'GOODYHUT_TWO_TECH_BOOSTS', 0, 0, 0, 'LOC_EGHS_GOODYHUT_TWO_TECH_BOOSTS_NAME', 'LOC_EGHS_GOODYHUT_TWO_TECH_BOOSTS_DESCRIPTION', NULL, 'ICON_DISTRICT_CAMPUS', 'ICON_NOTIFICATION_TECH_BOOST', 30, 30), 
    ('GOODYHUT_SCIENCE', 'GOODYHUT_ONE_TECH', 0, 1, 0, 'LOC_EGHS_GOODYHUT_ONE_TECH_NAME', 'LOC_EGHS_GOODYHUT_ONE_TECH_DESCRIPTION', NULL, 'ICON_DISTRICT_CAMPUS', 'ICON_NOTIFICATION_TECH_DISCOVERED', 15, 15), 
    -- survivors type
    ('GOODYHUT_SURVIVORS', 'GOODYHUT_ADD_POP', 0, 1, 1, 'LOC_EGHS_GOODYHUT_ADD_POP_NAME', 'LOC_EGHS_GOODYHUT_ADD_POP_DESCRIPTION', NULL, 'ICON_DISTRICT_NEIGHBORHOOD', 'ICON_UNITOPERATION_FOUND_CITY', 40, 40), 
    ('GOODYHUT_SURVIVORS', 'GOODYHUT_GRANT_BUILDER', 0, 1, 1, 'LOC_EGHS_GOODYHUT_GRANT_BUILDER_NAME', 'LOC_EGHS_GOODYHUT_GRANT_BUILDER_DESCRIPTION', NULL, 'ICON_DISTRICT_NEIGHBORHOOD', 'ICON_UNIT_BUILDER', 35, 35), 
    ('GOODYHUT_SURVIVORS', 'GOODYHUT_GRANT_TRADER', 15, 1, 1, 'LOC_EGHS_GOODYHUT_GRANT_TRADER_NAME', 'LOC_EGHS_GOODYHUT_GRANT_TRADER_DESCRIPTION', NULL, 'ICON_DISTRICT_NEIGHBORHOOD', 'ICON_UNIT_TRADER', 25, 25), 
    ('GOODYHUT_SURVIVORS', 'GOODYHUT_GRANT_SETTLER', 0, 1, 1, 'LOC_EGHS_GOODYHUT_GRANT_SETTLER_NAME', 'LOC_EGHS_GOODYHUT_GRANT_SETTLER_DESCRIPTION', NULL, 'ICON_DISTRICT_NEIGHBORHOOD', 'ICON_UNIT_SETTLER', 0, 0); 

-- configure Standard types for Rise and Fall
REPLACE INTO TribalVillageTypes 
SELECT 'Expansion1GoodyHutTypes' AS Domain, GoodyHut, Name, Description, ChangesXP1, ChangesXP2, Notice, NumRewards, Icon, Weight, DefaultWeight FROM TribalVillageTypes
WHERE Domain = 'StandardGoodyHutTypes';

-- configure Standard rewards for Rise and Fall
REPLACE INTO TribalVillageRewards 
SELECT 'Expansion1GoodyHutRewards' AS Domain, GoodyHut, SubTypeGoodyHut, Name, Description, Turn, MinOneCity, RequiresUnit, Notice, Icon, IconFG, Weight, DefaultWeight FROM TribalVillageRewards
WHERE Domain = 'StandardGoodyHutRewards';

-- configure new types for Rise and Fall

-- configure new rewards for Rise and Fall

-- changes to types for Rise and Fall

-- changes to rewards for Rise and Fall

-- configure Rise and Fall types for Gathering Storm
REPLACE INTO TribalVillageTypes 
SELECT 'Expansion2GoodyHutTypes' AS Domain, GoodyHut, Name, Description, ChangesXP1, ChangesXP2, Notice, NumRewards, Icon, Weight, DefaultWeight FROM TribalVillageTypes
WHERE Domain = 'Expansion1GoodyHutTypes';

-- configure Rise and Fall rewards for Gathering Storm
REPLACE INTO TribalVillageRewards 
SELECT 'Expansion2GoodyHutRewards' AS Domain, GoodyHut, SubTypeGoodyHut, Name, Description, Turn, MinOneCity, RequiresUnit, Notice, Icon, IconFG, Weight, DefaultWeight FROM TribalVillageRewards
WHERE Domain = 'Expansion1GoodyHutRewards';

-- configure new types for Gathering Storm
REPLACE INTO TribalVillageTypes (Domain, GoodyHut, NumRewards, Name, Description, Icon)
VALUES 
    -- diplomacy type is provided by Firaxis
    ('Expansion2GoodyHutTypes', 'GOODYHUT_DIPLOMACY', 3, 'LOC_EGHS_GOODYHUT_DIPLOMACY_NAME', 'LOC_EGHS_GOODYHUT_DIPLOMACY_DESCRIPTION', 'ICON_DISTRICT_DIPLOMATIC_QUARTER');

-- configure new rewards for Gathering Storm
REPLACE INTO TribalVillageRewards (Domain, GoodyHut, SubTypeGoodyHut, Turn, MinOneCity, RequiresUnit, Name, Description, Notice, Icon, IconFG, Weight, DefaultWeight)
VALUES 
    -- diplomacy type
    ('Expansion2GoodyHutRewards', 'GOODYHUT_DIPLOMACY', 'GOODYHUT_FAVOR', 30, 0, 0, 'LOC_EGHS_GOODYHUT_FAVOR_NAME', 'LOC_EGHS_GOODYHUT_FAVOR_DESCRIPTION', NULL, 'ICON_DISTRICT_DIPLOMATIC_QUARTER', 'ICON_YIELD_FAVOR', 45, 45), 
    ('Expansion2GoodyHutRewards', 'GOODYHUT_DIPLOMACY', 'GOODYHUT_ENVOY', 0, 0, 0, 'LOC_EGHS_GOODYHUT_ENVOY_NAME', 'LOC_EGHS_GOODYHUT_ENVOY_DESCRIPTION', NULL, 'ICON_DISTRICT_DIPLOMATIC_QUARTER', 'ICON_ENVOY_BONUS_SUZERAIN', 40, 40), 
    ('Expansion2GoodyHutRewards', 'GOODYHUT_DIPLOMACY', 'GOODYHUT_GOVERNOR_TITLE', 30, 0, 0, 'LOC_EGHS_GOODYHUT_GOVERNOR_TITLE_NAME', 'LOC_EGHS_GOODYHUT_GOVERNOR_TITLE_DESCRIPTION', NULL, 'ICON_DISTRICT_DIPLOMATIC_QUARTER', NULL, 15, 15), 
    -- military type
    ('Expansion2GoodyHutRewards', 'GOODYHUT_MILITARY', 'GOODYHUT_RESOURCES', 0, 0, 0, 'LOC_EGHS_GOODYHUT_GRANT_RESOURCES_NAME', 'LOC_EGHS_GOODYHUT_GRANT_RESOURCES_DESCRIPTION', NULL, 'ICON_DISTRICT_ENCAMPMENT', NULL, 20, 20);

-- changes to types for Gathering Storm
UPDATE TribalVillageTypes 
SET NumRewards = 4, ChangesXP2 = 'LOC_EGHS_GOODYHUT_MILITARY_XP2' 
WHERE GoodyHut = 'GOODYHUT_MILITARY' AND Domain = 'Expansion2GoodyHutTypes';

-- changes to rewards for Gathering Storm
UPDATE TribalVillageRewards 
SET Weight = 35, DefaultWeight = 35 
WHERE SubTypeGoodyHut = 'GOODYHUT_GRANT_SCOUT' AND Domain = 'Expansion2GoodyHutRewards';

UPDATE TribalVillageRewards 
SET Weight = 25, DefaultWeight = 25 
WHERE SubTypeGoodyHut = 'GOODYHUT_HEAL' AND Domain = 'Expansion2GoodyHutRewards';

UPDATE TribalVillageRewards 
SET Weight = 20, DefaultWeight = 20 
WHERE SubTypeGoodyHut = 'GOODYHUT_GRANT_EXPERIENCE' AND Domain = 'Expansion2GoodyHutRewards';

-- reposition the No Barbarians parameter, and give it a description
UPDATE Parameters SET Description = 'LOC_GAME_NO_BARBARIANS_DESCRIPTION', SortIndex = 2021 WHERE ParameterId = 'NoBarbarians';

-- reposition the No Tribal Villages parameter, and give it a description
UPDATE Parameters SET Description = 'LOC_GAME_NO_GOODY_HUTS_DESCRIPTION', SortIndex = 2022 WHERE ParameterId = 'NoGoodyHuts';

-- new EGHS parameters
REPLACE INTO Parameters (Key1, Key2, ParameterId, Name, Description, Domain, DefaultValue, Hash, Array, ConfigurationGroup, ConfigurationId, GroupId, UxHint, SortIndex)
VALUES 
    -- disable meteor strike event
    ('Ruleset', 'RULESET_EXPANSION_2', 'DisableMeteorStrike', 'LOC_GAME_DISABLE_METEOR_STRIKE_NAME', 'LOC_GAME_DISABLE_METEOR_STRIKE_DESCRIPTION', 'bool', 0, 0, 0, 'Game', 'GAME_DISABLE_METEOR_STRIKE', 'AdvancedOptions', NULL, 2024), 
    -- goody hut distribution slider
    (NULL, NULL, 'GoodyHutFrequency', 'LOC_GOODYHUT_FREQUENCY_NAME', 'LOC_GOODYHUT_FREQUENCY_DESCRIPTION', 'GoodyHutFrequencyRange', 4, 0, 0, 'Game', 'GOODYHUT_FREQUENCY', 'AdvancedOptions', NULL, 2031), 
    -- goody hut type picker
    ('Ruleset', 'RULESET_STANDARD', 'GoodyHutTypes', 'LOC_GOODYHUT_TYPES_NAME', 'LOC_GOODYHUT_TYPES_DESCRIPTION', 'StandardGoodyHutTypes', NULL, 0, 1, 'Game', 'EXCLUDE_GOODYHUT_TYPES', 'AdvancedOptions', 'InvertSelection', 2032), 
    ('Ruleset', 'RULESET_EXPANSION_1', 'GoodyHutTypes', 'LOC_GOODYHUT_TYPES_NAME', 'LOC_GOODYHUT_TYPES_DESCRIPTION', 'Expansion1GoodyHutTypes', NULL, 0, 1, 'Game', 'EXCLUDE_GOODYHUT_TYPES', 'AdvancedOptions', 'InvertSelection', 2032), 
    ('Ruleset', 'RULESET_EXPANSION_2', 'GoodyHutTypes', 'LOC_GOODYHUT_TYPES_NAME', 'LOC_GOODYHUT_TYPES_DESCRIPTION', 'Expansion2GoodyHutTypes', NULL, 0, 1, 'Game', 'EXCLUDE_GOODYHUT_TYPES', 'AdvancedOptions', 'InvertSelection', 2032), 
    -- equalize active goody hut types
    (NULL, NULL, 'EqualizeGoodyHutTypes', 'LOC_GAME_EQUALIZE_GOODYHUT_TYPES_NAME', 'LOC_GAME_EQUALIZE_GOODYHUT_TYPES_DESCRIPTION', 'bool', 0, 0, 0, 'Game', 'GAME_EQUALIZE_GOODYHUT_TYPES', 'AdvancedOptions', NULL, 2033), 
    -- goody hut reward picker
    ('Ruleset', 'RULESET_STANDARD', 'GoodyHutRewards', 'LOC_GOODYHUT_REWARDS_NAME', 'LOC_GOODYHUT_REWARDS_DESCRIPTION', 'StandardGoodyHutRewards', NULL, 0, 1, 'Game', 'EXCLUDE_GOODYHUT_REWARDS', 'AdvancedOptions', 'InvertSelection', 2034), 
    ('Ruleset', 'RULESET_EXPANSION_1', 'GoodyHutRewards', 'LOC_GOODYHUT_REWARDS_NAME', 'LOC_GOODYHUT_REWARDS_DESCRIPTION', 'Expansion1GoodyHutRewards', NULL, 0, 1, 'Game', 'EXCLUDE_GOODYHUT_REWARDS', 'AdvancedOptions', 'InvertSelection', 2034), 
    ('Ruleset', 'RULESET_EXPANSION_2', 'GoodyHutRewards', 'LOC_GOODYHUT_REWARDS_NAME', 'LOC_GOODYHUT_REWARDS_DESCRIPTION', 'Expansion2GoodyHutRewards', NULL, 0, 1, 'Game', 'EXCLUDE_GOODYHUT_REWARDS', 'AdvancedOptions', 'InvertSelection', 2034), 
    -- equalize active goody hut rewards
    (NULL, NULL, 'EqualizeGoodyHutRewards', 'LOC_GAME_EQUALIZE_GOODYHUT_REWARDS_NAME', 'LOC_GAME_EQUALIZE_GOODYHUT_REWARDS_DESCRIPTION', 'bool', 0, 0, 0, 'Game', 'GAME_EQUALIZE_GOODYHUT_REWARDS', 'AdvancedOptions', NULL, 2035), 
    -- remove minimum turn requirements
    (NULL, NULL, 'RemoveMinimumTurn', 'LOC_GAME_REMOVE_MINTURN_NAME', 'LOC_GAME_REMOVE_MINTURN_DESCRIPTION', 'bool', 0, 0, 0, 'Game', 'GAME_REMOVE_MINTURN', 'AdvancedOptions', NULL, 2036);

-- create GameConfiguration objects for each unique picker item
-- these are used to set type/reward Weights in the gameplay database
-- this is stupidly complicated
REPLACE INTO Parameters 
	(ParameterId, ConfigurationId, Key1, Key2, Name, 
    Description, Domain, Hash, Array, DefaultValue, ConfigurationGroup, 
    DomainConfigurationId, DomainValuesConfigurationId, 
    ValueNameConfigurationId, ValueDomainConfigurationId, 
    NameArrayConfigurationId, GroupId, Visible, ReadOnly, 
	SupportsSinglePlayer, SupportsLANMultiplayer, 
    SupportsInternetMultiplayer, SupportsHotSeat, 
	SupportsPlayByCloud, ChangeableAfterGameStart, 
    ChangeableAfterPlayByCloudMatchCreate, UxHint, SortIndex)
SELECT 
    t.GoodyHut, t.GoodyHut, NULL, NULL, 'LOC_EGHS_DUMMY_NAME', 
    NULL, 'int', 0, 0, -1, 'Game', 
    NULL, NULL, 
    NULL, NULL, 
    NULL, 'AdvancedOptions', 0, 0, 
	1, 1, 
    1, 1, 
	1, 0, 
    1, NULL, 100
FROM TribalVillageTypes t 
UNION SELECT 
    r.SubTypeGoodyHut, r.SubTypeGoodyHut, NULL, NULL, 'LOC_EGHS_DUMMY_NAME', 
    NULL, 'int', 0, 0, -1, 'Game', 
    NULL, NULL, 
    NULL, NULL, 
    NULL, 'AdvancedOptions', 0, 0, 
	1, 1, 
    1, 1, 
	1, 0, 
    1, NULL, 100
FROM TribalVillageRewards r 
GROUP BY r.SubTypeGoodyHut;

-- goody hut distribution slider range
-- UI will multiply the selected value by 25 to display the frequency
REPLACE INTO DomainRanges (Domain, MinimumValue, MaximumValue) 
VALUES 
    ('GoodyHutFrequencyRange', 0, 32);

-- picker query IDs
REPLACE INTO DomainValueQueries (QueryId) 
VALUES 
    -- goody hut type picker
    ('GoodyHutTypes'), 
    -- goody hut reward picker
    ('GoodyHutRewards');

-- picker SQLite queries
REPLACE INTO Queries (QueryId, SQL) 
VALUES 
    -- goody hut type picker
    ('GoodyHutTypes', 'SELECT Domain, Name, Description, GoodyHut AS Value, Icon, Weight AS SortIndex, DefaultWeight FROM TribalVillageTypes'), 
    -- goody hut reward picker
    ('GoodyHutRewards', 'SELECT Domain, Name, Description, GoodyHut, SubTypeGoodyHut AS Value, Icon, IconFG, Weight AS SortIndex, DefaultWeight FROM TribalVillageRewards');

-- localized text and GameConfiguration value lookup for type picker
REPLACE INTO EGHS_TypeWeights (Tier, Name, Description, Weight) 
VALUES 
    -- default
    (-1, 'LOC_WEIGHT_DEFAULT_NAME', 'LOC_WEIGHT_DEFAULT_DESCRIPTION', -1), 
    -- disabled
    (0, 'LOC_WEIGHT_DISABLED_NAME', 'LOC_WEIGHT_DISABLED_DESCRIPTION', 0), 
    -- quadruple "normal"
    (1, 'LOC_WEIGHT_QUADRUPLE_NAME', 'LOC_WEIGHT_QUADRUPLE_DESCRIPTION', 400), 
    -- double "normal"
    (2, 'LOC_WEIGHT_DOUBLE_NAME', 'LOC_WEIGHT_DOUBLE_DESCRIPTION', 200), 
    -- "normal"
    (3, 'LOC_WEIGHT_NORMAL_NAME', 'LOC_WEIGHT_NORMAL_DESCRIPTION', 100), 
    -- half "normal"
    (4, 'LOC_WEIGHT_HALF_NAME', 'LOC_WEIGHT_HALF_DESCRIPTION', 50), 
    -- quarter "normal"
    (5, 'LOC_WEIGHT_QUARTER_NAME', 'LOC_WEIGHT_QUARTER_DESCRIPTION', 25);

-- localized text and GameConfiguration value lookup for reward picker
REPLACE INTO EGHS_RewardWeights (Tier, Name, Description, Weight) 
VALUES 
    -- default
    (-1, 'LOC_WEIGHT_DEFAULT_NAME', 'LOC_WEIGHT_DEFAULT_DESCRIPTION', -1), 
    -- disabled
    (0, 'LOC_WEIGHT_DISABLED_NAME', 'LOC_WEIGHT_DISABLED_DESCRIPTION', 0), 
    -- ubiquitous
    (1, 'LOC_WEIGHT_UBIQUITOUS_NAME', 'LOC_WEIGHT_UBIQUITOUS_DESCRIPTION', 100), 
    -- common
    (2, 'LOC_WEIGHT_COMMON_NAME', 'LOC_WEIGHT_COMMON_DESCRIPTION', 55), 
    -- uncommon
    (3, 'LOC_WEIGHT_UNCOMMON_NAME', 'LOC_WEIGHT_UNCOMMON_DESCRIPTION', 30), 
    -- rare
    (4, 'LOC_WEIGHT_RARE_NAME', 'LOC_WEIGHT_RARE_DESCRIPTION', 15), 
    -- legendary
    (5, 'LOC_WEIGHT_LEGENDARY_NAME', 'LOC_WEIGHT_LEGENDARY_DESCRIPTION', 5), 
    -- mythic
    (6, 'LOC_WEIGHT_MYTHIC_NAME', 'LOC_WEIGHT_MYTHIC_DESCRIPTION', 1);

-- localized text lookup for picker sort-by pulldowns
REPLACE INTO EGHS_SortPulldownTags (Name, Description) 
VALUES 
    ('NameAZ', 'LOC_GOODYHUT_SORT_NAME_ASC'), 
    ('NameZA', 'LOC_GOODYHUT_SORT_NAME_DESC'), 
    ('SelectedWeightLH', 'LOC_GOODYHUT_SORT_SELWEIGHT_ASC'), 
    ('SelectedWeightHL', 'LOC_GOODYHUT_SORT_SELWEIGHT_DESC'), 
    ('TypeAZ', 'LOC_GOODYHUT_SORT_TYPE_ASC'), 
    ('TypeZA', 'LOC_GOODYHUT_SORT_TYPE_DESC'), 
    ('DefaultWeightLH', 'LOC_GOODYHUT_SORT_DEFWEIGHT_ASC'), 
    ('DefaultWeightHL', 'LOC_GOODYHUT_SORT_DEFWEIGHT_DESC');

/* ===========================================================================
    End frontend setup
=========================================================================== */
