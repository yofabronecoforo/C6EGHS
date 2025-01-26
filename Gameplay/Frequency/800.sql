/* ===========================================================================
    Enhanced Goody Hut Setup (EGHS) for Civilization VI
    Copyright © 2020-2024 yofabronecoforo
    All rights reserved.

    Begin ingame setup - GOODYHUT_FREQUENCY 800% of map baseline
=========================================================================== */

-- update Goody Hut frequency; default: TilesPerGoody = 128, GoodyRange = 3
UPDATE Improvements SET TilesPerGoody = 16, GoodyRange = 0 WHERE ImprovementType = 'IMPROVEMENT_GOODY_HUT';

/* ===========================================================================
    End ingame setup - GOODYHUT_FREQUENCY 800% of map baseline
=========================================================================== */
