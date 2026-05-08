local InventorySaveData = UGCGameSystem.UGCRequire('Script.Gameplay.Inventory.InventorySaveData')

_G.TestGunfireInventoryLoadedPlayers = _G.TestGunfireInventoryLoadedPlayers or {}

local InventoryService = {
    LoadedPlayers = _G.TestGunfireInventoryLoadedPlayers,
    LoadResults = {},
}

local function Log(Message)
    ugcprint("[InventoryService] " .. tostring(Message))
end

local function IsValidDefineID(DefineID)
    return DefineID ~= nil and DefineID.Type ~= 0 and DefineID.TypeSpecificID ~= 0 and DefineID.InstanceID ~= 0
end

local function AddCount(CountMap, ItemID, Count)
    if not ItemID or not Count then
        return
    end

    CountMap[ItemID] = (CountMap[ItemID] or 0) + Count
end

local function BuildExpectedSaveSnapshot(SaveData)
    local Snapshot = {
        BackpackAndEquippedCounts = {},
        WarehouseCounts = {},
        EquippedSlots = {},
        Attachments = {},
    }

    if not SaveData or not SaveData.Items then
        return Snapshot
    end

    for _, ItemData in ipairs(SaveData.Items) do
        if ItemData and ItemData.ItemID and ItemData.Count and ItemData.Count > 0 then
            if ItemData.Place == InventorySaveData.Place.Warehouse then
                AddCount(Snapshot.WarehouseCounts, ItemData.ItemID, ItemData.Count)
            elseif ItemData.Place == InventorySaveData.Place.Attached then
                table.insert(Snapshot.Attachments, ItemData)
            else
                AddCount(Snapshot.BackpackAndEquippedCounts, ItemData.ItemID, ItemData.Count)
            end

            if ItemData.Place == InventorySaveData.Place.Equipped and ItemData.Slot then
                Snapshot.EquippedSlots[ItemData.Slot] = ItemData.ItemID
            end
        end
    end

    return Snapshot
end

local function BuildSaveSignature(SaveData)
    local Parts = {}

    if not SaveData or not SaveData.Items then
        return ""
    end

    for Index, ItemData in ipairs(SaveData.Items) do
        Parts[Index] = table.concat({
            tostring(ItemData.ItemID or ""),
            tostring(ItemData.Count or ""),
            tostring(ItemData.Place or ""),
            tostring(ItemData.Slot or ""),
            tostring(ItemData.TargetItemID or ""),
            tostring(ItemData.AttachSlot or ""),
        }, ":")
    end

    return table.concat(Parts, "|")
end

function InventoryService.GetPlayerController(PlayerKey)
    if not PlayerKey then
        return nil
    end

    return UGCGameSystem.GetPlayerControllerByPlayerKey(PlayerKey)
end

function InventoryService.TryLoadAllLobbyPlayers()
    local PlayerControllers = UGCGameSystem.GetAllPlayerController(true)
    if not PlayerControllers then
        return
    end

    for _, PlayerController in pairs(PlayerControllers) do
        local PlayerKey = UGCGameSystem.GetPlayerKeyByPlayerController(PlayerController)
        if PlayerKey then
            InventoryService.TryLoadPlayerInventory(PlayerKey, PlayerController)
        end
    end
end

