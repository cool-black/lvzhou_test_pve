local InventorySettlementService = UGCGameSystem.UGCRequire('Script.Gameplay.Inventory.InventorySettlementService')
local RunStateService = UGCGameSystem.UGCRequire('Script.Gameplay.State.RunStateService')

local CommonGame_Settle = {}

local function Log(Message)
    ugcprint("[CommonGame_Settle] " .. tostring(Message))
end

function CommonGame_Settle:LuaExecuteWithFinish(_, IsFinish)
    local bIsFinish = IsFinish == nil and true or IsFinish
    Log("LuaExecuteWithFinish IsFinish=" .. tostring(bIsFinish))

    local AllPlayers = UGCLevelFlowSystem.GetAllPlayerControllerInCurrentLevel()
    if not AllPlayers or #AllPlayers <= 0 then
        AllPlayers = UGCGameSystem.GetAllPlayerController(true)
    end

    if not AllPlayers or #AllPlayers <= 0 then
        Log("LuaExecuteWithFinish failed, AllPlayers is empty")
        return
    end

    for _, PlayerController in pairs(AllPlayers) do
        local PlayerState = UGCGameSystem.GetPlayerStateByPlayerController(PlayerController)
        local PlayerKey = UGCGameSystem.GetPlayerKeyByPlayerController(PlayerController)
        Log(string.format("Settle PlayerKey=%s IsFinish=%s", tostring(PlayerKey), tostring(bIsFinish)))

        InventorySettlementService.SettlePlayer(PlayerController, bIsFinish, "CommonGame_Settle")

        if PlayerState then
            PlayerState.SettlementSucceeded = bIsFinish
            PlayerState.Settled = true

            if bIsFinish then
                RunStateService.SetState(PlayerState, RunStateService.StateType.Settled, "CommonGame_Settle")
            else
                RunStateService.SetState(PlayerState, RunStateService.StateType.Dead, "CommonGame_Settle")
            end

            UnrealNetwork.RepLazyProperty(PlayerState, "SettlementSucceeded")
            UnrealNetwork.RepLazyProperty(PlayerState, "Settled")
        else
            Log("Settle skipped PlayerState, PlayerKey=" .. tostring(PlayerKey))
        end
    end
end

return CommonGame_Settle
