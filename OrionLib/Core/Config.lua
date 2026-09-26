-- Core/Config.lua
local HttpService = game:GetService("HttpService")

local Config = {}

function Config.PackColor(color3)
    return { R = math.floor(color3.R * 255), G = math.floor(color3.G * 255), B = math.floor(color3.B * 255) }
end

function Config.UnpackColor(tbl)
    return Color3.fromRGB(tbl.R or 0, tbl.G or 0, tbl.B or 0)
end

function Config.LoadCfgFromString(OrionLib, jsonString)
    local ok, data = pcall(function() return HttpService:JSONDecode(jsonString) end)
    if not ok or type(data) ~= "table" then return false, "invalid json" end
    for key, val in pairs(data) do
        if OrionLib.Flags[key] then
            spawn(function()
                if OrionLib.Flags[key].Type == "Colorpicker" then
                    OrionLib.Flags[key]:Set(Config.UnpackColor(val))
                else
                    OrionLib.Flags[key]:Set(val)
                end
            end)
        else
            warn("OrionLib Config Loader - Could not find flag:", key)
        end
    end
    return true
end

function Config.SaveCfgToFile(OrionLib, folder, name)
    local data = {}
    for k, v in pairs(OrionLib.Flags or {}) do
        if v.Save then
            if v.Type == "Colorpicker" then
                data[k] = Config.PackColor(v.Value)
            else
                data[k] = v.Value
            end
        end
    end
    local ok, encoded = pcall(function() return HttpService:JSONEncode(data) end)
    if not ok then return false, "encode failed" end
    pcall(function() writefile(folder .. "/" .. name .. ".txt", encoded) end)
    return true
end

return Config
