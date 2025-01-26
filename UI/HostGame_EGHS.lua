--[[ =========================================================================
	Enhanced Goody Hut Setup (EGHS) for Civilization VI
    Copyright © 2020-2025 yofabronecoforo
    All rights reserved.

	Begin HostGame_EGHS.lua configuration script
=========================================================================== ]]
print("[+]: Loading HostGame_EGHS.lua UI script . . .");

--[[ =========================================================================
	OVERRIDE: call BeforeHostGame() and pass arguments to pre-EGHS HostGame()
=========================================================================== ]]
Pre_EGHS_HostGame = HostGame;
function HostGame(serverType:number) 
    BeforeHostGame();
    Pre_EGHS_HostGame(serverType);
end

--[[ =========================================================================
	End HostGame_EGHS.lua configuration script
=========================================================================== ]]
