local CommonLevel_Settle = {}

function CommonLevel_Settle:LuaExecuteWithFinish(InstanceId, IsFinish)
    local bIsFinish = IsFinish == nil and true or IsFinish
    ugcprint(string.format("[CommonLevel_Settle] LuaExecuteWithFinish InstanceId=%s IsFinish=%s", tostring(InstanceId), tostring(bIsFinish)))
    UGCLevelFlowSystem.GameSettle(bIsFinish)
end

return CommonLevel_Settle
