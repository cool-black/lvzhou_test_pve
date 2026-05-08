local UGCPlayerPawn = {}

local COMMON_LEVEL_MODE_ID = 1002

local function Log(Message)
    ugcprint("[UGCPlayerPawn] " .. tostring(Message))
end

function UGCPlayerPawn:ReceiveBeginPlay()
    UGCPlayerPawn.SuperClass.ReceiveBeginPlay(self)

    if not UGCGameSystem.IsServer() then
        return
    end

    UGCPawnSystem.SkipSpawnDeadTombBox(self, true)

    if self.DynamicStateEnterHandle then
        self.DynamicStateEnterHandle:Add(self.OnDynamicStateEnter, self)
        Log("Bind DynamicStateEnterHandle")
    else
        Log("ReceiveBeginPlay failed, DynamicStateEnterHandle is nil")
    end
end

function UGCPlayerPawn:OnDynamicStateEnter(CurState)
    if not UGCGameSystem.IsServer() then
        return
    end

    if UGCMultiMode.GetModeID() ~= COMMON_LEVEL_MODE_ID then
        return
    end

    local DeadTag = UGCGameplayTagSystem.RequestGameplayTag("PawnState.Dead")
    if not UGCGameplayTagSystem.IsValidTag(DeadTag) or not UGCPersistEffectSystem.HasDynamicState(self, DeadTag) then
        return
    end

    if self.bTestGunfireDeathSettled then
        return
    end
    self.bTestGunfireDeathSettled = true

    local PlayerController = UGCGameSystem.GetPlayerControllerByPlayerPawn(self)
    if not PlayerController then
        Log("OnDynamicStateEnter dead failed, PlayerController is nil")
        return
    end

    Log("OnDynamicStateEnter dead, request failed settlement")
    if PlayerController.ServerRequestLevelSettle then
        PlayerController:ServerRequestLevelSettle(false, "PawnDead")
    end
end

--[[
function UGCPlayerPawn:ReceiveTick(DeltaTime)
    UGCPlayerPawn.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function UGCPlayerPawn:ReceiveEndPlay()
    UGCPlayerPawn.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function UGCPlayerPawn:GetAvailableServerRPCs()
    return
end
--]]

function UGCPlayerPawn:GetReplicatedProperties()
    return {"__SubObjectRepList", "Lazy"}
end


return UGCPlayerPawn
