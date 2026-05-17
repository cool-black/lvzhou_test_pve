local UGCGameData = {}

UGCGameData.ModeID = {
    Lobby = 1001,
    CommonLevel = 1002,
}

UGCGameData.DefaultModeID = UGCGameData.ModeID.Lobby

UGCGameData.ModeName = {
    Lobby = "大厅广场",
    CommonLevel = "普通副本",
}

local TABLE_GAME_MODE_CONFIG_PATH = UGCGameSystem.GetUGCResourcesFullPath(
    'Asset/Data/Table/TableGamemodeConfig.TableGamemodeConfig'
)

function UGCGameData.GetGameModeConfig(ModeID)
    local GameModeConfigTable = UGCGameSystem.GetTableData(TABLE_GAME_MODE_CONFIG_PATH)

    if not GameModeConfigTable then
        ugcprint("UGCGameData.GetGameModeConfig failed, TableGameModeConfig is nil.")
        return nil
    end

    for _, GameModeConfig in pairs(GameModeConfigTable) do
        if GameModeConfig.ModeID == ModeID or GameModeConfig.ModeId == ModeID then
            return GameModeConfig
        end
    end

    ugcprint("UGCGameData.GetGameModeConfig failed, ModeID=" .. tostring(ModeID))
    return nil
end

function UGCGameData.GetGameModeName(ModeID)
    if not ModeID or ModeID == 0 then
        return nil
    end

    local GameModeConfig = UGCGameData.GetGameModeConfig(ModeID)
    if GameModeConfig then
        return GameModeConfig.ModeName or GameModeConfig.Name
    end

    if ModeID == UGCGameData.ModeID.Lobby then
        return UGCGameData.ModeName.Lobby
    end

    if ModeID == UGCGameData.ModeID.CommonLevel then
        return UGCGameData.ModeName.CommonLevel
    end

    print(string.format("[warning][GetGameModeName]>>>>>>>>>>>>can not get game mode name of id: %s", ModeID))

    return nil
end

return UGCGameData
