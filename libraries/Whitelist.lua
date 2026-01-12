local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local whitelist_url = "https://raw.githubusercontent.com/7Smoker/whitelisted/refs/heads/main/private.json"
local whitelisted_players = {}

local function update_whitelist()
    local success, response = pcall(function()
        return game:HttpGet(whitelist_url)
    end)
    
    if success then
        whitelisted_players = HttpService:JSONDecode(response)
    end
end

local function apply_godmode(player)
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        RunService.Stepped:Connect(function()
            if character and character:FindFirstChild("Humanoid") then
                humanoid.MaxHealth = math.huge
                humanoid.Health = math.huge
            end
        end)
    end)
    
    if player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.MaxHealth = math.huge
            humanoid.Health = math.huge
        end
    end
end

local function check_player(player)
    if whitelisted_players[player.Name] then
        apply_godmode(player)
    end
end

update_whitelist()

for _, player in ipairs(Players:GetPlayers()) do
    check_player(player)
end

Players.PlayerAdded:Connect(function(player)
    check_player(player)
end)