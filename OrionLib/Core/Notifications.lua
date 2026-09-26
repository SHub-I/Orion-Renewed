-- Core/Notifications.lua
local TweenService = game:GetService("TweenService")

local Notifications = {}

-- Create a notification inside a holder frame (holder must be created by caller)
function Notifications.Create(holder, cfg, Theme)
    cfg = cfg or {}
    cfg.Name = cfg.Name or "Notification"
    cfg.Content = cfg.Content or "Test"
    cfg.Image = cfg.Image or "rbxassetid://4384403532"
    cfg.Time = cfg.Time or 6

    local parent = Instance.new("Frame")
    parent.Size = UDim2.new(1, 0, 0, 0)
    parent.AutomaticSize = Enum.AutomaticSize.Y
    parent.Parent = holder

    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.Size = UDim2.new(1, 0, 0, 0)
    frame.Position = UDim2.new(1, -55, 0, 0)
    frame.BackgroundTransparency = 0
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.BackgroundColor3 = Theme:Get("Main")

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Theme:Get("Stroke")
    stroke.Thickness = 1.2

    local padding = Instance.new("UIPadding", frame)
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)

    local icon = Instance.new("ImageLabel", frame)
    icon.Size = UDim2.new(0, 20, 0, 20)
    icon.Image = cfg.Image
    icon.BackgroundTransparency = 1
    icon.ImageColor3 = Theme:Get("Text")

    local title = Instance.new("TextLabel", frame)
    title.Text = cfg.Name
    title.Font = Enum.Font.GothamBold
    title.TextSize = 15
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 30, 0, 0)
    title.Size = UDim2.new(1, -30, 0, 20)
    title.TextColor3 = Theme:Get("Text")

    local content = Instance.new("TextLabel", frame)
    content.Text = cfg.Content
    content.Font = Enum.Font.GothamSemibold
    content.TextSize = 14
    content.BackgroundTransparency = 1
    content.Position = UDim2.new(0, 0, 0, 25)
    content.Size = UDim2.new(1, 0, 0, 0)
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.TextWrapped = true
    content.TextColor3 = Theme:Get("TextDark")

    -- animate in
    TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 0, 0, 0)}):Play()

    spawn(function()
        wait(math.max(0.5, cfg.Time - 0.9))
        pcall(function() TweenService:Create(icon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play() end)
        pcall(function() TweenService:Create(frame, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.6}):Play() end)
        wait(0.3)
        pcall(function() TweenService:Create(stroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Transparency = 0.9}):Play() end)
        pcall(function() TweenService:Create(title, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.4}):Play() end)
        pcall(function() TweenService:Create(content, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.5}):Play() end)
        wait(0.05)
        frame:TweenPosition(UDim2.new(1, 20, 0, 0), 'In', 'Quint', 0.8, true)
        wait(1.35)
        parent:Destroy()
    end)
end

return Notifications
