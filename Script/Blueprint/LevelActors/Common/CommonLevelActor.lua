---@class CommonLevelActor_C:UGCLevelActor
---@field DefaultSceneRoot USceneComponent
--Edit Below--
local CommonLevelActor = {}
 
--[[
function CommonLevelActor:ReceiveBeginPlay()
    CommonLevelActor.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function CommonLevelActor:ReceiveTick(DeltaTime)
    CommonLevelActor.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function CommonLevelActor:ReceiveEndPlay()
    CommonLevelActor.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function CommonLevelActor:GetReplicatedProperties()
    return
end
--]]

--[[
function CommonLevelActor:GetAvailableServerRPCs()
    return
end
--]]

return CommonLevelActor