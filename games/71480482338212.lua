local Library = loadfile("Haze/libraries/Library.lua")()

local Window = Library:Window({
    ["Name"] = "H A Z E",
    ["GradientTitle"] = {
        ["Enabled"] = true,
        ["Start"] = Color3.fromRGB(66, 135, 245),
        ["Middle"] = Color3.fromRGB(255, 0, 225),
        ["End"] = Color3.fromRGB(66, 135, 245),
        ["Speed"] = 2
    }
})

local Watermark = Library:Watermark("H A Z E", {"Haze/assets/lib/logo.png", Color3.fromRGB(66, 135, 245)}, true)

local KeybindList = Library:KeybindList()

local CombatTab = Window:Page({Name = "Combat", Columns = 2})
local MovementTab = Window:Page({Name = "Movement", Columns = 2})
local UtilityTab = Window:Page({Name = "Utility", Columns = 2})
local VisualsTab = Window:Page({Name = "Visuals",  Columns = 2})
local PlayersTab = Window:Page({Name = "Players", Columns = 1})
local SettingsTab = Window:Page({Name = "Settings", Columns = 2})

PlayersTab:PlayerList({
    ["Name"] = "Playerlist",
    ["Flag"] = "Playerlist",
    ["Callback"] = function()
        print(Players)
    end
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local WCam = workspace.CurrentCamera
local RunService = game:GetService("RunService")

--[[ Libraries ]]
local LocalLibrary = "Haze/libraries"
local modules = {
    Whitelist = loadfile(LocalLibrary .. "/Whitelist.lua")(),
    SprintController = loadfile(LocalLibrary .. "/bedfight/SprintController.lua")(),
    ESPController = loadfile(LocalLibrary .. "/modules/EspController.lua")(),
    ScaffoldController = loadfile(LocalLibrary .. "/bedfight/ScaffoldController.lua")(),
    FlyController = loadfile(LocalLibrary .. "/bedfight/FlyController.lua")(),
    PartyController = loadfile(LocalLibrary .. "/bedfight/PartyController.lua")()
}

--[[ Speed ]]
local gmt = getrawmetatable(game)
setreadonly(gmt, false)
local oldindex = gmt.__index

gmt.__index = newcclosure(function(self, b)
    if b == "JumpPower" then return 50 end
    if b == "WalkSpeed" then return 16 end
    return oldindex(self, b)
end)
setreadonly(gmt, true)

local SpeedVar = false
local SpeedValue = 16

RunService.Heartbeat:Connect(function()
    if SpeedVar then
        local Character = LocalPlayer.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
        if Humanoid then
            Humanoid.WalkSpeed = SpeedValue
        end
    end
end)

local SpeedSection = MovementTab:Section({
    ["Name"] = "Speed",
    ["Side"] = 1
})

SpeedSection:Toggle({
    ["Name"] = "Speed", 
    ["Default"] = false, 
    ["Flag"] = "SpeedTog",
    ["Tooltip"] = "Makes you walk faster",
    ["Risky"] = false,
    ["Callback"] = function(State)
        SpeedVar = State        if not State then
            local Character = LocalPlayer.Character
            local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then Humanoid.WalkSpeed = 16 end
        end
    end
})

SpeedSection:Slider({
    ["Name"] = "Speed",
    ["Flag"] = "SpeedVal",
    ["Min"] = 16,
    ["Default"] = 16,
    ["Max"] = 32,
    ["Suffix"] = "studs",
    ["Decimals"] = 1,
    ["Callback"] = function(Value)
        SpeedValue = Value
    end
})

--[[ KillAura ]]
local SwordHitRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ItemsRemotes"):WaitForChild("SwordHit")

local Swords = {"Emerald Sword", "Diamond Sword", "Iron Sword", "Stone Sword", "Wooden Sword"}

local KAVar = false
local HighVar = false
local AnimsVar = false
local AnimMode = "Respect Delay"
local currentHighlight = nil
local LastAnimTime = 0

local SwingSound = Instance.new("Sound")
SwingSound.SoundId = "rbxassetid://104766549106531"
SwingSound.Volume = 1
SwingSound.Parent = workspace

local SwingAnimation = Instance.new("Animation")
SwingAnimation.AnimationId = "rbxassetid://123800159244236"

local function isAlive(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function getnearplayer()
    local closest, closestDist = nil, math.huge
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot or not isAlive(myChar) then return nil end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and isAlive(p.Character) then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local sameTeam = LocalPlayer.Team and p.Team == LocalPlayer.Team
                if sameTeam and p.Team and p.Team.Name ~= "Spectators" then continue end

                local dist = (root.Position - myRoot.Position).Magnitude
                if dist <= 20 and dist < closestDist then
                    closestDist = dist
                    closest = p
                end
            end
        end
    end
    return closest
end

local function updhighlight(target)
    if currentHighlight then
        currentHighlight:Destroy()
        currentHighlight = nil
    end
    if HighVar and target and target.Character then
        local highlight = Instance.new("Highlight")
        highlight.Adornee = target.Character
        highlight.FillColor = Color3.fromRGB(0, 255, 0)
        highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = workspace
        currentHighlight = highlight
    end
end

local function playanims()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local animator = humanoid:FindFirstChildWhichIsA("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end
    local track = animator:LoadAnimation(SwingAnimation)
    track:Play()
end

local function runKA()
    task.spawn(function()
        while KAVar do
            local target = getnearplayer()
            updhighlight(target)

            if target then
                for _, sword in ipairs(Swords) do
                    SwordHitRemote:FireServer(target.Character, sword)
                end

                if AnimsVar then
                    if AnimMode == "No Delay" then
                        playanims()
                        SwingSound:Play()
                    elseif AnimMode == "Respect Delay" then
                        local now = tick()
                        if now - LastAnimTime > 0.5 then
                            playanims()
                            SwingSound:Play()
                            LastAnimTime = now
                        end
                    end
                end
            end
            task.wait(0.01)
        end
        updhighlight(nil)
    end)
end

local KASec = CombatTab:Section({
    ["Name"] = "Killaura",
    ["Side"] = 1
})

KASec:Toggle({
    ["Name"] = "Killaura",
    ["Default"] = false,
    ["Flag"] = "Killaura",
    ["Tooltip"] = "Attacks players around you",
    ["Callback"] = function(state)
        KAVar = state
        if state then
            runKA()
        end
    end
})

KASec:Toggle({
    ["Name"] = "Highlight",
    ["Default"] = false,
    ["Flag"] = "KA_Highlight",
    ["Tooltip"] = "Highlight the target",
    ["Callback"] = function(state)
        HighVar = state
        if not state and currentHighlight then
            currentHighlight:Destroy()
            currentHighlight = nil
        end
    end
})

KASec:Toggle({
    ["Name"] = "Anims",
    ["Default"] = false,
    ["Flag"] = "KA_Anims",
    ["Callback"] = function(state)
        AnimsVar = state
    end
})

KASec:Dropdown({
    ["Name"] = "Delay",
    ["Flag"] = "KA_Delay",
    ["Items"] = {"No Delay", "Respect Delay"},
    ["Multi"] = false,
    ["Default"] = "Respect Delay",
    ["Callback"] = function(value)
        AnimMode = value
    end
})

--[[ Nuker ]]
local NukerSec = CombatTab:Section({
    ["Name"] = "Nuker",
    ["Side"] = 1
})

local MineBlockRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ItemsRemotes"):WaitForChild("MineBlock")

local NukerVar = false

local function getnearbed(range)
    local bedsContainer = workspace:FindFirstChild("BedsContainer")
    if not bedsContainer or not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then return nil end

    local closestBed, closestDist
    for _, bed in ipairs(bedsContainer:GetChildren()) do
        local hitbox = bed:FindFirstChild("BedHitbox")
        if hitbox then
            local distance = (LocalPlayer.Character.PrimaryPart.Position - hitbox.Position).Magnitude
            if distance <= range and (not closestDist or distance < closestDist) then
                closestBed, closestDist = hitbox, distance
            end
        end
    end
    return closestBed
end

local function getpickaxe()
    if LocalPlayer.Backpack then
        for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if item.Name:lower():find("pickaxe") then return item end
        end
    end
    if LocalPlayer.Character then
        for _, item in ipairs(LocalPlayer.Character:GetChildren()) do
            if item.Name:lower():find("pickaxe") then return item end
        end
    end
end

local function breakbed(pick, hitbox)
    if not pick or not hitbox then return end
    local model = hitbox.Parent
    local pos = hitbox.Position
    local origin = pos + Vector3.new(0, 3, 0)
    local direction = (pos - origin).Unit
    MineBlockRemote:FireServer(
        pick.Name,
        model,
        vector.create(pos.X, pos.Y, pos.Z),
        vector.create(origin.X, origin.Y, origin.Z),
        vector.create(direction.X, direction.Y, direction.Z)
    )
end

NukerSec:Toggle({
    ["Name"] = "Nuker",
    ["Flag"] = "Nuker",
    ["Default"] = false,
    ["Callback"] = function(state)
        NukerVar = state
        if state then
            task.spawn(function()
                while NukerVar do
                    task.wait(0.1)
                    if not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then
                        continue
                    end

                    local bedHitbox = getnearbed(30)
                    local pickaxe = getpickaxe()
                    if bedHitbox and pickaxe then
                        breakbed(pickaxe, bedHitbox)
                    end
                end
            end)
        end
    end
})

--[[ Cape ]]
local Capevar = false

local CapePNG = "Haze/Assets/capes/Cat.png"
local CapeColor = Color3.fromRGB(255,255,255)

local Cape, Motor

local CapeSection = VisualsTab:Section({
    ["Name"] = "Cape",
    ["Side"] = 1
})

local function torso(char)
    return char:FindFirstChild("UpperTorso")
        or char:FindFirstChild("Torso")
        or char:FindFirstChild("HumanoidRootPart")
end

local function clear()
    if Cape then Cape:Destroy() Cape = nil end
    if Motor then Motor:Destroy() Motor = nil end
end

local function build(char)
    clear()
    local t = torso(char)
    if not t then return end

    Cape = Instance.new("Part")
    Cape.Size = Vector3.new(2,4,0.1)
    Cape.Color = CapeColor
    Cape.Material = Enum.Material.SmoothPlastic
    Cape.Massless = true
    Cape.CanCollide = false
    Cape.CastShadow = false
    Cape.Parent = WCam

    local gui = Instance.new("SurfaceGui", Cape)
    gui.Adornee = Cape
    gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud

    local img = Instance.new("ImageLabel", gui)
    img.Size = UDim2.fromScale(1,1)
    img.BackgroundTransparency = 1
    img.Image = CapePNG:find("rbxasset") and CapePNG or getcustomasset(CapePNG)

    Motor = Instance.new("Motor6D", Cape)
    Motor.Part0 = Cape
    Motor.Part1 = t
    Motor.MaxVelocity = 0.08
    Motor.C0 = CFrame.new(0,2,0) * CFrame.Angles(0, math.rad(-90), 0)
    Motor.C1 = CFrame.new(0, t.Size.Y/2, 0.45) * CFrame.Angles(0, math.rad(90), 0)

    task.spawn(function()
        while Capevar and Cape and Motor do
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local v = math.min(root.Velocity.Magnitude, 90)
                Motor.DesiredAngle = math.rad(6 + v) +
                    (v > 1 and math.abs(math.cos(tick()*5))/3 or 0)
            end

            local d = (WCam.CFrame.Position - WCam.Focus.Position).Magnitude
            gui.Enabled = d > 0.6
            Cape.Transparency = d > 0.6 and 0 or 1
            task.wait()
        end
    end)
end

local CapeTog = CapeSection:Toggle({
    ["Name"] = "Cape",
    ["Flag"] = "CapeToggle",
    ["Callback"] = function(v)
        Capevar = v
        if v and LocalPlayer.Character then
            build(LocalPlayer.Character)
        else
            clear()
        end
    end
})

CapeSection:Dropdown({
    ["Name"] = "Capes",
    ["Items"] = {"Cat","Waifu","Troll", "Wave"},
    ["Flag"] = "CapeTexture",
    ["Callback"] = function(v)
        local path = "Haze/Assets/capes/"..v..".png"
        if isfile(path) then
            CapePNG = path
            if Capevar and LocalPlayer.Character then
                build(LocalPlayer.Character)
            end
        end
    end
})

CapeTog:Colorpicker({
    ["Name"] = "Cape Color",
    ["Default"] = CapeColor,
    ["Callback"] = function(c)
        CapeColor = c
        if Cape then Cape.Color = c end
    end
})

--[[ FECape ]]
local FECapeSec = VisualsTab:Section({
    ["Name"] = "LGBTQ Cape",
    ["Side"] = 1
})

local FECapeVar = false

local Capelist = {"Black", "White", "Red", "Yellow", "Green", "Blue", "Pink"}
local SelectedColors = {"Black", "White", "Red", "Yellow", "Green", "Blue", "Pink"}

local FECape = FECapeSec:Toggle({
    ["Name"] = "LGBTQ Cape",
    ["Default"] = false,
    ["Flag"] = "FECape",
    ["Tooltip"] = "Im sorry for this, FE btw",
    ["Risky"] = false,
    ["Callback"] = function(state)
        FECapeVar = state
        while FECapeVar do
            for _, color in ipairs(SelectedColors) do
                ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("EquipCape"):FireServer(color)
                wait(.1)
                if not FECapeVar then break end
            end
        end
    end
})

local MultiDropdown = FECapeSec:Dropdown({
    Name = "Cape Colors", 
    Flag = "CapeColors", 
    Items = Capelist, 
    Default = {"Pink", "White", "Blue"},
    Multi = true,
    Callback = function(values)
        SelectedColors = values
    end
})

--[[ Pro Cape ]]
local ProCapeSec = VisualsTab:Section({
    ["Name"] = "Pro Cape",
    ["Side"] = 2
})

local ProCape = ProCapeSec:Button({
    ["Name"] = "Pro Cape",
    ["Callback"] = function()
        Library:Notification("Equipped Pro Cape | (yes its FE)", 5, Color3.fromRGB(185, 66, 245))
        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("EquipCape"):FireServer("Pro")
    end
})

--[[ Vibe ]]
local VibeSec = VisualsTab:Section({
    ["Name"] = "Vibe",
    ["Side"] = 2
})

VibeSec:Toggle({
    ["Name"] = "Vibe",
    ["Flag"] = "Vibe",
    ["Callback"] = function(state)
        if state then
            Lighting.TimeOfDay = "00:00:00"
            Lighting.Technology = Enum.Technology.Future

            if not Lighting:FindFirstChild("VibeSky") then
                local sky = Instance.new("Sky")
                sky.Name = "VibeSky"
                sky.SkyboxBk = ""; sky.SkyboxDn = ""; sky.SkyboxFt = ""
                sky.SkyboxLf = ""; sky.SkyboxRt = ""; sky.SkyboxUp = ""
                sky.Parent = Lighting

                local atm = Instance.new("Atmosphere")
                atm.Density = 0.3
                atm.Offset = 0
                atm.Color = Color3.fromRGB(255,182,193)
                atm.Decay = Color3.fromRGB(50,0,80)
                atm.Glare = 0.5
                atm.Haze = 0.1
                atm.Parent = Lighting
            end

            if not Workspace:FindFirstChild("Snowing") then
                local p = Instance.new("Part")
                p.Name = "Snowing"
                p.Anchored = true
                p.CanCollide = false
                p.Size = Vector3.new(500,1,500)
                p.Position = Vector3.new(0,150,0)
                p.Transparency = 1
                p.Parent = Workspace

                local e = Instance.new("ParticleEmitter")
                e.Texture = "rbxassetid://258128463"
                e.Rate = 200
                e.Lifetime = NumberRange.new(8,15)
                e.Speed = NumberRange.new(5,10)
                e.SpreadAngle = Vector2.new(360,0)
                e.Size = NumberSequence.new(2)
                e.VelocityInheritance = 0
                e.Acceleration = Vector3.new(0,-50,0)
                e.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,182,193)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(173,216,230)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(50,0,80))
                }
                e.LightEmission = 0.9
                e.Parent = p
            end
        else
            Lighting.TimeOfDay = "14:00:00"
            Lighting.Technology = Enum.Technology.Compatibility

            if Workspace:FindFirstChild("Snowing") then Workspace.Snowing:Destroy() end
            if Lighting:FindFirstChild("VibeSky") then Lighting.VibeSky:Destroy() end
            for _, a in pairs(Lighting:GetChildren()) do if a:IsA("Atmosphere") then a:Destroy() end end
        end
    end
})

--[[ FOV ]]
local FOVVar = false
local FOVValue = 90
local FOVConnection

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    WCam = workspace.CurrentCamera
end)

