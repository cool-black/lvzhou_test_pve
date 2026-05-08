---@class UGCPlayerState_C:BP_UGCPlayerState_C
--Edit Below--
local Delegate = require("common.Delegate")

local UGCPlayerState = {
    LobbyState = "Idle",
    RunState = "InRun",
    Settled = false,
    ExtractStartTime = 0,
    ExtractDuration = 8,
    KillCount = 0,
    EliteKillCount = 0,
    PickCount = 0,
    bLobbyStateInitialized = false,
    bRunStateInitialized = false,
    LobbyStateChangedDelegate = Delegate.New(),
    RunStateChangedDelegate = Delegate.New(),
}

local function Log(Message)
    ugcprint("[UGCPlayerState] " .. tostring(Message))
end

local function GetPlayerKey(PlayerState)
    local PlayerKey = UGCGameSystem.GetPlayerKeyByPlayerState(PlayerState)
    return tostring(PlayerKey)
end

function UGCPlayerState:GetReplicatedProperties()
    return {"LobbyState", "Lazy"}, {"RunState", "Lazy"}, {"Settled", "Lazy"},
        {"ExtractStartTime", "Lazy"}, {"ExtractDuration", "Lazy"},
        {"KillCount", "Lazy"}, {"EliteKillCount", "Lazy"}, {"PickCount", "Lazy"}
end

function UGCPlayerState:ReceiveBeginPlay()
    UGCPlayerState.SuperClass.ReceiveBeginPlay(self)
    self.LobbyStateChangedDelegate = self.LobbyStateChangedDelegate or Delegate.New()
    self.RunStateChangedDelegate = self.RunStateChangedDelegate or Delegate.New()

    Log(string.format("BeginPlay Side=%s PlayerKey=%s LobbyState=%s RunState=%s",
        UGCGameSystem.IsServer() and "Server" or "Client",
        GetPlayerKey(self),
        tostring(self.LobbyState),
        tostring(self.RunState)))
end

function UGCPlayerState:GetLobbyState()
    return self.LobbyState or "Idle"
end

function UGCPlayerState:IsLobbyReady()
    return self:GetLobbyState() == "Ready"
end

function UGCPlayerState:GetRunState()
    return self.RunState or "InRun"
end

function UGCPlayerState:OnRep_LobbyState()
    Log(string.format("Client OnRep_LobbyState PlayerKey=%s State=%s", GetPlayerKey(self), tostring(self.LobbyState)))

    if self.LobbyStateChangedDelegate then
        self.LobbyStateChangedDelegate:Broadcast(self.LobbyState)
    end
end

function UGCPlayerState:OnRep_RunState()
    Log(string.format("Client OnRep_RunState PlayerKey=%s State=%s", GetPlayerKey(self), tostring(self.RunState)))

    if self.RunStateChangedDelegate then
        self.RunStateChangedDelegate:Broadcast(self.RunState)
    end
end

function UGCPlayerState:OnRep_Settled()
    Log(string.format("Client OnRep_Settled PlayerKey=%s Settled=%s", GetPlayerKey(self), tostring(self.Settled)))
end

function UGCPlayerState:ReceiveEndPlay()
    UGCPlayerState.SuperClass.ReceiveEndPlay(self)

    if self.LobbyStateChangedDelegate then
        self.LobbyStateChangedDelegate:RemoveAll()
    end

    if self.RunStateChangedDelegate then
        self.RunStateChangedDelegate:RemoveAll()
    end
end

return UGCPlayerState
