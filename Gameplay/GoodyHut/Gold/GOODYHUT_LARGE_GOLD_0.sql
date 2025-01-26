/* ===========================================================================
    Enhanced Goody Hut Setup (EGHS) for Civilization VI
    Copyright © 2020-2024 yofabronecoforo
    All rights reserved.

    Begin ingame setup - GOODYHUT_LARGE_GOLD reward DISABLED
=========================================================================== */

-- update subtype Weight
UPDATE GoodyHutSubTypes SET Weight = 0 WHERE SubTypeGoodyHut = 'GOODYHUT_LARGE_GOLD';

/* ===========================================================================
    End ingame setup - GOODYHUT_LARGE_GOLD reward DISABLED
=========================================================================== */