local FOVSec = VisualsTab:Section({
    ["Name"] = "FOV",
    ["Side"] = 1
})

local function ManageFOV()
    if FOVConnection then FOVConnection:Disconnect() end
    
    if FOVVar then
        FOVConnection = RunService.RenderStepped:Connect(function()
            WCam.FieldOfView = FOVValue
        end)
    else
        WCam.FieldOfView = 70
    end
end

FOVSec:Toggle({
    ["Name"] = "FOV",
    ["Default"] = false,
    ["Flag"] = "FOV_Toggle",
    ["Tooltip"] = "Incrase your foc",
    ["Callback"] = function(state)
        FOVVar = state
        ManageFOV()
    end
})

FOVSec:Slider({
    ["Name"] = "FOV",
    ["Min"] = 70,
    ["Max"] = 120,
    ["Default"] = 90,
    ["Decimals"] = 1,
    ["Flag"] = "FOV_Value",
    ["Callback"] = function(val)
        FOVValue = val
    end
})

--[[ ChestStealer ]]
local ChestStealSec = UtilityTab:Section({
    ["Name"] = "Chest Stealer",
    ["Side"] = 1
})

local TeamColors = {"Red", "Orange", "Yellow", "Green", "Blue", "Purple", "Pink", "Brown"}

local CSVar = false

