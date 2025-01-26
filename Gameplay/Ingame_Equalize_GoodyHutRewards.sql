/* ===========================================================================
    Enhanced Goody Hut Setup (EGHS) for Civilization VI
    Copyright © 2020-2024 yofabronecoforo
    All rights reserved.

    Begin ingame setup - Equalize Goody Hut Rewards
	This will be loaded if :
        (1) Advanced Setup option GAME_EQUALIZE_GOODYHUT_REWARDS is enabled
    Weights for enabled reward subtype(s) will be equalized below
=========================================================================== */

-- equalize active subtypes
UPDATE GoodyHutSubTypes SET Weight = 100 WHERE Weight > 0;

/* ===========================================================================
    End ingame setup - Equalize Goody Hut Rewards
=========================================================================== */
