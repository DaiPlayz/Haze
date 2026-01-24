local FlyController = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

FlyController.Enabled = false
FlyController.Vertical = true
FlyController.Speed = 50

local Connection

function FlyController:Start()
    if self.Enabled then return end
    self.Enabled = true

    Connection = RunService.Heartbeat:Connect(function(deltaTime)
        local Character = LocalPlayer.Character
        if not Character then return end

        local Root = Character:FindFirstChild("HumanoidRootPart")
        if not Root then return end

        local Velocity = Root.AssemblyLinearVelocity
        local ExpY = 0.8 + deltaTime

        if self.Vertical then
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                ExpY += self.Speed
            elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                ExpY -= self.Speed
            end
        end

        Root.AssemblyLinearVelocity = Vector3.new(
            Velocity.X,
            ExpY,
            Velocity.Z
        )
    end)
end

function FlyController:Stop()
    self.Enabled = false

    if Connection then
        Connection:Disconnect()
        Connection = nil
    end
end

function FlyController:Toggle(state)
    if state then
        self:Start()
    else
        self:Stop()
    end
end

function FlyController:SetVertical(state)
    self.Vertical = state
end

function FlyController:SetSpeed(newSpeed)
    assert(type(newSpeed) == "number" and newSpeed > 0, "must be positive number")
    self.Speed = newSpeed
end

return FlyController