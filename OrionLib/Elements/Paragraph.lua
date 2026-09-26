-- OrionLib Gen 2 - Paragraph Element
-- File: OrionLib/Elements/Paragraph.lua

local Paragraph = {}
Paragraph.__index = Paragraph

local function new(class, props)
    local obj = Instance.new(class)
    if props then for k, v in pairs(props) do obj[k] = v end end
    return obj
end

function Paragraph.Create(OrionLib, title, content)
    title = title or "Title"
    content = content or "Content"

    local Root = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 })
    local Card = new("Frame", { Parent = Root, Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 0.7, BorderSizePixel = 0 })
    new("UICorner", { Parent = Card, CornerRadius = UDim.new(0, 5) })
    new("UIStroke", { Parent = Card, Thickness = 1 })
    local Title = new("TextLabel", { Parent = Card, Text = title, Font = Enum.Font.GothamBold, TextSize = 15, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 6), Size = UDim2.new(1, -24, 0, 16), TextColor3 = OrionLib.Theme:Get("Text") })
    local Content = new("TextLabel", { Parent = Card, Text = content, Font = Enum.Font.GothamSemibold, TextSize = 13, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 26), Size = UDim2.new(1, -24, 0, 0), TextWrapped = true, TextColor3 = OrionLib.Theme:Get("TextDark") })

    Content:GetPropertyChangedSignal("Text"):Connect(function()
        Content.Size = UDim2.new(1, -24, 0, Content.TextBounds.Y)
        Card.Size = UDim2.new(1, 0, 0, Content.TextBounds.Y + 40)
    end)
    Content.Text = content

    function Root:Set(text)
        Content.Text = text
    end

    function Root:SetCompact(compact)
        if compact then
            -- show only title
            Content.Visible = false
            Card.Size = UDim2.new(1, 0, 0, 28)
        else
            Content.Visible = true
            Content.Size = UDim2.new(1, -24, 0, Content.TextBounds.Y)
            Card.Size = UDim2.new(1, 0, 0, Content.TextBounds.Y + 40)
        end
    end

    return Root
end

return Paragraph
