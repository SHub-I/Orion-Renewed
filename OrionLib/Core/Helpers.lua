-- Core/Helpers.lua
local HttpService = game:GetService("HttpService")

local Helpers = {}

-- Create instance helper
function Helpers.Create(className, props, children)
    local obj = Instance.new(className)
    if props then
        for k,v in pairs(props) do obj[k] = v end
    end
    if children then
        for _, child in ipairs(children) do child.Parent = obj end
    end
    return obj
end

-- Element registry helper (used by original source.lua)
function Helpers.CreateElement(registry, name, fn)
    registry[name] = fn
end

-- Set properties helper
function Helpers.SetProps(instance, props)
    for k,v in pairs(props or {}) do instance[k] = v end
    return instance
end

-- Set children helper
function Helpers.SetChildren(instance, children)
    for _, c in ipairs(children or {}) do c.Parent = instance end
    return instance
end

-- AddConnection: stores connections and returns the connection
function Helpers.AddConnection(storeTable, signal, fn)
    if not storeTable then return end
    local conn = signal:Connect(fn)
    table.insert(storeTable, conn)
    return conn
end

-- ReturnProperty: map instance class to theme property
function Helpers.ReturnProperty(obj)
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
    return nil
end

-- AddThemeObject: register object into theme table and apply initial color
function Helpers.AddThemeObject(themeTable, obj, typeName)
    if not themeTable[typeName] then themeTable[typeName] = {} end
    table.insert(themeTable[typeName], obj)
    local prop = Helpers.ReturnProperty(obj)
    if prop and themeTable.SelectedTheme and themeTable.Themes and themeTable.Themes[themeTable.SelectedTheme] then
        local color = themeTable.Themes[themeTable.SelectedTheme][typeName]
        if color then obj[prop] = color end
    end
    return obj
end

-- SetTheme: apply theme colors to registered objects
function Helpers.SetTheme(themeTable)
    for typeName, list in pairs(themeTable.ThemeObjects or {}) do
        for _, obj in ipairs(list) do
            local prop = Helpers.ReturnProperty(obj)
            if prop and themeTable.Themes and themeTable.Themes[themeTable.SelectedTheme] then
                obj[prop] = themeTable.Themes[themeTable.SelectedTheme][typeName]
            end
        end
    end
end

-- CheckKey: small helper to check membership
function Helpers.CheckKey(tbl, key)
    for _, v in ipairs(tbl or {}) do
        if v == key then return true end
    end
    return false
end

return Helpers
