/* ===========================================================================
    Enhanced Goody Hut Setup (EGHS) for Civilization VI
    Copyright © 2020-2024 yofabronecoforo
    All rights reserved.

    Begin ingame setup - Disable Goody Hut Types
    When all rewards of a given type have been disabled, disable that type
    Otherwise, leave the type Weight at its current value
    This should ensure that the gamecore does not select any type with zero active rewards
    Types below are valid for all rulesets
=========================================================================== */

-- Culture type
UPDATE GoodyHuts 
SET Weight = CASE 
	WHEN ((SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_CULTURE') = 0) THEN 0 
	ELSE (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_CULTURE') 
	END 
WHERE GoodyHutType = 'GOODYHUT_CULTURE';

-- Faith type
UPDATE GoodyHuts 
SET Weight = CASE 
	WHEN ((SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_FAITH') = 0) THEN 0 
	ELSE (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_FAITH') 
	END 
WHERE GoodyHutType = 'GOODYHUT_FAITH';

-- Gold type
UPDATE GoodyHuts 
SET Weight = CASE 
	WHEN ((SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_GOLD') = 0) THEN 0 
	ELSE (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_GOLD') 
	END 
WHERE GoodyHutType = 'GOODYHUT_GOLD';

-- Military type
UPDATE GoodyHuts 
SET Weight = CASE 
	WHEN ((SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_MILITARY') = 0) THEN 0 
	ELSE (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_MILITARY') 
	END 
WHERE GoodyHutType = 'GOODYHUT_MILITARY';

-- Science type
UPDATE GoodyHuts 
SET Weight = CASE 
	WHEN ((SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_SCIENCE') = 0) THEN 0 
	ELSE (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_SCIENCE') 
	END 
WHERE GoodyHutType = 'GOODYHUT_SCIENCE';

-- Survivors type
UPDATE GoodyHuts 
SET Weight = CASE 
	WHEN ((SELECT SUM(Weight) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_SURVIVORS') = 0) THEN 0 
	ELSE (SELECT Weight FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_SURVIVORS') 
	END 
WHERE GoodyHutType = 'GOODYHUT_SURVIVORS';

/* ===========================================================================
    End ingame setup - Disable Goody Hut Types
=========================================================================== */
