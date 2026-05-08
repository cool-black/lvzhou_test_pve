local InventorySaveData = {}

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

function InventorySaveData.LoadPlayerSave(PlayerKey)
    return {
        PlayerKey = PlayerKey,
        Items = MOCK_ITEMS,
    }
end

return InventorySaveData
