local ScaffoldController = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlaceRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ItemsRemotes"):WaitForChild("PlaceBlock")

local IsEnabled = false
local Connection = nil

local TeamColors = {
    "Red",
    "Orange",
    "Yellow",
    "Green",
    "Blue",
    "Purple",
    "Pink",
    "Brown"
}

local function DetectBlock()
    local blocks = {}
    for _, color in ipairs(TeamColors) do
        table.insert(blocks, color .. " Wool")
    end
    table.insert(blocks, "Fake Block")
    return blocks[math.random(#blocks)]
end

local function ScaffoldPos()
    local char = Players.LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")

    if hrp and hum and hum.MoveDirection.Magnitude > 0 then
        local targetPos = hrp.Position + (hum.MoveDirection * 7)

        return Vector3.new(
            math.floor(targetPos.X),
            math.floor(hrp.Position.Y - 3.5),
            math.floor(targetPos.Z)
        )
    end
    return nil
end

function ScaffoldController:SetState(state)
    IsEnabled = state

    if not state then
        if Connection then
            Connection:Disconnect()
            Connection = nil
        end
        return
    end

    if Connection then return end

    Connection = RunService.PostSimulation:Connect(function()
        if not IsEnabled then return end

        local pos = ScaffoldPos()
        if not pos then return end

        local blockName = DetectBlock()
        PlaceRemote:FireServer(
            blockName,
            1,
            vector.create(pos.X, pos.Y, pos.Z)
        )
    end)
end

return ScaffoldController