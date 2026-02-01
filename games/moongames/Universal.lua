local guiLibrary = loadfile("Haze/uis/MoonLibrary.lua")()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local WCam = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

--[[ Libraries ]]
local modules = {
    Whitelist = loadfile("Haze/libraries/Whitelist.lua")(),
    ESPController = loadfile("Haze/libraries/modules/EspController.lua")()
}

modules.Notifications:Notify("Success", "Welcome " .. LocalPlayer.Name .. ".", 20)

--[[ Speed ]]
local SpeedVar = false
local SpeedValue = 16

local gmt = getrawmetatable(game)
setreadonly(gmt, false)
local oldindex = gmt.__index

gmt.__index = newcclosure(function(self, b)
    if b == "JumpPower" then return 50 end
    if b == "WalkSpeed" then return 16 end
    return oldindex(self, b)
end)
setreadonly(gmt, true)

RunService.Heartbeat:Connect(function()
    if SpeedVar then
        local Character = LocalPlayer.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
        if Humanoid then
            Humanoid.WalkSpeed = SpeedValue
        end
    end
end)

local SpeedModule = guiLibrary.Windows.Movement:createModule({
    ["Name"] = "Speed",
    ["Description"] = "Makes you walk faster",
    ["Function"] = function(state)
        SpeedVar = state
        if not state then
            local Character = LocalPlayer.Character
            local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                Humanoid.WalkSpeed = 16
            end
        end
    end,
    ["ExtraText"] = function()
        return tostring(SpeedValue)
    end
})

local SpeedValueMod = SpeedModule.sliders.new({
    ["Name"] = "Speed Value",
    ["Minimum"] = 16,
    ["Maximum"] = 100,
    ["Default"] = 16,
    ["Function"] = function(value)
        SpeedValue = value
    end
})

--[[ Cape ]]
local Capevar = false

local CapePNG = "Haze/assets/capes/Cat.png"
local CapeColor = Color3.fromRGB(255,255,255)

local Cape, Motor

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

local CapeModule = guiLibrary.Windows.Visuals:createModule({
    ["Name"] = "Cape",
    ["Function"] = function(v)
        Capevar = v
        if v and LocalPlayer.Character then
            build(LocalPlayer.Character)
        else
            clear()
        end
    end
})

local CapeFiles = CapeModule.selectors.new({
    ["Name"] = "Capes",
    ["Default"] = "Wave",
    ["Selections"] = {"Cat", "Waifu", "Troll", "Wave"},
    ["Function"] = function(v)
        local path = "Haze/assets/capes/"..v..".png"
        if isfile(path) then
            CapePNG = path
            if Capevar and LocalPlayer.Character then
                build(LocalPlayer.Character)
            end
        end
    end
})

--[[ Vibe ]]
local VibeModule = guiLibrary.Windows.Visuals:createModule({
    ["Name"] = "Vibe",
    ["Function"] = function(state)
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

local FOVModule = guiLibrary.Windows.Visuals:createModule({
    ["Name"] = "FOV",
    ["Function"] = function(state)
        FOVVar = state
        ManageFOV()
    end,
    ["ExtraText"] = function()
        return tostring(FOVValue)
    end
})

local FOVModuleVal = FOVModule.sliders.new({
    ["Name"] = "FOV",
    ["Minimum"] = 90,
    ["Maximum"] = 200,
    ["Default"] = 120,
    ["Function"] = function(value)
        FOVValue = value
    end
})

--[[ ESP ]]
local ESPModule = guiLibrary.Windows.Visuals:createModule({
    ["Name"] = "ESP",
    ["Function"] = function(state)
        modules.ESPController.Enabled = state
    end
})

local ESPVibe = ESPModule.toggles.new({
    ["Name"] = "Vibe ESP",
    ["Description"] = "Give a good vibe to the esp boxes",
    ["Function"] = function(state)
        modules.ESPController.UseGradient = state
    end
})

local ESPTheme = ESPModule.selectors.new({
    ["Name"] = "Themes",
    ["Default"] = "Haze",
    ["Selections"] = {"Haze", "Aqua", "Nova"},
    ["Function"] = function(val)
        if val and val ~= "" then
            modules.ESPController.Theme = val
        else
            modules.ESPController.Theme = "Haze"
        end
    end
})

local ESPTeamCheck = ESPModule.toggles.new({
    ["Name"] = "Team Check",
    ["Function"] = function(state)
        modules.ESPController.TeamCheck = state
    end
})

local ESPIgnoreTeam = ESPModule.toggles.new({
    ["Name"] = "Ignore Team",
    ["Function"] = function(state)
        modules.ESPController.NoTeam = state
    end
})

--[[ Fly ]]
local FlyModule = guiLibrary.Windows.Movement:createModule({
    ["Name"] = "Fly",
    ["Function"] = function(state)
        modules.FlyController:Toggle(state)
    end
})

local FlyVertical = FlyModule.toggles.new({
    ["Name"] = "Vertical",
    ["Function"] = function(state)
        modules.FlyController:SetVertical(state)
    end
})

--[[ Reverbs ]]
local RevertReverbs = SoundService.AmbientReverb

local ReverbModule = guiLibrary.Windows.Visuals:createModule({
    ["Name"] = "Reverbs",
    ["Function"] = function(state)
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
local beatLoaded = false

local function playBeat()
    if not beatLoaded then
        local path = "Haze/assets/audios/beat.mp3"
        local success, asset = pcall(function()
            return getcustomasset(path)
        end)
        if success and asset then
            MusicSound.SoundId = tostring(asset)
            beatLoaded = true
        else
            warn("Failed to load beat.mp3")
            return
        end
    end
    MusicSound:Play()
end

local ViberModule = guiLibrary.Windows.Visuals:createModule({
    ["Name"] = "Viber",
    ["Function"] = function(state)
        viberVar = state
        if state then
            playBeat()

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
                    s.Color = rainbow and Color3.fromHSV(math.random(),1,1) or Color3.fromRGB(180,220,255)
                    s.Position = Vector3.new(math.random(-500,500), 80, math.random(-500,500))
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
                    local hit = workspace:Raycast(s.Position, Vector3.new(0, -fall, 0), params)
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

local ViberReverb = ViberModule.toggles.new({
    ["Name"] = "Reverbs",
    ["Function"] = function(state)
        reverbsvibervar = state
        if viberVar then
            SoundService.AmbientReverb = state and Enum.ReverbType.Cave or ReverbBackup
        end
    end
})

local ViberVolume = ViberModule.sliders.new({
    ["Name"] = "Volume",
    ["Minimum"] = 0.5,
    ["Maximum"] = 10,
    ["Default"] = 1,
    ["Function"] = function(value)
        volumeVal = value
        MusicSound.Volume = value
    end
})