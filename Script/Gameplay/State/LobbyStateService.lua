local LobbyStateService = {
    State = "Idle",
}

LobbyStateService.StateType = {
    Idle = "Idle",
    Ready = "Ready",
}

function LobbyStateService.GetState()
    return LobbyStateService.State
end

function LobbyStateService.IsIdle()
    return LobbyStateService.State == LobbyStateService.StateType.Idle
end

function LobbyStateService.IsReady()
    return LobbyStateService.State == LobbyStateService.StateType.Ready
end

function LobbyStateService.SetIdle()
    LobbyStateService.State = LobbyStateService.StateType.Idle
end

function LobbyStateService.SetReady()
    LobbyStateService.State = LobbyStateService.StateType.Ready
end

return LobbyStateService
