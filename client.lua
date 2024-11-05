-- client.lua

local isNearWarehouse = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = #(playerCoords - Config.WarehouseLocation)  -- Menggunakan vector3 langsung dari config

        if distance < 5.0 then
            isNearWarehouse = true
            DisplayHelpText("Tekan ~INPUT_CONTEXT~ untuk mengakses gudang.")
            if IsControlJustPressed(0, 38) then -- Tekan E untuk membuka gudang
                OpenWarehouse()
            end
        else
            isNearWarehouse = false
        end
    end
end)

function DisplayHelpText(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function OpenWarehouse()
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "openWarehouse"
    })
end

RegisterNUICallback("closeWarehouse", function(data, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("storeItem", function(data, cb)
    local item = data.item
    local amount = data.amount
    TriggerServerEvent("warehouse:storeItem", item, amount)
    cb("ok")
end)

RegisterNUICallback("takeItem", function(data, cb)
    local item = data.item
    local amount = data.amount
    TriggerServerEvent("warehouse:takeItem", item, amount)
    cb("ok")
end)

RegisterNetEvent('warehouse:notify')
AddEventHandler('warehouse:notify', function(message)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(false, true)
end)
