local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")

local ROOT = "Haze"
local GAMES = ROOT .. "/games"

local Notifications = loadfile(ROOT .. "/libraries/Notifications.lua")()

local Config = {
    Buttons = {
        Haze = {
            Color = Color3.fromRGB(28,28,28),
            GradientColors = {
                Color3.fromRGB(66,245,138),
                Color3.fromRGB(66,191,245),
                Color3.fromRGB(255,255,255),
                Color3.fromRGB(245,66,200),
                Color3.fromRGB(255,255,255),
                Color3.fromRGB(66,245,138)
            },
            GradientSpeed = 1
        },
        Moon = {
            Color = Color3.fromRGB(28,28,28),
            GradientColors = {
                Color3.fromRGB(220, 7, 240),
                Color3.fromRGB(162, 0, 255),
                Color3.fromRGB(255,255,255),
                Color3.fromRGB(100, 20, 145),
                Color3.fromRGB(255,255,255),
                Color3.fromRGB(220, 7, 240)
            },
            GradientSpeed = 1
        }
    }
}

local function safeload(path)
    if not isfile(path) then Notifications:Notify("Error","File missing: "..path,10) return end
    local source = readfile(path)
    if not source or source=="" then Notifications:Notify("Error","File empty: "..path,10) return end
    if source:sub(1,3)=="\239\187\191" then source = source:sub(4) end
    if source:sub(1,5)=="<!DOC" then Notifications:Notify("Error","Invalid file: "..path,10) return end
    local fn = loadstring(source)
    if not fn then Notifications:Notify("Error","Failed to compile script!",10) return end
    local ok = pcall(fn)
    if not ok then Notifications:Notify("Error","Runtime error!",10) end
end

do
    local executor = identifyexecutor and identifyexecutor()
    if executor then
        local name = executor:lower()
        if name:find("xeno") or name:find("solara") then
            Notifications:Notify("Warning",executor.." unsupported",15)
            Notifications:Notify("Warning","Use Velocity or Bunni.lol",15)
            return
        end
    end
    if not getrawmetatable or not pcall(getrawmetatable,game) then
        Notifications:Notify("Warning","Executor missing getrawmetatable",15)
        return
    end
end

local SelectedTheme = nil

local gui = Instance.new("ScreenGui")
gui.Name = "HazeTheme"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local blur = Instance.new("BlurEffect")
blur.Size = 1
blur.Parent = game:GetService("Lighting")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromScale(0.28,0.2)
frame.Position = UDim2.fromScale(0.5,0.5)
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.BackgroundColor3 = Color3.fromRGB(18,18,18)
frame.BackgroundTransparency = 1
frame.Parent = gui
Instance.new("UICorner",frame).CornerRadius=UDim.new(0,16)

local shadow = Instance.new("ImageLabel")
shadow.Image = "rbxassetid://1316045217"
shadow.Size = UDim2.fromScale(1.15,1.25)
shadow.Position = UDim2.fromScale(0.5,0.55)
shadow.AnchorPoint = Vector2.new(0.5,0.5)
shadow.BackgroundTransparency = 1
shadow.ImageTransparency = 1
shadow.ZIndex = 0
shadow.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0.35,0)
title.BackgroundTransparency = 1
title.Text = "Choose UI Theme"
title.TextColor3 = Color3.fromRGB(235,235,235)
title.Font = Enum.Font.GothamSemibold
title.TextScaled = true
title.Parent = frame

local container = Instance.new("Frame")
container.Size = UDim2.new(1,-30,0.45,0)
container.Position = UDim2.new(0,15,0.45,0)
container.BackgroundTransparency = 1
container.Parent = frame

local layout = Instance.new("UIListLayout",container)
layout.FillDirection = Enum.FillDirection.Horizontal
layout.Padding = UDim.new(0,14)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function animateGradientFlow(gradient,speed)
    local offset = -1
    RunService.RenderStepped:Connect(function(dt)
        offset = offset + dt*speed
        if offset>2 then offset=-1 end
        gradient.Offset = Vector2.new(offset,0)
    end)
end

local function createButton(text,config)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromScale(0.45,1)
    btn.Text = ""
    btn.BackgroundColor3 = config.Color
    btn.AutoButtonColor = false
    btn.Parent = container
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,14)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1,1)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = Enum.Font.GothamMedium
    label.TextScaled = true
    label.TextColor3 = Color3.new(1,1,1)
    label.Parent = btn

    local gradient = Instance.new("UIGradient")
    local keypoints = {}
    local step = 1/(#config.GradientColors-1)
    for i,color in ipairs(config.GradientColors) do
        table.insert(keypoints, ColorSequenceKeypoint.new((i-1)*step,color))
    end
    gradient.Color = ColorSequence.new(keypoints)
    gradient.Rotation = 0
    gradient.Offset = Vector2.new(-1,0)
    gradient.Parent = label

    animateGradientFlow(gradient,config.GradientSpeed)

    local hover = TweenService:Create(btn,TweenInfo.new(0.15),{BackgroundColor3=config.Color:Lerp(Color3.new(1,1,1),0.12)})
    local leave = TweenService:Create(btn,TweenInfo.new(0.15),{BackgroundColor3=config.Color})
    btn.MouseEnter:Connect(function() hover:Play() end)
    btn.MouseLeave:Connect(function() leave:Play() end)
    btn.MouseButton1Down:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1),{Size=UDim2.fromScale(0.43,0.95)}):Play() end)
    btn.MouseButton1Up:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1),{Size=UDim2.fromScale(0.45,1)}):Play() end)

    return btn
end

local hazeBtn = createButton("Haze",Config.Buttons.Haze)
local moonBtn = createButton("Moon",Config.Buttons.Moon)

hazeBtn.MouseButton1Click:Connect(function() SelectedTheme = "Haze" end)
moonBtn.MouseButton1Click:Connect(function() SelectedTheme = "Moon" end)

TweenService:Create(frame,TweenInfo.new(0.25,Enum.EasingStyle.Quad),{BackgroundTransparency=0}):Play()
TweenService:Create(shadow,TweenInfo.new(0.25),{ImageTransparency=0.35}):Play()
TweenService:Create(blur,TweenInfo.new(0.25),{Size=12}):Play()

while not SelectedTheme do task.wait() end

TweenService:Create(frame,TweenInfo.new(0.2),{BackgroundTransparency=1}):Play()
TweenService:Create(blur,TweenInfo.new(0.2),{Size=0}):Play()
task.wait(0.2)
gui:Destroy()
blur:Destroy()

local placeId = tostring(game.PlaceId)
local gamedetect, universaldetect
if SelectedTheme=="Haze" then
    gamedetect = GAMES.."/"..placeId..".lua"
    universaldetect = GAMES.."/Universal.lua"
elseif SelectedTheme=="Moon" then
    gamedetect = GAMES.."/moongames/"..placeId..".lua"
    universaldetect = GAMES.."/moongames/Universal.lua"
end

local function getGameName()
    local success, info = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId).Name end)
    if success and info then return info else return "Unknown Game" end
end

local displayName = getGameName()

if isfile(gamedetect) then
    Notifications:Notify("Info","Loading script for: "..displayName,5)
    safeload(gamedetect)
elseif isfile(universaldetect) then
    Notifications:Notify("Info","Loading universal script for: "..displayName,5)
    safeload(universaldetect)
else
    Notifications:Notify("Error","No compatible game script found for: "..displayName,10)
    return
end

local whitelist = ROOT.."/libraries/Whitelist.lua"
if isfile(whitelist) then safeload(whitelist) end