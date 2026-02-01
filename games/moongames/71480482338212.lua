--[[ BedFight ]]
local guiLibrary = loadfile("Haze/uis/MoonLibrary.lua")()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local WCam = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

--[[ Libraries ]]
local LocalLibrary = "Haze/libraries"
local modules = {
    Entity = loadfile(LocalLibrary .. "/modules/Entity.lua")(),
    Whitelist = loadfile(LocalLibrary .. "/Whitelist.lua")(),
    Notifications = loadfile(LocalLibrary .. "/Notifications.lua")(),
    SprintController = loadfile(LocalLibrary .. "/bedfight/SprintController.lua")(),
    ESPController = loadfile(LocalLibrary .. "/modules/EspController.lua")(),
    ScaffoldController = loadfile(LocalLibrary .. "/bedfight/ScaffoldController.lua")(),
    FlyController = loadfile(LocalLibrary .. "/bedfight/FlyController.lua")(),
    PartyController = loadfile(LocalLibrary .. "/bedfight/PartyController.lua")()
}

local remotes = {
    SwordHitRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ItemsRemotes"):WaitForChild("SwordHit"),
    MineBlockRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ItemsRemotes"):WaitForChild("MineBlock"),
    EquipRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ItemsRemotes"):WaitForChild("EquipTool"),
    EquipCape = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("EquipCape"),
    TakeItemFromChest = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TakeItemFromChest")
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
    ["Maximum"] = 32,
    ["Default"] = 16,
    ["Function"] = function(value)
        SpeedValue = value
    end
})

--[[ KillAura ]]
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

local function getnearplayer()
    local closest, closestDist = nil, math.huge
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myTeam = LocalPlayer.Team

    if not myRoot or not modules.Entity.isAlive(myChar) then
        return nil
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and modules.Entity.isAlive(p.Character) then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local dist = (root.Position - myRoot.Position).Magnitude
                if dist <= 20 and dist < closestDist then

                    local AttackData = false
                    if myTeam == nil or myTeam.Name == "Spectators" then
                        AttackData = true
                    else
                        if p.Team ~= myTeam then
                            AttackData = true
                        end
                    end

                    if AttackData then
                        closestDist = dist
                        closest = p
                    end
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
                    remotes.SwordHitRemote:FireServer(target.Character, sword)
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

local KillAuraModule = guiLibrary.Windows.Combat:createModule({
    ["Name"] = "KillAura",
    ["Description"] = "Automatically attacks players",
    ["Function"] = function(state)
        KAVar = state
        if state then
            runKA()
        end
    end,
    ["ExtraText"] = function()
        return tostring(AnimMode)
    end
})

local KillAuraHL = KillAuraModule.toggles.new({
    ["Name"] = "Highlight",
    ["Function"] = function(state)
        HighVar = state
        if not state and currentHighlight then
            currentHighlight:Destroy()
            currentHighlight = nil
        end
    end
})

local KillAuraAnims = KillAuraModule.toggles.new({
    ["Name"] = "Anims",
    ["Function"] = function(state)
        AnimsVar = state
    end
})

local KillAuraDelay = KillAuraModule.selectors.new({
    ["Name"] = "Delay",
    ["Default"] = "No Delay",
    ["Selections"] = {"No Delay", "Respect Delay"},
    ["Function"] = function(value)
        AnimMode = value
    end
})

--[[ Nuker ]]
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
    remotes.MineBlockRemote:FireServer(
        pick.Name,
        model,
        vector.create(pos.X, pos.Y, pos.Z),
        vector.create(origin.X, origin.Y, origin.Z),
        vector.create(direction.X, direction.Y, direction.Z)
    )
end

