-- OrionLib Gen 2 - Button Element (responsive)
local TweenService = game:GetService("TweenService")

local Button = {}
Button.__index = Button

local function new(class, props)
    local obj = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            obj[k] = v
        end
    end
    return obj
end

function Button.Create(OrionLib, config)
    config = config or {}
    local text = config.Text or "Button"
    local icon = config.Icon or ""
    local callback = config.Callback or function() end
    local bgTransparency = config.BackgroundTransparency or 0.7

    local Click = new("TextButton", {
        Name = "OrionButton",
        Text = "",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 36)
    })

    local Frame = new("Frame", {
        Name = "Frame",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = bgTransparency,
        BorderSizePixel = 0,
        Parent = Click
    })

    new("UICorner", { CornerRadius = UDim.new(0, 6), Parent = Frame })
    new("UIStroke", { Thickness = 1, Parent = Frame })

    local hLayout = new("UIListLayout", { Parent = Frame })
    hLayout.FillDirection = Enum.FillDirection.Horizontal
    hLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    hLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    hLayout.Padding = UDim.new(0, 10)

    local IconContainer = new("Frame", { Parent = Frame, Name = "IconContainer", Size = UDim2.new(0, 36, 1, 0), BackgroundTransparency = 1 })
    local IconLabel = new("ImageLabel", { Parent = IconContainer, Name = "Icon", Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 8, 0.5, -10), BackgroundTransparency = 1, Image = icon })

    local Label = new("TextLabel", {
        Parent = Frame,
        Name = "Label",
        Size = UDim2.new(1, -56, 1, 0),
        Position = UDim2.new(0, 56, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = OrionLib.Theme:Get("Text"),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextScaled = true,
        Text = text
    })

    OrionLib.Theme:Add(Frame, "Second")
    OrionLib.Theme:Add(Label, "Text")
    OrionLib.Theme:Add(IconLabel, "TextDark")

    local hoverTweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local clickTweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local function onEnter()
        TweenService:Create(Frame, hoverTweenInfo, {BackgroundTransparency = math.max(0, bgTransparency - 0.12)}):Play()
    end

    local function onLeave()
        TweenService:Create(Frame, hoverTweenInfo, {BackgroundTransparency = bgTransparency}):Play()
    end

    local function onClick()
        local origPos = Frame.Position
        TweenService:Create(Frame, clickTweenInfo, {Position = UDim2.new(origPos.X.Scale, origPos.X.Offset, origPos.Y.Scale, origPos.Y.Offset + 1)}):Play()
        task.delay(0.06, function()
            TweenService:Create(Frame, clickTweenInfo, {Position = origPos}):Play()
        end)
        task.spawn(function() pcall(callback) end)
    end

    Click.MouseEnter:Connect(onEnter)
    Click.MouseLeave:Connect(onLeave)
    Click.MouseButton1Click:Connect(onClick)

    local api = {}

    function api:SetText(newText) Label.Text = newText end
    function api:SetIcon(newIcon) IconLabel.Image = newIcon end
    function api:SetCallback(fn) if type(fn) == "function" then callback = fn end end
    function api:SetBackgroundTransparency(val) Frame.BackgroundTransparency = val end
    function api:GetInstance() return Click end

    return api, Click
end

return Button
