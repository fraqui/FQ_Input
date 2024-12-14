local UIHandler = {
    allowMove = false,
    canWalk = false,
    isVisible = false,
    currentRequestId = 0,
    isMainTaskWorking = false,
    pendingRequests = {}
}

function UIHandler:Show(title, canWalk, maxLength, callback, inputType)
    if self.isVisible then return end

    inputType = inputType or "text"
    if not (inputType == "text" or inputType == "small_text" or inputType == "number") then
        inputType = "text"
    end

    local requestId = self:GetRequestId()

    self.isVisible = true
    self.canWalk = canWalk

    SendNUIMessage({
        show = true,
        request = requestId,
        maxlength = maxLength,
        title = title,
        type = inputType
    })

    if callback then
        self.pendingRequests[requestId] = callback
    end

    if not self.isMainTaskWorking then
        SetNuiFocus(true, true)
        self:SpawnMainTask()
    end
end

function UIHandler:Hide()
    SendNUIMessage({ hide = true })
    self.isVisible = false
    SetNuiFocus(false, false)
    self.isMainTaskWorking = false
end

function UIHandler:GetRequestId()
    self.currentRequestId = (self.currentRequestId + 1) % 65536
    return self.currentRequestId
end

function UIHandler:SpawnMainTask()
    if self.isMainTaskWorking then return end

    self.isMainTaskWorking = true
    CreateThread(function()
        while self.isMainTaskWorking do
            DisableAllControlActions(0)
            EnableControlAction(0, 249, true) -- Push-to-Talk
            if self.allowMove and self.canWalk then
                EnableControlAction(0, 30, true) -- Move Left/Right
                EnableControlAction(0, 31, true) -- Move Up/Down
            end
            Wait(0)
        end
    end)
end

-- NUI Callbacks
RegisterNUICallback("response", function(data)
    local req = data.request
    if req ~= -1 and UIHandler.pendingRequests[req] then
        UIHandler.pendingRequests[req](data.value)
        UIHandler.pendingRequests[req] = nil
    end
    UIHandler:Hide()
end)

-- Test Command
RegisterCommand("test", function()
    UIHandler:Show("Un exemple de l'input ?", false, 100, function(input)
        print("You entered:", input)
    end, "text")
end)

-- Export the single handler
exports("UIHandler", function()
    return UIHandler
end)
