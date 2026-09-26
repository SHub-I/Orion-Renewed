-- OrionLib Gen 2 - Window Module (Responsive Orion UI)
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Window = {}

local function new(class, props)
    local obj = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            obj[k] = v
        end
    end
    return obj
end

local function ensureScreenGui(name)
    local sg = Instance.new("ScreenGui")
    sg.Name = name or "OrionLibGui"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    if syn and syn.protect_gui then
        pcall(function() syn.protect_gui(sg) end)
        sg.Parent = game:GetService("CoreGui")
    else
        sg.Parent = (gethui and gethui()) or game:GetService("CoreGui")
    end

    for _, child in ipairs(sg.Parent:GetChildren()) do
        if child ~= sg and child.Name == sg.Name then
            child:Destroy()
        end
    end

    return sg
end

function Window.Create(OrionLib, WindowConfig)
    assert(OrionLib, "OrionLib table required")
    WindowConfig = WindowConfig or {}

    WindowConfig.Name = WindowConfig.Name or "Orion Library"
    WindowConfig.ConfigFolder = WindowConfig.ConfigFolder or WindowConfig.Name
    WindowConfig.SaveConfig = WindowConfig.SaveConfig or false
    WindowConfig.HidePremium = WindowConfig.HidePremium or false
    if WindowConfig.IntroEnabled == nil then WindowConfig.IntroEnabled = true end
    WindowConfig.IntroText = WindowConfig.IntroText or WindowConfig.Name
    WindowConfig.CloseCallback = WindowConfig.CloseCallback or function() end
    WindowConfig.ShowIcon = WindowConfig.ShowIcon or false
    WindowConfig.Icon = WindowConfig.Icon or "rbxassetid://8834748103"
    WindowConfig.IntroIcon = WindowConfig.IntroIcon or WindowConfig.Icon

    if not OrionLib.ScreenGui or not OrionLib.ScreenGui.Parent then
        OrionLib.ScreenGui = ensureScreenGui("OrionLibGui")
    end

    local MainWindow = new("Frame", {
        Name = "MainWindow",
        Parent = OrionLib.ScreenGui,
        Size = UDim2.new(0, 615, 0, 344),
        Position = UDim2.new(0.5, -307, 0.5, -172),
        BackgroundColor3 = OrionLib.Theme:Get("Main"),
        BorderSizePixel = 0,
        ClipsDescendants = true
    })

    local Stroke = new("UIStroke", {
        Color = OrionLib.Theme:Get("Stroke"),
        Thickness = 1.2,
        Parent = MainWindow
    })
    new("UICorner", { CornerRadius = UDim.new(0, 10), Parent = MainWindow })

    local TopBar = new("Frame", {
        Name = "TopBar",
        Parent = MainWindow,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1
    })

    local TitleLabel = new("TextLabel", {
        Name = "WindowTitle",
        Parent = TopBar,
        Text = WindowConfig.Name,
        Font = Enum.Font.GothamBlack,
        TextSize = 20,
        TextColor3 = OrionLib.Theme:Get("Text"),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 25, 0, 6),
        Size = UDim2.new(1, -30, 0, 34),
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local Controls = new("Frame", {
        Name = "Controls",
        Parent = TopBar,
        Size = UDim2.new(0, 120, 1, 0),
        Position = UDim2.new(1, -120, 0, 0),
        BackgroundTransparency = 1
    })

    local function makeIconButton(iconImage)
        local btn = new("TextButton", {
            Parent = Controls,
            Size = UDim2.new(0, 36, 0, 34),
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false
        })
        local img = new("ImageLabel", {
            Parent = btn,
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(0, 9, 0, 8),
            BackgroundTransparency = 1,
            Image = iconImage,
            ImageColor3 = OrionLib.Theme:Get("Text")
        })
        return btn, img
    end

    local MinBtn, MinIcon = makeIconButton("rbxassetid://7072719338")
    MinBtn.Name = "Minimize"
    MinBtn.Position = UDim2.new(1, -96, 0, 0)

    local CloseBtn, CloseIcon = makeIconButton("rbxassetid://7072725342")
    CloseBtn.Name = "Close"
    CloseBtn.Position = UDim2.new(1, -60, 0, 0)

    local Sidebar = new("Frame", {
        Name = "Sidebar",
        Parent = MainWindow,
        Size = UDim2.new(0, 150, 1, -50),
        Position = UDim2.new(0, 0, 0, 50),
        BackgroundTransparency = 1
    })

    new("Frame", {
        Parent = Sidebar,
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    })

    local TabHolder = new("ScrollingFrame", {
        Parent = Sidebar,
        Name = "TabHolder",
        Size = UDim2.new(1, 0, 1, -10),
        Position = UDim2.new(0, 0, 0, 10),
        BackgroundTransparency = 1,
        ScrollBarThickness = 6,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    TabHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y

    new("UIListLayout", {
        Parent = TabHolder,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6)
    })

    local ContentArea = new("Frame", {
        Name = "ContentArea",
        Parent = MainWindow,
        Size = UDim2.new(1, -170, 1, -50),
        Position = UDim2.new(0, 170, 0, 50),
        BackgroundTransparency = 1
    })

    local ContentScroll = new("ScrollingFrame", {
        Parent = ContentArea,
        Name = "ContentScroll",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 6,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    ContentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

    new("UIListLayout", {
        Parent = ContentScroll,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8)
    })

    local function addTheme(obj, typeName)
        if OrionLib.Theme and OrionLib.Theme.Add then
            OrionLib.Theme:Add(obj, typeName)
        end
    end

    addTheme(MainWindow, "Main")
    addTheme(Stroke, "Stroke")
    addTheme(TitleLabel, "Text")
    addTheme(MinIcon, "Text")
    addTheme(CloseIcon, "Text")

    if OrionLib.Drag and OrionLib.Drag.Enable then
        OrionLib.Drag.Enable(TopBar, MainWindow)
    end

    if OrionLib.Rescale and OrionLib.Rescale.Attach then
        -- Rescale.Attach returns a BindableEvent
        local evt = OrionLib.Rescale.Attach(MainWindow)
        -- We'll connect later after building WindowAPI
        -- store evt for connection below
        MainWindow:SetAttribute("RescaleEventPresent", evt and true or false)
        MainWindow:SetAttribute("RescaleEventRef", evt)
    end

    local function notify(cfg)
        if OrionLib.MakeNotification then
            OrionLib:MakeNotification(cfg)
        end
    end

    local hidden = false
    CloseBtn.MouseButton1Click:Connect(function()
        MainWindow.Visible = false
        hidden = true
        notify({ Name = "Interface Hidden", Content = "Press RightShift to reopen the interface", Time = 5 })
        WindowConfig.CloseCallback()
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.RightShift and hidden then
            MainWindow.Visible = true
            hidden = false
        end
    end)

    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        if minimized then
            TweenService:Create(MainWindow, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 615, 0, 344)}):Play()
            minimized = false
        else
            TweenService:Create(MainWindow, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Size = UDim2.new(0, TitleLabel.TextBounds.X + 140, 0, 50)}):Play()
            minimized = true
        end
    end)

    local function playIntro()
        if not WindowConfig.IntroEnabled then return end
        MainWindow.Visible = false
        local logo = new("ImageLabel", {
            Parent = OrionLib.ScreenGui,
            Image = WindowConfig.IntroIcon,
            Size = UDim2.new(0, 28, 0, 28),
            Position = UDim2.new(0.5, 0, 0.4, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            ImageTransparency = 1
        })
        local text = new("TextLabel", {
            Parent = OrionLib.ScreenGui,
            Text = WindowConfig.IntroText,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = OrionLib.Theme:Get("Text"),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5)
        })

        TweenService:Create(logo, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {ImageTransparency = 0}):Play()
        task.wait(0.8)
        TweenService:Create(text, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
        task.wait(1.6)
        logo:Destroy()
        text:Destroy()
        MainWindow.Visible = true
    end

    playIntro()

    -- Responsive registry and handlers
    local WindowAPI = {
        Main = MainWindow,
        TabHolder = TabHolder,
        ContentScroll = ContentScroll,
        Theme = OrionLib.Theme,
        _responsive = { Buttons = {}, Toggles = {}, Sliders = {}, Dropdowns = {}, Labels = {}, Sections = {}, OverflowActions = {}, Tabs = {} }
    }

    local OverflowBar = Instance.new("Frame")
    OverflowBar.Name = "OverflowBar"
    OverflowBar.Size = UDim2.new(0, 200, 0, 40)
    OverflowBar.Position = UDim2.new(0, 8, 1, -48)
    OverflowBar.AnchorPoint = Vector2.new(0, 0)
    OverflowBar.BackgroundTransparency = 1
    OverflowBar.Visible = false
    OverflowBar.Parent = MainWindow

    local OverflowLayout = Instance.new("UIListLayout", OverflowBar)
    OverflowLayout.FillDirection = Enum.FillDirection.Horizontal
    OverflowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    OverflowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    OverflowLayout.Padding = UDim.new(0, 8)

    function WindowAPI:RegisterResponsive(kind, instance, meta)
        if not kind or not instance then return end
        meta = meta or {}
        if not self._responsive[kind] then
            self._responsive[kind] = {}
        end
        table.insert(self._responsive[kind], {inst = instance, meta = meta})
    end

    function WindowAPI:RegisterOverflowAction(image, callback)
        table.insert(self._responsive.OverflowActions, {Image = image, Callback = callback})
    end

    local function PopulateOverflow()
        for _, child in ipairs(OverflowBar:GetChildren()) do
            if not child:IsA("UIListLayout") then child:Destroy() end
        end
        for i, act in ipairs(WindowAPI._responsive.OverflowActions) do
            local btn = Instance.new("ImageButton")
            btn.Name = "OverflowAction" .. i
            btn.Size = UDim2.new(0, 28, 0, 28)
            btn.BackgroundTransparency = 1
            btn.Image = act.Image or ""
            btn.Parent = OverflowBar
            if type(act.Callback) == "function" then
                btn.MouseButton1Click:Connect(function() pcall(act.Callback) end)
            end
        end
    end

    local function UpdateResponsiveLayout(scale)
        local compactThreshold = 0.85
        local wideScale = math.clamp(scale, 0.6, 1.6)

        if scale < compactThreshold then
            OverflowBar.Visible = true
            PopulateOverflow()
        else
            OverflowBar.Visible = false
        end

        for _, entry in ipairs(WindowAPI._responsive.Buttons) do
            local btn = entry.inst
            if btn and btn:IsA("TextButton") then
                local widthScale = math.clamp(0.9 + (wideScale - 1) * 0.6, 0.6, 1.6)
                local y = btn.Size.Y
                btn.Size = UDim2.new(widthScale, 0, y.Y.Scale, y.Y.Offset)
                local label = btn:FindFirstChild("Label")
                if label and label:IsA("TextLabel") then
                    label.TextScaled = true
                    pcall(function()
                        label.TextSize = math.clamp(14 * widthScale, 10, 28)
                    end)
                end
            end
        end

        for _, entry in ipairs(WindowAPI._responsive.Tabs) do
            local tabBtn = entry.inst
            if tabBtn and tabBtn:IsA("TextButton") then
                local title = tabBtn:FindFirstChild("Title") or tabBtn:FindFirstChildWhichIsA("TextLabel")
                local ico = tabBtn:FindFirstChildWhichIsA("ImageLabel")
                if title then
                    if scale < compactThreshold then
                        title.Visible = false
                        if ico then ico.Size = UDim2.new(0, 20, 0, 20) end
                    else
                        title.Visible = true
                        if ico then ico.Size = UDim2.new(0, 18, 0, 18) end
                    end
                end
            end
        end

        for _, entry in ipairs(WindowAPI._responsive.Toggles) do
            local t = entry.inst
            if t and type(t.SetCompact) == "function" then
                pcall(function() t:SetCompact(scale < compactThreshold) end)
            end
        end

        for _, entry in ipairs(WindowAPI._responsive.Sliders) do
            local s = entry.inst
            if s and type(s.SetCompact) == "function" then
                pcall(function() s:SetCompact(scale < compactThreshold) end)
            end
        end

        for _, entry in ipairs(WindowAPI._responsive.Dropdowns) do
            local d = entry.inst
            if d and type(d.SetCompact) == "function" then
                pcall(function() d:SetCompact(scale < compactThreshold) end)
            end
        end

        for _, entry in ipairs(WindowAPI._responsive.Sections) do
            local sec = entry.inst
            if sec and type(sec.SetCompact) == "function" then
                pcall(function() sec:SetCompact(scale < compactThreshold) end)
            end
        end
    end

    -- connect to rescale event if present
    local ok, rescaleModule = pcall(function() return require(script.Parent.Rescale) end)
    if ok and rescaleModule and rescaleModule.Attach then
        local evt = rescaleModule.Attach(MainWindow)
        if evt and evt.Event then
            evt.Event:Connect(function(scale)
                pcall(UpdateResponsiveLayout, scale)
            end)
        end
    end

    -- MakeTab API
    local firstTab = true
    function WindowAPI:MakeTab(tabConfig)
        tabConfig = tabConfig or {}
        tabConfig.Name = tabConfig.Name or "Tab"
        tabConfig.Icon = tabConfig.Icon or ""
        tabConfig.PremiumOnly = tabConfig.PremiumOnly or false

        local TabBtn = new("TextButton", {
            Parent = TabHolder,
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false
        })
        local TabIcon = new("ImageLabel", {
            Parent = TabBtn,
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(0, 10, 0.5, -9),
            BackgroundTransparency = 1,
            Image = tabConfig.Icon
        })
        local TabTitle = new("TextLabel", {
            Parent = TabBtn,
            Size = UDim2.new(1, -35, 1, 0),
            Position = UDim2.new(0, 35, 0, 0),
            BackgroundTransparency = 1,
            Text = tabConfig.Name,
            Font = Enum.Font.GothamSemibold,
            TextSize = 14,
            TextColor3 = OrionLib.Theme:Get("Text"),
            TextTransparency = 0.4,
            TextXAlignment = Enum.TextXAlignment.Left,
            Name = "Title"
        })

        addTheme(TabIcon, "Text")
        addTheme(TabTitle, "Text")

        local Container = new("ScrollingFrame", {
            Parent = MainWindow,
            Name = "ItemContainer",
            Size = UDim2.new(1, -170, 1, -50),
            Position = UDim2.new(0, 170, 0, 50),
            BackgroundTransparency = 1,
            Visible = false,
            ScrollBarThickness = 6
        })
        Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
        new("UIListLayout", { Parent = Container, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) })
        new("UIPadding", { Parent = Container, PaddingLeft = UDim.new(0, 15), PaddingTop = UDim.new(0, 15), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 15) })

        if firstTab then
            firstTab = false
            TabIcon.ImageTransparency = 0
            TabTitle.TextTransparency = 0
            TabTitle.Font = Enum.Font.GothamBlack
            Container.Visible = true
        end

        TabBtn.MouseButton1Click:Connect(function()
            for _, child in ipairs(TabHolder:GetChildren()) do
                if child:IsA("TextButton") and child ~= TabBtn then
                    local t = child:FindFirstChild("Title")
                    if t then
                        t.Font = Enum.Font.GothamSemibold
                        TweenService:Create(child:FindFirstChildWhichIsA("ImageLabel"), TweenInfo.new(0.25, Enum.EasingStyle.Quint), {ImageTransparency = 0.4}):Play()
                        TweenService:Create(t, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {TextTransparency = 0.4}):Play()
                    end
                end
            end
            for _, c in ipairs(MainWindow:GetChildren()) do
                if c.Name == "ItemContainer" and c ~= Container then
                    c.Visible = false
                end
            end
            TweenService:Create(TabBtn:FindFirstChildWhichIsA("ImageLabel"), TweenInfo.new(0.25, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
            TweenService:Create(TabTitle, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
            TabTitle.Font = Enum.Font.GothamBlack
            Container.Visible = true
        end)

        -- register tab for responsiveness
        WindowAPI:RegisterResponsive("Tabs", TabBtn, {Icon = tabConfig.Icon})

        local function GetElements(ItemParent)
            local ElementFunction = {}

            function ElementFunction:AddLabel(Text)
                local Frame = new("Frame", { Parent = ItemParent, Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 0.7, BorderSizePixel = 0 })
                new("UICorner", { Parent = Frame, CornerRadius = UDim.new(0, 5) })
                local Stroke = new("UIStroke", { Parent = Frame, Thickness = 1 })
                addTheme(Frame, "Second")
                addTheme(Stroke, "Stroke")

                local Label = new("TextLabel", {
                    Parent = Frame,
                    Text = Text or "",
                    Font = Enum.Font.GothamBold,
                    TextSize = 15,
                    TextColor3 = OrionLib.Theme:Get("Text"),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -24, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                addTheme(Label, "Text")

                WindowAPI:RegisterResponsive("Labels", Frame, {})
                return { Set = function(_, v) Label.Text = v end }
            end

            function ElementFunction:AddParagraph(Title, Content)
                Title = Title or "Title"
                Content = Content or "Content"
                local Frame = new("Frame", { Parent = ItemParent, Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 0.7, BorderSizePixel = 0 })
                new("UICorner", { Parent = Frame, CornerRadius = UDim.new(0, 5) })
                local Stroke = new("UIStroke", { Parent = Frame, Thickness = 1 })
                addTheme(Frame, "Second")
                addTheme(Stroke, "Stroke")

                local TitleLbl = new("TextLabel", {
                    Parent = Frame,
                    Text = Title,
                    Font = Enum.Font.GothamBold,
                    TextSize = 15,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 6),
                    Size = UDim2.new(1, -24, 0, 16),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextColor3 = OrionLib.Theme:Get("Text")
                })
                addTheme(TitleLbl, "Text")

                local ContentLabel = new("TextLabel", {
                    Parent = Frame,
                    Text = Content,
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 13,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0, 26),
                    Size = UDim2.new(1, -24, 0, 0),
                    TextWrapped = true,
                    TextColor3 = OrionLib.Theme:Get("TextDark")
                })
                addTheme(ContentLabel, "TextDark")

                ContentLabel:GetPropertyChangedSignal("Text"):Connect(function()
                    ContentLabel.Size = UDim2.new(1, -24, 0, ContentLabel.TextBounds.Y)
                    Frame.Size = UDim2.new(1, 0, 0, ContentLabel.TextBounds.Y + 40)
                end)
                ContentLabel.Text = Content

                WindowAPI:RegisterResponsive("Sections", Frame, {collapseOnCompact = true})
                return { Set = function(_, v) ContentLabel.Text = v end }
            end

            function ElementFunction:AddButton(cfg)
                cfg = cfg or {}
                cfg.Name = cfg.Name or "Button"
                cfg.Callback = cfg.Callback or function() end
                cfg.Icon = cfg.Icon or "rbxassetid://3944703587"

                local Click = new("TextButton", { Parent = ItemParent, Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1, Text = "", AutoButtonColor = false })
                local Frame = new("Frame", { Parent = Click, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0.7, BorderSizePixel = 0 })
                new("UICorner", { Parent = Frame, CornerRadius = UDim.new(0, 6) })
                local Stroke = new("UIStroke", { Parent = Frame, Thickness = 1 })
                addTheme(Frame, "Second")
                addTheme(Stroke, "Stroke")

                local hLayout = new("UIListLayout", { Parent = Frame })
                hLayout.FillDirection = Enum.FillDirection.Horizontal
                hLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                hLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
                hLayout.Padding = UDim.new(0, 10)

                local IconContainer = new("Frame", { Parent = Frame, Name = "IconContainer", Size = UDim2.new(0, 36, 1, 0), BackgroundTransparency = 1 })
                local IconLabel = new("ImageLabel", { Parent = IconContainer, Name = "Icon", Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 8, 0.5, -10), BackgroundTransparency = 1, Image = cfg.Icon })
                local Label = new("TextLabel", { Parent = Frame, Name = "Label", Size = UDim2.new(1, -56, 1, 0), Position = UDim2.new(0, 56, 0, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 15, TextColor3 = OrionLib.Theme:Get("Text"), TextXAlignment = Enum.TextXAlignment.Left, TextScaled = true, Text = cfg.Name })

                addTheme(Label, "Text")
                addTheme(IconLabel, "TextDark")

                Click.MouseEnter:Connect(function()
                    TweenService:Create(Frame, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.6}):Play()
                end)
                Click.MouseLeave:Connect(function()
                    TweenService:Create(Frame, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.7}):Play()
                end)
                Click.MouseButton1Click:Connect(function()
                    pcall(cfg.Callback)
                end)

                -- register for responsiveness and overflow
                WindowAPI:RegisterResponsive("Buttons", Click, {icon = cfg.Icon, callback = cfg.Callback})
                WindowAPI:RegisterOverflowAction(cfg.Icon, cfg.Callback)

                return {
                    SetText = function(_, t) Label.Text = t end,
                    SetCallback = function(_, fn) if type(fn) == "function" then cfg.Callback = fn end end,
                    Instance = Click
                }
            end

            return ElementFunction, ItemParent
        end

        return GetElements(Container), Container
    end

    return WindowAPI
end

return Window