local CSTog = ChestStealSec:Toggle({
    ["Name"] = "Chest Stealer",
    ["Default"] = false,
    ["Flag"] = "Chest_Stealer",
    ["Tooltip"] = "Steal loot from every chest",
    ["Risky"] = false,
    ["Callback"] = function(state)
        CSVar = state
        if state then
            spawn(function()
                while CSVar do
                    for _, color in ipairs(TeamColors) do
                        for num = 1, 20 do
                            if not CSVar then break end
                            ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TakeItemFromChest"):FireServer(color, num, "1")
                            task.wait(.1)
                        end
                        if not CSVar then break end
                    end
                end
            end)
        end
    end
})

--[[ Velocity ]]
local VelocityUtils = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("VelocityUtils"))

local VelocityVar = false
local originalCreate

local VelocitySec = UtilityTab:Section({
    ["Name"] = "Velocity",
    ["Side"] = 2
})

VelocitySec:Toggle({
    ["Name"] = "Velocity",
    ["Default"] = false,
    ["Flag"] = "Velocity",
    ["Tooltip"] = "Bypasses the knockback in our ways",
    ["Callback"] = function(state)
        VelocityVar = state
        originalCreate = hookfunction(VelocityUtils.Create, function(...)
            if VelocityVar then
                return nil
            end
            return originalCreate(...)
        end)
    end
})

