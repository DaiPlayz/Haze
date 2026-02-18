--[[ Skybridge Duels Game ]]
local guiLibrary = loadfile("Haze/uis/HazeLibrary.lua")()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--[[ Libraries ]]
local LocalLibrary = "Haze/libraries"
local modules = {
    SwordController = loadfile(LocalLibrary .. "/skybridge/SwordController.lua")(),
    BowController = loadfile(LocalLibrary .. "/skybridge/BowController.lua")()
}

--[[ Speed ]]
local SpeedVar = false
local SpeedValue = 16

local oldindex;oldindex = hookfunction(getrawmetatable(game).__index,newcclosure(function(self, b)
    if b == "JumpPower" then return 50 end
    if b == "WalkSpeed" then return 16 end
    return oldindex(self, b)
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
    ["Maximum"] = 50,
    ["Default"] = 16,
    ["Function"] = function(value)
        SpeedValue = value
    end
})

--[[ AutoWin ]]--
local Teams = {"Red", "Blue"}

local AutoWinVar = false

local AutoWinModule = guiLibrary.Windows.Combat:createModule({
    ["Name"] = "AutoWin",
    ["Function"] = function(state)
        AutoWinVar = state
        if state then
            if workspace:FindFirstChild("Blocks") then
                workspace.Blocks:Destroy()
            end

            local tpIndex = 1
            task.spawn(function()
                while AutoWinVar do
                    local character = LocalPlayer.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        local currentTeam = Teams[tpIndex]
                        local teamFolder = workspace.WORLDPARTS.Teams:FindFirstChild(currentTeam)
                        local GoalHitbox = teamFolder and teamFolder:FindFirstChild("GoalHitbox")

                        if GoalHitbox then
                            character.HumanoidRootPart.CFrame = GoalHitbox.CFrame + Vector3.new(0,5,0)
                        end

                        tpIndex = tpIndex % #Teams + 1
                    end
                    wait(.5)
                end
            end)
        end
    end
})

--[[ Killaura ]]
local KAVar = false
local KAConnection = nil

local function runKA()
    if KAConnection then KAConnection:Disconnect() end

    KAConnection = RunService.Heartbeat:Connect(function()
        if not KAVar then
            if KAConnection then
                KAConnection:Disconnect()
                KAConnection = nil
            end
            return
        end

        local target = modules.SwordController.GetNearestPlayer()
        if target then
            modules.SwordController.Attack(target)
        end
    end)
end

local KillAuraModule = guiLibrary.Windows.Combat:createModule({
    ["Name"] = "KillAura",
    ["Description"] = "Automatically attacks players around you",
    ["Function"] = function(state)
        KAVar = state
        if state then
            runKA()
        else
            if KAConnection then
                KAConnection:Disconnect()
                KAConnection = nil
            end
        end
    end
})

--[[ Crasher ]]
local CrasherVar = false
local CrashConnection = nil

local function runCrasher()
    if CrashConnection then CrashConnection:Disconnect() end

    CrashConnection = RunService.Heartbeat:Connect(function()
        if not CrasherVar then
            if CrashConnection then
                CrashConnection:Disconnect()
                CrashConnection = nil
            end
            return
        end

        local target = modules.BowController.GetNearestPlayer()
        if target then
            modules.BowController.Shoot(target)
        end
    end)
end

local CrasherModule = guiLibrary.Windows.Exploit:createModule({
    ["Name"] = "Crasher",
    ["Function"] = function(state)
        CrasherVar = state
        if state then
            runCrasher()
        else
            if CrashConnection then
                CrashConnection:Disconnect()
                CrashConnection = nil
            end
        end
    end
})

--[[ AutoLobby ]]
local endMatch = PlayerGui:WaitForChild("MatchEnd"):WaitForChild("Canvas")

local AutoLobbyConnect

local AutoLobbyModule = guiLibrary.Windows.Utility:createModule({
    ["Name"] = "AutoLobby",
    ["Function"] = function(state)
        if state then
            AutoLobbyConnect = endMatch:GetPropertyChangedSignal("Visible"):Connect(function()
                if endMatch.Visible then
                    ReplicatedStorage.Network.Request_ReturnToLobby:FireServer()
                end
            end)

            if endMatch.Visible then
                ReplicatedStorage.Network.Request_ReturnToLobby:FireServer()
            end
        else
            if AutoLobbyConnect then
                AutoLobbyConnect:Disconnect()
                AutoLobbyConnect = nil
            end
        end
    end
})