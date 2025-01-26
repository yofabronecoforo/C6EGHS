/* ===========================================================================
    Enhanced Goody Hut Setup (EGHS) for Civilization VI
    Copyright © 2020-2024 yofabronecoforo
    All rights reserved.

    Begin ingame setup - Disable meteor strike goodies
=========================================================================== */

-- disable the METEOR_GOODIES type
UPDATE GoodyHuts SET Weight = 0 WHERE GoodyHutType = 'METEOR_GOODIES';

-- disable the METEOR_GRANT_GOODIES subtype
UPDATE GoodyHutSubTypes SET Weight = 0 WHERE SubTypeGoodyHut = 'METEOR_GRANT_GOODIES';

/* ===========================================================================
    End ingame setup - meteor strike goodies
=========================================================================== */
