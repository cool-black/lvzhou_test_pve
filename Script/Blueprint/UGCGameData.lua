local UGCGameData = {}

UGCGameData.DefaultModeID = 1001

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
        if GameModeConfig.ModeID == ModeID then
            return GameModeConfig
        end
    end

    ugcprint("UGCGameData.GetGameModeConfig failed, ModeID=" .. tostring(ModeID))
    return nil
end

return UGCGameData
