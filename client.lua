RegisterNetEvent('figrs_trivia:openCreateMenu', function()
    local input = lib.inputDialog('Create Trivia', {
        {type = 'input', label = 'Question', description = 'Enter your trivia question', required = true},
        {type = 'input', label = 'Answer', description = 'Enter the correct answer', required = true},
        {type = 'select', label = 'Reward Type', options = {
            {value = 'money', label = 'Money'},
            {value = 'item', label = 'Item'}
        }},
        {type = 'number', label = 'Amount', description = 'Amount to reward winner', required = true, min = 1, max = Config.MaxReward}
    })
    
    if not input then return end
    
    local question, answer, rewardType, amount = input[1], input[2], input[3], input[4]
    
    if rewardType == 'money' then
        TriggerServerEvent('figrs_trivia:createNewTrivia', question, answer, amount, nil, 0)
    else
        local itemSelect = lib.inputDialog('Select Item Reward', {
            {type = 'select', label = 'Item', options = Config.RewardItems},
            {type = 'number', label = 'Quantity', default = 1, min = 1, max = 100}
        })
        
        if itemSelect then
            TriggerServerEvent('figrs_trivia:createNewTrivia', question, answer, 0, itemSelect[1], itemSelect[2])
        end
    end
end)