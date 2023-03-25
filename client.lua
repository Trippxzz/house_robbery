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

local start, inside, can_review, revising, all_reviewed = false, false, true, false, false
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
    if start == false then
        if Config.OxTarget then
                local options = {
                    {
                        name = 'steal:house',
                        event = 'fly:checkpolice', 
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
                                            TriggerEvent('fly:checkpolice')
                                    end
                            end
                        end
                Citizen.Wait(s)
            end
        end
    else
        ESX.ShowNotification("You already have a robbery in progress!")
    end
end)

RegisterNetEvent('fly:checkpolice')
AddEventHandler('fly:checkpolice', function()
    Citizen.CreateThread(function()
        while true do
            s = 1000
            local canrob = nil
                ESX.TriggerServerCallback('fly:house:cooldown', function(can)	
                    if can then
                        ESX.TriggerServerCallback('fly:contpolice', function(cb)
                            canrob = cb
                        end)
                        while canrob == nil do
                            Wait(10)
                        end
                        if canrob then
                            TriggerServerEvent('fly:time')
                            TriggerEvent('fly:startrobbery')
                            exit = false
                        else
                            ESX.ShowNotification("Not enough cops connected")
                        end
                    end
                end)
            Citizen.Wait(s)
            break
        end
    end)
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
        ESX.ShowNotification("Perfect, go to the marked house and steal as much as you can.")
        start = true
        Citizen.CreateThread(function()
            while true do
                s = 1000 
                local coords = GetEntityCoords(PlayerPedId())
                    if GetDistanceBetweenCoords(coords, alllocations[randomlocation].door ) < 3 then
                        s = 5
                            if Config.OxTarget then
                                if start == true then
                                       exports.ox_target:addSphereZone({
                                        coords = alllocations[randomlocation].door,
                                        radius = 1,
                                        debug = false,
                                        options = {
                                            {
                                                name = 'opendoor',
                                                serverEvent = 'fly:checkitem',
                                                icon = 'fa-solid fa-circle',
                                                label = 'Sheet metal forcing',
                                                canInteract = function()
                                                    return start
                                                end
                                            }
                                        }
                                    })
                                end
                            else
                                ESX.ShowFloatingHelpNotification("Press [E] to Sheet metal forcing", vector3(alllocations[randomlocation].door))
                                if IsControlJustReleased(0,38) and PlayerData.job.name ~= Config.PoliceJob then
                                    if start == true then
                                    TriggerServerEvent('fly:checkitem')
                                    else
                                        ESX.ShowNotification("You can no longer re-enter")
                                    end
                                end
                            end
                    end
                Citizen.Wait(s)
            end
        end)
        Timetoarrive()
end)

RegisterNetEvent('fly:startminigame')
AddEventHandler('fly:startminigame', function()
    startAnim(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer")
    local success = lib.skillCheck({ 'easy', 'easy', 'easy', { areaSize = 60, speedMultiplier = 1 }, 'easy' })

        if success then
            inside = true
            RemoveBlip(Blip)
            ClearPedTasks(PlayerPedId())
            SetEntityCoords(PlayerPedId(),alllocations[randomlocation].interior,0,0,0,0)
			SetEntityHeading(PlayerPedId(),alllocations[randomlocation].hint)
            DisplayLoot()
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
                                ESX.ShowFloatingHelpNotification("Press [E] to leaves the house", vector3(alllocations[randomlocation].interior))
                                if IsControlJustReleased(0,38)  then
                                    SetEntityCoords(PlayerPedId(),alllocations[randomlocation].door,0,0,0,0)
                                end
                            end
                        end
                    Citizen.Wait(s)
                end
            end)
            timetocheck()
        else
            TriggerServerEvent('fly:removeitem')
            ClearPedTasks(PlayerPedId())
        end
end)

RegisterNetEvent('fly:leavehouse')
AddEventHandler('fly:leavehouse', function()
    start = false
    SetEntityCoords(PlayerPedId(),alllocations[randomlocation].door,0,0,0,0)
end)


local cont = 0
function DisplayLoot()
    for i,v in ipairs(alllocations[randomlocation].loot) do
    local collected = false
    Citizen.CreateThread(function()
        while true do
            s = 1000
            local coords = GetEntityCoords(PlayerPedId())
                if GetDistanceBetweenCoords(coords,alllocations[randomlocation].loot[i], true) < 2 and PlayerData.job ~= nil and PlayerData.job.name ~= Config.JobName and can_review then
                     s = 5
                     ESX.ShowFloatingHelpNotification("Press [E] to check the place",alllocations[randomlocation].loot[i])
                        if GetDistanceBetweenCoords(coords,alllocations[randomlocation].loot[i], true) < 1 then
                                if IsControlJustReleased(1, 51) and not collected then
                                        animation()
                                        collected = true
                                        revising = true
                                        cont = cont + 1
                                        if cont == 1 then   --this will be used so that when the thief has checked at least 1 places, an announcement will be sent to the police, so that the thief will have a chance to escape.
                                            ESX.ShowNotification('Hey, youre making too much noise, be quieter.')
                                            TriggerServerEvent('fly:sendcall', alllocations[randomlocation].door)
                                        elseif cont == 4 then
                                            revising = false
                                            can_review = false
                                            all_reviewed = true
                                        end
                                elseif IsControlJustReleased(1, 51) and collected then
                                        ESX.ShowNotification('This site has already been reviewed')
                                end
                        end
                end
            Citizen.Wait(s)
        end
    end)
    end
end

RegisterNetEvent('fly:policecall')
AddEventHandler('fly:policecall', function(coords)
    if PlayerData.job ~= nil and PlayerData.job.name == Config.JobName then
		ESX.ShowNotification("Apparently a person has forced the door of a house and is stealing inside.")
		blippolice = AddBlipForCoord(coords)
		SetBlipSprite(blippolice, 161)
		SetBlipColour(blippolice,  1)
		SetBlipAlpha(blippolice, 250)
		SetBlipScale(blippolice, 1.2)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString('House robbery')
		EndTextCommandSetBlipName(blippolice)
        Wait(60000)
        RemoveBlip(blippolice)
	end
end)

Citizen.CreateThread(function()
    if Config.BlipEnabled then
            blip = AddBlipForCoord(Config.Ped.Pos.x, Config.Ped.Pos.y)
            SetBlipSprite(blip, 280)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.7)
            SetBlipColour(blip, 24)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("House Robbery")
            EndTextCommandSetBlipName(blip)
    end
end)

