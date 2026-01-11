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
local VisualsTab = Window:Page({Name = "Visuals",  Columns = 1})
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

--[[Killaura]]
local KaSection = CombatTab:Section({Name="KillAura", Side=1})
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ItemsRemotes = Remotes:WaitForChild("ItemsRemotes")

local function equipsword()
    for _, s in ipairs({"Wooden Sword","Stone Sword","Iron Sword","Diamond Sword","Emerald Sword"}) do
        if LocalPlayer.Backpack:FindFirstChild(s) then
            ItemsRemotes.EquipTool:FireServer(s)
            return s
        end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(s) then
            return s
        end
    end
end

local function nearplayer(range)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local nearest, dist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        local hum = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
        if p ~= LocalPlayer and hrp and hum and hum.Health > 0 then
            local sameTeam = LocalPlayer.Team and p.Team == LocalPlayer.Team
            local isSpectator = p.Team and p.Team.Name:lower():find("spectator")
            if not sameTeam or isSpectator then
                local d = (hrp.Position - root.Position).Magnitude
                if d < dist then
                    nearest, dist = p, d
                end
            end
        end
    end
    return nearest
end

local KAVar = false
local HighVar = false
local CHighlight

KaSection:Toggle({
    ["Name"] = "KillAura",
    ["Default"] = false,
    ["Callback"] = function(state)
        KAVar = state
        if KAVar then
            task.spawn(function()
                while KAVar do
                    local sword = equipsword()
                    local target = nearplayer(18)

                    if sword and target and target.Character then
                        ItemsRemotes.SwordHit:FireServer(target.Character, sword)

                        if HighVar then
                            if not CHighlight then
                                CHighlight = Instance.new("Highlight")
                            end
                            CHighlight.Adornee = target.Character
                            CHighlight.FillColor = Color3.fromRGB(66, 135, 245)
                            CHighlight.Parent = target.Character
                        end
                    elseif CHighlight and CHighlight.Adornee then
                        CHighlight:Destroy()
                        CHighlight = nil
                    end

                    task.wait(0.1)
                end
            end)
        else
            if CHighlight and CHighlight.Adornee then
                CHighlight:Destroy()
                CHighlight = nil
            end
        end
    end
})

KaSection:Toggle({
    ["Name"] = "Highlight",
    ["Default"] = false,
    ["Callback"] = function(state)
        HighVar = state
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