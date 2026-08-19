---@class UGCGameMode_C:BP_UGCGameBase_C
--Edit Below--
local UGCGameMode = {};
local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')
local InventoryService = UGCGameSystem.UGCRequire('Script.Gameplay.Inventory.InventoryService')
local LobbyStateService = UGCGameSystem.UGCRequire('Script.Gameplay.State.LobbyStateService')
local RunStateService = UGCGameSystem.UGCRequire('Script.Gameplay.State.RunStateService')

function UGCGameMode:ReceiveBeginPlay()
    if not UGCGameSystem.IsServer() then
        return
    end

    local ModeID = UGCMultiMode.GetModeID()
    if ModeID == 0 then
        ModeID = UGCGameData.DefaultModeID
    end

    self.CurrentModeID = ModeID
    self:InitLevelFlow(ModeID)
end

function UGCGameMode:ReceiveTick(DeltaTime)
    if not UGCGameSystem.IsServer() then
        return
    end

    if self.CurrentModeID == UGCGameData.ModeID.Lobby then
        LobbyStateService.TryInitAllLobbyPlayers()
        InventoryService.TryLoadAllLobbyPlayers()
        return
    end

    if self.CurrentModeID == UGCGameData.ModeID.CommonLevel then
        RunStateService.TryInitAllRunPlayers()
    end
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

function UGCGameMode:PrintTable(t, indent)
    indent = indent or 0
    for k, v in pairs(t) do
        local prefix = string.rep("  ", indent)
        if type(v) == "table" then
            print(prefix .. tostring(k) .. " = {")
            UGCGameMode.PrintTable(v, indent + 1)
            print(prefix .. "}")
        else
            print(prefix .. tostring(k) .. " = " .. tostring(v))
        end
    end
end

return UGCGameMode;
