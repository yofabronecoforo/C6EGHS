/* ===========================================================================
    Enhanced Goody Hut Setup (EGHS) for Civilization VI
    Copyright © 2020-2024 yofabronecoforo
    All rights reserved.

    Begin ingame setup - Remove Minimum Turn Requirements
	This will be loaded if :
        (1) Advanced Setup option GAME_REMOVE_MINTURN is enabled
    GoodyHutSubTypes.Turn will be set to 0 below for all defined subtypes
    This can have unintended, possibly game-breaking consequences
=========================================================================== */

-- remove minimum turn requirements on all defined subtypes
UPDATE GoodyHutSubTypes SET Turn = 0;

/* ===========================================================================
    End ingame setup - Remove Minimum Turn Requirements
=========================================================================== */
