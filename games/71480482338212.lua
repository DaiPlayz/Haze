local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/7Smoker/Haze/refs/heads/main/libraries/Library.lua"))()

local Window = Library:Window({
    Name = "H A Z E",
    GradientTitle = {
        Enabled = true,
        Start = Color3.fromRGB(66, 135, 245),
        Middle = Color3.fromRGB(255, 0, 225),
        End = Color3.fromRGB(66, 135, 245),
        Speed = 2
    }
})

local Watermark = Library:Watermark("H A Z E", {"Haze/assets/lib/logo.png", Color3.fromRGB(66, 135, 245)})
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

--[[ Speed ]]
local gmt = getrawmetatable(game)
setreadonly(gmt, false)
local oldindex = gmt.__index

gmt.__index = newcclosure(function(self, b)
    if b == "JumpPower" then
        return 50
    end
    if b == "WalkSpeed" then
        return 16
    end
    return oldindex(self, b)
end)

setreadonly(gmt, true)

local SpeedVar = false

local SpeedSection = MovementTab:Section({
    ["Name"] = "Speed",
    ["Side"] = 1
})

local SpeedTog = SpeedSection:Toggle({
    ["Name"] = "Speed", 
    ["Default"] = false, 
    ["Flag"] = "SpeedTog",
    ["Tooltip"] = "Makes you walk faster",
    ["Risky"] = false,
    ["Callback"] = function(State)
        SpeedVar = State
        if State == true then
            --ok
        else
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end
})

local SpeedSlide = SpeedSection:Slider({
    ["Name"] = "Speed",
    ["Flag"] = "SpeedVal",
    ["Min"] = 16,
    ["Default"] = 16,
    ["Max"] = 40,
    ["Suffix"] = "%",
    ["Decimals"] = 1,
    ["Callback"] = function(Value)
        task.spawn(function()
            while SpeedVar do
                LocalPlayer.Character.Humanoid.WalkSpeed = Value
                task.wait(0.1)
            end
        end)
    end
})

--[[ KillAura ]]
local ItemsRemotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ItemsRemotes")
local KaSection = CombatTab:Section({
    ["Name"] = "Killaura",
    ["Side"] = 1
})

local KAVar = false
local HighVar = false
local CHighlight

local function getequippedtool()
    if not LocalPlayer.Character then return end
    for _, v in ipairs(LocalPlayer.Character:GetChildren()) do
        if v:IsA("Tool") then return v end
    end
end

local function toolequip(name)
    local eq = getequippedtool()
    if eq and eq.Name == name then return end
    if LocalPlayer.Backpack:FindFirstChild(name) then
        ItemsRemotes.EquipTool:FireServer(name)
    end
end

local function getsword()
    for _, s in ipairs({"Emerald Sword","Diamond Sword","Iron Sword","Stone Sword","Wooden Sword"}) do
        if LocalPlayer.Backpack:FindFirstChild(s) or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(s)) then
            return s
        end
    end
end

local function getnearplayer(range)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = LocalPlayer.Character.HumanoidRootPart
    local closest, dist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local d = (p.Character.HumanoidRootPart.Position - root.Position).Magnitude
                if d < range and d < dist then closest, dist = p, d end
            end
        end
    end
    return closest
end

KaSection:Toggle({
    ["Name"] = "Killaura",
    ["Default"] = false,
    ["Flag"] = "Killaura",
    ["Callback"] = function(state)
        KAVar = state
    end
})

KaSection:Toggle({
    ["Name"] = "Highlight",
    ["Default"] = false,
    ["Flag"] = "HighlightKA",
    ["Tooltip"] = "Highlight target",
    ["Callback"] = function(state)
        HighVar = state
        if not state and CHighlight then
            CHighlight:Destroy()
            CHighlight = nil
        end
    end
})

--[[ Nuker ]]
local NukerSec = CombatTab:Section({
    ["Name"] = "Nuker",
    ["Side"] = 2
})

local NukerVar = false

