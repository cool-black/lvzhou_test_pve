local InventorySaveData = UGCGameSystem.UGCRequire('Script.Gameplay.Inventory.InventorySaveData')

local InventorySettlementService = {}

local function Log(Message)
    ugcprint("[InventorySettlement] " .. tostring(Message))
end

local function IsValidDefineID(DefineID)
    return DefineID ~= nil and DefineID.Type ~= 0 and DefineID.TypeSpecificID ~= 0 and DefineID.InstanceID ~= 0
end

local function GetDefineKey(DefineID)
    if not IsValidDefineID(DefineID) then
        return nil
    end

    return table.concat({
        tostring(DefineID.Type),
        tostring(DefineID.TypeSpecificID),
        tostring(DefineID.InstanceID),
    }, ":")
end

local function AddItemRow(Items, ItemID, Count, Place, Slot, TargetItemID, AttachSlot)
    if not ItemID or not Count or Count <= 0 then
        return
    end

    table.insert(Items, {
        ItemID = ItemID,
        Count = Count,
        Place = Place,
        Slot = Slot,
        TargetItemID = TargetItemID,
        AttachSlot = AttachSlot,
    })
end

local function AddCountRow(CountMap, ItemID, Count, Place)
    if not ItemID or not Count or Count <= 0 then
        return
    end

    local Key = tostring(Place) .. ":" .. tostring(ItemID)
    local CountData = CountMap[Key]
    if not CountData then
        CountData = {
            ItemID = ItemID,
            Count = 0,
            Place = Place,
        }
        CountMap[Key] = CountData
    end

    CountData.Count = CountData.Count + Count
end

local function AddAttachmentRow(AttachmentMap, ItemID, Count, TargetItemID, AttachSlot)
    if not ItemID or not Count or Count <= 0 or not TargetItemID then
        return
    end

    local SlotName = AttachSlot and tostring(AttachSlot) or nil
    local Key = table.concat({
        tostring(ItemID),
        tostring(TargetItemID),
        tostring(SlotName or ""),
    }, ":")
    local AttachmentData = AttachmentMap[Key]
    if not AttachmentData then
        AttachmentData = {
            ItemID = ItemID,
            Count = 0,
            Place = InventorySaveData.Place.Attached,
            TargetItemID = TargetItemID,
            AttachSlot = SlotName,
        }
        AttachmentMap[Key] = AttachmentData
    end

    AttachmentData.Count = AttachmentData.Count + Count
end

local function AddCountRowsToItems(Items, CountMap)
    for _, CountData in pairs(CountMap) do
        AddItemRow(Items, CountData.ItemID, CountData.Count, CountData.Place)
    end
end

local function AddAttachmentRowsToItems(Items, AttachmentMap)
    for _, AttachmentData in pairs(AttachmentMap) do
        AddItemRow(
            Items,
            AttachmentData.ItemID,
            AttachmentData.Count,
            AttachmentData.Place,
            nil,
            AttachmentData.TargetItemID,
            AttachmentData.AttachSlot
        )
    end
end

function InventorySettlementService.CollectWarehouseItems(Player)
    local Items = {}
    local WarehouseCounts = {}
    local DefineIDs = UGCBackpackSystemV2.GetAllWarehouseItemDefineIDs(Player)

    if DefineIDs then
        for _, DefineID in pairs(DefineIDs) do
            if IsValidDefineID(DefineID) then
                local Count = UGCBackpackSystemV2.GetWarehouseItemCountByDefineID(Player, DefineID) or 0
                AddCountRow(WarehouseCounts, DefineID.TypeSpecificID, Count, InventorySaveData.Place.Warehouse)
            end
        end
    end

    AddCountRowsToItems(Items, WarehouseCounts)
    return Items
end

