/* ===========================================================================
    Enhanced Goody Hut Setup (EGHS) for Civilization VI
    Copyright © 2020-2024 yofabronecoforo
    All rights reserved.

    Begin ingame setup - GOODYHUT_TWO_CIVIC_BOOSTS reward DISABLED
=========================================================================== */

-- update subtype Weight
UPDATE GoodyHutSubTypes SET Weight = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_TWO_CIVIC_BOOSTS';

/* ===========================================================================
    End ingame setup - GOODYHUT_TWO_CIVIC_BOOSTS reward DISABLED
=========================================================================== */
