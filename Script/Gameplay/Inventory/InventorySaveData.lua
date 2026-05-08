local InventorySaveData = {}

_G.TestGunfirePlayerSaveData = _G.TestGunfirePlayerSaveData or {}

InventorySaveData.Place = {
    Backpack = "Backpack",
    Warehouse = "Warehouse",
    Equipped = "Equipped",
    Attached = "Attached",
}

InventorySaveData.EquipSlot = {
    PrimaryWeapon = "EquipmentSlot.Core.MainSlot1",
    SecondaryWeapon = "EquipmentSlot.Core.MainSlot2",
    Helmet = "EquipmentSlot.Core.Helmet",
    Armor = "EquipmentSlot.Core.Armor",
}

InventorySaveData.AttachSlot = {
    Muzzle = "EquipmentSlot.Core.GunPoint",
}

local MOCK_ITEMS = {
    { ItemID = 8310000, Count = 140, Place = InventorySaveData.Place.Backpack },
    { ItemID = 8310000, Count = 200, Place = InventorySaveData.Place.Warehouse },
    {
        ItemID = 8310001,
        Count = 1,
        Place = InventorySaveData.Place.Equipped,
        Slot = InventorySaveData.EquipSlot.PrimaryWeapon,
    },
    { ItemID = 8310001, Count = 1, Place = InventorySaveData.Place.Backpack },
    { ItemID = 8310001, Count = 1, Place = InventorySaveData.Place.Warehouse },
    {
        ItemID = 8310002,
        Count = 2,
        Place = InventorySaveData.Place.Attached,
        TargetItemID = 8310001,
        AttachSlot = InventorySaveData.AttachSlot.Muzzle,
    },
}

local function CloneItem(ItemData)
    local NewItemData = {}

    if not ItemData then
        return NewItemData
    end

    for Key, Value in pairs(ItemData) do
        NewItemData[Key] = Value
    end

    return NewItemData
end

local function CloneItems(Items)
    local NewItems = {}

    if not Items then
        return NewItems
    end

    for Index, ItemData in ipairs(Items) do
        NewItems[Index] = CloneItem(ItemData)
    end

    return NewItems
end

local function GetPlayerKeyString(PlayerKey)
    return tostring(PlayerKey or "Unknown")
end

function InventorySaveData.LoadPlayerSave(PlayerKey)
    local PlayerKeyString = GetPlayerKeyString(PlayerKey)
    if not _G.TestGunfirePlayerSaveData[PlayerKeyString] then
        _G.TestGunfirePlayerSaveData[PlayerKeyString] = {
            PlayerKey = PlayerKey,
            Items = CloneItems(MOCK_ITEMS),
        }
        ugcprint("[InventorySaveData] InitMockSave PlayerKey=" .. tostring(PlayerKey))
    end

    local SaveData = _G.TestGunfirePlayerSaveData[PlayerKeyString]
    return {
        PlayerKey = PlayerKey,
        Items = CloneItems(SaveData.Items),
    }
end

function InventorySaveData.SavePlayerSave(PlayerKey, SaveData)
    local PlayerKeyString = GetPlayerKeyString(PlayerKey)
    local Items = SaveData and SaveData.Items or {}

    _G.TestGunfirePlayerSaveData[PlayerKeyString] = {
        PlayerKey = PlayerKey,
        Items = CloneItems(Items),
    }

    ugcprint(string.format("[InventorySaveData] SavePlayerSave PlayerKey=%s ItemRows=%s", tostring(PlayerKey), tostring(#Items)))
    return true
end

return InventorySaveData
