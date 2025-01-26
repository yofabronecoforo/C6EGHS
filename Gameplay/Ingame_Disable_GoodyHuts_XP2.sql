/* ===========================================================================
    Enhanced Goody Hut Setup (EGHS) for Civilization VI
    Copyright © 2020-2024 yofabronecoforo
    All rights reserved.

    Begin ingame setup - Disable Goody Hut Types for XP2
    When all rewards of a given type have been disabled, disable that type
    Otherwise, leave the type Weight at its current value
    This should ensure that the gamecore does not select any type with zero active rewards
    Types below are valid for Gathering Storm ruleset
=========================================================================== */

-- Diplomacy type
UPDATE GoodyHuts 
SET Weight = CASE 
	WHEN ((SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_DIPLOMACY') = 0) THEN 0 
	ELSE (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_DIPLOMACY') 
	END 
WHERE GoodyHutType = 'GOODYHUT_DIPLOMACY';

/* ===========================================================================
    End ingame setup - Disable Goody Hut Types for XP2
=========================================================================== */
