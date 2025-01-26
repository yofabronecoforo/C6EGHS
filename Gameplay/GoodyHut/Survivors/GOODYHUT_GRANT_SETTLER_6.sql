/* ===========================================================================
    Enhanced Goody Hut Setup (EGHS) for Civilization VI
    Copyright © 2020-2024 yofabronecoforo
    All rights reserved.

    Begin ingame setup - GOODYHUT_GRANT_SETTLER reward Mythic
=========================================================================== */

-- update subtype Weight
UPDATE GoodyHutSubTypes SET Weight = 1 WHERE SubTypeGoodyHut = 'GOODYHUT_GRANT_SETTLER';

/* ===========================================================================
    End ingame setup - GOODYHUT_GRANT_SETTLER reward Mythic
=========================================================================== */
