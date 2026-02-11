local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local ROOT = "Haze"
local GAMES = ROOT .. "/games"

local Notifications = loadfile(ROOT .. "/libraries/Notifications.lua")()

local function safeload(path)
    if not isfile(path) then 
        Notifications:Notify("Error", "File missing: " .. path, 10) 
        return 
    end
    local source = readfile(path)
    if not source or source == "" then 
        Notifications:Notify("Error", "File empty: " .. path, 10) 
        return 
    end
    if source:sub(1, 3) == "\239\187\191" then source = source:sub(4) end
    
    local fn, err = loadstring(source)
    if not fn then 
        Notifications:Notify("Error", "Failed to compile: " .. path, 10) 
        warn(err)
        return 
    end
    
    local ok, runtimeErr = pcall(fn)
    if not ok then 
        Notifications:Notify("Error", "Runtime error in script!", 10)
        warn(runtimeErr)
    end
end

do
    local executor = identifyexecutor and identifyexecutor()
    if executor then
        local name = executor:lower()
        if name:find("xeno") or name:find("solara") then
            Notifications:Notify("Warning", executor .. " unsupported", 15)
            return
        end
    end
    if not getrawmetatable or not pcall(getrawmetatable, game) then
        Notifications:Notify("Warning", "Executor missing getrawmetatable", 15)
        return
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
    Notifications:Notify("Info", "Loading script for: " .. displayName, 5)
    safeload(gamedetect)
elseif isfile(universaldetect) then
    Notifications:Notify("Info", "Loading universal for: " .. displayName, 5)
    safeload(universaldetect)
else
    Notifications:Notify("Error", "No compatible script found for: " .. displayName, 10)
end

local whitelist = ROOT .. "/libraries/Whitelist.lua"
if isfile(whitelist) then safeload(whitelist) end