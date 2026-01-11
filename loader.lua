local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer

local CONFIG = {
    ROOT = "Haze",
    DATA = "Haze/data",
    BASE_URL = "https://raw.githubusercontent.com/7Smoker/Haze/main/",
    API_URL = "https://api.github.com/repos/7Smoker/Haze/contents/",
    FOLDERS = { "assets", "games", "libraries"},
    NOTIFICATIONS = 5
}

local Notifications = loadstring(
    game:HttpGet("https://raw.githubusercontent.com/7Smoker/Haze/refs/heads/main/libraries/Notifications.lua")
)()

do
    local exec = identifyexecutor and identifyexecutor()
    if exec then
        local name = string.lower(exec)
        if name:find('xeno') or name:find('solara') then
                Notifications:Notify('Warning', exec .. " is a shitty unsupported executor", 15)
                Notifications:Notify('Warning', "Get a good quality executor. Free Executors good quality: Velocity, Bunni.lol", 15)
            return
        end
    end

    local ok = false
    if getrawmetatable then
        ok = pcall(function()
            getrawmetatable(game)
        end)
    end

    if not ok then
            Notifications:Notify('Warning', 'Your executor is shit, does not support getrawmetatable', 15)
            Notifications:Notify('Warning', 'getrawmetatable is necessary to spoof most of speed detections', 15)
        return
    end
end

local HTTP = {}
function HTTP:Get(url)
    local ok, res = pcall(game.HttpGet, game, url)
    return ok and res or nil
end

local File = {}
function File:EnsureFolder(path)
    if not isfolder(path) then makefolder(path) end
end
function File:Write(path, content)
    writefile(path, content)
end
function File:IsFile(path)
    return isfile(path)
end
function File:IsFolder(path)
    return isfolder(path)
end

local Loader = {}
function Loader:DownloadFolder(remote, localPath)
    File:EnsureFolder(localPath)
    local raw = HTTP:Get(CONFIG.API_URL .. remote)
    if not raw then
        Notifications:Notify('Warning', 'Failed to fetch folder: ' .. remote, CONFIG.NOTIFICATIONS)
        return
    end

    local ok, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
    if not ok or type(decoded) ~= "table" then return end

    for _, item in ipairs(decoded) do
        local path = localPath .. "/" .. item.name
        if item.type == "file" then
            if not File:IsFile(path) then
                local content = HTTP:Get(item.download_url)
                if content then
                    File:Write(path, content)
                    Notifications:Notify('Success', 'Installed file: ' .. item.name, CONFIG.NOTIFICATIONS)
                else
                    Notifications:Notify('Warning', 'Failed File: ' .. item.name, CONFIG.NOTIFICATIONS)
                end
            end
        elseif item.type == "dir" then
            self:DownloadFolder(remote .. "/" .. item.name, path)
        end
    end
end

function Loader:RunScript(url, silent)
    local src = HTTP:Get(url)
    if not src then return false end

    local fn, err = loadstring(src)
    if not fn then return false end

    pcall(fn)
    if not silent then
        Notifications:Notify('Info', 'Running script: ' .. url:match("[^/]+$"), CONFIG.NOTIFICATIONS)
    end
    return true
end

File:EnsureFolder(CONFIG.ROOT)
File:EnsureFolder(CONFIG.DATA)
for _, folder in ipairs(CONFIG.FOLDERS) do
    Loader:DownloadFolder(folder, CONFIG.ROOT .. "/" .. folder)
end

local loaderPath = CONFIG.ROOT .. "/loader.lua"
if not File:IsFile(loaderPath) then
    local loaderContent = HTTP:Get(CONFIG.BASE_URL .. "loader.lua")
    if loaderContent then
        File:Write(loaderPath, loaderContent)
        Notifications:Notify('Success', 'Loader has been installed', CONFIG.NOTIFICATIONS)
    else
        Notifications:Notify('Warning', 'Failed to install loader.lua', CONFIG.NOTIFICATIONS)
    end
end

local PlaceId = tostring(game.PlaceId)
local apiUrl = CONFIG.API_URL .. "games/" .. PlaceId .. ".lua"
local rawUrl = CONFIG.BASE_URL .. "games/" .. PlaceId .. ".lua"

local exists = false
local apiResponse = HTTP:Get(apiUrl)

if apiResponse then
    local ok, decoded = pcall(HttpService.JSONDecode, HttpService, apiResponse)
    if ok and type(decoded) == "table" and decoded.type == "file" then
        exists = true
    end
end

if exists then
    Loader:RunScript(rawUrl)
else
    Loader:RunScript(CONFIG.BASE_URL .. "games/Universal.lua")
end

Loader:RunScript(CONFIG.BASE_URL .. "UILibrary/Whitelist.lua", true)