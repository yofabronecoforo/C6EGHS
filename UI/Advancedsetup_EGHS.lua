--[[ =========================================================================
	Enhanced Goody Hut Setup (EGHS) for Civilization VI
    Copyright © 2020-2025 yofabronecoforo
    All rights reserved.

	Begin AdvancedSetup_EGHS.lua configuration script
=========================================================================== ]]
print("[+]: Loading AdvancedSetup_EGHS.lua UI script . . .");

--[[ =========================================================================
	OVERRIDE: call BeforeHostGame() and call pre-EGHS HostGame()
=========================================================================== ]]
Pre_EGHS_HostGame = HostGame;
function HostGame()
    BeforeHostGame();
    Pre_EGHS_HostGame();
end

--[[ =========================================================================
	End AdvancedSetup_EGHS.lua configuration script
=========================================================================== ]]
