---@class LobbyLevelActor_C:UGCLevelActor
---@field DefaultSceneRoot USceneComponent
--Edit Below--
local LobbyLevelActor = {}
 
--[[
function LobbyLevelActor:ReceiveBeginPlay()
    LobbyLevelActor.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function LobbyLevelActor:ReceiveTick(DeltaTime)
    LobbyLevelActor.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function LobbyLevelActor:ReceiveEndPlay()
    LobbyLevelActor.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function LobbyLevelActor:GetReplicatedProperties()
    return
end
--]]

--[[
function LobbyLevelActor:GetAvailableServerRPCs()
    return
end
--]]

return LobbyLevelActor