local CommonLevel_Reward = {}

function CommonLevel_Reward:LuaExecute()
    ugcprint("[CommonLevel_Reward] LuaExecute")
    self:OnFinish()
end

return CommonLevel_Reward
