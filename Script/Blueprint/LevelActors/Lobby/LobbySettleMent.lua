local LobbySettleMent = {}
 
--[[
function LobbySettleMent:LuaExecuteWithFinish(_, IsFinish)
    -- Call OnFinish() when finish settle.
    self:OnFinish()
end
--]]

return LobbySettleMent