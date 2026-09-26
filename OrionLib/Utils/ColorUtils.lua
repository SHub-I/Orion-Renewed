-- OrionLib Gen 2 - Color utilities
-- File: OrionLib/Utils/ColorUtils.lua

local ColorUtils = {}

function ColorUtils.Pack(color3)
    return { R = math.floor(color3.R * 255), G = math.floor(color3.G * 255), B = math.floor(color3.B * 255) }
end

function ColorUtils.Unpack(tbl)
    return Color3.fromRGB(tbl.R or 0, tbl.G or 0, tbl.B or 0)
end

function ColorUtils.Lerp(a, b, t)
    t = math.clamp(t, 0, 1)
    return Color3.new(a.R + (b.R - a.R) * t, a.G + (b.G - a.G) * t, a.B + (b.B - a.B) * t)
end

function ColorUtils.ToHex(color3)
    local r = math.floor(color3.R * 255)
    local g = math.floor(color3.G * 255)
    local b = math.floor(color3.B * 255)
    return string.format("#%02X%02X%02X", r, g, b)
end

return ColorUtils
