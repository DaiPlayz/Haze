local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local uncfunctions = {"identifyexecutor","hookmetamethod","checkcaller"}

local ROOT = "Haze"
local GAMES = ROOT .. "/games"

local Notifications = loadfile(ROOT .. "/libraries/Notifications.lua")()

local function safeload(path)
    if not isfile(path) then 
        Notifications:Notify("Error", "File missing: " .. path, 5, Color3.fromRGB(255, 0, 0))
        return 
    end
    local source = readfile(path)
    if not source or source == "" then 
        Notifications:Notify("Error", "File empty: " .. path, 5, Color3.fromRGB(255, 0, 0))
        return 
    end
    if source:sub(1, 3) == "\239\187\191" then source = source:sub(4) end
    
    local fn, err = loadstring(source)
    if not fn then 
        Notifications:Notify("Error", "Failed to compile: " .. path, 5, Color3.fromRGB(255, 0, 0))
        warn(err)
        return 
    end
    
    local ok, runtimeErr = pcall(fn)
    if not ok then 
        Notifications:Notify("Error", "Runtime error in script!", 5, Color3.fromRGB(255, 0, 0))
        warn(runtimeErr)
    end
end

do
    local executor = identifyexecutor and identifyexecutor()
    if executor then
        local name = executor:lower()
        if name:find("xeno") or name:find("solara") then
            Notifications:Notify("Cooked", executor .. " unsupported", 15, Color3.fromRGB(191, 92, 105))
            return
        end
    end
    for i,v in uncfunctions do
        if not getgenv()[v] then
            Notifications:Notify("Cooked", `Executor missing {v}`, 15, Color3.fromRGB(191,92,105))
        end
    end
end

local placeId = tostring(game.PlaceId)
local gamedetect = GAMES .. "/" .. placeId .. ".lua"
local universaldetect = GAMES .. "/Universal.lua"

local function getGameName()
    local success, info = pcall(function() 
        return MarketplaceService:GetProductInfo(game.PlaceId).Name 
    end)
    return (success and info) and info or "Unknown Game"
end

local displayName = getGameName()

if isfile(gamedetect) then
    Notifications:Notify("Loading", "Loading script for: " .. displayName, 5)
    safeload(gamedetect)
elseif isfile(universaldetect) then
    Notifications:Notify("Loading", "Loading universal for: " .. displayName, 5)
    safeload(universaldetect)
else
    Notifications:Notify("Error", "No compatible script found for: " .. displayName, 10, Color3.fromRGB(255, 0, 0))
end

local whitelist = ROOT .. "/libraries/Whitelist.lua"
if isfile(whitelist) then safeload(whitelist) end
