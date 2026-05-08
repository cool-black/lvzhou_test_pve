---@class LobbyLevelMgr_C:UGCLevelActorMgr
--Edit Below--
local LobbyLevelMgr = {}
 
--[[
function LobbyLevelMgr:ReceiveBeginPlay()
    LobbyLevelMgr.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function LobbyLevelMgr:ReceiveTick(DeltaTime)
    LobbyLevelMgr.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function LobbyLevelMgr:ReceiveEndPlay()
    LobbyLevelMgr.SuperClass.ReceiveEndPlay(self) 
end
--]]

return LobbyLevelMgr