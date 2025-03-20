local ESX = exports['es_extended']:getSharedObject()
local activeTriviaData = nil
local triviaTimer = nil

local function IsAllowedToCreateTrivia(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    return xPlayer and Config.AllowedGroups[xPlayer.getGroup()] or false
end

local function StartTrivia(source, question, answer, money, item, quantity)
    if activeTriviaData then
        TriggerClientEvent('ox_lib:notify', source, {title = 'Trivia Error', description = 'There is already an active trivia question!', type = 'error'})
        return false
    end
    
    activeTriviaData = {
        question = question,
        answer = answer:lower(),
        money = money,
        item = item,
        quantity = quantity,
        startedBy = source,
        startTime = os.time()
    }
    
    local rewardText = money > 0 and "$" .. money or quantity .. "x " .. ESX.GetItemLabel(item)
    
    TriggerClientEvent('chat:addMessage', -1, {
        color = {255, 255, 0},
        multiline = true,
        args = {"[TRIVIA]", "New trivia question worth " .. rewardText .. ":\n" .. question .. "\n\nUse /answer [your answer] to respond!"}
    })
    
    triviaTimer = SetTimeout(Config.TriviaTimeout, function()
        if activeTriviaData then
            TriggerClientEvent('chat:addMessage', -1, {
                color = {255, 0, 0},
                multiline = true,
                args = {"[TRIVIA]", "Time's up! No one answered correctly. The answer was: " .. activeTriviaData.answer}
            })
            activeTriviaData = nil
        end
    end)
    
    return true
end

local function CheckAnswer(source, answer)
    if not activeTriviaData then
        TriggerClientEvent('ox_lib:notify', source, {title = 'Trivia Error', description = 'There is no active trivia question!', type = 'error'})
        return
    end
    
    if answer:lower() == activeTriviaData.answer then
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return end
        
        if activeTriviaData.money > 0 then
            exports.ox_inventory:AddItem(source, 'money', activeTriviaData.money)
        elseif activeTriviaData.item then
            exports.ox_inventory:AddItem(source, activeTriviaData.item, activeTriviaData.quantity)
        end
        
        local rewardText = activeTriviaData.money > 0 
            and "$" .. activeTriviaData.money 
            or activeTriviaData.quantity .. "x " .. ESX.GetItemLabel(activeTriviaData.item)
        
        TriggerClientEvent('chat:addMessage', -1, {
            color = {0, 255, 0},
            multiline = true,
            args = {"[TRIVIA]", xPlayer.getName() .. " answered correctly and won " .. rewardText .. "!\nThe answer was: " .. activeTriviaData.answer}
        })
        
        if triviaTimer then
            ClearTimeout(triviaTimer)
            triviaTimer = nil
        end
        activeTriviaData = nil
    else
        TriggerClientEvent('ox_lib:notify', source, {title = 'Trivia', description = 'Wrong answer! Try again.', type = 'error'})
    end
end

RegisterCommand('trivia', function(source)
    if not IsAllowedToCreateTrivia(source) then
        TriggerClientEvent('ox_lib:notify', source, {title = 'Trivia Error', description = 'You do not have permission to create trivia questions!', type = 'error'})
        return
    end
    TriggerClientEvent('figrs_trivia:openCreateMenu', source)
end, false)

RegisterCommand('answer', function(source, args)
    if #args < 1 then
        TriggerClientEvent('ox_lib:notify', source, {title = 'Trivia Error', description = 'Please provide an answer! Usage: /answer [your answer]', type = 'error'})
        return
    end
    CheckAnswer(source, table.concat(args, " "))
end, false)

RegisterNetEvent('figrs_trivia:createNewTrivia', function(question, answer, money, item, quantity)
    local source = source
    
    if not question or question == '' or not answer or answer == '' then
        TriggerClientEvent('ox_lib:notify', source, {title = 'Trivia Error', description = 'Invalid trivia data! Please fill in all fields correctly.', type = 'error'})
        return
    end
    
    if not IsAllowedToCreateTrivia(source) then
        TriggerClientEvent('ox_lib:notify', source, {title = 'Trivia Error', description = 'You do not have permission to create trivia questions!', type = 'error'})
        return
    end
    
    if StartTrivia(source, question, answer, money, item, quantity) then
        TriggerClientEvent('ox_lib:notify', source, {title = 'Trivia', description = 'Trivia question has been broadcast to all players!', type = 'success'})
    end
end)