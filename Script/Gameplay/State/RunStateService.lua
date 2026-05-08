local RunStateService = {}

RunStateService.StateType = {
    InRun = "InRun",
    Extracting = "Extracting",
    Extracted = "Extracted",
    Settled = "Settled",
    Dead = "Dead",
}

local DEFAULT_EXTRACT_DURATION = 8

local function Log(Message)
    ugcprint("[RunState] " .. tostring(Message))
end

local function IsValidState(State)
    for _, StateValue in pairs(RunStateService.StateType) do
        if State == StateValue then
            return true
        end
    end

    return false
end

function RunStateService.GetState(PlayerState)
    if not PlayerState or not PlayerState.RunState then
        return RunStateService.StateType.InRun
    end

    return PlayerState.RunState
end

function RunStateService.SetState(PlayerState, NewState, Reason)
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

    local OldState = RunStateService.GetState(PlayerState)
    if OldState == NewState then
        return true
    end

    PlayerState.RunState = NewState
    UnrealNetwork.RepLazyProperty(PlayerState, "RunState")

    local PlayerKey = UGCGameSystem.GetPlayerKeyByPlayerState(PlayerState)
    Log(string.format("Server PlayerKey=%s %s -> %s Reason=%s", tostring(PlayerKey), tostring(OldState), tostring(NewState), tostring(Reason)))
    return true
end

function RunStateService.InitPlayer(PlayerState, Reason)
    if not PlayerState then
        Log("InitPlayer failed, PlayerState is nil")
        return false
    end

    if PlayerState.bRunStateInitialized then
        return true
    end

    PlayerState.bRunStateInitialized = true
    PlayerState.Settled = false
    PlayerState.SettlementSucceeded = false
    PlayerState.ExtractStartTime = 0
    PlayerState.ExtractDuration = DEFAULT_EXTRACT_DURATION
    PlayerState.KillCount = 0
    PlayerState.EliteKillCount = 0
    PlayerState.PickCount = 0
    PlayerState.RunState = RunStateService.StateType.InRun

    UnrealNetwork.RepLazyProperty(PlayerState, "Settled")
    UnrealNetwork.RepLazyProperty(PlayerState, "SettlementSucceeded")
    UnrealNetwork.RepLazyProperty(PlayerState, "ExtractStartTime")
    UnrealNetwork.RepLazyProperty(PlayerState, "ExtractDuration")
    UnrealNetwork.RepLazyProperty(PlayerState, "KillCount")
    UnrealNetwork.RepLazyProperty(PlayerState, "EliteKillCount")
    UnrealNetwork.RepLazyProperty(PlayerState, "PickCount")
    UnrealNetwork.RepLazyProperty(PlayerState, "RunState")

    local PlayerKey = UGCGameSystem.GetPlayerKeyByPlayerState(PlayerState)
    Log(string.format("Server init PlayerKey=%s RunState=%s Reason=%s", tostring(PlayerKey), tostring(PlayerState.RunState), tostring(Reason)))
    return true
end

function RunStateService.TryInitAllRunPlayers()
    local PlayerStates = UGCGameSystem.GetAllPlayerState(true)
    if not PlayerStates then
        return
    end

    for _, PlayerState in pairs(PlayerStates) do
        RunStateService.InitPlayer(PlayerState, "TryInitAllRunPlayers")
    end
end

return RunStateService
