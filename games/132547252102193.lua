--[[ 1 Kill = 1 Armor ]]
local guiLibrary = loadfile("Haze/uis/HazeLibrary.lua")()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

--[[ Libraries ]]
local LocalLibrary = "Haze/libraries"
local modules = {
    Entity = loadfile(LocalLibrary .. "/modules/Entity.lua")(),
    Notifications = loadfile(LocalLibrary .. "/Notifications.lua")()
}

--[[ Remotes ]]
local remotes = {
    ApplyDamage = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("CombatService"):WaitForChild("RF"):WaitForChild("ApplyDamage"),
    InviteRemote = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("InviteService"):WaitForChild("RF"):WaitForChild("SendClanInvite")
}

--[[ Modules ]]
local AnimationData = require(ReplicatedStorage:WaitForChild("GameInfo"):WaitForChild("Ids"):WaitForChild("Animations"))

local humanoidvalues = {
    ['JumpPower'] = 50,
    ['WalkSpeed'] = 16
}

--[[ Speed ]]
local SpeedVar = false
local SpeedValue = 16

local oldindex;oldindex = hookmetamethod(game,"__index",newcclosure(function(self,key)
    if self:IsA("Humanoid") and humanoidvalues[key] then return humanoidvalues[key] end
    return oldindex(self,key)
end))
local oldnewindex;oldnewindex = hookmetamethod(game,"__newindex",newcclosure(function(self,key,value)
    if not checkcaller() and self:IsA("Humanoid") and humanoidvalues[key] then
        humanoidvalues[key] = value
        return
    end
    return oldnewindex(self,key,value)
end))

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
    ["Maximum"] = 29,
    ["Default"] = 16,
    ["Function"] = function(value)
        SpeedValue = value
    end
})

--[[ KillAura ]]
local KillAuraVar = false
local FaceTargetVar = false
local KARange = 18
local currentTargetPart = nil
local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

local KillAuraModule = guiLibrary.Windows.Combat:createModule({
    ["Name"] = "KillAura",
    ["Function"] = function(state)
        KillAuraVar = state
    end
})

KillAuraModule.toggles.new({
    ["Name"] = "FaceTarget",
    ["Default"] = false,
    ["Function"] = function(state)
        FaceTargetVar = state
    end
})

KillAuraModule.sliders.new({
    ["Name"] = "Range",
    ["Minimum"] = 5,
    ["Maximum"] = 18,
    ["Default"] = 18,
    ["Function"] = function(value)
        KARange = value
    end
})

task.spawn(function()
    while true do
        task.wait(0.1)
        if not KillAuraVar then 
            currentTargetPart = nil
            continue 
        end

        local targetPlayer = modules.Entity.nearPlayer(KARange)
        if targetPlayer and targetPlayer.Character then
            currentTargetPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            remotes.ApplyDamage:InvokeServer(targetPlayer.Character)
        else
            currentTargetPart = nil
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if not KillAuraVar or not FaceTargetVar or not currentTargetPart then 
        return 
    end

    if character and rootPart then
        local targetPos = currentTargetPart.Position
        local myPos = rootPart.Position
        local lookAtPos = Vector3.new(targetPos.X, myPos.Y, targetPos.Z)
        local targetCFrame = CFrame.lookAt(myPos, lookAtPos)
        rootPart.CFrame = rootPart.CFrame:Lerp(targetCFrame, 0.15) 
    end
end)

--[[ TPAura ]]
local TPAuraVar = false
local TPAHeight = 5
local TPARange = 18
local tweeninfo = TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

local TPAuraModule = guiLibrary.Windows.Movement:createModule({
    ["Name"] = "TPAura",
    ["Description"] = "beta",
    ["Function"] = function(state)
        TPAuraVar = state
        if state then
            task.spawn(function()
                while TPAuraVar do
                    task.wait(0.1)
                    
                    local myChar = LocalPlayer.Character
                    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    
                    if not myRoot then continue end

                    local targetPlayer = modules.Entity.nearPlayer(TPARange)

                    if targetPlayer and targetPlayer.Character and modules.Entity.isAlive(targetPlayer.Character) then
                        local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                        
                        if targetRoot then
                            local targetPos = targetRoot.Position + Vector3.new(0, TPAHeight, 0)
                            TweenService:Create(myRoot, tweeninfo, {CFrame = CFrame.new(targetPos)}):Play()
                        end
                    end
                end
            end)
        end
    end
})

--[[ TargetStrafe ]]
local TargetStrafeVar = false
local TSRange = 18
local SpinSpeed = 2
local SpinAngle = 0
local LookAtTarget = false