function InventorySettlementService.CollectRunItems(Player)
    local Items = {}
    local EquippedKeys = {}
    local BackpackCounts = {}
    local AttachmentMap = {}

    for _, SlotName in pairs(InventorySaveData.EquipSlot) do
        local DefineID = UGCBackpackSystemV2.GetEquippedItemBySlotName(Player, SlotName)
        if IsValidDefineID(DefineID) then
            EquippedKeys[GetDefineKey(DefineID)] = true
            AddItemRow(Items, DefineID.TypeSpecificID, 1, InventorySaveData.Place.Equipped, SlotName)
        end
    end

    local DefineIDs = UGCBackpackSystemV2.GetAllItemDefineIDsV2(Player)
    if DefineIDs then
        for _, DefineID in pairs(DefineIDs) do
            if IsValidDefineID(DefineID) then
                local DefineKey = GetDefineKey(DefineID)
                local bAttached, TargetDefineID, AttachSlot = UGCItemSystemV2.GetAttachTargetItem(DefineID)
                if bAttached and IsValidDefineID(TargetDefineID) then
                    AddAttachmentRow(AttachmentMap, DefineID.TypeSpecificID, 1, TargetDefineID.TypeSpecificID, AttachSlot)
                elseif not EquippedKeys[DefineKey] then
                    local Count = UGCBackpackSystemV2.GetItemCountByDefineIDV2(Player, DefineID) or 0
                    AddCountRow(BackpackCounts, DefineID.TypeSpecificID, Count, InventorySaveData.Place.Backpack)
                end
            end
        end
    end

    AddCountRowsToItems(Items, BackpackCounts)
    AddAttachmentRowsToItems(Items, AttachmentMap)
    return Items
end

function InventorySettlementService.CollectCurrentSave(PlayerController, bKeepRunItems)
    local Items = InventorySettlementService.CollectWarehouseItems(PlayerController)

    if bKeepRunItems then
        local RunItems = InventorySettlementService.CollectRunItems(PlayerController)
        for _, ItemData in ipairs(RunItems) do
            table.insert(Items, ItemData)
        end
    end

    return {
        PlayerKey = UGCGameSystem.GetPlayerKeyByPlayerController(PlayerController),
        Items = Items,
    }
end

function InventorySettlementService.ClearRunItems(Player)
    local RemoveList = {}
    local DefineIDs = UGCBackpackSystemV2.GetAllItemDefineIDsV2(Player)

    if DefineIDs then
        for _, DefineID in pairs(DefineIDs) do
            if IsValidDefineID(DefineID) then
                table.insert(RemoveList, {
                    DefineID = DefineID,
                    Count = UGCBackpackSystemV2.GetItemCountByDefineIDV2(Player, DefineID) or 1,
                })
            end
        end
    end

    for _, SlotName in pairs(InventorySaveData.EquipSlot) do
        local DefineID = UGCBackpackSystemV2.GetEquippedItemBySlotName(Player, SlotName)
        if IsValidDefineID(DefineID) then
            UGCBackpackSystemV2.UnEquipItemV2(Player, SlotName)
            table.insert(RemoveList, {
                DefineID = DefineID,
                Count = UGCBackpackSystemV2.GetItemCountByDefineIDV2(Player, DefineID) or 1,
            })
        end
    end

    local RemovedCount = 0
    local RemovedKeys = {}
    for _, RemoveData in ipairs(RemoveList) do
        local DefineID = RemoveData.DefineID
        local DefineKey = GetDefineKey(DefineID)
        if DefineKey and not RemovedKeys[DefineKey] then
            RemovedKeys[DefineKey] = true
            local Count = RemoveData.Count or 1
            if Count <= 0 then
                Count = 1
            end

            local Removed = UGCBackpackSystemV2.RemoveItemByDefineIDV2(Player, DefineID, Count) or 0
            if Removed <= 0 then
                Removed = UGCBackpackSystemV2.RemoveItemV2(Player, DefineID.TypeSpecificID, Count) or 0
            end

            if Removed > 0 then
                RemovedCount = RemovedCount + 1
            else
                Log(string.format("RemoveItemByDefineIDV2 failed, ItemID=%s Count=%s", tostring(DefineID.TypeSpecificID), tostring(Count)))
            end
        end
    end

    UGCBackpackSystemV2.TrySortOutItemV2(Player)
    return RemovedCount
end

function InventorySettlementService.SettlePlayer(PlayerController, bIsFinish, Reason)
    if not PlayerController then
        Log("SettlePlayer failed, PlayerController is nil")
        return false
    end

    local PlayerKey = UGCGameSystem.GetPlayerKeyByPlayerController(PlayerController)
    local SaveData = InventorySettlementService.CollectCurrentSave(PlayerController, bIsFinish)
    InventorySaveData.SavePlayerSave(PlayerKey, SaveData)

    local RemovedCount = 0
    if not bIsFinish then
        RemovedCount = InventorySettlementService.ClearRunItems(PlayerController)
    end

    Log(string.format(
        "SettlePlayer PlayerKey=%s IsFinish=%s Reason=%s SaveRows=%s RemovedRunRows=%s",
        tostring(PlayerKey),
        tostring(bIsFinish),
        tostring(Reason),
        tostring(#SaveData.Items),
        tostring(RemovedCount)
    ))
    return true
end

return InventorySettlementService
