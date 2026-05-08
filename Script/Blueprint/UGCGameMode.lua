---@class UGCGameMode_C:BP_UGCGameBase_C
--Edit Below--
local UGCGameMode = {};
local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')

function UGCGameMode:ReceiveBeginPlay()
    if not UGCGameSystem.IsServer() then
        return
    end

    local ModeID = UGCMultiMode.GetModeID()
    if ModeID == 0 then
        ModeID = UGCGameData.DefaultModeID
    end

    self:InitLevelFlow(ModeID)
end

function UGCGameMode:InitLevelFlow(ModeID)
    if not ModeID then
        ugcprint("UGCGameMode:InitLevelFlow failed, invalid ModeID=" .. tostring(ModeID))
        return
    end

    local GameModeConfig = UGCGameData.GetGameModeConfig(ModeID)
    if not GameModeConfig or not GameModeConfig.LevelActorMgrPath or GameModeConfig.LevelActorMgrPath == "" then
        ugcprint("UGCGameMode:InitLevelFlow failed, LevelActorMgrPath is nil, ModeID=" .. tostring(ModeID))
        return
    end

    UGCLevelFlowSystem.EnableLevelFlow(
        UGCGameSystem.GetUGCResourcesFullPath(GameModeConfig.LevelActorMgrPath)
    )
end

return UGCGameMode;
