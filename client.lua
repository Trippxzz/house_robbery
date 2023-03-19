ESX = nil
local PlayerData = {}

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(500)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(100)
    end

    Citizen.Wait(800)
    PlayerData = ESX.GetPlayerData() -- Setting PlayerData vars
end)
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)

local alllocations = {}
local randomlocation = 1

Citizen.CreateThread(function()
	local idhouse = 1
	for k,v in pairs(Config.Houses) do
		table.insert(alllocations, {
				id = idhouse,
				door = vector3(v.Door.x, v.Door.y, v.Door.z),
                interior = vector3(v.Interior.x, v.Interior.y, v.Interior.z),
                hint = v.HeadingInt,
                loot = v.LootH
		})
		idhouse = idhouse + 1  
	end
end)


Citizen.CreateThread(function()
	local pedh = GetHashKey(Config.Ped.Name)
	RequestModel(pedh)
	while not HasModelLoaded(pedh) do
		Citizen.Wait(1)
	end	
	PED = CreatePed(1, pedh, Config.Ped.Pos.x, Config.Ped.Pos.y, Config.Ped.Pos.z, Config.Ped.Pos.h, false, true)
	SetBlockingOfNonTemporaryEvents(PED, true)
	SetPedDiesWhenInjured(PED, false)
	SetPedCanPlayAmbientAnims(PED, true)
	SetPedCanRagdollFromPlayerImpact(PED, false)
	SetEntityInvincible(PED, true)
	FreezeEntityPosition(PED, true)

    if Config.OxTarget then
            local options = {
                {
                    name = 'steal:house',
                    event = 'fly:startminigame', 
                    icon = 'fa-solid fa-house',
                    label = 'Steals a house',
                },
            }
            exports.ox_target:addModel(pedh, options)
    
    else
        while true do
            s = 1000
            local coords = GetEntityCoords(PlayerPedId())
                if GetDistanceBetweenCoords(coords, Config.Ped.Pos.x, Config.Ped.Pos.y, Config.Ped.Pos.z, true) < 4 and PlayerData.job ~= nil and PlayerData.job.name ~= Config.JobName then
                    s = 5
                    ESX.ShowFloatingHelpNotification("Press [E] to steals a house", vector3(Config.Ped.Pos.x, Config.Ped.Pos.y, Config.Ped.Pos.z+1.9))
                     if GetDistanceBetweenCoords(coords, Config.Ped.Pos.x, Config.Ped.Pos.y, Config.Ped.Pos.z, true) < 2 then
                            if IsControlJustReleased(1, 51) and PlayerData.job ~= nil and  PlayerData.job.name ~= Config.JobName  then 
                                    if IsControlJustReleased(1, 51)  then
                                        TriggerEvent('fly:startrobbery')
                                    else
                                        ESX.ShowNotification(Config.Language.NoPoli, 3500)
                                    end
                                end
                           end
                     end
            Citizen.Wait(s)
        end
    end
end)


RegisterNetEvent('fly:startrobbery')
AddEventHandler('fly:startrobbery', function()
        randomlocation = math.random(1,#alllocations)
		Blip = AddBlipForCoord(alllocations[randomlocation].door)	
		SetBlipSprite(Blip, 1)
		SetBlipColour(Blip, 2)
		SetBlipAsShortRange(Blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("House")
		EndTextCommandSetBlipName(Blip)
		SetBlipAsMissionCreatorBlip(Blip, true)
		SetBlipRoute(Blip, true)

        Citizen.CreateThread(function()
            while true do
                s = 1000 
                local coords = GetEntityCoords(PlayerPedId())
                    if GetDistanceBetweenCoords(coords, alllocations[randomlocation].door ) < 6 and PlayerData.job ~= nil and PlayerData.job.name ~= Config.PoliceJob then
                        s = 5
                        if Config.OxTarget then
                            exports.ox_target:addSphereZone({
                                coords = alllocations[randomlocation].door,
                                radius = 1,
                                debug = false,
                                options = {
                                    {
                                        name = 'opendoor',
                                        event = 'fly:startminigame',
                                        icon = 'fa-solid fa-circle',
                                        label = 'Start the robbery house',
                                    }
                                }
                            })
                        else
                            ESX.ShowFloatingHelpNotification("Press [E] to start the robbery house", vector3(alllocations[randomlocation].door+2))
                            if IsControlJustReleased(0,38)  then
                                TriggerEvent('fly:startrobbery')	
                            end
                        end
                        end
                Citizen.Wait(s)
            end
        end)
end)

RegisterNetEvent('fly:startminigame')
AddEventHandler('fly:startminigame', function()
    local success = lib.skillCheck({ 'easy', 'easy', 'easy', { areaSize = 60, speedMultiplier = 1 }, 'easy' })

    
        if success then
            SetEntityCoords(PlayerPedId(),alllocations[randomlocation].interior,0,0,0,0)
			SetEntityHeading(PlayerPedId(),alllocations[randomlocation].hint)
            DisplayLoot()
            if GetPedDrawableVariation(PlayerPedId(), 1) == 0 then
                print("notenimascara")
            else
               print("tenimascara")
            end
            Citizen.CreateThread(function()
                while true do
                    s = 1000
                    local coords = GetEntityCoords(PlayerPedId())
                        if GetDistanceBetweenCoords(coords,alllocations[randomlocation].interior, true) < 2 then
                             s = 5
                             if Config.OxTarget then
                                exports.ox_target:addSphereZone({
                                    coords = alllocations[randomlocation].interior,
                                    radius = 1,
                                    debug = false,
                                    options = {
                                        {
                                            name = 'exithouse',
                                            event = 'fly:leavehouse',
                                            icon = 'fa-solid fa-circle',
                                            label = 'Leaves the house',
                                        }
                                    }
                                })
                            else
                                ESX.ShowFloatingHelpNotification("Press [E] to Leaves the house", vector3(alllocations[randomlocation].door+2))
                                if IsControlJustReleased(0,38)  then
                                    SetEntityCoords(PlayerPedId(),alllocations[randomlocation].door,0,0,0,0)
                                end
                            end
                        end
                    Citizen.Wait(s)
                end
            end)
        else
            print('quitaitem')
        end
end)

RegisterNetEvent('fly:leavehouse')
AddEventHandler('fly:leavehouse', function()
    SetEntityCoords(PlayerPedId(),alllocations[randomlocation].door,0,0,0,0)
end)
RegisterCommand('te', function ()
    DisplayLoot()
end)


function DisplayLoot()
    for i,v in ipairs(alllocations[randomlocation].loot) do
    local collected = false
    Citizen.CreateThread(function()
        while true do
            s = 1000
            local coords = GetEntityCoords(PlayerPedId())
                if GetDistanceBetweenCoords(coords,alllocations[randomlocation].loot[i], true) < 2 and PlayerData.job ~= nil and PlayerData.job.name ~= Config.JobName  then
                     s = 5
                     ESX.ShowFloatingHelpNotification("Press [E] to steals a house",alllocations[randomlocation].loot[i])
                        if GetDistanceBetweenCoords(coords,alllocations[randomlocation].loot[i], true) < 1 then
                                if IsControlJustReleased(1, 51) and not collected then
                                        print('entregaitemrandompornivel')
                                    else
                                        print('robao')
                                end

                        end
                end
            Citizen.Wait(s)
        end
    end)
end
end