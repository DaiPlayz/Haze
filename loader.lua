local ROOT = "Haze"
local GAMES = ROOT .. "/games"

local Notifications = loadfile(ROOT .. "/libraries/Notifications.lua")()

do
    local executor = identifyexecutor and identifyexecutor()
    if executor then
        executor = executor:lower()
        if executor:find('xeno') or executor:find('solara') then
                Notifications:Notify('Warning', executor .. " is a shitty unsupported executor", 15)
                Notifications:Notify('Warning', "Get a good quality executor. Free Executors good quality: Velocity, Bunni.lol", 15)
            return
        end
    end

    if not getrawmetatable or not pcall(getrawmetatable, game) then
            Notifications:Notify('Warning', 'Your executor is shit, does not support getrawmetatable', 15)
            Notifications:Notify('Warning', 'getrawmetatable is necessary to spoof most of speed detections', 15)
        return
    end
end

local PlaceID = tostring(game.PlaceId)
local Gamescript = GAMES .. "/" .. PlaceID .. ".lua"
local Universalscript = GAMES .. "/Universal.lua"

if isfile(Gamescript) then
    Notifications:Notify("Info", "Loading game script", 5)
    loadfile(Gamescript)()

elseif isfile(Universalscript) then
    Notifications:Notify("Info", "Loading universal script", 5)
    loadfile(Universalscript)()

else
    Notifications:Notify("Error", "No compatible game script found", 10)
    return
end

local whitelistpath = ROOT .. "/UILibrary/Whitelist.lua"
if isfile(whitelistpath) then
    loadfile(whitelistpath)()
end