--[[ AutoSprint ]]
local SprintSec = UtilityTab:Section({
    ["Name"] = "AutoSprint",
    ["Side"] = 1
})

SprintSec:Toggle({
    ["Name"] = "AutoSprint",
    ["Default"] = false,
    ["Flag"] = "AutoSprint",
    ["Tooltip"] = "Sprints for you",
    ["Callback"] = function(state)
        modules.SprintController:SetState(state)
    end
})

--[[ ESP ]]
local ESPSec = VisualsTab:Section({
    ["Name"] = "ESP",
    ["Side"] = 1
})

ESPSec:Toggle({
    ["Name"] = "ESP",
    ["Default"] = false,
    ["Flag"] = "ESP",
    ["Callback"] = function(state)
        modules.ESPController.Enabled = state
    end
})

ESPSec:Toggle({
    ["Name"] = "Vibe ESP",
    ["Default"] = true,
    ["Flag"] = "ESP_Vibe",
    ["Tooltip"] = "Give a good vibe to the esp boxes",
    ["Callback"] = function(state)
        modules.ESPController.UseGradient = state
    end
})

ESPSec:Dropdown({
    ["Name"] = "Theme",
    ["Flag"] = "ESP_Theme",
    ["Items"] = {"Haze", "Aqua", "Nova"},
    ["Default"] = "Haze",
    ["Callback"] = function(val)
        if val and val ~= "" then
            modules.ESPController.Theme = val
        else
            modules.ESPController.Theme = "Haze"
        end
    end
})

