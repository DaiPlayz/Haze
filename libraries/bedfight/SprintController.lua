local SprintController = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local StarterPlayer = game:GetService("StarterPlayer")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Modules = ReplicatedStorage:WaitForChild("Modules")
local ButtonProperties = require(Modules:WaitForChild("ButtonProperties"))

local TWEEN_INFO = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

local SprintObj = ButtonProperties.new("Sprint")
local IsEnabled = false
local RenderSteppedConn = nil

local function GetBaseFOV()
    local settings = Player:FindFirstChild("Settings")
    local fovVal = settings and settings:FindFirstChild("FOV")
    return fovVal and fovVal.Value or 70
end

local function UpdateSprint(active, humanoid)
    if not humanoid then return end
    
    local baseFOV = GetBaseFOV()
    local targetFOV = active and (baseFOV + 15) or baseFOV
    local DefSpeed = humanoid:GetAttribute("DefaultSpeed") or StarterPlayer.CharacterWalkSpeed
    
    TweenService:Create(Camera, TWEEN_INFO, {FieldOfView = targetFOV}):Play()

    if active then
        SprintObj:Set(true)
        if not humanoid:GetAttribute("SpeedLock") then
            humanoid.WalkSpeed = DefSpeed + 4
        end
    else
        SprintObj:Set(false)
        if not humanoid:GetAttribute("SpeedLock") then
            humanoid.WalkSpeed = DefSpeed
        end
    end
end

function SprintController:SetState(state)
    IsEnabled = state
    
    if not state then
        if RenderSteppedConn then RenderSteppedConn:Disconnect() RenderSteppedConn = nil end
        local char = Player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        UpdateSprint(false, hum)
        return
    end

    if RenderSteppedConn then return end

    RenderSteppedConn = RunService.RenderStepped:Connect(function()
        local char = Player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if hum then
            local isMoving = hum.MoveDirection.Magnitude > 0
            if isMoving and SprintObj.Active.Value == false then
                UpdateSprint(true, hum)
            elseif not isMoving and SprintObj.Active.Value == true then
                UpdateSprint(false, hum)
            end
            
            if IsEnabled and isMoving and hum:GetAttribute("SpeedLock") then
                hum:SetAttribute("SpeedLock", false)
                hum.WalkSpeed = (hum:GetAttribute("DefaultSpeed") or StarterPlayer.CharacterWalkSpeed) + 4
            end
        end
    end)
end

return SprintController