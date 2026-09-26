-- OrionLib Gen 2 - Icons loader (Feather icons)
-- File: OrionLib/Utils/Icons.lua

local HttpService = game:GetService("HttpService")

local Icons = {}
Icons.__index = Icons

local function safeGet(url)
    local ok, res = pcall(function() return game:HttpGetAsync(url) end)
    if ok then return res end
    return nil
end

function Icons.LoadFromUrl(url)
    local raw = safeGet(url)
    if not raw then return nil end
    local ok, parsed = pcall(function() return HttpService:JSONDecode(raw) end)
    if not ok then return nil end
    return parsed
end

function Icons:Get(name)
    if not self._map then return nil end
    return self._map[name]
end

function Icons:SetMap(map)
    self._map = map or {}
end

-- try to load default feather icons (best-effort)
do
    local ok, res = pcall(function()
        return HttpService:JSONDecode(game:HttpGetAsync("https://raw.githubusercontent.com/evoincorp/lucideblox/master/src/modules/util/icons.json"))
    end)
    if ok and type(res) == "table" and res.icons then
        local map = {}
        for k, v in pairs(res.icons) do map[k] = v end
        Icons._map = map
    else
        Icons._map = {}
    end
end

return Icons