ESPSec:Toggle({
    ["Name"] = "Team Check",
    ["Default"] = false,
    ["Flag"] = "ESP_TeamCheck",
    ["Callback"] = function(state)
        modules.ESPController.TeamCheck = state
    end
})

ESPSec:Toggle({
    ["Name"] = "Ignore Team",
    ["Default"] = false,
    ["Flag"] = "ESP_NoTeam",
    ["Callback"] = function(state)
        modules.ESPController.NoTeam = state
    end
})

--[[ Scaffold ]]
local ScaffoldSec = UtilityTab:Section({
    ["Name"] = "Scaffold",
    ["Side"] = 2
})

local ScaffoldKey = ScaffoldSec:Label("Scaffold", "Left"):Keybind({
    ["Name"] = "Scaffold",
    ["Flag"] = "Scaffold",
    ["Default"] = Enum.KeyCode.V,
    ["Mode"] = "Toggle",
    ["Callback"] = function(state)
        modules.ScaffoldController:SetState(state)
    end
})

--[[ Fly ]]
local FlySec = MovementTab:Section({
    ["Name"] = "Fly",
    ["Side"] = 2
})

local FlyKey = FlySec:Label("Fly", "Left"):Keybind({
    ["Name"] = "Fly",
    ["Flag"] = "Fly",
    ["Default"] = Enum.KeyCode.R,
    ["Mode"] = "Toggle",
    ["Callback"] = function(state)
        modules.FlyController:Toggle(state)
    end
})

