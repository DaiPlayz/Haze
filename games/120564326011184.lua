--[[ Be a YouTuber! ]]
local guiLibrary = loadfile("Haze/uis/MoonLibrary.lua")()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Character = LocalPlayer.Character

--[[ Libraries ]]
local LocalLibrary = "Haze/libraries"
local modules = {
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

--[[ AutoPlace ]]
local AutoPlaceModule = guiLibrary.Windows.Combat:createModule({
    ["Name"] = "AutoPlace",
    ["Function"] = function(state)
        if state then
            modules.PlaceController:Start()
        else
            modules.PlaceController:Stop()
        end
    end
})

local AutoPlacePosSelector = AutoPlaceModule.selectors.new({
    ["Name"] = "Position",
    ["Default"] = "LocalPlayer",
    ["Selections"] = {"LocalPlayer", "Players"},
    ["Function"] = function(value)
        modules.PlaceController:SetTarget(value)
    end
})

--[[ AutoClaim ]]
local AutoClaimVar = false
local AutoClaimModule = guiLibrary.Windows.Utility:createModule({
    ["Name"] = "AutoClaim",
    ["Function"] = function(state)
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
local AutoUploadModule = guiLibrary.Windows.Utility:createModule({
    ["Name"] = "Auto Upload",
    ["Function"] = function(state)
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

--[[ AutoPickUp Everything ]]
local AutoPickUpVar = false
local AutoPickUpModule = guiLibrary.Windows.Utility:createModule({
    ["Name"] = "AutoPickUp",
    ["Function"] = function(state)
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
local AutoCollectModule = guiLibrary.Windows.Utility:createModule({
    ["Name"] = "AutoCollect",
    ["Function"] = function(state)
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