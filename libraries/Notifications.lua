local NotifyLib = {}
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local STYLE = {
    Width = 320,
    Height = 75,
    Padding = 30,
    Background = Color3.fromRGB(15, 15, 15),
    DefaultAccent = Color3.fromRGB(66, 245, 108),
    Font = Enum.Font.GothamMedium,
    TitleSize = 14,
    TextSize = 12,
}

local screenGui
local container

function NotifyLib:Initialize()
    if screenGui then return end
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HazeNotify"
    screenGui.DisplayOrder = 999
    screenGui.Parent = (gethui and gethui()) or CoreGui

    container = Instance.new("Frame")
    container.Name = "NotifContainer"
    container.Size = UDim2.new(0, STYLE.Width, 0.9, 0)
    container.Position = UDim2.new(1, -STYLE.Padding, 1, -STYLE.Padding)
    container.AnchorPoint = Vector2.new(1, 1)
    container.BackgroundTransparency = 1
    container.Parent = screenGui

    local layout = Instance.new("UIListLayout")
    layout.Parent = container
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 15)
end

function NotifyLib:Notify(title, text, duration, customColor)
    self:Initialize()

    local isHaze = (title:upper() == "HAZE")
    local duration = duration or 4
    local accentColor = customColor or STYLE.DefaultAccent
    
    local notif = Instance.new("CanvasGroup") 
    notif.Size = UDim2.new(1, 0, 0, STYLE.Height)
    notif.BackgroundColor3 = STYLE.Background
    notif.GroupTransparency = 1 
    notif.BorderSizePixel = 0
    notif.Parent = container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = notif

    local shineOverlay = Instance.new("Frame")
    shineOverlay.Size = UDim2.new(1, 0, 1, 0)
    shineOverlay.BackgroundTransparency = 1
    shineOverlay.ZIndex = 10 
    shineOverlay.Parent = notif

    local shineGrad = Instance.new("UIGradient")
    shineGrad.Rotation = 30
    shineGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.45, 1),
        NumberSequenceKeypoint.new(0.5, 0.6), 
        NumberSequenceKeypoint.new(0.55, 1),
        NumberSequenceKeypoint.new(1, 1)
    })
    shineGrad.Offset = Vector2.new(-1, 0)
    shineGrad.Parent = shineOverlay

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color = accentColor
    stroke.Transparency = 1
    stroke.Parent = notif

    local watermark = Instance.new("TextLabel")
    watermark.Size = UDim2.new(0, 60, 0, 20)
    watermark.Position = UDim2.new(1, -72, 0, 10) 
    watermark.BackgroundTransparency = 1
    watermark.Text = "HAZE"
    watermark.TextColor3 = Color3.new(1, 1, 1)
    watermark.TextSize = 11
    watermark.Font = Enum.Font.GothamBold
    watermark.TextXAlignment = Enum.TextXAlignment.Right
    watermark.Parent = notif

    local waterGrad = Instance.new("UIGradient")
    waterGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(0.7, 0.7, 0.7)),
        ColorSequenceKeypoint.new(0.5, accentColor),
        ColorSequenceKeypoint.new(1, Color3.new(0.7, 0.7, 0.7))
    })
    waterGrad.Parent = watermark

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -90, 0, 25)
    titleLabel.Position = UDim2.new(0, 18, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title:upper()
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextSize = STYLE.TitleSize
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notif

    if isHaze then
        local titleGrad = Instance.new("UIGradient")
        titleGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(0.7, 0.7, 0.7)),
            ColorSequenceKeypoint.new(0.5, accentColor),
            ColorSequenceKeypoint.new(1, Color3.new(0.7, 0.7, 0.7))
        })
        titleGrad.Parent = titleLabel
        
        task.spawn(function()
            while notif.Parent do
                titleGrad.Offset = Vector2.new(math.sin(tick() * 2.5) * 0.6, 0)
                RunService.RenderStepped:Wait()
            end
        end)
    end

    local contentLabel = Instance.new("TextLabel")
    contentLabel.Size = UDim2.new(1, -36, 0, 30)
    contentLabel.Position = UDim2.new(0, 18, 0, 34)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = text
    contentLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    contentLabel.TextSize = STYLE.TextSize
    contentLabel.Font = STYLE.Font
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextWrapped = true
    contentLabel.Parent = notif

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 3)
    bar.Position = UDim2.new(0, 0, 1, -3)
    bar.BackgroundColor3 = accentColor
    bar.BorderSizePixel = 0
    bar.Parent = notif

    notif.Position = UDim2.new(1.3, 0, 0, 0)
    TweenService:Create(notif, TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0),
        GroupTransparency = 0
    }):Play()
    TweenService:Create(stroke, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 0.1}):Play()

    task.spawn(function()
        while notif.Parent do
            waterGrad.Offset = Vector2.new(math.sin(tick() * 2.5) * 0.6, 0)
            RunService.RenderStepped:Wait()
        end
    end)

    task.spawn(function()
        while notif.Parent do
            task.wait(3.5)
            local t = TweenService:Create(shineGrad, TweenInfo.new(1.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Offset = Vector2.new(1, 0)})
            t:Play()
            t.Completed:Wait()
            shineGrad.Offset = Vector2.new(-1, 0)
        end
    end)

    TweenService:Create(bar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 3)}):Play()

    task.delay(duration, function()
        local exit = TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
            Position = UDim2.new(1.3, 0, 0, 0),
            GroupTransparency = 1
        })
        exit:Play()
        exit.Completed:Connect(function() notif:Destroy() end)
    end)
end

return NotifyLib