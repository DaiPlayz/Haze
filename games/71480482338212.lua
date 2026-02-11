--[[ BedFight ]]
local guiLibrary = loadfile("Haze/uis/HazeLibrary.lua")()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--[[ Libraries ]]
local LocalLibrary = "Haze/libraries"
local modules = {
    Entity = loadfile(LocalLibrary .. "/modules/Entity.lua")(),
    SprintController = loadfile(LocalLibrary .. "/bedfight/SprintController.lua")(),
    ScaffoldController = loadfile(LocalLibrary .. "/bedfight/ScaffoldController.lua")(),
    PartyController = loadfile(LocalLibrary .. "/bedfight/PartyController.lua")(),
    EmotesController = loadfile(LocalLibrary .. "/bedfight/EmotesController.lua")()
}

local remotes = {
    SwordHitRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ItemsRemotes"):WaitForChild("SwordHit"),
    MineBlockRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ItemsRemotes"):WaitForChild("MineBlock"),
    EquipRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ItemsRemotes"):WaitForChild("EquipTool"),
    EquipCape = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("EquipCape"),
    TakeItemFromChest = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TakeItemFromChest")
}

local Swords = {"Emerald Sword", "Diamond Sword", "Iron Sword", "Stone Sword", "Wooden Sword"}

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

--[[ Scaffold ]]
local ScaffoldModule = guiLibrary.Windows.Utility:createModule({
    ["Name"] = "Scaffold",
    ["Function"] = function(state)
        modules.ScaffoldController:SetState(state)
    end
})

--[[ Spam Invites ]]
local InviteSpamVar = false
local InviteModule = guiLibrary.Windows.Utility:createModule({
    ["Name"] = "Spam Invites",
    ["Description"] = "Invites everyone in your party",
    ["Function"] = function(state)
        InviteSpam = state

        task.spawn(function()
            while InviteSpam do
                modules.PartyController:InviteAll()
                wait(.1)
            end
        end)
    end
})

--[[ Kick Spam ]]
local KickExpVar = false
local KickModule = guiLibrary.Windows.Utility:createModule({
    ["Name"] = "KickExploit",
    ["Description"] = "Spam Kick everyone for party, everyone in server will get spam kicked even if not in party",
    ["Function"] = function(state)
        KickExpVar = state

        task.spawn(function()
            while KickExpVar do
                modules.PartyController:KickAll()
                wait(.1)
            end
        end)
    end
})

--[[ Emote Exploit ]]
local currentEmote
local EmoteEXPVar = false

local EmoteModule
EmoteModule = guiLibrary.Windows.Utility:createModule({
    ["Name"] = "EmoteExploit",
    ["Description"] = "Remake bedfight emotes in our ways",
    ["Function"] = function(state)
        EmoteEXPVar = state
        if not state then
            modules.EmotesController:StopAll()
            return
        end

        if currentEmote then
            modules.EmotesController:StopAll()
            modules.EmotesController:Play(currentEmote)
        end

        if currentEmote == "Makeup" then
            task.spawn(function()
                task.wait(5)
                if EmoteModule.enabled then
                    EmoteModule:toggle(true)
                end
            end)
        end
    end
})

local EmoteList = EmoteModule.selectors.new({
    ["Name"] = "Emotes",
    ["Default"] = "Crystal",
    ["Selections"] = {"Crystal", "Chair", "Make up"},
    ["Function"] = function(value)
        if value == "Crystal" then
            currentEmote = "CrystalIdle"
        elseif value == "Chair" then
            currentEmote = "Chair"
        elseif value == "Make up" then
            currentEmote = "Makeup"
        end

        if EmoteEXPVar then
            modules.EmotesController:StopAll()
            modules.EmotesController:Play(currentEmote)

            if currentEmote == "Makeup" then
                task.spawn(function()
                    task.wait(3)
                    if EmoteModule.enabled then
                        EmoteModule:toggle(true)
                    end
                end)
            end
        end
    end
})