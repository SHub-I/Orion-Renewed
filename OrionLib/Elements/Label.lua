-- OrionLib Gen 2 - Label Element (responsive)
-- File: OrionLib/Elements/Label.lua

local Label = {}
Label.__index = Label

local function new(class, props)
    local obj = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            obj[k] = v
        end
    end
    return obj
end

-- Create a label element.
-- OrionLib: the library table (used for Theme, ScreenGui, etc.)
-- config: {
--   Text = string,
--   TextSize = number (base size),
--   TextColor = Color3,
--   TextDark = boolean (use TextDark theme instead of Text),
--   AutoSize = boolean (use AutomaticSize.Y),
--   Truncate = boolean (use single-line truncation in compact mode)
-- }
function Label.Create(OrionLib, config)
    config = config or {}
    local text = config.Text or ""
    local baseTextSize = config.TextSize or 15
    local useTextDark = config.TextDark or false
    local autoSize = config.AutoSize
    local truncate = config.Truncate or false

    -- Root container (keeps consistent styling with other elements)
    local Root = new("Frame", {
        Name = "OrionLabel",
        Size = autoSize and UDim2.new(1, 0, 0, 0) or UDim2.new(1, 0, 0, math.max(20, baseTextSize + 6)),
        AutomaticSize = autoSize and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
        BackgroundTransparency = 1
    })

    -- Card frame for background/rounded look (matches other elements)
    local Card = new("Frame", {
        Name = "Card",
        Parent = Root,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0
    })
    new("UICorner", { CornerRadius = UDim.new(0, 5), Parent = Card })
    new("UIStroke", { Thickness = 1, Parent = Card })

    -- Text label
    local TextLabel = new("TextLabel", {
        Name = "Label",
        Parent = Card,
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = baseTextSize,
        TextColor3 = config.TextColor or OrionLib.Theme:Get(useTextDark and "TextDark" or "Text"),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 6),
        Size = UDim2.new(1, -24, 0, baseTextSize + 4),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = not truncate,
        RichText = true
    })

    -- If autoSize, let the label expand vertically
    if autoSize then
        TextLabel.AutomaticSize = Enum.AutomaticSize.Y
        -- keep a small top/bottom padding
        Root.Size = UDim2.new(1, 0, 0, 0)
        Card.Size = UDim2.new(1, 0, 0, 0)
        Card.AutomaticSize = Enum.AutomaticSize.Y
    end

    -- Theme registration
    if OrionLib and OrionLib.Theme and OrionLib.Theme.Add then
        OrionLib.Theme:Add(Card, "Second")
        OrionLib.Theme:Add(TextLabel, useTextDark and "TextDark" or "Text")
    end

    -- Tooltip helper (optional): show full text on hover when truncated
    local Tooltip
    local function showTooltip()
        if not truncate and not autoSize then return end
        if Tooltip and Tooltip.Parent then Tooltip:Destroy() end
        Tooltip = Instance.new("TextLabel")
        Tooltip.Name = "OrionLabelTooltip"
        Tooltip.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Tooltip.TextColor3 = Color3.fromRGB(240, 240, 240)
        Tooltip.Font = Enum.Font.Gotham
        Tooltip.TextSize = 14
        Tooltip.Text = TextLabel.Text
        Tooltip.Size = UDim2.new(0, math.clamp(TextLabel.TextBounds.X + 16, 120, 600), 0, math.clamp(TextLabel.TextBounds.Y + 12, 20, 400))
        Tooltip.Position = UDim2.new(0, TextLabel.AbsolutePosition.X - Root.AbsolutePosition.X, 0, TextLabel.AbsolutePosition.Y - Root.AbsolutePosition.Y - Tooltip.Size.Y.Offset - 6)
        Tooltip.AnchorPoint = Vector2.new(0, 1)
        Tooltip.BackgroundTransparency = 0
        Tooltip.Parent = Root
        local corner = Instance.new("UICorner", Tooltip)
        corner.CornerRadius = UDim.new(0, 6)
    end

    local function hideTooltip()
        if Tooltip then
            Tooltip:Destroy()
            Tooltip = nil
        end
    end

    -- Hover connections for tooltip (only if truncation or autosize)
    TextLabel.MouseEnter:Connect(function()
        if truncate or autoSize then
            showTooltip()
        end
    end)
    TextLabel.MouseLeave:Connect(function()
        hideTooltip()
    end)

    -- Public API
    function Root:Set(textValue)
        TextLabel.Text = tostring(textValue or "")
        -- update size if not using AutomaticSize
        if not autoSize then
            -- adjust height to fit one line if truncating, otherwise keep base size
            if truncate then
                TextLabel.Size = UDim2.new(1, -24, 0, baseTextSize + 4)
                Root.Size = UDim2.new(1, 0, 0, baseTextSize + 12)
                Card.Size = Root.Size
            else
                -- keep existing
            end
        end
    end

    function Root:SetTextColor(color3)
        TextLabel.TextColor3 = color3
    end

    function Root:SetTextSize(size)
        baseTextSize = size or baseTextSize
        TextLabel.TextSize = baseTextSize
        if not autoSize and truncate then
            TextLabel.Size = UDim2.new(1, -24, 0, baseTextSize + 4)
            Root.Size = UDim2.new(1, 0, 0, baseTextSize + 12)
            Card.Size = Root.Size
        end
    end

    function Root:SetCompact(compact)
        -- compact: hide content or truncate to single line and optionally reduce padding
        if compact then
            TextLabel.TextWrapped = false
            TextLabel.TextScaled = true
            TextLabel.Size = UDim2.new(1, -24, 0, math.max(18, math.floor(baseTextSize * 0.9)))
            Root.Size = UDim2.new(1, 0, 0, TextLabel.Size.Y.Offset + 12)
            Card.Size = Root.Size
        else
            TextLabel.TextWrapped = not truncate
            TextLabel.TextScaled = false
            TextLabel.TextSize = baseTextSize
            if autoSize then
                -- let AutomaticSize handle it
                TextLabel.AutomaticSize = Enum.AutomaticSize.Y
                Card.AutomaticSize = Enum.AutomaticSize.Y
                Root.AutomaticSize = Enum.AutomaticSize.Y
            else
                TextLabel.Size = UDim2.new(1, -24, 0, baseTextSize + 4)
                Root.Size = UDim2.new(1, 0, 0, baseTextSize + 12)
                Card.Size = Root.Size
            end
        end
    end

    function Root:GetInstance()
        return Root
    end

    return Root
end

return Label