function Timetoarrive()
    if start then
        Citizen.Wait(420000) -- 7 minutes 420000
        if inside == false then
            start = false
            RemoveBlip(Blip)
            ESX.ShowNotification("You didn't force the door in a reasonable time, come back to steal later.")
        end
    end
end

function timetocheck()
    if inside then
        Citizen.Wait(300000) --5 minutes 300000
        if revising == false then
            if all_reviewed == false then
                can_review = false
                ESX.ShowNotification("The time to review the site locations is over.")
                TriggerServerEvent('fly_logsloot')
            else
                all_reviewed = false
            end
        end

    end
end

function animation()
    startAnim(PlayerPedId(), "anim@gangops@facility@servers@bodysearch@", "player_search")
    FreezeEntityPosition(PlayerPedId(), true)
    Citizen.Wait(8000)
    ClearPedTasks(PlayerPedId())
    FreezeEntityPosition(PlayerPedId(), false)
    TriggerServerEvent('fly:giveloot')
end

function startAnim(ped, dictionary, anim)
	Citizen.CreateThread(function()
	  RequestAnimDict(dictionary)
	  while not HasAnimDictLoaded(dictionary) do
		Citizen.Wait(0)
	  end
		TaskPlayAnim(ped, dictionary, anim ,8.0, -8.0, -1, 50, 0, false, false, false)
	end)
end