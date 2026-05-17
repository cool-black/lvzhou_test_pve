---@class UGCPlayerController_C:BP_UGCPlayerController_C
--Edit Below--
local LobbyStateService = UGCGameSystem.UGCRequire('Script.Gameplay.State.LobbyStateService')
local RunStateService = UGCGameSystem.UGCRequire('Script.Gameplay.State.RunStateService')
local UGCGameData = UGCGameSystem.UGCRequire('Script.Blueprint.UGCGameData')

local UGCPlayerController = {}

local function Log(Message)
    ugcprint("[UGCPlayerController] " .. tostring(Message))
end

function UGCPlayerController:GetAvailableServerRPCs()
    return "RPC_Server_SetLobbyState", "RPC_Server_RequestLevelSettle"
end

function UGCPlayerController:GetPlayerState()
    return UGCGameSystem.GetPlayerStateByPlayerController(self)
end

function UGCPlayerController:GetPlayerKey()
    return UGCGameSystem.GetPlayerKeyByPlayerController(self)
end

function UGCPlayerController:RequestToggleLobbyReady()
    local PlayerState = self:GetPlayerState()
    local CurrentState = LobbyStateService.GetState(PlayerState)
    Log(string.format("Client RequestToggleLobbyReady PlayerKey=%s CurrentState=%s", tostring(self:GetPlayerKey()), tostring(CurrentState)))

    if CurrentState == LobbyStateService.StateType.Ready then
        local bCancelRequested = UGCMultiMode.RequestCancelMatch()
        Log(string.format("Client RequestCancelMatch Result=%s", tostring(bCancelRequested)))
        if bCancelRequested then
            self:RequestSetLobbyState(LobbyStateService.StateType.Idle, "CancelMatch")
            UGCWidgetManagerSystem.ShowTipsUI("已取消匹配")
        else
            UGCWidgetManagerSystem.ShowTipsUI("取消匹配失败")
        end
        return
    end

    local bRequested = UGCMultiMode.RequestMatch(UGCGameData.ModeID.CommonLevel, self.OnRequestMatchResponse, self, true)
    Log(string.format("Client RequestMatch ModeID=%s Result=%s", tostring(UGCGameData.ModeID.CommonLevel), tostring(bRequested)))
    if bRequested then
        self:RequestSetLobbyState(LobbyStateService.StateType.Ready, "StartMatch")
        UGCWidgetManagerSystem.ShowTipsUI("开始匹配")
    else
        UGCWidgetManagerSystem.ShowTipsUI("开始匹配失败")
    end
end

function UGCPlayerController:OnRequestMatchResponse(bSuccess)
    Log(string.format("Client OnRequestMatchResponse PlayerKey=%s Success=%s", tostring(self:GetPlayerKey()), tostring(bSuccess)))
    if bSuccess then
        self:RequestSetLobbyState(LobbyStateService.StateType.Ready, "MatchResponseSuccess")
        return
    end

    self:RequestSetLobbyState(LobbyStateService.StateType.Idle, "MatchResponseFailed")
    UGCWidgetManagerSystem.ShowTipsUI("匹配失败")
end

function UGCPlayerController:RequestReturnLobby()
    Log(string.format("Client RequestReturnLobby PlayerKey=%s", tostring(self:GetPlayerKey())))

    if UGCMultiMode.GetModeID() == UGCGameData.ModeID.CommonLevel then
        UnrealNetwork.CallUnrealRPC(self, self, "RPC_Server_RequestLevelSettle", true, "ReturnLobby")
        return
    end

    local bRequested = UGCMultiMode.RequestMatch(UGCGameData.ModeID.Lobby, nil, self)
    Log(string.format("Client RequestReturnLobby Result=%s", tostring(bRequested)))
    if not bRequested then
        UGCWidgetManagerSystem.ShowTipsUI("返回大厅失败")
    end
end

function UGCPlayerController:RequestSetLobbyState(NewState, Reason)
    Log(string.format("Client RequestSetLobbyState PlayerKey=%s NewState=%s Reason=%s", tostring(self:GetPlayerKey()), tostring(NewState), tostring(Reason)))
    UnrealNetwork.CallUnrealRPC(self, self, "RPC_Server_SetLobbyState", NewState, Reason)
end

function UGCPlayerController:RPC_Server_SetLobbyState(NewState, Reason)
    local PlayerState = self:GetPlayerState()
    Log(string.format("Server RPC_SetLobbyState PlayerKey=%s NewState=%s Reason=%s", tostring(self:GetPlayerKey()), tostring(NewState), tostring(Reason)))
    LobbyStateService.SetState(PlayerState, NewState, Reason)
end

function UGCPlayerController:RPC_Server_RequestLevelSettle(IsFinish, Reason)
    local bIsFinish = IsFinish == nil and true or IsFinish
    Log(string.format("Server RPC_RequestLevelSettle PlayerKey=%s IsFinish=%s Reason=%s", tostring(self:GetPlayerKey()), tostring(bIsFinish), tostring(Reason)))
    self:ServerRequestLevelSettle(bIsFinish, Reason)
end

function UGCPlayerController:ServerRequestLevelSettle(IsFinish, Reason)
    if not UGCGameSystem.IsServer() then
        Log("ServerRequestLevelSettle ignored on client")
        return false
    end

    local PlayerState = self:GetPlayerState()
    if PlayerState and PlayerState.Settled then
        Log(string.format("ServerRequestLevelSettle ignored, already settled PlayerKey=%s Reason=%s", tostring(self:GetPlayerKey()), tostring(Reason)))
        return false
    end

    local bIsFinish = IsFinish == nil and true or IsFinish
    if PlayerState then
        if bIsFinish then
            RunStateService.SetState(PlayerState, RunStateService.StateType.Extracted, Reason or "ServerRequestLevelSettle")
        else
            RunStateService.SetState(PlayerState, RunStateService.StateType.Dead, Reason or "ServerRequestLevelSettle")
        end
    end

    local TeamID = self.TeamID
    if not TeamID or TeamID <= 0 then
        TeamID = UGCTeamSystem.GetTeamIDByPlayerKey(self:GetPlayerKey())
    end

    if TeamID and TeamID > 0 then
        UGCLevelFlowSystem.LevelSettle(TeamID, bIsFinish)
        Log(string.format("ServerRequestLevelSettle LevelSettle TeamID=%s IsFinish=%s", tostring(TeamID), tostring(bIsFinish)))
        return true
    end

    UGCLevelFlowSystem.GameSettle(bIsFinish)
    Log(string.format("ServerRequestLevelSettle fallback GameSettle IsFinish=%s", tostring(bIsFinish)))
    return true
end

function UGCPlayerController:OnGameSettle()
    local PlayerState = self:GetPlayerState()
    if not PlayerState or not PlayerState.Settled then
        Log("Client OnGameSettle ignored, PlayerState is nil or not settled")
        return
    end

    Log(string.format("Client OnGameSettle PlayerKey=%s SettlementSucceeded=%s", tostring(self:GetPlayerKey()), tostring(PlayerState.SettlementSucceeded)))

    if UGCMultiMode.GetModeID() ~= UGCGameData.ModeID.CommonLevel then
        return
    end

    local bRequested = UGCMultiMode.RequestMatch(UGCGameData.ModeID.Lobby, nil, self)
    Log(string.format("Client OnGameSettle RequestMatch Lobby Result=%s", tostring(bRequested)))
    if not bRequested then
        UGCWidgetManagerSystem.ShowTipsUI("返回大厅失败")
    end
end

return UGCPlayerController
