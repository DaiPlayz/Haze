--[[ Be a YouTuber! ]]
local Library = loadfile("Haze/uis/HazeLibrary.lua")()

local Window = Library:Window({
    ["Name"] = "H A Z E",
    ["GradientTitle"] = {
        ["Enabled"] = true,
        ["Start"] = Color3.fromRGB(66, 245, 138),
        ["Middle"] = Color3.fromRGB(66, 191, 245),
        ["End"] = Color3.fromRGB(245, 66, 200),
        ["Speed"] = 1
    }
})

local Watermark = Library:Watermark("H A Z E", {"Haze/assets/lib/logo.png", Color3.fromRGB(66, 245, 138)}, false)

local KeybindList = Library:KeybindList()

local CombatTab = Window:Page({Name = "Combat", Columns = 2})
local MovementTab = Window:Page({Name = "Movement", Columns = 2})
local VisualsTab = Window:Page({Name = "Visuals",  Columns = 2})
local UtilityTab = Window:Page({Name = "Utility",  Columns = 2})
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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local WCam = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Character = LocalPlayer.Character

--[[ Libraries ]]
local LocalLibrary = "Haze/libraries"
local modules = {
    Discord = loadfile(LocalLibrary .. "/Discord.lua")(),
    Whitelist = loadfile(LocalLibrary .. "/Whitelist.lua")(),
    ESPController = loadfile(LocalLibrary .. "/modules/EspController.lua")(),
    PlaceController = loadfile(LocalLibrary .. "/youtuber/PlaceController.lua")()
}

--[[ Remotes ]]
local byremotes = {
    AutoUpload = ReplicatedStorage:WaitForChild("events"):WaitForChild("uploadAll"),
    AutoPickUp = ReplicatedStorage:WaitForChild("events"):WaitForChild("pickUp"),
    AutoClaim = ReplicatedStorage:WaitForChild("events"):WaitForChild("claimVideo"),
    AutoCollect = ReplicatedStorage:WaitForChild("events"):WaitForChild("collect")
}

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

local SpeedLab = SpeedSection:Label("Bypasses most of the anticheats","Left")

