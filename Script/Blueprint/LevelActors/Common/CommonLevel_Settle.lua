local CommonLevel_Settle = {}
 
--[[
function CommonLevel_Settle:LuaExecuteWithFinish(_, IsFinish)
    -- Call OnFinish() when finish settle.
    self:OnFinish()
end
--]]

return CommonLevel_Settle