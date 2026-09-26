-- OrionLib Gen 2 - Toggle Element (compact-aware)
local TweenService = game:GetService("TweenService")

local Toggle = {}
Toggle.__index = Toggle

local function new(class, props)
    local obj = Instance.new(class)
    if props then
        for k, v in pairs(props) do obj[k] = v end
    end
    return obj
end

function Toggle.Create(OrionLib, config)
    config = config or {}
    local labelText = config.Text or "Toggle"
    local default = config.Default or false
    local callback = config.Callback or function() end

    local Root = new("Frame", { Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1 })
    local Frame = new("Frame", { Parent = Root, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0.7, BorderSizePixel = 0 })
    new("UICorner", { Parent = Frame, CornerRadius = UDim.new(0, 6) })
    new("UIStroke", { Parent = Frame, Thickness = 1 })
    local Label = new("TextLabel", { Parent = Frame, Text = labelText, Font = Enum.Font.GothamBold, TextSize = 14, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -60, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = OrionLib.Theme:Get("Text") })
    local Switch = new("Frame", { Parent = Frame, Size = UDim2.new(0, 36, 0, 20), Position = UDim2.new(1, -46, 0.5, -10), BackgroundTransparency = 1 })
    local SwitchBtn = new("ImageButton", { Parent = Switch, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Image = "rbxassetid://7072719338" })

    OrionLib.Theme:Add(Frame, "Second")
    OrionLib.Theme:Add(Label, "Text")
    OrionLib.Theme:Add(SwitchBtn, "TextDark")

    local state = default
    local function setState(v)
        state = not not v
        pcall(callback, state)
        if state then
            SwitchBtn.Image = "rbxassetid://7072719338"
        else
            SwitchBtn.Image = "rbxassetid://7072720870"
        end
    end

    SwitchBtn.MouseButton1Click:Connect(function()
        setState(not state)
    end)

    -- compact mode: show small icon-only representation
    function Root:SetCompact(compact)
        if compact then
            Label.Visible = false
            Frame.Size = UDim2.new(1, 0, 0, 28)
            Switch.Size = UDim2.new(0, 28, 0, 28)
            SwitchBtn.Size = UDim2.new(1, 0, 1, 0)
        else
            Label.Visible = true
            Frame.Size = UDim2.new(1, 0, 0, 28)
            Switch.Size = UDim2.new(0, 36, 0, 20)
            SwitchBtn.Size = UDim2.new(1, 0, 1, 0)
        end
    end

    function Root:GetState() return state end
    function Root:SetState(v) setState(v) end

    return Root
end

return Toggle
