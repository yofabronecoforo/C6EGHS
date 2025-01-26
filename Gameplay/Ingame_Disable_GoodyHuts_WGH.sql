/* ===========================================================================
    Enhanced Goody Hut Setup (EGHS) for Civilization VI
    Copyright © 2020-2024 yofabronecoforo
    All rights reserved.

    Begin ingame setup - Disable Goody Hut Types for WGH
    When all rewards of a given type have been disabled, disable that type
    Otherwise, leave the type Weight at its current value
    This should ensure that the gamecore does not select any type with zero active rewards
    Types below are valid when Wondrous Goody Huts is present and enabled
=========================================================================== */

-- Wondrous type
UPDATE GoodyHuts 
SET Weight = CASE 
	WHEN ((SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_SAILOR_WONDROUS') = 0) THEN 0 
	ELSE (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_SAILOR_WONDROUS') 
	END 
WHERE GoodyHutType = 'GOODYHUT_SAILOR_WONDROUS';

/* ===========================================================================
    End ingame setup - Disable Goody Hut Types for WGH
=========================================================================== */
