-- config.lua

Config = {}

-- Lokasi Gudang dalam format vector3
Config.WarehouseLocation = vector3(1000.0, -3000.0, -39.0)

-- Pengaturan kapasitas
Config.MaxCapacity = 1000 -- Jumlah maksimal item yang dapat disimpan

-- Framework yang digunakan: 'QBCore' atau 'ESX'
Config.Framework = 'QBCore'

-- Inventory system yang digunakan: 'ox_inventory', 'qb-inventory', 'esx_inventory'
Config.InventorySystem = 'ox_inventory'

-- Daftar item yang diblacklist (tidak bisa disimpan di gudang)
Config.BlacklistItems = {
    "weapon_pistol",      -- Contoh item senjata
    "illegal_item",       -- Item yang dilarang
    "special_item"        -- Item spesial
}
