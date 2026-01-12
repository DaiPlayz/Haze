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

    if source:sub(1,3) == "\239\187\191" then
        source = source:sub(4)
    end

    if source:sub(1,5) == "<!DOC" then
            Notifications:Notify("Error", "Invalid file received: " .. path, 10)
        return
    end

    local fn, err = loadstring(source)
    if not fn then
            Notifications:Notify("Error", "Failed to compile script! Report this to the devs!", 10)
        return
    end

    local ok, runtimeErr = pcall(fn)
    if not ok then
        Notifications:Notify("Error", "Runtime error occurred! Report to devs!", 10)
    end
end

do
    local executor = identifyexecutor and identifyexecutor()
    if executor then
        local name = executor:lower()
        if name:find("xeno") or name:find("solara") then
                Notifications:Notify("Warning", executor .. " is unsupported", 15)
                Notifications:Notify("Warning", "Use a good executor: Velocity, Bunni.lol", 15)
            return
        end
    end

    if not getrawmetatable or not pcall(getrawmetatable, game) then
            Notifications:Notify("Warning", "Executor missing getrawmetatable", 15)
        return
    end
end

local MarketplaceService = game:GetService("MarketplaceService")

local function getgamename()
    local success, info = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId).Name
    end)
    if success and info then
        return info
    else
        return "this game apparently have no name"
    end
end

local placeId = tostring(game.PlaceId)
local gamedetect = GAMES .. "/" .. placeId .. ".lua"
local universaldetect = GAMES .. "/Universal.lua"

local gamename = getgamename()

if isfile(gamedetect) then
    Notifications:Notify("Info", "Loading script for: " .. gamename, 5)
    safeload(gamedetect)
elseif isfile(universaldetect) then
    Notifications:Notify("Info", "Loading universal: " .. gamename, 5)
    safeload(universaldetect)
else
    Notifications:Notify("Error", "No compatible game script found for: " .. gamename, 10)
    return
end

local whitelist = ROOT .. "/UILibrary/Whitelist.lua"
if isfile(whitelist) then
    safeload(whitelist)
end