local function getpickaxe()
    for _, n in ipairs({"Diamond Pickaxe","Iron Pickaxe","Stone Pickaxe","Wooden Pickaxe"}) do
        if LocalPlayer.Backpack:FindFirstChild(n) then return LocalPlayer.Backpack[n] end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(n) then return LocalPlayer.Character[n] end
    end
end

local function getnearbed(range)
    local beds = workspace:FindFirstChild("BedsContainer")
    if not beds or not LocalPlayer.Character then return end
    local closest, dist
    for _, b in ipairs(beds:GetChildren()) do
        local pivot = b:GetPivot().Position
        local d = (pivot - LocalPlayer.Character:GetPivot().Position).Magnitude
        if d <= range and (not dist or d < dist) then closest, dist = b, d end
    end
    return closest
end

local function breakbed(pick, bed)
    local pivot = bed:GetPivot().Position
    local minePos = pivot + Vector3.new(0, bed:GetExtentsSize().Y + 0.05, 0)
    ItemsRemotes.MineBlock:FireServer(pick.Name, bed, pivot, minePos, pivot - minePos)
end

NukerSec:Toggle({
    ["Name"] = "Nuker",
    ["Default"] = false,
    ["Flag"] = "Nuker",
    ["Tooltip"] = "Breaks beds around you",
    ["Risky"] = true
    ["Callback"] = function(state)
        NukerVar = state
    end
})

local Lastswitch, Switchdelay = 0, 0.08
local Usesword = true
local Lastmine, Minedelay = 0, 0.15

task.spawn(function()
    while task.wait(0.03) do
        if not LocalPlayer.Character then continue end

        local target = KAVar and getnearplayer(18)
        local bed = NukerVar and getnearbed(30)
        local now = tick()

        if target and bed then
            if now - Lastswitch >= Switchdelay then
                Lastswitch = now
                Usesword = not Usesword
            end
        elseif target then Usesword = true
        elseif bed then Usesword = false
        else Usesword = true end

        if KAVar and target then
            local sword = getsword()
            if sword then
                toolequip(sword)
                ItemsRemotes.SwordHit:FireServer(target.Character, sword)
            end
        end

        if NukerVar and bed and now - Lastmine >= Minedelay then
            Lastmine = now
            local pick = getpickaxe()
            if pick then
                toolequip(pick.Name)
                task.wait(0.02)
                breakbed(pick, bed)
                if KAVar and target then
                    local sword = getsword()
                    if sword then task.wait(0.01) toolequip(sword) end
                end
            end
        end

        if HighVar and target and target.Character then
            if not CHighlight then
                CHighlight = Instance.new("Highlight")
                CHighlight.FillColor = Color3.fromRGB(66,135,245)
            end
            CHighlight.Adornee = target.Character
            CHighlight.Parent = target.Character
        elseif CHighlight then
            CHighlight:Destroy()
            CHighlight=nil
        end
    end
end)

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
    ["Items"] = {"Cat","Waifu","Troll"},
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
local FOVSec = VisualsTab:Section({
    ["Name"] = "FOV",
    ["Side"] = 1
})

local FOVVar = false

local FOVTog = FOVSec:Toggle({
    ["Name"] = "FOV",
    ["Default"] = false,
    ["Flag"] = "FOV",
    ["Tooltip"] = "Incrase your fov",
    ["Risky"] = false,
    ["Callback"] = function(state)
        FOVVar = state
        if FOVVar == false then
            workspace.CurrentCamera.FieldOfView = 70
        end
    end
})

local FOVVal = FOVSec:Slider({
    ["Name"] = "FOV",
    ["Flag"] = "FOVVal",
    ["Min"] = 70,
    ["Default"] = 90,
    ["Max"] = 120,
    ["Suffix"] = "%",
    ["Decimals"] = 1,
    ["Callback"] = function(value)
        if FOVVar == true then
            workspace.CurrentCamera.FieldOfView = value
        else
            workspace.CurrentCamera.FieldOfView = 70
        end
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