function InventoryService.TryLoadPlayerInventory(PlayerKey, PlayerController)
    if not PlayerController then
        PlayerController = InventoryService.GetPlayerController(PlayerKey)
    end

    if not PlayerController then
        return false
    end

    if not UGCBackpackSystemV2.CheckInitPersistCompleted(PlayerController) then
        return false
    end

    local SaveData = InventorySaveData.LoadPlayerSave(PlayerKey)
    if not SaveData or not SaveData.Items then
        Log("load failed, empty save data, PlayerKey=" .. tostring(PlayerKey))
        return false
    end

    local SaveSignature = BuildSaveSignature(SaveData)
    if InventoryService.LoadedPlayers[PlayerKey] == SaveSignature then
        return true
    end

    if InventoryService.IsSaveAlreadyApplied(PlayerController, SaveData) then
        InventoryService.ApplyEquipmentSnapshot(PlayerController, SaveData)
        UGCBackpackSystemV2.TrySortOutItemV2(PlayerController)
        UGCBackpackSystemV2.TrySortOutWarehouseItem(PlayerController)
        InventoryService.LoadedPlayers[PlayerKey] = SaveSignature
        InventoryService.LoadResults[PlayerKey] = true
        Log("load skipped, save already applied, PlayerKey=" .. tostring(PlayerKey))
        return true
    end

    local Result = false
    if InventoryService.IsBaseSaveAlreadyApplied(PlayerController, SaveData) then
        InventoryService.ApplyEquipmentSnapshot(PlayerController, SaveData)
        Result = InventoryService.ApplyAttachedSaveItems(PlayerController, SaveData)
        UGCBackpackSystemV2.TrySortOutItemV2(PlayerController)
        UGCBackpackSystemV2.TrySortOutWarehouseItem(PlayerController)
    else
        Result = InventoryService.ApplySaveData(PlayerController, SaveData)
    end

    InventoryService.LoadedPlayers[PlayerKey] = SaveSignature
    InventoryService.LoadResults[PlayerKey] = Result

    if Result then
        Log("load completed, PlayerKey=" .. tostring(PlayerKey))
    else
        Log("load finished with errors, PlayerKey=" .. tostring(PlayerKey))
    end

    return Result
end

function InventoryService.ApplySaveData(Player, SaveData)
    local bAllSuccess = true

    for _, ItemData in ipairs(SaveData.Items) do
        if ItemData.Place ~= InventorySaveData.Place.Attached then
            local bSuccess = InventoryService.ApplySaveItem(Player, ItemData)
            bAllSuccess = bAllSuccess and bSuccess
        end
    end

    InventoryService.ApplyEquipmentSnapshot(Player, SaveData)

    bAllSuccess = InventoryService.ApplyAttachedSaveItems(Player, SaveData) and bAllSuccess

    UGCBackpackSystemV2.TrySortOutItemV2(Player)
    UGCBackpackSystemV2.TrySortOutWarehouseItem(Player)
    return bAllSuccess
end

function InventoryService.ApplyAttachedSaveItems(Player, SaveData)
    local bAllSuccess = true

    if not SaveData or not SaveData.Items then
        return false
    end

    for _, ItemData in ipairs(SaveData.Items) do
        if ItemData.Place == InventorySaveData.Place.Attached then
            local bSuccess = InventoryService.ApplySaveItem(Player, ItemData)
            bAllSuccess = bAllSuccess and bSuccess
        end
    end

    return bAllSuccess
end

function InventoryService.IsBaseSaveAlreadyApplied(Player, SaveData)
    local Snapshot = BuildExpectedSaveSnapshot(SaveData)

    for ItemID, Count in pairs(Snapshot.BackpackAndEquippedCounts) do
        local CurrentCount = UGCBackpackSystemV2.GetItemCountV2(Player, ItemID) or 0
        if CurrentCount < Count then
            return false
        end
    end

    for ItemID, Count in pairs(Snapshot.WarehouseCounts) do
        local CurrentCount = UGCBackpackSystemV2.GetWarehouseItemCount(Player, ItemID) or 0
        if CurrentCount < Count then
            return false
        end
    end

    for SlotName, ItemID in pairs(Snapshot.EquippedSlots) do
        local DefineID = UGCBackpackSystemV2.GetEquippedItemBySlotName(Player, SlotName)
        if not IsValidDefineID(DefineID) or DefineID.TypeSpecificID ~= ItemID then
            return false
        end
    end

    return true
end

function InventoryService.IsSaveAlreadyApplied(Player, SaveData)
    local Snapshot = BuildExpectedSaveSnapshot(SaveData)

    if not InventoryService.IsBaseSaveAlreadyApplied(Player, SaveData) then
        return false
    end

    for _, AttachmentData in ipairs(Snapshot.Attachments) do
        if InventoryService.GetAppliedAttachmentCount(Player, AttachmentData) < AttachmentData.Count then
            return false
        end
    end

    return true
end

function InventoryService.ApplyEquipmentSnapshot(Player, SaveData)
    local Snapshot = BuildExpectedSaveSnapshot(SaveData)

    for _, SlotName in pairs(InventorySaveData.EquipSlot) do
        if not Snapshot.EquippedSlots[SlotName] then
            local DefineID = UGCBackpackSystemV2.GetEquippedItemBySlotName(Player, SlotName)
            if IsValidDefineID(DefineID) then
                UGCBackpackSystemV2.UnEquipItemV2(Player, SlotName)
            end
        end
    end