local NukerModule = guiLibrary.Windows.Utility:createModule({
    ["Name"] = "Nuker",
    ["Description"] = "Automatically break beds",
    ["Function"] = function(state)
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

--[[ Killaura and Nuker Holder ]]
local Swords = {"Emerald Sword", "Diamond Sword", "Iron Sword", "Stone Sword", "Wooden Sword"}

local function getbestsword()
    local container = {LocalPlayer.Backpack, LocalPlayer.Character}
    for _, parent in ipairs(container) do
        if parent then
            for _, swordName in ipairs(Swords) do
                local tool = parent:FindFirstChild(swordName)
                if tool then return tool.Name end
            end
        end
    end
end

local currentTool = nil

RunService.Heartbeat:Connect(function()
    local pickaxe = getpickaxe()
    local sword = getbestsword()
    local targetTool = nil

    local nearBed = getnearbed(30)

    if NukerVar and not KAVar then
        if pickaxe and nearBed then
            targetTool = pickaxe.Name
        end
    elseif KAVar and not NukerVar then
        targetTool = sword
    elseif NukerVar and KAVar then
        if currentTool ~= sword and sword then
            targetTool = sword
        elseif pickaxe and nearBed and currentTool ~= pickaxe then
            targetTool = pickaxe.Name
        end
    end

    if targetTool and targetTool ~= currentTool then
        remotes.EquipRemote:FireServer(targetTool)
        currentTool = targetTool
    end
end)

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

--[[ GayCape ]]
local GayCapeVar = false

local Capelist = {"Black", "White", "Red", "Yellow", "Green", "Blue", "Pink"}

local GayCapeModule = guiLibrary.Windows.Extra:createModule({
    ["Name"] = "GayCape",
    ["Description"] = "Im sorry for this, FE btw",
    ["Function"] = function(state)
        GayCapeVar = state
        if GayCapeVar then
            task.spawn(function()
                while GayCapeVar do
                    for _, color in ipairs(Capelist) do
                        remotes.EquipCape:FireServer(color)
                        task.wait(.1)
                        if not GayCapeVar then break end
                    end
                end
            end)
        end
    end
})

--[[ Unique FE Capes ]]
local UniqueCapesData = {
    Pro = {
        Name = "Pro",
    },
    Fire = {
        Name = "Fire",
    }
}

local UniqueCapeModule = guiLibrary.Windows.Extra:createModule({
    ["Name"] = "UniqueCape",
    ["Function"] = function(state)
        if not state then
            remotes.EquipCape:FireServer("None")
        end
    end
})

local UniqueCapeList = UniqueCapeModule.selectors.new({
    ["Name"] = "Capes",
    ["Default"] = "Fire",
    ["Selections"] = {"Pro", "Fire"},
    ["Function"] = function(value)
        local UniqueCape = UniqueCapesData[value]

        if UniqueCape then
            remotes.EquipCape:FireServer(UniqueCape.Name)
        else
            remotes.EquipCape:FireServer("None")
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
    ["Maximum"] = 120,
    ["Default"] = 120,
    ["Function"] = function(value)
        FOVValue = value
    end
})

--[[ ChestStealer ]]
local TeamColors = {"Red", "Orange", "Yellow", "Green", "Blue", "Purple", "Pink", "Brown"}

local CSVar = false

local ChestStealerModule = guiLibrary.Windows.Utility:createModule({
    ["Name"] = "Chest Stealer",
    ["Function"] = function(state)
        CSVar = state
        if state then
            spawn(function()
                while CSVar do
                    for _, color in ipairs(TeamColors) do
                        for num = 1, 20 do
                            if not CSVar then break end
                            remotes.TakeItemFromChest:FireServer(color, num, "1")
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

local VelocityModul = guiLibrary.Windows.Utility:createModule({
    ["Name"] = "Velocity",
    ["Description"] = "Remove knockback",
    ["Function"] = function(state)
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
local SprintModule = guiLibrary.Windows.Movement:createModule({
    ["Name"] = "AutoSprint",
    ["Function"] = function(state)
        modules.SprintController:SetState(state)
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

--[[ Scaffold ]]
local ScaffoldModule = guiLibrary.Windows.Utility:createModule({
    ["Name"] = "Scaffold",
    ["Function"] = function(state)
        modules.ScaffoldController:SetState(state)
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

--[[ Spam Invites ]]
local InviteModule = guiLibrary.Windows.Utility:createModule({
    ["Name"] = "Spam Invites",
    ["Description"] = "Invites everyone in your party",
    ["Function"] = function(state)
        spawn(function()
            while state do
                modules.PartyController:InviteAll()
                wait(0.1)
            end
        end)
    end
})

--[[ Kick Spam ]]
local KickModule = guiLibrary.Windows.Utility:createModule({
    ["Name"] = "KickExploit",
    ["Description"] = "Spam Kick everyone for party, everyone in server will get spam kicked even if not in party",
    ["Function"] = function(state)
        spawn(function()
            while state do
                modules.PartyController:KickAll()
                wait(0.1)
            end
        end)
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