-- OrionLib Gen 2 - Rescale Module (Responsive, emits ScaleChanged)
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Rescale = {}

local MIN_SCALE = 0.6
local MAX_SCALE = 1.6

function Rescale.Attach(Window)
    -- store base pixel size (capture initial offsets)
    local BASE_W = Window.Size.X.Offset
    local BASE_H = Window.Size.Y.Offset

    -- create an event on the window for scale changes
    local scaleEvent = Instance.new("BindableEvent")
    scaleEvent.Name = "ScaleChanged"
    scaleEvent.Parent = Window

    -- image handle
    local Handle = Instance.new("ImageLabel")
    Handle.Name = "RescaleHandle"
    Handle.Size = UDim2.new(0, 20, 0, 20)
    Handle.AnchorPoint = Vector2.new(1, 1)
    Handle.Position = UDim2.new(1, -4, 1, -4)
    Handle.BackgroundTransparency = 1
    Handle.Image = "rbxassetid://153287174"
    Handle.ImageColor3 = Color3.fromRGB(255, 255, 255)
    Handle.ZIndex = 50
    Handle.Parent = Window

    local dragging = false
    local startMouse
    local startSize

    Handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startMouse = UserInputService:GetMouseLocation()
            startSize = Window.Size

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    RunService.RenderStepped:Connect(function()
        if not dragging then return end

        local mousePos = UserInputService:GetMouseLocation()
        local delta = mousePos - startMouse

        local newW = math.clamp(startSize.X.Offset + delta.X, BASE_W * MIN_SCALE, BASE_W * MAX_SCALE)
        local newH = math.clamp(startSize.Y.Offset + delta.Y, BASE_H * MIN_SCALE, BASE_H * MAX_SCALE)

        Window.Size = UDim2.new(0, newW, 0, newH)

        -- compute scale factor relative to base width
        local scaleFactor = newW / BASE_W
        if scaleEvent and scaleEvent.Fire then
            scaleEvent:Fire(scaleFactor)
        end
    end)

    return scaleEvent
end

return Rescale
