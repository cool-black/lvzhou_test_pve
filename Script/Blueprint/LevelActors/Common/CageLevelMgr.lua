---@class CageLevelMgr_C:UGCLevelActorMgr
--Edit Below--
local CommonLevelMgr = {}
 
--[[
function CommonLevelMgr:ReceiveBeginPlay()
    CommonLevelMgr.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function CommonLevelMgr:ReceiveTick(DeltaTime)
    CommonLevelMgr.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function CommonLevelMgr:ReceiveEndPlay()
    CommonLevelMgr.SuperClass.ReceiveEndPlay(self) 
end
--]]

return CommonLevelMgr