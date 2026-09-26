-- OrionLib Gen 2 - Slider Element (compact-aware)
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Slider = {}
Slider.__index = Slider

local function new(class, props)
    local obj = Instance.new(class)
    if props then for k, v in pairs(props) do obj[k] = v end end
    return obj
end

function Slider.Create(OrionLib, config)
    config = config or {}
    local label = config.Text or "Slider"
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or min
    local step = config.Step or 1
    local callback = config.Callback or function() end

    local Root = new("Frame", { Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 1 })
    local Frame = new("Frame", { Parent = Root, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0.7, BorderSizePixel = 0 })
    new("UICorner", { Parent = Frame, CornerRadius = UDim.new(0, 6) })
    new("UIStroke", { Parent = Frame, Thickness = 1 })

    local Title = new("TextLabel", { Parent = Frame, Text = label, Font = Enum.Font.GothamBold, TextSize = 14, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 2), Size = UDim2.new(1, -24, 0, 18), TextColor3 = OrionLib.Theme:Get("Text"), TextXAlignment = Enum.TextXAlignment.Left })
    local Bar = new("Frame", { Parent = Frame, Size = UDim2.new(1, -24, 0, 10), Position = UDim2.new(0, 12, 0, 24), BackgroundColor3 = Color3.fromRGB(60, 60, 60), BorderSizePixel = 0 })
    new("UICorner", { Parent = Bar, CornerRadius = UDim.new(0, 6) })
    local Fill = new("Frame", { Parent = Bar, Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(120, 200, 255), BorderSizePixel = 0 })
    new("UICorner", { Parent = Fill, CornerRadius = UDim.new(0, 6) })

    local value = math.clamp(default, min, max)
    local function updateFillFromValue()
        local pct = (value - min) / math.max(1, (max - min))
        Fill.Size = UDim2.new(pct, 0, 1, 0)
        pcall(callback, value)
    end
    updateFillFromValue()

    local dragging = false
    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    Bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local absPos = input.Position.X
            local barPos = Bar.AbsolutePosition.X
            local barSize = Bar.AbsoluteSize.X
            local pct = math.clamp((absPos - barPos) / barSize, 0, 1)
            local raw = min + pct * (max - min)
            value = math.floor(raw / step + 0.5) * step
            updateFillFromValue()
        end
    end)

    -- compact mode: hide full slider and show icon that opens a small popup
    local CompactIcon = new("ImageButton", { Parent = Frame, Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, -40, 0, 8), BackgroundTransparency = 1, Image = "rbxassetid://7072719338", Visible = false })
    OrionLib.Theme:Add(CompactIcon, "TextDark")

    function Root:SetCompact(compact)
        if compact then
            Bar.Visible = false
            CompactIcon.Visible = true
            Title.Size = UDim2.new(1, -56, 0, 18)
        else
            Bar.Visible = true
            CompactIcon.Visible = false
            Title.Size = UDim2.new(1, -24, 0, 18)
        end
    end

    CompactIcon.MouseButton1Click:Connect(function()
        -- small popup: simple prompt using a TextBox overlay
        local popup = Instance.new("Frame")
        popup.Size = UDim2.new(0, 220, 0, 80)
        popup.Position = UDim2.new(0.5, -110, 0.5, -40)
        popup.AnchorPoint = Vector2.new(0.5, 0.5)
        popup.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        popup.Parent = OrionLib.ScreenGui
        new("UICorner", { Parent = popup, CornerRadius = UDim.new(0, 8) })
        local tb = new("TextBox", { Parent = popup, Size = UDim2.new(1, -20, 0, 28), Position = UDim2.new(0, 10, 0, 20), Text = tostring(value), ClearTextOnFocus = false, Font = Enum.Font.Gotham, TextSize = 14 })
        tb.FocusLost:Connect(function(enter)
            local n = tonumber(tb.Text)
            if n then
                value = math.clamp(math.floor(n / step + 0.5) * step, min, max)
                updateFillFromValue()
            end
            popup:Destroy()
        end)
    end)

    function Root:GetValue() return value end
    function Root:SetValue(v) value = math.clamp(v, min, max); updateFillFromValue() end

    WindowAPI = WindowAPI -- noop safe reference if needed externally
    return Root
end

return Slider
