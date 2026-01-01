local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer

local CONFIG = {
    ROOT = "Haze",
    DATA = "Haze/data",
    BASE_URL = "https://raw.githubusercontent.com/7Smoker/Haze/main/",
    API_URL = "https://api.github.com/repos/7Smoker/Haze/contents/",
    FOLDERS = { "assets", "data", "games", "libraries"},
    NOTIFICATIONS = 5
}

local Notifications = loadstring(game:HttpGet("https://raw.githubusercontent.com/7Smoker/Haze/refs/heads/main/libraries/Notifications.lua"))()

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
    Notifications:Notify('Info', 'Installing folder: ' .. remote, CONFIG.NOTIFICATIONS)
    local raw = HTTP:Get(CONFIG.API_URL .. remote)
    if not raw then return Notifications:Notify('Warn', 'Failed to fetch folder: ' .. remote, CONFIG.NOTIFICATIONS) end

    for _, item in ipairs(HttpService:JSONDecode(raw)) do
        local path = localPath .. "/" .. item.name
        if item.type == "file" then
            if not File:IsFile(path) then
                local content = HTTP:Get(item.download_url)
                if content then
                    File:Write(path, content)
                    Notifications:Notify('Success', 'Installed file: ' ..item.name, CONFIG.NOTIFICATIONS)
                else
                    Notifications:Notify('Warn', 'Failed File: ' ..item.name, CONFIG.NOTIFICATIONS)
                end
            end
        elseif item.type == "dir" then
            self:DownloadFolder(remote .. "/" .. item.name, path)
        end
    end
end

function Loader:RunScript(url)
    Notifications:Notify('Info', 'Running script: ' .. url:match("[^/]+$"), CONFIG.NOTIFICATIONS)
    local src = HTTP:Get(url)
    if src then
        local fn, err = loadstring(src)
        if fn then
            pcall(fn)
            return true
        else
            Notifications:Notify('Warn', 'Loadstring error: ' .. err, CONFIG.NOTIFICATIONS)
        end
    else
        Notifications:Notify('Warn', 'Failed to fetch script: ' .. url, CONFIG.NOTIFICATIONS)
    end
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
        Notifications:Notify('Warn', 'Failed to install loader.lua', CONFIG.NOTIFICATIONS)
    end
end

local PlaceId = tostring(game.PlaceId)
if not Loader:RunScript(CONFIG.BASE_URL .. "games/" .. PlaceId .. ".lua") then
    Loader:RunScript(CONFIG.BASE_URL .. "games/Universal.lua")
end

Loader:RunScript(CONFIG.BASE_URL .. "UILibrary/Whitelist.lua")