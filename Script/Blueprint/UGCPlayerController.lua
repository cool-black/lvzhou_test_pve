---@class UGCPlayerController_C:BP_UGCPlayerController_C
--Edit Below--
local LobbyStateService = UGCGameSystem.UGCRequire('Script.Gameplay.State.LobbyStateService')

local UGCPlayerController = {}

local LOBBY_MODE_ID = 1001
local COMMON_LEVEL_MODE_ID = 1002

local function Log(Message)
    ugcprint("[UGCPlayerController] " .. tostring(Message))
end

function UGCPlayerController:GetAvailableServerRPCs()
    return "RPC_Server_SetLobbyState"
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

    local bRequested = UGCMultiMode.RequestMatch(COMMON_LEVEL_MODE_ID, self.OnRequestMatchResponse, self, true)
    Log(string.format("Client RequestMatch ModeID=%s Result=%s", tostring(COMMON_LEVEL_MODE_ID), tostring(bRequested)))
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

    local bRequested = UGCMultiMode.RequestMatch(LOBBY_MODE_ID, nil, self)
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

return UGCPlayerController
