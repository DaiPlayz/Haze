--[[ SkyBridge Duels Lobby ]]
local guiLibrary = loadfile("Haze/uis/HazeLibrary.lua")()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

--[[ Libraries ]]
local LocalLibrary = "Haze/libraries"
local modules = {
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

--[[ Spam Invites ]]
local InviteSpamVar = false
local InvitesModule = guiLibrary.Windows.Utility:createModule({
    ["Name"] = "Spam Invites",
    ["Function"] = function(state)
        InviteSpamVar = state

        task.spawn(function()
            while InviteSpamVar do
                modules.PartyController:InviteAll()
                task.wait(.1)
            end
        end)
    end
})

--[[ Party Kick ]]
local KickSpamVar = false
local KicksModule = guiLibrary.Windows.Utility:createModule({
    ["Name"] = "Spam Kicks",
    ["Function"] = function(state)
        KickSpamVar = state

        task.spawn(function()
            while KickSpamVar do
                modules.PartyController:KickAll()
                wait(.1)
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
