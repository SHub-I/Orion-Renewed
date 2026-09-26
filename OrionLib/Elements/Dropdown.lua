-- OrionLib Gen 2 - Dropdown Element (responsive)
-- File: OrionLib/Elements/Dropdown.lua

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Dropdown = {}
Dropdown.__index = Dropdown

local function new(class, props)
    local obj = Instance.new(class)
    if props then
        for k, v in pairs(props) do obj[k] = v end
    end
    return obj
end

-- Creates a dropdown. Returns API and root instance (Frame)
function Dropdown.Create(OrionLib, config)
    config = config or {}
    local labelText = config.Text or "Dropdown"
    local options = config.Options or {}
    local default = config.Default or options[1]
    local callback = config.Callback or function() end

    local Root = new("Frame", { Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1 })
    local Frame = new("Frame", { Parent = Root, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0.7, BorderSizePixel = 0 })
    new("UICorner", { Parent = Frame, CornerRadius = UDim.new(0, 6) })
    new("UIStroke", { Parent = Frame, Thickness = 1 })

    local Label = new("TextLabel", {
        Parent = Frame,
        Text = labelText,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 6),
        Size = UDim2.new(0.5, -12, 0, 24),
        TextColor3 = OrionLib.Theme:Get("Text"),
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local Selector = new("TextButton", {
        Parent = Frame,
        Text = tostring(default or ""),
        Font = Enum.Font.Gotham,
        TextSize = 14,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.5, -24, 0, 24),
        Position = UDim2.new(0.5, 12, 0, 6),
        AutoButtonColor = false
    })

    local Arrow = new("ImageLabel", {
        Parent = Selector,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -20, 0.5, -8),
        BackgroundTransparency = 1,
        Image = "rbxassetid://7072725342"
    })

    OrionLib.Theme:Add(Frame, "Second")
    OrionLib.Theme:Add(Label, "Text")
    OrionLib.Theme:Add(Selector, "Text")
    OrionLib.Theme:Add(Arrow, "TextDark")

    -- dropdown list
    local List = new("Frame", {
        Parent = Root,
        Size = UDim2.new(0, 220, 0, 0),
        Position = UDim2.new(0, 0, 1, 6),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Visible = false
    })
    new("UICorner", { Parent = List, CornerRadius = UDim.new(0, 6) })
    local ListInner = new("Frame", { Parent = List, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 0.9 })
    new("UIListLayout", { Parent = ListInner, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) })

    local current = default

    local function buildList()
        for _, child in ipairs(ListInner:GetChildren()) do
            if not child:IsA("UIListLayout") then child:Destroy() end
        end
        for i, opt in ipairs(options) do
            local item = new("TextButton", {
                Parent = ListInner,
                Text = tostring(opt),
                Font = Enum.Font.Gotham,
                TextSize = 14,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 28),
                AutoButtonColor = false
            })
            OrionLib.Theme:Add(item, "Text")
            item.MouseButton1Click:Connect(function()
                current = opt
                Selector.Text = tostring(opt)
                List.Visible = false
                pcall(callback, opt)
            end)
        end
        -- adjust list size
        local count = #options
        ListInner.Size = UDim2.new(1, 0, 0, count * 32)
        List.Size = UDim2.new(0, 220, 0, count * 32)
    end

    buildList()

    Selector.MouseButton1Click:Connect(function()
        List.Visible = not List.Visible
    end)

    -- compact mode: show icon-only opener
    function Root:SetCompact(compact)
        if compact then
            Label.Visible = false
            Selector.Size = UDim2.new(1, -24, 1, 0)
            Selector.Position = UDim2.new(0, 12, 0, 0)
            Selector.TextScaled = true
        else
            Label.Visible = true
            Selector.Size = UDim2.new(0.5, -24, 0, 24)
            Selector.Position = UDim2.new(0.5, 12, 0, 6)
            Selector.TextScaled = false
        end
    end

    function Root:SetOptions(tbl)
        options = tbl or {}
        if #options > 0 then current = options[1] end
        Selector.Text = tostring(current or "")
        buildList()
    end

    function Root:GetValue() return current end
    function Root:SetValue(v) current = v; Selector.Text = tostring(v); pcall(callback, v) end

    return Root
end

return Dropdown
