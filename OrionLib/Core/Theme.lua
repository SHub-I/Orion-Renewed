-- OrionLib Gen 2 - Theme Module

local Theme = {}

Theme.Themes = {
    Default = {
        Main      = Color3.fromRGB(25, 25, 25),
        Second    = Color3.fromRGB(32, 32, 32),
        Stroke    = Color3.fromRGB(60, 60, 60),
        Divider   = Color3.fromRGB(60, 60, 60),
        Text      = Color3.fromRGB(240, 240, 240),
        TextDark  = Color3.fromRGB(150, 150, 150)
    }
}

Theme.Selected = "Default"
Theme.Objects = {}

local function ReturnProperty(obj)
    if obj:IsA("Frame") or obj:IsA("TextButton") then
        return "BackgroundColor3"
    end
    if obj:IsA("ScrollingFrame") then
        return "ScrollBarImageColor3"
    end
    if obj:IsA("UIStroke") then
        return "Color"
    end
    if obj:IsA("TextLabel") or obj:IsA("TextBox") then
        return "TextColor3"
    end
    if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
        return "ImageColor3"
    end
end

function Theme:Add(obj, typeName)
    if not Theme.Objects[typeName] then
        Theme.Objects[typeName] = {}
    end

    table.insert(Theme.Objects[typeName], obj)

    local prop = ReturnProperty(obj)
    obj[prop] = Theme.Themes[Theme.Selected][typeName]

    return obj
end

function Theme:SetTheme(name)
    if not Theme.Themes[name] then
        warn("Theme does not exist:", name)
        return
    end

    Theme.Selected = name

    for typeName, list in pairs(Theme.Objects) do
        for _, obj in ipairs(list) do
            local prop = ReturnProperty(obj)
            obj[prop] = Theme.Themes[name][typeName]
        end
    end
end

function Theme:Get(typeName)
    return Theme.Themes[Theme.Selected][typeName]
end

return Theme
