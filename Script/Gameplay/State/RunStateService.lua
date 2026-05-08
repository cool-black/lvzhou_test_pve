local RunStateService = {
    PlayerStates = {},
}

RunStateService.StateType = {
    InRun = "InRun",
    Extracting = "Extracting",
    Extracted = "Extracted",
    Settled = "Settled",
    Dead = "Dead",
}

function RunStateService.InitPlayer(PlayerKey)
    if not PlayerKey then
        return nil
    end

    if not RunStateService.PlayerStates[PlayerKey] then
        RunStateService.PlayerStates[PlayerKey] = {
            State = RunStateService.StateType.InRun,
            Settled = false,
            ExtractStartTime = 0,
            ExtractDuration = 8,
            KillCount = 0,
            EliteKillCount = 0,
            PickCount = 0,
        }
    end

    return RunStateService.PlayerStates[PlayerKey]
end

function RunStateService.TryInitAllRunPlayers()
    local PlayerKeys = UGCGameSystem.GetAllPlayerKey(true)
    if not PlayerKeys then
        return
    end

    for _, PlayerKey in pairs(PlayerKeys) do
        RunStateService.InitPlayer(PlayerKey)
    end
end

function RunStateService.GetPlayerState(PlayerKey)
    return RunStateService.PlayerStates[PlayerKey]
end

function RunStateService.SetState(PlayerKey, NewState)
    local PlayerState = RunStateService.InitPlayer(PlayerKey)
    if not PlayerState then
        return false
    end

    PlayerState.State = NewState
    return true
end

return RunStateService
