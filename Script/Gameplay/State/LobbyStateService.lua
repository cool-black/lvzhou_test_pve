local LobbyStateService = {}

LobbyStateService.StateType = {
    Idle = "Idle",
    Ready = "Ready",
}

local function Log(Message)
    ugcprint("[LobbyState] " .. tostring(Message))
end

local function IsValidState(State)
    for _, StateValue in pairs(LobbyStateService.StateType) do
        if State == StateValue then
            return true
        end
    end

    return false
end

function LobbyStateService.GetState(PlayerState)
    if not PlayerState or not PlayerState.LobbyState then
        return LobbyStateService.StateType.Idle
    end

    return PlayerState.LobbyState
end

function LobbyStateService.IsIdle(PlayerState)
    return LobbyStateService.GetState(PlayerState) == LobbyStateService.StateType.Idle
end

function LobbyStateService.IsReady(PlayerState)
    return LobbyStateService.GetState(PlayerState) == LobbyStateService.StateType.Ready
end

function LobbyStateService.SetState(PlayerState, NewState, Reason)
    if not PlayerState then
        Log("SetState failed, PlayerState is nil, NewState=" .. tostring(NewState))
        return false
    end

    if not UGCGameSystem.IsServer() then
        Log("SetState ignored on client, NewState=" .. tostring(NewState))
        return false
    end

    if not IsValidState(NewState) then
        Log("SetState failed, invalid NewState=" .. tostring(NewState))
        return false
    end

    local OldState = LobbyStateService.GetState(PlayerState)
    if OldState == NewState then
        return true
    end

    PlayerState.LobbyState = NewState
    PlayerState.bLobbyStateInitialized = true
    UnrealNetwork.RepLazyProperty(PlayerState, "LobbyState")

    local PlayerKey = UGCGameSystem.GetPlayerKeyByPlayerState(PlayerState)
    Log(string.format("Server PlayerKey=%s %s -> %s Reason=%s", tostring(PlayerKey), tostring(OldState), tostring(NewState), tostring(Reason)))
    return true
end

function LobbyStateService.InitPlayer(PlayerState, Reason)
    if not PlayerState then
        Log("InitPlayer failed, PlayerState is nil")
        return false
    end

    if PlayerState.bLobbyStateInitialized then
        return true
    end

    PlayerState.bLobbyStateInitialized = true
    PlayerState.LobbyState = LobbyStateService.StateType.Idle
    UnrealNetwork.RepLazyProperty(PlayerState, "LobbyState")

    local PlayerKey = UGCGameSystem.GetPlayerKeyByPlayerState(PlayerState)
    Log(string.format("Server init PlayerKey=%s LobbyState=%s Reason=%s", tostring(PlayerKey), tostring(PlayerState.LobbyState), tostring(Reason or "InitLobby")))
    return true
end

function LobbyStateService.TryInitAllLobbyPlayers()
    local PlayerStates = UGCGameSystem.GetAllPlayerState(true)
    if not PlayerStates then
        return
    end

    for _, PlayerState in pairs(PlayerStates) do
        LobbyStateService.InitPlayer(PlayerState, "TryInitAllLobbyPlayers")
    end
end

return LobbyStateService
