ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('fly:checkitem')
AddEventHandler('fly:checkitem', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local item = exports.ox_inventory:GetItem(source, Config.ItemRequired, nil, 1)
    if Config.RequiredItem then
        if xPlayer.getInventoryItem(Config.ItemRequired).count >= 1 then -- or if xPlayer.getInventoryItem('Config.ItemRequired', 1) then  ####  for users who do not use ox inventory
            xPlayer.triggerEvent('fly:startminigame')
        else
            xPlayer.showNotification('You dont have a lock pick')
        end
    else
        xPlayer.triggerEvent('fly:startminigame')
        print('mono')
    end
end)

RegisterServerEvent('fly:removeitem')
AddEventHandler('fly:removeitem', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeInventoryItem(Config.ItemRequired, 1)
end)


RegisterServerEvent('fly:giveloot')
AddEventHandler('fly:giveloot', function ()
    local xPlayer = ESX.GetPlayerFromId(source)
    local random = math.random(1,3) 
    if random == 1 then
        xPlayer.addInventoryItem(Config.Loot.badloot[math.random(#Config.Loot.badloot)], math.random(Config.Cant.badloot[1], Config.Cant.badloot[2]))
    elseif random == 2 then
        xPlayer.addInventoryItem(Config.Loot.mediumloot[math.random(#Config.Loot.mediumloot)], math.random(Config.Cant.mediumloot[1], Config.Cant.mediumloot[2]))
    elseif random == 3 then
        xPlayer.addInventoryItem(Config.Loot.goodloot[math.random(#Config.Loot.goodloot)], tonumber(math.random(Config.Cant.goodloot[1], Config.Cant.goodloot[2])))
    end
end)


ESX.RegisterServerCallback('fly:contpolice', function(source, cb)
    local police = 0
    local xPlayers = ESX.GetPlayers()
    for i = 1, #xPlayers do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        if xPlayer.job.name == Config.JobName then
            police = police + 1
        end
    end
    if police >= Config.CopsRequired then
        cb(true)
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback('fly:house:cooldown', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
	if (os.time() - Config.Lastrob) < Config.Cooldown and Config.Lastrob ~= 0 then
		cb(false)
        xPlayer.showNotification("A robbery has just started, you must wait a little while.")
	else
		cb(true)
	end
end)

RegisterServerEvent('fly:time')
AddEventHandler('fly:time', function()
    Config.Lastrob = os.time()
end)

RegisterServerEvent('fly:sendcall')
AddEventHandler('fly:sendcall', function(coords)
    TriggerClientEvent('fly:policecall', -1, coords)
end)

