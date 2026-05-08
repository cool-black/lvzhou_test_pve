local UGCGameData = {}

UGCGameData.DefaultModeID = 1001

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

    if ModeID == 1001 then
        return UGCGameData.ModeName.Lobby
    end

    if ModeID == 1002 then
        return UGCGameData.ModeName.CommonLevel
    end

    return nil
end

return UGCGameData
