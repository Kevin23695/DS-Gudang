-- server.lua

local WarehouseStorage = {}

-- Fungsi untuk mendapatkan framework yang sesuai
local function getFramework()
    return Config.Framework == 'QBCore' and exports['qb-core']:GetCoreObject() or (Config.Framework == 'ESX' and ESX or nil)
end

-- Fungsi untuk memeriksa apakah item termasuk dalam blacklist
local function isBlacklistedItem(item)
    for _, blacklistedItem in ipairs(Config.BlacklistItems) do
        if item == blacklistedItem then
            return true
        end
    end
    return false
end

-- Fungsi untuk mendapatkan jumlah item di inventory pemain
local function getInventoryItemCount(xPlayer, item)
    if Config.InventorySystem == 'ox_inventory' then
        return exports.ox_inventory:GetItem(xPlayer.source, item).count
    elseif Config.InventorySystem == 'qb-inventory' then
        return xPlayer.Functions.GetItemByName(item) and xPlayer.Functions.GetItemByName(item).amount or 0
    elseif Config.InventorySystem == 'esx_inventory' then
        return xPlayer.getInventoryItem(item).count
    else
        return 0
    end
end

-- Fungsi untuk menambahkan item ke inventory pemain
local function addInventoryItem(xPlayer, item, amount)
    if Config.InventorySystem == 'ox_inventory' then
        exports.ox_inventory:AddItem(xPlayer.source, item, amount)
    elseif Config.InventorySystem == 'qb-inventory' then
        xPlayer.Functions.AddItem(item, amount)
    elseif Config.InventorySystem == 'esx_inventory' then
        xPlayer.addInventoryItem(item, amount)
    end
end

-- Fungsi untuk menghapus item dari inventory pemain
local function removeInventoryItem(xPlayer, item, amount)
    if Config.InventorySystem == 'ox_inventory' then
        exports.ox_inventory:RemoveItem(xPlayer.source, item, amount)
    elseif Config.InventorySystem == 'qb-inventory' then
        xPlayer.Functions.RemoveItem(item, amount)
    elseif Config.InventorySystem == 'esx_inventory' then
        xPlayer.removeInventoryItem(item, amount)
    end
end

-- Fungsi untuk menyimpan item ke gudang
RegisterServerEvent("warehouse:storeItem")
AddEventHandler("warehouse:storeItem", function(item, amount)
    local source = source
    local xPlayer = getFramework().GetPlayerFromId(source)

    -- Cek apakah item termasuk dalam blacklist
    if isBlacklistedItem(item) then
        TriggerClientEvent('chat:addMessage', source, { args = { "Gudang", "Item ini tidak bisa disimpan di gudang." } })
        return
    end

    local itemCount = getInventoryItemCount(xPlayer, item)

    if itemCount >= amount then
        removeInventoryItem(xPlayer, item, amount)
        WarehouseStorage[item] = (WarehouseStorage[item] or 0) + amount
        TriggerClientEvent('chat:addMessage', source, { args = { "Gudang", "Item berhasil disimpan ke gudang." } })
    else
        TriggerClientEvent('chat:addMessage', source, { args = { "Gudang", "Item tidak mencukupi." } })
    end
end)

-- Fungsi untuk mengambil item dari gudang
RegisterServerEvent("warehouse:takeItem")
AddEventHandler("warehouse:takeItem", function(item, amount)
    local source = source
    local xPlayer = getFramework().GetPlayerFromId(source)
    
    if WarehouseStorage[item] and WarehouseStorage[item] >= amount then
        addInventoryItem(xPlayer, item, amount)
        WarehouseStorage[item] = WarehouseStorage[item] - amount
        TriggerClientEvent('chat:addMessage', source, { args = { "Gudang", "Item berhasil diambil dari gudang." } })
    else
        TriggerClientEvent('chat:addMessage', source, { args = { "Gudang", "Item tidak mencukupi di gudang." } })
    end
end)

-- Fungsi untuk mengecek isi gudang
RegisterServerEvent("warehouse:getInventory")
AddEventHandler("warehouse:getInventory", function()
    local source = source
    TriggerClientEvent("warehouse:returnInventory", source, WarehouseStorage)
end)
