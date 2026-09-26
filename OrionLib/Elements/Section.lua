-- OrionLib Gen 2 - Section Element (responsive)
-- File: OrionLib/Elements/Section.lua

local Section = {}
Section.__index = Section

local function new(class, props)
    local obj = Instance.new(class)
    if props then for k, v in pairs(props) do obj[k] = v end end
    return obj
end

function Section.Create(OrionLib, title)
    title = title or "Section"
    local Root = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 })
    local Header = new("TextLabel", {
        Parent = Root,
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = OrionLib.Theme:Get("Text"),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20)
    })
    OrionLib.Theme:Add(Header, "Text")

    local Body = new("Frame", { Parent = Root, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 })
    new("UIListLayout", { Parent = Body, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) })

    local collapsed = false

    function Root:Collapse()
        if collapsed then return end
        collapsed = true
        Body.Visible = false
    end

    function Root:Expand()
        if not collapsed then return end
        collapsed = false
        Body.Visible = true
    end

    function Root:SetCompact(compact)
        if compact then
            -- collapse children if desired
            if not collapsed then
                self:Collapse()
            end
        else
            self:Expand()
        end
    end

    function Root:Add(child)
        child.Parent = Body
    end

    return Root
end

return Section