local TargetStrafeModule = guiLibrary.Windows.Combat:createModule({
    ["Name"] = "TargetStrafe",
    ["Description"] = "Spins around the player",
    ["Function"] = function(state)
        TargetStrafeVar = state
        if state then
            task.spawn(function()
                while TargetStrafeVar do
                    local dt = task.wait()
                    if not TargetStrafeVar then break end

                    local myChar = LocalPlayer.Character
                    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    if not myRoot then continue end

                    local targetPlayer = modules.Entity.nearPlayer(TSRange)
                    if not targetPlayer or not targetPlayer.Character or not modules.Entity.isAlive(targetPlayer.Character) then
                        continue
                    end

                    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if not targetRoot then continue end

                    SpinAngle = SpinAngle + SpinSpeed * dt
                    local offsetX = math.cos(SpinAngle) * 8
                    local offsetZ = math.sin(SpinAngle) * 8
                    local newPosition = targetRoot.Position + Vector3.new(offsetX, 3, offsetZ)

                    if LookAtTarget then
                        local lookPos = Vector3.new(targetRoot.Position.X, newPosition.Y, targetRoot.Position.Z)
                        myRoot.CFrame = CFrame.lookAt(newPosition, lookPos)
                    else
                        myRoot.CFrame = (myRoot.CFrame - myRoot.Position) + newPosition
                    end
                end
            end)
        end
    end
})

TargetStrafeModule.sliders.new({
    ["Name"] = "Spin Speed",
    ["Minimum"] = 5,
    ["Maximum"] = 10,
    ["Default"] = 10,
    ["Function"] = function(value)
        SpinSpeed = value
    end
})

TargetStrafeModule.sliders.new({
    ["Name"] = "Range",
    ["Minimum"] = 5,
    ["Maximum"] = 18,
    ["Default"] = 18,
    ["Function"] = function(value)
        TSRange = value
    end
})

TargetStrafeModule.toggles.new({
    ["Name"] = "Target Face",
    ["Default"] = false,
    ["Function"] = function(state)
        LookAtTarget = state
    end
})

--[[ JesusMode ]]
local JesusModeVar = false
local LastNotify = 0
local WaterObject = workspace:FindFirstChild("Water", true)

local function waterpart()
    if WaterObject:IsA("BasePart") then return WaterObject end
    if WaterObject:IsA("Model") then
        return WaterObject.PrimaryPart or WaterObject:FindFirstChildWhichIsA("BasePart")
    end
    return nil
end

local JesusModeModule = guiLibrary.Windows.Movement:createModule({
    ["Name"] = "JesusMode",
    ["Function"] = function(state)
        JesusModeVar = state
        local p = waterpart()
        if p then
            if state then
                p.Size = Vector3.new(100000, 1.2, 100000)
                p.CanCollide = true
                p.Anchored = true
            else
                p.Size = Vector3.new(15, 1.2, 15.2)
                p.CanCollide = false
            end
        end
    end
})

RunService.Heartbeat:Connect(function()
    if not JesusModeVar then return end
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local p = waterpart()
    
    if root and p then
        if root.Position.Y < (p.Position.Y - 0.5) then
            if TPAuraVar then
                TPAuraVar = false
                TPAuraModule:toggle(false)
            end
            
            if TargetStrafeVar then
                TargetStrafeVar = false
                TargetStrafeModule:toggle(false)
            end
            root.Velocity = Vector3.zero
            root.CFrame = CFrame.new(root.Position.X, p.Position.Y + 5, root.Position.Z)
            if tick() - LastNotify > 5 then
                modules.Notifications:Notify("JesusMode", "Targeting DISABLED to prevent dying!", 5)
                LastNotify = tick()
            end
        end
    end
end)

--[[ ClanInviter ]]
local ClanInviterVar = false
local ClanInviterModule = guiLibrary.Windows.Utility:createModule({
    ["Name"] = "ClanInviter",
    ["Description"] = "(you must own a clan)",
    ["Function"] = function(state)
        ClanInviterVar = state
        if state then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    pcall(function()
                        remotes.InviteRemote:InvokeServer(player.UserId)
                    end)
                end
            end

            Players.PlayerAdded:Connect(function(player)
                if ClanInviterVar and player ~= LocalPlayer then
                    pcall(function()
                        remotes.InviteRemote:InvokeServer(player.UserId)
                    end)
                end
            end)
        end
    end
})

--[[ InstaKill ]]
local killConnect

local function getTarget()
    local target = nil
    local lastDist = 20
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if not root then return nil end

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local pRoot = v.Character.HumanoidRootPart
            local dist = (pRoot.Position - root.Position).Magnitude
            
            if dist < lastDist then
                lastDist = dist
                target = v.Character
            end
        end
    end
    return target
end

local InstaKillModule = guiLibrary.Windows.Exploit:createModule({
    ["Name"] = "InstaKill",
    ["Description"] = "instakill exploit from haze private leaked",
    ["Function"] = function(callback)
        if callback then
            killConnect = RunService.Heartbeat:Connect(function()
                local enemy = getTarget()
                if enemy then
                    remotes.ApplyDamage:InvokeServer(enemy)
                end
            end)
        else
            if killConnect then
                killConnect:Disconnect()
                killConnect = nil
            end
        end
    end
})