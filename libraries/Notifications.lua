local NotifyLib = {}
local TweenService = game:GetService("TweenService")
local CoreGui = cloneref(game:GetService("CoreGui"))

local libraryUI
local templates
local notificationCanvas

function NotifyLib:Initialize()
    libraryUI = game:GetObjects("rbxassetid://15133757123")[1]
    templates = libraryUI.Templates
    notificationCanvas = libraryUI.list

    libraryUI.Name = "HazeNotify"
    libraryUI.Parent = CoreGui
end

function NotifyLib:Notify(Mode, Text, Duration)
    local existingLib = CoreGui:FindFirstChild("HazeNotify")
    if not existingLib then
        self:Initialize()
    else
        libraryUI = existingLib
        templates = libraryUI.Templates
        notificationCanvas = libraryUI.list
    end

    if not templates:FindFirstChild(Mode) then
        warn("Notification theme not found: " .. Mode)
        return
    end

    task.spawn(function()
        local success, err = pcall(function()
            local notif = templates[Mode]:Clone()
            local filler = notif.Filler
            local progressBar = notif.bar
            notif.Header.Text = Text
            notif.BackgroundColor3 = Color3.fromRGB(math.random(100,255), math.random(100,255), math.random(100,255))
            notif.BorderSizePixel = 0
            notif.Visible = true
            notif.Parent = notificationCanvas
            notif.Size = UDim2.new(0, 0, 0.1, 0)
            notif.Position = UDim2.new(0.5, 0, 0.1, 0)
            notif.AnchorPoint = Vector2.new(0.5, 0)
            filler.Size = UDim2.new(1, 0, 1, 0)
            filler.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            filler.BackgroundTransparency = 0.5
            local openTween = TweenInfo.new(0.4, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
            local closeTween = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
            local progressTween = TweenInfo.new(Duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
            TweenService:Create(notif, openTween, {Size = UDim2.new(0.8, 0, 0.1, 0)}):Play()
            task.wait(0.2)
            TweenService:Create(filler, progressTween, {Size = UDim2.new(0.02, 0, 1, 0)}):Play()
            TweenService:Create(progressBar, progressTween, {Size = UDim2.new(1, 0, 0.05, 0)}):Play()
            task.wait(Duration)
            TweenService:Create(notif, closeTween, {Size = UDim2.new(0, 0, 0.1, 0), BackgroundTransparency = 1}):Play()
            task.wait(0.4)

            notif:Destroy()
        end)
        if not success then
            warn("Notification error: " .. tostring(err))
        end
    end)
end

return NotifyLib