end

function InventoryService.ApplySaveItem(Player, ItemData)
    if not ItemData or not ItemData.ItemID or not ItemData.Count or ItemData.Count <= 0 then
        return false
    end

    if ItemData.Place == InventorySaveData.Place.Warehouse then
        return InventoryService.AddItemToWarehouse(Player, ItemData.ItemID, ItemData.Count)
    end

    if ItemData.Place == InventorySaveData.Place.Attached then
        return InventoryService.AddAndAttachItem(Player, ItemData)
    end

    if ItemData.Place == InventorySaveData.Place.Equipped then
        return InventoryService.AddAndEquipItem(Player, ItemData.ItemID, ItemData.Count, ItemData.Slot)
    end

    return InventoryService.AddItemToBackpack(Player, ItemData.ItemID, ItemData.Count)
end

function InventoryService.GetAttachSlot(Player, TargetDefineID, TargetItemID, AttachmentItemID, AttachSlot)
    if AttachSlot and AttachSlot ~= "" then
        return AttachSlot
    end

    local AllowSlots = nil
    if TargetDefineID then
        AllowSlots = UGCItemSystemV2.GetAttachAllowSlotsByDefineID(Player, TargetDefineID, AttachmentItemID)
    end
    if AllowSlots then
        for _, SlotName in pairs(AllowSlots) do
            if SlotName and SlotName ~= "" then
                return SlotName
            end
        end
    end

    AllowSlots = UGCItemSystemV2.GetAttachAllowSlots(TargetItemID, AttachmentItemID)
    if AllowSlots then
        for _, SlotName in pairs(AllowSlots) do
            if SlotName and SlotName ~= "" then
                return SlotName
            end
        end
    end

    return nil
end

function InventoryService.GetAppliedAttachmentCount(Player, AttachmentData)
    if not AttachmentData or not AttachmentData.TargetItemID then
        return 0
    end

    local TargetDefineIDs = UGCBackpackSystemV2.GetItemDefineIDsByIDV2(Player, AttachmentData.TargetItemID)
    if not TargetDefineIDs then
        return 0
    end

    local AppliedCount = 0
    for _, TargetDefineID in pairs(TargetDefineIDs) do
        if IsValidDefineID(TargetDefineID) then
            local SlotName = InventoryService.GetAttachSlot(Player, TargetDefineID, AttachmentData.TargetItemID, AttachmentData.ItemID, AttachmentData.AttachSlot)
            if SlotName then
                local ChildDefineID = UGCItemSystemV2.GetAttachChildItem(TargetDefineID, SlotName)
                if IsValidDefineID(ChildDefineID) and ChildDefineID.TypeSpecificID == AttachmentData.ItemID then
                    AppliedCount = AppliedCount + 1
                end
            end
        end
    end

    return AppliedCount
end

