local HttpService = game:GetService("HttpService")

local CONFIG = {
    ROOT = "Haze",
    BASE_URL = "https://raw.githubusercontent.com/7Smoker/Haze/main/",
    API_URL  = "https://api.github.com/repos/7Smoker/Haze/contents/",

    INSTALL_FOLDERS = {
        "assets",
        "games",
        "libraries"
    },

    INSTALL_FILES = {
        "loader.lua"
    }
}

local Notifications = loadstring(
    game:HttpGet("https://raw.githubusercontent.com/7Smoker/Haze/main/libraries/Notifications.lua")
)()

local function httpGet(url)
    local ok, res = pcall(game.HttpGet, game, url)
    return ok and res or nil
end

local function ensureFolder(path)
    if not isfolder(path) then
        makefolder(path)
    end
end

local function read(path)
    return isfile(path) and readfile(path) or nil
end

local function write(path, content)
    writefile(path, content)
end

local function syncFile(localPath, content)
    local existing = read(localPath)

    if not existing then
        write(localPath, content)
        Notifications:Notify("Success", "Installed: " .. localPath, 4)
        return
    end

    if existing ~= content then
        write(localPath, content)
        Notifications:Notify("Success", "Updated: " .. localPath, 4)
    end
end

local function syncFolder(remotePath, localPath)
    ensureFolder(localPath)

    local raw = httpGet(CONFIG.API_URL .. remotePath)
    if not raw then return end

    local decoded = HttpService:JSONDecode(raw)
    for _, item in ipairs(decoded) do
        local localItemPath = localPath .. "/" .. item.name

        if item.type == "file" then
            local content = httpGet(item.download_url)
            if content then
                syncFile(localItemPath, content)
            end
        elseif item.type == "dir" then
            syncFolder(remotePath .. "/" .. item.name, localItemPath)
        end
    end
end

ensureFolder(CONFIG.ROOT)

for _, folder in ipairs(CONFIG.INSTALL_FOLDERS) do
    syncFolder(folder, CONFIG.ROOT .. "/" .. folder)
end

for _, file in ipairs(CONFIG.INSTALL_FILES) do
    local content = httpGet(CONFIG.BASE_URL .. file)
    if content then
        syncFile(CONFIG.ROOT .. "/" .. file, content)
    end
end

local loaderPath = CONFIG.ROOT .. "/loader.lua"
local loaderFn = loadfile(loaderPath)
if loaderFn then
    pcall(loaderFn)
else
    Notifications:Notify("Warning", "Failed to load loader.lua", 5)
end