FlySec:Toggle({
    ["Name"] = "Vertical",
    ["Flag"] = "Vertical",
    ["Default"] = false,
    ["Callback"] = function(state)
        modules.FlyController:SetVertical(state)
    end
})

--[[ Spam Invites ]]
local PartySec = UtilityTab:Section({
    ["Name"] = "Party Utilities",
    ["Side"] = 1
})

PartySec:Toggle({
    ["Name"] = "Spam Invites",
    ["Flag"] = "InviteSpam",
    ["Tooltip"] = "Invites everyone in your party",
    ["Default"] = false,
    ["Callback"] = function(state)
        spawn(function()
            while state do
                modules.PartyController:InviteAll()
                wait(0.1)
            end
        end)
    end
})

PartySec:Toggle({
    ["Name"] = "Spam Kicks",
    ["Flag"] = "KickSpam",
    ["Tooltip"] = "Kicks everyone from your party",
    ["Default"] = false,
    ["Callback"] = function(state)
        spawn(function()
            while state do
                modules.PartyController:KickAll()
                wait(0.1)
            end
        end)
    end
})

--[[ Themes + Config ]]
local ThemesSection = SettingsTab:Section({
    ["Name"] = "Settings",
    ["Side"] = 1
})

do
    for Index, Value in Library.Theme do 
        Library.ThemeColorpickers[Index] = ThemesSection:Label(Index, "Left"):Colorpicker({
            ["Name"] = Index,
            ["Flag"] = "Theme" .. Index,
            ["Default"] = Value,
            ["Callback"] = function(Value)
                Library.Theme[Index] = Value
                Library:ChangeTheme(Index, Value)
            end
        })
    end

    ThemesSection:Dropdown({
        ["Name"] = "Themes list",
        ["Items"] = {"Default", "Bitchbot", "Onetap", "Aqua"},
        ["Default"] = "Default",
        ["Callback"] = function(Value)
            local ThemeData = Library.Themes[Value]

            if not ThemeData then 
                return
            end

            for Index, Value in Library.Theme do 
                Library.Theme[Index] = ThemeData[Index]
                Library:ChangeTheme(Index, ThemeData[Index])

                Library.ThemeColorpickers[Index]:Set(ThemeData[Index])
            end

            task.wait(0.3)

        Library:Thread(function()
            for Index, Value in Library.Theme do 
                Library.Theme[Index] = Library.Flags["Theme"..Index].Color
                Library:ChangeTheme(Index, Library.Flags["Theme"..Index].Color)
            end    
        end)
    end})

    local ThemeName
    local SelectedTheme 

    local ThemesListbox = ThemesSection:Listbox({
        ["Name"] = "Themes List",
        ["Flag"] = "Themes List",
        ["Items"] = { },
        ["Multi"] = false,
        ["Default"] = nil,
        ["Callback"] = function(Value)
            SelectedTheme = Value
        end
    })

    ThemesSection:Textbox({
        ["Name"] = "Name",
        ["Flag"] = "Theme Name",
        ["Default"] = "",
        ["Placeholder"] = ". . .",
        ["Callback"] = function(Value)
            ThemeName = Value
        end
    })

    ThemesSection:Button({
        ["Name"] = "Save Theme",
        ["Callback"] = function()
            if ThemeName == "" then 
                return
            end

            if not isfile(Library.Folders.Themes .. "/" .. ThemeName .. ".json") then
                writefile(Library.Folders.Themes .. "/" .. ThemeName .. ".json", Library:GetTheme())

                Library:RefreshThemeList(ThemesListbox)
            else
                Library:Notification("Theme '" .. ThemeName .. ".json' already exists", 3, Color3.fromRGB(66, 135, 245))
                return
            end
        end
    }):SubButton({
        ["Name"] = "Load Theme",
        ["Callback"] = function()
            if SelectedTheme then
                Library:LoadTheme(readfile(Library.Folders.Themes .. "/" .. SelectedTheme))
            end
        end
    })

    ThemesSection:Button({
        ["Name"] = "Refresh Themes",
        ["Callback"] = function()
            Library:RefreshThemeList(ThemesListbox)
        end
    })

    Library:RefreshThemeList(ThemesListbox)
