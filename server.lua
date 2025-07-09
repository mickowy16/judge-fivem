
local wantedPlayers = {}

local sentencesData = {}

local function loadWarrants()
    local data = LoadResourceFile(GetCurrentResourceName(), 'warrant_data.json')
    if data then
        local decoded = json.decode(data)
        if decoded then
            wantedPlayers = decoded
            print('[WARRANT] Wczytano dane poszukiwanych z pliku.')
        end
    end
end

local function saveWarrants()
    SaveResourceFile(GetCurrentResourceName(), 'warrant_data.json', json.encode(wantedPlayers, {indent=true}), -1)
    print('[WARRANT] Zapisano dane poszukiwanych do pliku.')
end

loadWarrants()

local function loadSentences()
    local data = LoadResourceFile(GetCurrentResourceName(), 'sentences_data.json')
    if data then
        local decoded = json.decode(data)
        if decoded then
            sentencesData = decoded
            print('[SENTENCES] Wczytano dane wyroków z pliku.')
        end
    end
end

local function saveSentences()
    SaveResourceFile(GetCurrentResourceName(), 'sentences_data.json', json.encode(sentencesData, {indent=true}), -1)
    print('[SENTENCES] Zapisano dane wyroków do pliku.')
end

loadSentences()

RegisterNetEvent('testy:requestPlayers')
AddEventHandler('testy:requestPlayers', function()
    local src = source
    local players = {}
    for _, id in ipairs(GetPlayers()) do
        local name = GetPlayerName(id)
        local wanted = wantedPlayers[tonumber(id)] or nil
        table.insert(players, {id = id, name = name, wanted = wanted})
    end
    print('[DEBUG][SERVER] Wysyłam graczy:', json.encode(players))
    TriggerClientEvent('testy:sendPlayers', src, players)
end)

RegisterNetEvent('testy:setWanted')
AddEventHandler('testy:setWanted', function(targetId, reason)
    wantedPlayers[tonumber(targetId)] = reason
    saveWarrants()
    print(('Gracz %s został oznaczony jako POSZUKIWANY (%s)'):format(targetId, reason))
    TriggerClientEvent('chat:addMessage', -1, {args = {('^1Gracz %s jest POSZUKIWANY! Powód: %s'):format(GetPlayerName(targetId), reason)}})
end)

RegisterNetEvent('testy:sendSentence')
AddEventHandler('testy:sendSentence', function(targetId, jailTime)
    print(('Gracz %s otrzymał wyrok %s minut'):format(targetId, jailTime))
    TriggerClientEvent('testy:jailPlayer', tonumber(targetId), jailTime)
    TriggerClientEvent('chat:addMessage', -1, {args = {('^3Gracz %s otrzymał wyrok zaoczny: %s min. więzienia'):format(GetPlayerName(targetId), jailTime)}})
end)

RegisterNetEvent('testy:pardonPlayer')
AddEventHandler('testy:pardonPlayer', function(targetId)
    wantedPlayers[tonumber(targetId)] = nil
    saveWarrants()
    print(('Gracz %s został ułaskawiony'):format(targetId))
    TriggerClientEvent('testy:freePlayer', tonumber(targetId))
    TriggerClientEvent('chat:addMessage', -1, {args = {('^2Gracz %s został ułaskawiony i wypuszczony z więzienia!'):format(GetPlayerName(targetId))}})
end)


RegisterNetEvent('testy:saveSentence')
AddEventHandler('testy:saveSentence', function(targetId, sentenceData)
    targetId = tostring(targetId)
    if not sentencesData[targetId] then sentencesData[targetId] = {} end
    table.insert(sentencesData[targetId], sentenceData)
    saveSentences()
    print(('Zapisano wyrok dla gracza %s'):format(targetId))
    TriggerClientEvent('chat:addMessage', source, {args = {'^2Wyrok zapisany!'}})
end)


RegisterNetEvent('testy:getSentences')
AddEventHandler('testy:getSentences', function()
    local src = source

    local all = {}
    for id, wyroki in pairs(sentencesData) do
        for _, wyrok in ipairs(wyroki) do
            table.insert(all, {
                id = id,
                imie = wyrok.imie,
                nazwisko = wyrok.nazwisko,
                powod = wyrok.powod,
                data = wyrok.data,
                tresc = wyrok.tresc
            })
        end
    end
    TriggerClientEvent('testy:sendSentences', src, all)
end)


RegisterCommand('wyrok', function(source, args, raw)
    local src = source
    local id = tostring(src)
    local list = sentencesData[id] or {}
    if #list == 0 then
        TriggerClientEvent('chat:addMessage', src, {args = {'^3Nie masz żadnych wyroków.'}})
        return
    end
    TriggerClientEvent('chat:addMessage', src, {args = {'^2Twoje wyroki:'}})
    for i, wyrok in ipairs(list) do
        local info = (wyrok.data or '') .. ' | ' .. (wyrok.imie or '') .. ' ' .. (wyrok.nazwisko or '') .. ' | ' .. (wyrok.powod or '')
        TriggerClientEvent('chat:addMessage', src, {args = {('^7%d. %s'):format(i, info)}})
    end
end, false)
