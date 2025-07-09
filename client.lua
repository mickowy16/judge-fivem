RegisterCommand('palenie', function()
    local playerPed = PlayerPedId()
    -- Animacja palenia jointa
    RequestAnimDict('amb@world_human_smoking@male@male_a@enter')
    while not HasAnimDictLoaded('amb@world_human_smoking@male@male_a@enter') do
        Wait(100)
    end
    TaskPlayAnim(playerPed, 'amb@world_human_smoking@male@male_a@enter', 'enter', 8.0, -8.0, 5000, 0, 0, false, false, false)
    TriggerEvent('chat:addMessage', {args = {'^2Palisz blanta...'}})
    Wait(5000)
    ClearPedTasks(playerPed)
    -- Efekt naćpania
    StartScreenEffect('DrugsTrevorClownsFight', 0, false)
    ShakeGameplayCam('DRUNK_SHAKE', 1.0)
    TriggerEvent('chat:addMessage', {args = {'^3Jesteś zjarany!'}})
    -- Efekt trwa 30 sekund
    Wait(30000)
    StopScreenEffect('DrugsTrevorClownsFight')
    ShakeGameplayCam('DRUNK_SHAKE', 0.0)
end, false)


RegisterCommand('sedzia', function()
    TriggerEvent('chat:addMessage', {args = {'^2[DEBUG] Komenda /sedzia wywołana'}})
    SetNuiFocus(true, true)
    TriggerServerEvent('testy:requestPlayers')
end, false)

RegisterNetEvent('testy:sendPlayers')
AddEventHandler('testy:sendPlayers', function(players)
    print('[DEBUG] Otrzymano listę graczy:', json.encode(players))
    TriggerEvent('chat:addMessage', {args = {'^3[DEBUG] Otrzymano graczy: ' .. #players}})
    local reports = {
        {id = 101, text = "Bijatyka na mieście"},
        {id = 102, text = "Kradzież auta"}
    }
    SendNUIMessage({type = 'openTablet', players = players, reports = reports})
end)


RegisterNUICallback('closeTablet', function(_, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({type = 'closeTablet'})
    cb('ok')
end)


RegisterNUICallback('sendSentence', function(data, cb)
    local player = data.player
    local jailTime = tonumber(data.sentence)
    if player and jailTime then
        TriggerServerEvent('testy:sendSentence', player.id, jailTime)
    end
    cb('ok')
end)


RegisterNetEvent('testy:jailPlayer')
AddEventHandler('testy:jailPlayer', function(jailTime)
    local playerPed = PlayerPedId()

    local jailPos = vector3(1690.5, 2593.4, 45.9)
    SetEntityCoords(playerPed, jailPos.x, jailPos.y, jailPos.z, false, false, false, true)
    FreezeEntityPosition(playerPed, true)
    TriggerEvent('chat:addMessage', {args = {'^1Zostałeś osadzony w więzieniu na ' .. jailTime .. ' minut.'}})
    Citizen.CreateThread(function()
        local seconds = jailTime * 60
        while seconds > 0 do
            Citizen.Wait(1000)
            seconds = seconds - 1
        end
        FreezeEntityPosition(playerPed, false)
        StopScreenEffect('DrugsTrevorClownsFight')
        ShakeGameplayCam('DRUNK_SHAKE', 0.0)

        SetEntityCoords(playerPed, 1849.7, 2586.3, 45.7, false, false, false, true)
        TriggerEvent('chat:addMessage', {args = {'^2Odsiedziałeś wyrok, wychodzisz na wolność!'}})
    end)
end)


RegisterNetEvent('testy:freePlayer')
AddEventHandler('testy:freePlayer', function()
    local playerPed = PlayerPedId()
    FreezeEntityPosition(playerPed, false)
    StopScreenEffect('DrugsTrevorClownsFight')
    ShakeGameplayCam('DRUNK_SHAKE', 0.0)

    SetEntityCoords(playerPed, 425.1, -979.5, 30.7, false, false, false, true)
    TriggerEvent('chat:addMessage', {args = {'^2Zostałeś ułaskawiony i wypuszczony z więzienia!'}})
end)


RegisterNUICallback('setWanted', function(data, cb)
    local player = data.player
    local reason = data.reason
    if player and reason and #reason > 0 then
        TriggerServerEvent('testy:setWanted', player.id, reason)
    end
    cb('ok')
end)


RegisterNUICallback('pardonPlayer', function(data, cb)
    local player = data.player
    if player then
        TriggerServerEvent('testy:pardonPlayer', player.id)
    end
    cb('ok')
end)


RegisterNUICallback('saveSentence', function(data, cb)
    local player = data.player
    local sentence = data.sentence
    if player and sentence then
        TriggerServerEvent('testy:saveSentence', player.id, sentence)
    end
    cb('ok')
end)

RegisterNUICallback('getSentences', function(data, cb)
    TriggerServerEvent('testy:getSentences')
    cb('ok')
end)


RegisterNetEvent('testy:sendSentences')
AddEventHandler('testy:sendSentences', function(sentences)
    SendNUIMessage({type = 'sentences', sentences = sentences})
end)


Citizen.CreateThread(function()
    Citizen.Wait(1500)
    StopScreenEffect('DrugsTrevorClownsFight')
    ShakeGameplayCam('DRUNK_SHAKE', 0.0)
    FreezeEntityPosition(PlayerPedId(), false)
end)

