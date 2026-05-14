---@class pk_arrow_C:UGCPickupWrapper_BP_C
--Edit Below--
local pk_arrow = {}
 
--[[
function pk_arrow:ReceiveBeginPlay()
    pk_arrow.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function pk_arrow:ReceiveTick(DeltaTime)
    pk_arrow.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function pk_arrow:ReceiveEndPlay()
    pk_arrow.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function pk_arrow:GetReplicatedProperties()
    return
end
--]]

--[[
function pk_arrow:GetAvailableServerRPCs()
    return
end
--]]

return pk_arrow