--[[ SkyBridge Duels Lobby ]]
local guiLibrary = loadfile("Haze/uis/MoonLibrary.lua")()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local WCam = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

--[[ Libraries ]]
local LocalLibrary = "Haze/libraries"
local modules = {
    Discord = loadfile(LocalLibrary .. "/Discord.lua")(),
    Whitelist = loadfile(LocalLibrary .. "/Whitelist.lua")(),
    PartyController = loadfile(LocalLibrary .. "/skybridge/PartyController.lua")()
}

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
    ["Maximum"] = 50,
    ["Default"] = 16,
    ["Function"] = function(value)
        SpeedValue = value
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

--[[ Spam Invites ]]
local InvitesModule = guiLibrary.Windows.Utility:createModule({
    ["Name"] = "Spam Invites",
    ["Function"] = function(state)
        spawn(function()
            while state do
                modules.PartyController:InviteAll()
                wait(0.01)
            end
        end)
    end
})

--[[ Party Kick ]]
local KicksModule = guiLibrary.Windows.Utility:createModule({
    ["Name"] = "Spam Kicks",
    ["Function"] = function(state)
        spawn(function()
            while state do
                modules.PartyController:KickAll()
                wait(0.01)
            end
        end)
    end
})

--[[ FakeWS ]]
local FakeWSVar = false
local FakeWSVal = 0
local oldWS = 0

local FakeWSModule = guiLibrary.Windows.Visuals:createModule({
    ["Name"] = "Fake Winstreak",
    ["Function"] = function(state)
        FakeWSVar = state
        if state then
            oldWS = LocalPlayer:GetAttribute("Streak") or 0
            LocalPlayer:SetAttribute("Streak", FakeWSVal)
        else
            LocalPlayer:SetAttribute("Streak", oldWS)
        end
    end,
    ["ExtraText"] = function()
        return tostring(FakeWSVal)
    end
})
local WinstreakValue = FakeWSModule.sliders.new({
    ["Name"] = "Winstreaks",
    ["Minimum"] = 0,
    ["Maximum"] = 1000,
    ["Default"] = 1000,
    ["Function"] = function(value)
        FakeWSVal = value
        if FakeWSVar then
            LocalPlayer:SetAttribute("Streak", value)
        end
    end
})

--[[ Device Spoofer ]]
local DeviceVar = false
local currentDevice = "PC"

local DeviceSpoofModule = guiLibrary.Windows.Visuals:createModule({
    ["Name"] = "Device Spoofer",
    ["Function"] = function(state)
        DeviceVar = state

        if DeviceVar then
            LocalPlayer:SetAttribute("Platform", currentDevice)
        else
            LocalPlayer:SetAttribute("Platform", nil)
        end
    end
})

DeviceSpoofModule.selectors.new({
    ["Name"] = "Devices",
    ["Default"] = "PC",
    ["Selections"] = {"PC", "Mobile", "Console"},
    ["Function"] = function(value)
        currentDevice = value

        if DeviceVar then
            LocalPlayer:SetAttribute("Platform", value)
        end
    end
})
