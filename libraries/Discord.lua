local Discord = {}

local HttpService = game:GetService("HttpService")
local Notifications = loadfile("Haze/libraries/Notifications.lua")()
local http_request = (syn and syn.request) or (http and http.request) or request
local HazeFolder = "Haze"
local filePath = HazeFolder .. "/Invited.txt"

local function AlreadySent(path)
    local f = io.open(path, "r")
    if f then
        f:close()
        return true
    else
        return false
    end
end

local function createFile(path, content)
    local f = io.open(path, "w")
    if f then
        f:write(content or "")
        f:close()
    end
end

local function getInviteCode(url)
    return url:match("discord%.gg/([%w-]+)") or url:match("discord%.com/invite/([%w-]+)")
end

function Discord:Join(inviteUrl, silent)
    if AlreadySent(filePath) then
        if not silent then
            Notifications:Notify("Success", "Thanks for joining our discord server!", 8)
        end
        return false
    end

    local inviteCode = getInviteCode(inviteUrl)
    if not inviteCode then
        if not silent then
            Notifications:Notify("Error","Discord invite has expired! Report this to the devs, ScriptIsFocus",3)
        end
        return false
    end

    if not http_request then
        if not silent then
            Notifications:Notify("Warning","Executor doesnt support http_request!",3)
        end
        return false
    end

    local success = pcall(function()
        http_request({
            Url = "http://127.0.0.1:6463/rpc?v=1",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Origin"] = "https://discord.com"
            },
            Body = HttpService:JSONEncode({
                cmd = "INVITE_BROWSER",
                args = { code = inviteCode },
                nonce = HttpService:GenerateGUID(false)
            })
        })
    end)

    if success then
        if not AlreadySent(HazeFolder) then
            os.execute("mkdir " .. HazeFolder)
        end
        createFile(filePath, "Joined Haze Discord Invite. https://discord.gg/W92SXVmB5X")
    end

    if not silent then
        if success then
            Notifications:Notify("Success","Make sure to join our discord server!",3)
        else
            Notifications:Notify("Error","Discord RPC failed, open manually",3)
        end
    end
    return success
end

function Discord:Copy(inviteUrl)
    if setclipboard then
        setclipboard(inviteUrl)
        return true
    end
    return false
end

return Discord