local AutoPlaceController = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AutoPlaceRemote = ReplicatedStorage:WaitForChild("events"):WaitForChild("placeYoutuber")
local YoutubersFolder = ReplicatedStorage:WaitForChild("youtubers")

local availableYoutubers = {}
for _, v in ipairs(YoutubersFolder:GetChildren()) do
    availableYoutubers[v.Name] = v
end

local AutoPlaceVar = false
local AutoPlaceTarget = "LocalPlayer"

local function InsidePattern(basePos, model)
    local y = basePos.Y + ((model:FindFirstChild("Size") and model.Size.Y) or 5) / 2
    return Vector3.new(basePos.X, y, basePos.Z)
end

local function AutoPlaceLoop()
    task.spawn(function()
        while AutoPlaceVar do
            local basePositions = {}
            if AutoPlaceTarget == "LocalPlayer" then
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then table.insert(basePositions, hrp.Position) end
            else
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer then
                        local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then table.insert(basePositions, hrp.Position) end
                    end
                end
            end

            for _, basePos in ipairs(basePositions) do
                for name, model in pairs(availableYoutubers) do
                    local pos = InsidePattern(basePos, model)
                    local cframe = CFrame.new(pos) * CFrame.Angles(0, math.rad(-90), 0)
                    pcall(function()
                        AutoPlaceRemote:FireServer(name, cframe, -90, "0")
                    end)
                    task.wait()
                end
            end
            task.wait()
        end
    end)
end

function AutoPlaceController:SetTarget(target)
    AutoPlaceTarget = target
end

function AutoPlaceController:Start()
    AutoPlaceVar = true
    AutoPlaceLoop()
end

function AutoPlaceController:Stop()
    AutoPlaceVar = false
end

return AutoPlaceController