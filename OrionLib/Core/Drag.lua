-- Core/Drag.lua
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Drag = {}

-- Enable dragging: DragPoint (Frame) and Target (Frame)
function Drag.Enable(DragPoint, Target)
    pcall(function()
        local Dragging, DragInput, MousePos, FramePos = false, nil, nil, nil

        DragPoint.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = true
                MousePos = input.Position
                FramePos = Target.Position

                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        Dragging = false
                    end
                end)
            end
        end)

        DragPoint.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                DragInput = input
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input == DragInput and Dragging then
                local Delta = input.Position - MousePos
                TweenService:Create(Target, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Position = UDim2.new(FramePos.X.Scale, FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
                }):Play()
            end
        end)
    end)
end

return Drag