local SpeedTog = SpeedSection:Toggle({
    ["Name"] = "Speed", 
    ["Default"] = false, 
    ["Flag"] = "SpeedTog",
    ["Tooltip"] = "Makes you walk faster | Bypasses most of anticheats",
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
    ["Max"] = 100,
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
    ["Tooltip"] = "Incrase your fov",
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

--[[ Reverbs ]]
local RevertReverbs = SoundService.AmbientReverb
local ReverbsSec = VisualsTab:Section({
    ["Name"] = "Reverbs",
    ["Side"] = 2
})

ReverbsSec:Toggle({
    ["Name"] = "Reverbs",
    ["Flag"] = "Reverbs",
    ["Default"] = false,
    ["Callback"] = function(state)
        if state then
            SoundService.AmbientReverb = Enum.ReverbType.SewerPipe
        else
            SoundService.AmbientReverb = RevertReverbs
        end
    end
})

--[[ Viber ]]
local oldFOV = WCam.FieldOfView
local ReverbBackup = SoundService.AmbientReverb
local oldRevert = {
    ClockTime = Lighting.ClockTime,
    Brightness = Lighting.Brightness,
    FogEnd = Lighting.FogEnd,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

local ViberSec = VisualsTab:Section({
    ["Name"] = "Viber",
    ["Side"] = 2
})

local volumeVal = 1

local MusicSound = Instance.new("Sound")
MusicSound.Parent = SoundService
MusicSound.Looped = true
MusicSound.Volume = volumeVal

local viberVar = false
local reverbsvibervar = false
local fovConnection
local snowConnection
local glowingsnow = {}

local function getAudioAsset(name)
    if not name or name == "" then return end

    local path = "Haze/assets/audios/" .. name .. ".mp3"
    local success, asset = pcall(function()
        return getcustomasset(path)
    end)

    if success and asset then
        MusicSound.SoundId = asset
        if viberVar then
            MusicSound:Play()
        end
    end
end

ViberSec:Toggle({
    ["Name"] = "Viber",
    ["Flag"] = "ViberToggle",
    ["Default"] = false,
    ["Callback"] = function(state)
        viberVar = state

        if state then
            if MusicSound.SoundId ~= "" then
                MusicSound:Play()
            end

            if reverbsvibervar then
                SoundService.AmbientReverb = Enum.ReverbType.Cave
            end

            Lighting.ClockTime = 23
            Lighting.Brightness = 2
            Lighting.FogEnd = 1000
            Lighting.Ambient = Color3.fromRGB(120,120,140)
            Lighting.OutdoorAmbient = Color3.fromRGB(80,80,100)

            fovConnection = RunService.RenderStepped:Connect(function()
                if MusicSound.IsPlaying then
                    local bass = MusicSound.PlaybackLoudness / 150
                    WCam.FieldOfView = oldFOV + bass * 15
                else
                    WCam.FieldOfView = oldFOV
                end
            end)

            snowConnection = RunService.RenderStepped:Connect(function(dt)
                local loudness = MusicSound.IsPlaying and MusicSound.PlaybackLoudness or 0
                local bassScale = math.clamp(loudness / 100, 0.5, 6)
                local rainbow = loudness >= 280

                for _ = 1, math.floor(6 * bassScale) do
                    local s = Instance.new("Part")
                    s.Anchored = true
                    s.CanCollide = false
                    s.Size = Vector3.new(0.5,0.5,0.5)
                    s.Material = Enum.Material.Neon
                    s.Color = rainbow
                        and Color3.fromHSV(math.random(),1,1)
                        or Color3.fromRGB(180,220,255)

                    s.Position = Vector3.new(
                        math.random(-500 , 500),
                        80,
                        math.random(-500 , 500)
                    )
                    s.Parent = workspace
                    table.insert(glowingsnow,s)
                end

                for i = #glowingsnow, 1, -1 do
                    local s = glowingsnow[i]
                    if not s or not s.Parent then
                        table.remove(glowingsnow, i)
                        continue
                    end

                    local fall = dt * 14 * bassScale
                    s.Position -= Vector3.new(0, fall, 0)

                    local params = RaycastParams.new()
                    params.FilterDescendantsInstances = { s }
                    params.FilterType = Enum.RaycastFilterType.Blacklist

                    local hit = workspace:Raycast(
                        s.Position,
                        Vector3.new(0, -fall, 0),
                        params
                    )

                    if hit or s.Position.Y <= 0 then
                        s:Destroy()
                        table.remove(glowingsnow, i)
                    end
                end
            end)

        else
            MusicSound:Stop()
            WCam.FieldOfView = oldFOV
            SoundService.AmbientReverb = ReverbBackup

            for k,v in pairs(oldRevert) do
                Lighting[k] = v
            end

            if fovConnection then fovConnection:Disconnect() end
            if snowConnection then snowConnection:Disconnect() end

            for _,s in ipairs(glowingsnow) do
                if s and s.Parent then s:Destroy() end
            end
            glowingsnow = {}
        end
    end
})

ViberSec:Toggle({
    ["Name"] = "Reverbs",
    ["Flag"] = "ViberReverb",
    ["Default"] = false,
    ["Callback"] = function(state)
        reverbsvibervar = state
        if viberVar then
            SoundService.AmbientReverb = state and Enum.ReverbType.Cave or ReverbBackup
        end
    end
})

ViberSec:Textbox({
    ["Name"] = "Asset Name",
    ["Flag"] = "MusicInput",
    ["Default"] = "",
    ["Placeholder"] = "song name (must be in Haze/assets/audios)",
    ["Callback"] = getAudioAsset
})

ViberSec:Slider({
    ["Name"] = "Volume",
    ["Min"] = 0.5,
    ["Max"] = 10,
    ["Default"] = 1,
    ["Decimals"] = 0.1,
    ["Flag"] = "ViberVolume",
    ["Callback"] = function(value)
        volumeVal = value
        MusicSound.Volume = value
    end
})

ViberSec:Button({
    ["Name"] = "Tutorial",
    ["Callback"] = function()
        Library:Notification("Place a song (.mp3) in the folder Haze/assets/audios then put the name of the file in the textbox (SONG FILE MUST BE UNDER 20mb and 7 Mins long)", 15, Color3.fromRGB(66, 245, 138))
    end
})

--[[ AutoPlace ]]
local AutoPlaceSec = UtilityTab:Section({
    ["Name"] = "AutoPlace",
    ["Side"] = 1
})

AutoPlaceSec:Toggle({
    ["Name"] = "Auto Place",
    ["Flag"] = "AutoPlace",
    ["Default"] = false,
    ["Callback"] = function(state)
        if state then
            modules.PlaceController:Start()
        else
            modules.PlaceController:Stop()
        end
    end
})

AutoPlaceSec:Dropdown({
    ["Name"] = "Method",
    ["Flag"] = "AutoPlace_Method",
    ["Items"] = {"LocalPlayer", "Players"},
    ["Default"] = "LocalPlayer",
    ["Callback"] = function(value)
        modules.PlaceController:SetTarget(value)
    end
})

--[[ AutoClaim ]]
local AutoClaimVar = false

local AutoClaimSec = UtilityTab:Section({
    ["Name"] = "AutoClaim",
    ["Side"] = 2
})

AutoClaimSec:Toggle({
    ["Name"] = "Auto Claim",
    ["Flag"] = "AutoClaim",
    ["Default"] = false,
    ["Callback"] = function(state)
        AutoClaimVar = state

        if state then
            task.spawn(function()
                while AutoClaimVar do
                    local uploading = LocalPlayer:FindFirstChild("videosFolder") and LocalPlayer:FindFirstChild("videosFolder"):FindFirstChild("uploading")
                    if uploading then
                        for _, videoFolder in ipairs(uploading:GetChildren()) do
                            if videoFolder then
                                local args = {videoFolder.Name}
                                pcall(function()
                                    byremotes.AutoClaim:FireServer(unpack(args))
                                end)
                                task.wait()
                            end
                        end
                    end
                    task.wait()
                end
            end)
        end
    end
})

--[[ AutoUpload ]]
local AutoUploadVar = false

local AutoUploadSec = UtilityTab:Section({
    ["Name"] = "AutoUpload",
    ["Side"] = 1
})

AutoUploadSec:Toggle({
    ["Name"] = "Auto Upload",
    ["Flag"] = "AutoUpload",
    ["Default"] = false,
    ["Callback"] = function(state)
        AutoUploadVar = state

        if state then
            task.spawn(function()
                while AutoUploadVar do
                    pcall(function()
                        byremotes.AutoUpload:FireServer()
                    end)
                    task.wait()
                end
            end)
        end
    end
})

--[[ AutoPickUp ]]
local AutoPickUpVar = false

local AutoPickUpSec = UtilityTab:Section({
    ["Name"] = "AutoPickUp",
    ["Side"] = 2
})

AutoPickUpSec:Toggle({
    ["Name"] = "Auto PickUp",
    ["Flag"] = "AutoPickUp",
    ["Default"] = false,
    ["Callback"] = function(state)
        AutoPickUpVar = state

        if state then
            task.spawn(function()
                while AutoPickUpVar do
                    for _, plot in ipairs(game.workspace.Plots:GetChildren()) do
                        local PlotSign = plot:FindFirstChild("PlayerSign")
                        if PlotSign and PlotSign:FindFirstChild("Main") and PlotSign.Main:FindFirstChild("SurfaceGui") and PlotSign.Main.SurfaceGui:FindFirstChild("TextLabel") then
                            local LPDetect = PlotSign.Main.SurfaceGui.TextLabel.Text
                            if LPDetect:match(LocalPlayer.Name) then
                                local buildsFolder = plot:FindFirstChild("Builds")
                                if buildsFolder then
                                    for _, build in ipairs(buildsFolder:GetChildren()) do
                                        pcall(function()
                                            byremotes.AutoPickUp:FireServer(build.Name)
                                        end)
                                        task.wait()
                                    end
                                end
                            end
                        end
                    end
                    task.wait()
                end
            end)
        end
    end
})

--[[ AutoCollect ]]
local AutoCollectVar = false

local AutoCollectSec = UtilityTab:Section({
    ["Name"] = "AutoCollect",
    ["Side"] = 1
})

AutoCollectSec:Toggle({
    ["Name"] = "Auto Collect",
    ["Flag"] = "AutoCollect",
    ["Default"] = false,
    ["Callback"] = function(state)
        AutoCollectVar = state

        if state then
            task.spawn(function()
                while AutoCollectVar do
                    for _, plot in ipairs(game.workspace.Plots:GetChildren()) do
                        local PlotSign = plot:FindFirstChild("PlayerSign")
                        if PlotSign and PlotSign:FindFirstChild("Main") and PlotSign.Main:FindFirstChild("SurfaceGui") and PlotSign.Main.SurfaceGui:FindFirstChild("TextLabel") then
                            local LPDetect = PlotSign.Main.SurfaceGui.TextLabel.Text
                            if LPDetect:match(LocalPlayer.Name) then
                                local buildsFolder = plot:FindFirstChild("Builds")
                                if buildsFolder then
                                    for _, build in ipairs(buildsFolder:GetChildren()) do
                                        pcall(function()
                                            local buildID = build:GetAttribute("ID") or build.Name
                                            byremotes.AutoCollect:FireServer(buildID)
                                        end)
                                        task.wait()
                                    end
                                end
                            end
                        end
                    end
                    task.wait()
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
                Library:Notification("Theme " .. ThemeName .. ".json already exists", 3, Color3.fromRGB(66, 245, 138))
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
                Library:Notification("Config " .. ConfigName .. ".json already exists", 3, Color3.fromRGB(66, 245, 138))
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
        ["Name"] = "Discord",
        ["Callback"] = function()
        modules.Discord:Join("https://discord.gg/W92SXVmB5X")
        modules.Discord:Copy("https://discord.gg/W92SXVmB5X")
    end})

    ConfigsSection:Button({
        ["Name"] = "Uninject",
        ["Callback"] = function()
        Library:Unload()
    end})

    task.spawn(function()
        repeat task.wait() until Library and Library.Flags

        local cfg = rawget(_G, "HazeAutoConfig")
        if type(cfg) ~= "string" then return end

        local path = cfg:find("/") and cfg or (Library.Folders.Configs .. "/" .. cfg)

        if isfile(path) then
            Library:LoadConfig(readfile(path))

            task.wait(0.1)
            for Index, _ in Library.Theme do
                local flag = Library.Flags["Theme"..Index]
                if flag then
                    Library.Theme[Index] = flag.Color
                    Library:ChangeTheme(Index, flag.Color)
                end
            end
        end
    end)
end