function InventoryService.AddAndAttachItem(Player, ItemData)
    if not ItemData.TargetItemID then
        Log("AddAndAttachItem failed, empty target, ItemID=" .. tostring(ItemData.ItemID))
        return false
    end

    local TargetDefineIDs = UGCBackpackSystemV2.GetItemDefineIDsByIDV2(Player, ItemData.TargetItemID)
    if not TargetDefineIDs then
        Log("AddAndAttachItem failed, empty target list, TargetItemID=" .. tostring(ItemData.TargetItemID))
        return false
    end

    local NeedCount = ItemData.Count or 0
    local AttachedCount = InventoryService.GetAppliedAttachmentCount(Player, ItemData)

    if AttachedCount >= NeedCount then
        return true
    end

    for _, TargetDefineID in pairs(TargetDefineIDs) do
        if AttachedCount >= NeedCount then
            break
        end

        if IsValidDefineID(TargetDefineID) then
            local SlotName = InventoryService.GetAttachSlot(Player, TargetDefineID, ItemData.TargetItemID, ItemData.ItemID, ItemData.AttachSlot)
            if SlotName then
                local ChildDefineID = UGCItemSystemV2.GetAttachChildItem(TargetDefineID, SlotName)
                if not IsValidDefineID(ChildDefineID) then
                    local AttachmentDefineID = UGCItemSystemV2.GetItemDefineID(ItemData.ItemID)
                    if AttachmentDefineID then
                        local AddedCount = UGCBackpackSystemV2.AddItemByDefineIDV2(Player, AttachmentDefineID, 1, false) or 0
                        if AddedCount > 0 and UGCBackpackSystemV2.AttachEquipmentToTargetItem(Player, AttachmentDefineID, TargetDefineID, SlotName) then
                            AttachedCount = AttachedCount + 1
                        else
                            Log(string.format("AttachEquipmentToTargetItem failed, ItemID=%s TargetItemID=%s Slot=%s", tostring(ItemData.ItemID), tostring(ItemData.TargetItemID), tostring(SlotName)))
                        end
                    else
                        Log("AddAndAttachItem failed, invalid DefineID, ItemID=" .. tostring(ItemData.ItemID))
                    end
                end
            else
                Log(string.format("AddAndAttachItem failed, empty attach slot, ItemID=%s TargetItemID=%s", tostring(ItemData.ItemID), tostring(ItemData.TargetItemID)))
            end
        end
    end

    if AttachedCount < NeedCount then
        Log(string.format("AddAndAttachItem partial, ItemID=%s TargetItemID=%s Count=%s Attached=%s", tostring(ItemData.ItemID), tostring(ItemData.TargetItemID), tostring(NeedCount), tostring(AttachedCount)))
    end

    return AttachedCount >= NeedCount
end

function InventoryService.AddItemToBackpack(Player, ItemID, Count)
    local AddedCount = UGCBackpackSystemV2.AddItemV2(Player, ItemID, Count)
    AddedCount = AddedCount or 0
    local bSuccess = AddedCount == Count
    if not bSuccess then
        Log(string.format("AddItemToBackpack partial, ItemID=%s Count=%s Added=%s", tostring(ItemID), tostring(Count), tostring(AddedCount)))
    end
    return bSuccess
end

function InventoryService.AddItemToWarehouse(Player, ItemID, Count)
    local RemainingCount = Count
    local AddedTotal = 0

    while RemainingCount > 0 do
        local DefineID = UGCItemSystemV2.GetItemDefineID(ItemID)
        if not DefineID then
            Log("AddItemToWarehouse failed, invalid DefineID, ItemID=" .. tostring(ItemID))
            break
        end

        local AddedCount = UGCBackpackSystemV2.AddItemByDefineIDV2(Player, DefineID, RemainingCount, false)
        AddedCount = AddedCount or 0
        if AddedCount <= 0 then
            break
        end

        UGCBackpackSystemV2.PutInWarehouse(Player, DefineID, AddedCount)
        AddedTotal = AddedTotal + AddedCount
        RemainingCount = RemainingCount - AddedCount
    end

    if RemainingCount > 0 then
        Log(string.format("AddItemToWarehouse partial, ItemID=%s Count=%s Added=%s", tostring(ItemID), tostring(Count), tostring(AddedTotal)))
    end

    return AddedTotal == Count
end

function InventoryService.AddAndEquipItem(Player, ItemID, Count, SlotName)
    if not SlotName or SlotName == "" then
        Log("AddAndEquipItem failed, empty slot, ItemID=" .. tostring(ItemID))
        return false
    end

    local DefineID = UGCItemSystemV2.GetItemDefineID(ItemID)
    if not DefineID then
        Log("AddAndEquipItem failed, invalid DefineID, ItemID=" .. tostring(ItemID))
        return false
    end

    local AddedCount = UGCBackpackSystemV2.AddItemByDefineIDV2(Player, DefineID, Count, false)
    AddedCount = AddedCount or 0
    if AddedCount <= 0 then
        Log(string.format("AddAndEquipItem add failed, ItemID=%s Count=%s", tostring(ItemID), tostring(Count)))
        return false
    end

    local bEquipped = UGCBackpackSystemV2.EquipItemV2(Player, SlotName, DefineID)
    if not bEquipped then
        Log(string.format("EquipItemV2 failed, ItemID=%s Slot=%s", tostring(ItemID), tostring(SlotName)))
    end

    return AddedCount == Count and bEquipped
end

return InventoryService