end

local ConfigsSection = SettingsTab:Section({
    ["Name"] = "Configs",
    ["Side"] = 2
})

do
    local ConfigName
    local SelectedConfig

    local ConfigsListbox = ConfigsSection:Listbox({
        ["Name"] = "Configs list",
        ["Flag"] = "Configs List",
        ["Items"] = { },
        ["Multi"] = false,
        ["Default"] = nil,
        ["Callback"] = function(Value)
            SelectedConfig = Value
        end
    })

    ConfigsSection:Textbox({
        ["Name"] = "Name",
        ["Flag"] = "Config Name",
        ["Default"] = "",
        ["Placeholder"] = ". . .",
        ["Callback"] = function(Value)
            ConfigName = Value
        end
    })

    ConfigsSection:Button({
        ["Name"] = "Load Config",
        ["Callback"] = function()
            if SelectedConfig then
                Library:LoadConfig(readfile("Haze/Configs/" .. SelectedConfig))
            end

            Library:Thread(function()
                task.wait(0.1)

                for Index, Value in Library.Theme do 
                    Library.Theme[Index] = Library.Flags["Theme"..Index].Color
                    Library:ChangeTheme(Index, Library.Flags["Theme"..Index].Color)
                end    
            end)
        end
    }):SubButton({
        ["Name"] = "Save Config",
        ["Callback"] = function()
            if SelectedConfig then
                Library:SaveConfig(SelectedConfig)
            end
        end
    })

    ConfigsSection:Button({
        ["Name"] = "Create Config",
        ["Callback"] = function()
            if ConfigName == "" then 
                return
            end

            if not isfile(Library.Folders.Configs .. "/" .. ConfigName .. ".json") then
                writefile(Library.Folders.Configs .. "/" .. ConfigName .. ".json", Library:GetConfig())

                Library:RefreshConfigsList(ConfigsListbox)
            else
                Library:Notification("Config '" .. ConfigName .. ".json' already exists", 3, Color3.fromRGB(66, 135, 245))
                return
            end
        end
    }):SubButton({
        ["Name"] = "Delete Config",
        ["Callback"] = function()
            if SelectedConfig then
                Library:DeleteConfig(SelectedConfig)

                Library:RefreshConfigsList(ConfigsListbox)
            end
        end
    })

    ConfigsSection:Button({
        ["Name"] = "Refresh Configs",
        ["Callback"] = function()
            Library:RefreshConfigsList(ConfigsListbox)
        end
    })

    Library:RefreshConfigsList(ConfigsListbox)

    ConfigsSection:Label("Menu Keybind", "Left"):Keybind({
        ["Name"] = "Menu Keybind",
        ["Flag"] = "Menu Keybind",
        ["Default"] = Enum.KeyCode.RightShift,
        ["Mode"] = "Toggle",
        ["Callback"] = function(Value)
        Library.MenuKeybind = Library.Flags["Menu Keybind"].Key
    end})

    ConfigsSection:Toggle({
        ["Name"] = "Watermark",
        ["Flag"] = "Watermark",
        ["Default"] = false,
        ["Callback"] = function(Value)
        Watermark:SetVisibility(Value)
    end})

    ConfigsSection:Toggle({
        ["Name"] = "Keybind List",
        ["Flag"] = "Keybind List",
        ["Default"] = false,
        ["Callback"] = function(Value)
        KeybindList:SetVisibility(Value)
    end})

    ConfigsSection:Dropdown({
        ["Name"] = "Style",
        ["Flag"] = "Tweening Style",
        ["Default"] = "Exponential",
        ["Items"] = {"Linear", "Sine", "Quad", "Cubic", "Quart", "Quint", "Exponential", "Circular", "Back", "Elastic", "Bounce"},
        ["Callback"] = function(Value)
        Library.Tween.Style = Enum.EasingStyle[Value]
    end})

    ConfigsSection:Dropdown({
        ["Name"] = "Direction",
        ["Flag"] = "Tweening Direction",
        ["Default"] = "Out",
        ["Items"] = {"In", "Out", "InOut"},
        ["Callback"] = function(Value)
        Library.Tween.Direction = Enum.EasingDirection[Value]
    end})

    ConfigsSection:Slider({
        ["Name"] = "Tweening Time",
        ["Min"] = 0,
        ["Max"] = 5,
        ["Default"] = 0.25,
        ["Decimals"] = 0.01,
        ["Flag"] = "Tweening Time",
        ["Callback"] = function(Value)
        Library.Tween.Time = Value
    end})

    ConfigsSection:Button({
        ["Name"] = "Uninject",
        ["Callback"] = function()
        Library:Unload()
    end})
end