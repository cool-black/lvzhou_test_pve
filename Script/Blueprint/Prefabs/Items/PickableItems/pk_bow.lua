---@class pk_bow_C:UGCPickupWrapper_BP_C
--Edit Below--
local pk_bow = {}
 
--[[
function pk_bow:ReceiveBeginPlay()
    pk_bow.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function pk_bow:ReceiveTick(DeltaTime)
    pk_bow.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function pk_bow:ReceiveEndPlay()
    pk_bow.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function pk_bow:GetReplicatedProperties()
    return
end
--]]

--[[
function pk_bow:GetAvailableServerRPCs()
    return
end
--]]

return pk_bow