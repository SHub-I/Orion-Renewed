local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")

local OrionLib = {
	Elements = {},
	ThemeObjects = {},
	Connections = {},
	Flags = {},
	Themes = {
		Default = {
			Main = Color3.fromRGB(25, 25, 25),
			Second = Color3.fromRGB(32, 32, 32),
			Stroke = Color3.fromRGB(60, 60, 60),
			Divider = Color3.fromRGB(60, 60, 60),
			Text = Color3.fromRGB(240, 240, 240),
			TextDark = Color3.fromRGB(150, 150, 150)
		}
	},
	SelectedTheme = "Default",
	Folder = nil,
	SaveCfg = false
}

_G.OrionLib = OrionLib

local suc, Localization, Icons = pcall(function()
    local Localization = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/SHub-I/Orion-Renewed/refs/heads/main/Localization.lua"
    ))()

    local Icons = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/SHub-I/Orion-Renewed/refs/heads/main/Icons.lua"
    ))().icons

    return Localization, Icons
end)

local function GetIcon(name)
    if type(Icons) == "table" and Icons[name] ~= nil then
        local icon = Icons[name]
        if type(icon) == "table" then
            return icon.Image or icon.image or icon.Id or icon.id or name
        end
        return icon
    end
    return name
end

local Orion = Instance.new("ScreenGui")
Orion.Name = "Orion"
if syn and syn.protect_gui then
	syn.protect_gui(Orion)
	Orion.Parent = game.CoreGui
elseif gethui then
	Orion.Parent = gethui()
else
	Orion.Parent = game.CoreGui
end

if gethui then
	for _, Interface in ipairs(gethui():GetChildren()) do
		if Interface.Name == Orion.Name and Interface ~= Orion then
			Interface:Destroy()
		end
	end
else
	for _, Interface in ipairs(game.CoreGui:GetChildren()) do
		if Interface.Name == Orion.Name and Interface ~= Orion then
			Interface:Destroy()
		end
	end
end

function OrionLib:IsRunning()
	if gethui then
		return Orion.Parent == gethui()
	else
		return Orion.Parent == game:GetService("CoreGui")
	end

end

local function AddConnection(Signal, Function)
	if (not OrionLib:IsRunning()) then
		return
	end
	local SignalConnect = Signal:Connect(Function)
	table.insert(OrionLib.Connections, SignalConnect)
	return SignalConnect
end

task.spawn(function()
	while (OrionLib:IsRunning()) do
		wait()
	end

	for _, Connection in next, OrionLib.Connections do
		Connection:Disconnect()
	end
end)

local function AddDraggingFunctionality(DragPoint, Main)
	pcall(function()
		local Dragging, DragInput, MousePos, FramePos = false
		DragPoint.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				Dragging = true
				MousePos = Input.Position
				FramePos = Main.Position

				Input.Changed:Connect(function()
					if Input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
			end
		end)
		DragPoint.InputChanged:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseMovement then
				DragInput = Input
			end
		end)
		UserInputService.InputChanged:Connect(function(Input)
			if Input == DragInput and Dragging then
				local Delta = Input.Position - MousePos
				TweenService:Create(Main, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position  = UDim2.new(FramePos.X.Scale,FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)}):Play()
			end
		end)
	end)
end   

local function Create(Name, Properties, Children)
	local Object = Instance.new(Name)
	for i, v in next, Properties or {} do
		Object[i] = v
	end
	for i, v in next, Children or {} do
		v.Parent = Object
	end
	return Object
end

local function CreateElement(ElementName, ElementFunction)
	OrionLib.Elements[ElementName] = function(...)
		return ElementFunction(...)
	end
end

local function MakeElement(ElementName, ...)
	local NewElement = OrionLib.Elements[ElementName](...)
	return NewElement
end

local function SetProps(Element, Props)
	table.foreach(Props, function(Property, Value)
		Element[Property] = Value
	end)
	return Element
end

local function SetChildren(Element, Children)
	table.foreach(Children, function(_, Child)
		Child.Parent = Element
	end)
	return Element
end

local function Round(Number, Factor)
	local Result = math.floor(Number/Factor + (math.sign(Number) * 0.5)) * Factor
	if Result < 0 then Result = Result + Factor end
	return Result
end

local function ReturnProperty(Object)
	if Object:IsA("Frame") or Object:IsA("TextButton") then
		return "BackgroundColor3"
	end 
	if Object:IsA("ScrollingFrame") then
		return "ScrollBarImageColor3"
	end 
	if Object:IsA("UIStroke") then
		return "Color"
	end 
	if Object:IsA("TextLabel") or Object:IsA("TextBox") then
		return "TextColor3"
	end   
	if Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
		return "ImageColor3"
	end   
end

local function AddThemeObject(Object, Type)
	if not OrionLib.ThemeObjects[Type] then
		OrionLib.ThemeObjects[Type] = {}
	end    
	table.insert(OrionLib.ThemeObjects[Type], Object)
	Object[ReturnProperty(Object)] = OrionLib.Themes[OrionLib.SelectedTheme][Type]
	return Object
end    

local function SetTheme()
	for Name, Type in pairs(OrionLib.ThemeObjects) do
		for _, Object in pairs(Type) do
			Object[ReturnProperty(Object)] = OrionLib.Themes[OrionLib.SelectedTheme][Name]
		end    
	end    
end

local function PackColor(Color)
	return {R = Color.R * 255, G = Color.G * 255, B = Color.B * 255}
end    

local function UnpackColor(Color)
	return Color3.fromRGB(Color.R, Color.G, Color.B)
end

local function LoadCfg(Config)
	local Data = HttpService:JSONDecode(Config)
	table.foreach(Data, function(a,b)
		if OrionLib.Flags[a] then
			spawn(function() 
				if OrionLib.Flags[a].Type == "Colorpicker" then
					OrionLib.Flags[a]:Set(UnpackColor(b))
				else
					OrionLib.Flags[a]:Set(b)
				end    
			end)
		else
			warn("Orion Library Config Loader - Could not find ", a ,b)
		end
	end)
end

local function SaveCfg(Name)
	if not OrionLib.SaveCfg or not OrionLib.Folder or type(writefile) ~= "function" then
		return false
	end

	local Data = {}
	for i,v in pairs(OrionLib.Flags) do
		if v.Save then
			if v.Type == "Colorpicker" then
				Data[i] = PackColor(v.Value)
			else
				Data[i] = v.Value
			end
		end	
	end
	writefile(OrionLib.Folder .. "/" .. Name .. ".txt", tostring(HttpService:JSONEncode(Data)))
	return true
end
-- animatedelement kkl8
local AnimationIndex = 0

local function RegisterAnimatedElement(Element)
	Element:SetAttribute("Animated", true)

	if Element.Parent ~= OrionLib.SearchResultsContainer then
		Element.Visible = false
	end

	Element.BackgroundTransparency = 1

	AddConnection(
		Element:GetPropertyChangedSignal("Parent"),
		function()
			if not Element.Parent then
				return
			end

			if Element.Parent ~= OrionLib.SearchResultsContainer then
				Element.Visible = false
			else
				Element.Visible = true
			end

			Element.BackgroundTransparency = 1
		end
	)

	return Element
end

local WhitelistedMouse = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2,Enum.UserInputType.MouseButton3}
local BlacklistedKeys = {Enum.KeyCode.Unknown,Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,Enum.KeyCode.Up,Enum.KeyCode.Left,Enum.KeyCode.Down,Enum.KeyCode.Right,Enum.KeyCode.Slash,Enum.KeyCode.Tab,Enum.KeyCode.Backspace,Enum.KeyCode.Escape}

local function CheckKey(Table, Key)
	for _, v in next, Table do
		if v == Key then
			return true
		end
	end
end

CreateElement("Corner", function(Scale, Offset)
	local Corner = Create("UICorner", {
		CornerRadius = UDim.new(Scale or 0, Offset or 10)
	})
	return Corner
end)

CreateElement("Stroke", function(Color, Thickness)
	local Stroke = Create("UIStroke", {
		Color = Color or Color3.fromRGB(255, 255, 255),
		Thickness = Thickness or 1
	})
	return Stroke
end)

CreateElement("List", function(Scale, Offset)
	local List = Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(Scale or 0, Offset or 0)
	})
	return List
end)

CreateElement("Padding", function(Bottom, Left, Right, Top)
	local Padding = Create("UIPadding", {
		PaddingBottom = UDim.new(0, Bottom or 4),
		PaddingLeft = UDim.new(0, Left or 4),
		PaddingRight = UDim.new(0, Right or 4),
		PaddingTop = UDim.new(0, Top or 4)
	})
	return Padding
end)

CreateElement("TFrame", function()
	local TFrame = Create("Frame", {
		BackgroundTransparency = 1
	})
	return TFrame
end)

CreateElement("Frame", function(Color)
	local Frame = Create("Frame", {
		BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0
	})
	return Frame
end)

CreateElement("RoundFrame", function(Color, Scale, Offset)
	local Frame = Create("Frame", {
		BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(Scale, Offset)
		})
	})
	return Frame
end)

CreateElement("Button", function()
	local Button = Create("TextButton", {
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	})
	return Button
end)

CreateElement("ScrollFrame", function(Color, Width)
	local ScrollFrame = Create("ScrollingFrame", {
		BackgroundTransparency = 1,
		MidImage = "rbxassetid://7445543667",
		BottomImage = "rbxassetid://7445543667",
		TopImage = "rbxassetid://7445543667",
		ScrollBarImageColor3 = Color,
		BorderSizePixel = 0,
		ScrollBarThickness = Width,
		CanvasSize = UDim2.new(0, 0, 0, 0)
	})
	return ScrollFrame
end)

CreateElement("Image", function(ImageID)
	local ImageNew = Create("ImageLabel", {
		Image = ImageID,
		BackgroundTransparency = 1
	})

	if GetIcon(ImageID) ~= nil then
		ImageNew.Image = GetIcon(ImageID)
	end	

	return ImageNew
end)

CreateElement("ImageButton", function(ImageID)
	local Image = Create("ImageButton", {
		Image = ImageID,
		BackgroundTransparency = 1
	})
	return Image
end)

CreateElement("Label", function(Text, TextSize, Transparency)
	local Label = Create("TextLabel", {
		Text = Text or "",
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = Transparency or 0,
		TextSize = TextSize or 15,
		Font = Enum.Font.Gotham,
		RichText = true,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	return Label
end)

local NotificationHolder = SetProps(SetChildren(MakeElement("TFrame"), {
    SetProps(MakeElement("List"), {
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 6)
    })
}), {
    Name = "Notifications",
    Position = UDim2.new(1, -30, 1, -30),
    Size = UDim2.new(0, 340, 1, -30),
    AnchorPoint = Vector2.new(1, 1),
    Parent = Orion
})

local NotificationTemplate = SetChildren(
    SetProps(
        MakeElement("RoundFrame", Color3.fromRGB(30, 30, 30), 0, 12),
        {
            Name = "Template",
            Visible = false,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -60, 0, 60)
        }
    ),
    {

        Create("ImageLabel", {
            Name = "Shadow",
            BackgroundTransparency = 1,
            Image = "rbxassetid://93536717263986",
            ImageTransparency = 0.8,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(24, 24, 276, 276),
            Size = UDim2.new(1, 50, 1, 50),
            Position = UDim2.new(0, -25, 0, -25),
            ZIndex = 0
        }),

        SetProps(
            MakeElement("Stroke", Color3.fromRGB(255, 255, 255), 1),
            {
                Name = "UIStroke",
                Transparency = 1
            }
        ),

        SetProps(
            MakeElement("Image", "rbxassetid://77891951053543"),
            {
                Name = "Icon",
                BackgroundTransparency = 1,
                ImageTransparency = 1,
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 20, 0.5, 0),
                Size = UDim2.new(0, 32, 0, 32)
            }
        ),

        SetProps(
            MakeElement("Label", "Title", 15),
            {
                Name = "Title",
                BackgroundTransparency = 1,
                TextTransparency = 1,
                Font = Enum.Font.GothamBold,
                Position = UDim2.new(0, 64, 0, 10),
                Size = UDim2.new(1, -78, 0, 18)
            }
        ),

        SetProps(
            MakeElement("Label", "Description", 14),
            {
                Name = "Description",
                BackgroundTransparency = 1,
                TextTransparency = 1,
                Font = Enum.Font.Gotham,
                Position = UDim2.new(0, 64, 0, 30),
                Size = UDim2.new(1, -78, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                TextWrapped = true
            }
        )
    }
)

NotificationTemplate.Parent = NotificationHolder

function OrionLib:MakeNotification(NotificationConfig)
    task.spawn(function()

        NotificationConfig.Name = NotificationConfig.Name or "Notification"
        NotificationConfig.Content = NotificationConfig.Content or "Content"
        NotificationConfig.Image = NotificationConfig.Image or "rbxassetid://4384403532"

        local NotificationParent = SetProps(MakeElement("TFrame"), {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = NotificationHolder
        })

        local NotificationFrame = NotificationTemplate:Clone()
        NotificationFrame.Parent = NotificationParent
        NotificationFrame.Visible = true
        NotificationFrame.Name = NotificationConfig.Name

        NotificationFrame.Title.Text = NotificationConfig.Name
        NotificationFrame.Description.Text = NotificationConfig.Content

        if NotificationConfig.Image then
            NotificationFrame.Icon.Image =
                GetIcon(NotificationConfig.Image)
                or NotificationConfig.Image
        end
        NotificationFrame.Title.TextTransparency = 1
        NotificationFrame.Description.TextTransparency = 1
        NotificationFrame.Icon.ImageTransparency = 1
        NotificationFrame.BackgroundTransparency = 1
        NotificationFrame.UIStroke.Transparency = 1
        NotificationFrame.Shadow.ImageTransparency = 0.8

        task.wait()

        local Bounds = {
            NotificationFrame.Title.TextBounds.Y,
            NotificationFrame.Description.TextBounds.Y
        }

        NotificationFrame.Size = UDim2.new(
            1,
            0,
            0,
            0
        )

        NotificationFrame.Icon.Size = UDim2.new(0, 32, 0, 32)
        NotificationFrame.Icon.Position = UDim2.new(0, 20, 0.5, 0)

        TweenService:Create(
            NotificationFrame,
            TweenInfo.new(0.6, Enum.EasingStyle.Exponential),
            {
                Size = UDim2.new(
                    1,
                    0,
                    0,
                    math.max(Bounds[1] + Bounds[2] + 31, 60)
                )
            }
        ):Play()

        task.wait(0.15)

        TweenService:Create(
            NotificationFrame,
            TweenInfo.new(0.4, Enum.EasingStyle.Exponential),
            {
                BackgroundTransparency = 0.45
            }
        ):Play()

        TweenService:Create(
            NotificationFrame.Title,
            TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
            {
                TextTransparency = 0
            }
        ):Play()

        task.wait(0.05)

        TweenService:Create(
            NotificationFrame.Icon,
            TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
            {
                ImageTransparency = 0
            }
        ):Play()

        task.wait(0.05)

        TweenService:Create(
            NotificationFrame.Description,
            TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
            {
                TextTransparency = 0.35
            }
        ):Play()

        TweenService:Create(
            NotificationFrame.UIStroke,
            TweenInfo.new(0.4, Enum.EasingStyle.Exponential),
            {
                Transparency = 0.95
            }
        ):Play()

        TweenService:Create(
            NotificationFrame.Shadow,
            TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
            {
                ImageTransparency = 0.90
            }
        ):Play()

        local WaitDuration = math.min(
            math.max((#NotificationFrame.Description.Text * 0.1) + 2.5, 3),
            10
        )

        task.wait(NotificationConfig.Time or WaitDuration)

        NotificationFrame.Icon.Visible = false

        TweenService:Create(
            NotificationFrame,
            TweenInfo.new(0.4, Enum.EasingStyle.Exponential),
            {
                BackgroundTransparency = 1
            }
        ):Play()

        TweenService:Create(
            NotificationFrame.UIStroke,
            TweenInfo.new(0.4, Enum.EasingStyle.Exponential),
            {
                Transparency = 1
            }
        ):Play()

        TweenService:Create(
            NotificationFrame.Shadow,
            TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
            {
                ImageTransparency = 1
            }
        ):Play()

        TweenService:Create(
            NotificationFrame.Title,
            TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
            {
                TextTransparency = 1
            }
        ):Play()

        TweenService:Create(
            NotificationFrame.Description,
            TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
            {
                TextTransparency = 1
            }
        ):Play()

        TweenService:Create(
            NotificationFrame,
            TweenInfo.new(1, Enum.EasingStyle.Exponential),
            {
                Size = UDim2.new(1, -90, 0, 0)
            }
        ):Play()

        task.wait(1)

        NotificationParent:Destroy()

    end)
end

function OrionLib:Init()
    if OrionLib.SaveCfg then    
        pcall(function()
            if isfile(OrionLib.Folder .. "/" .. game.GameId .. ".txt") then
                LoadCfg(readfile(OrionLib.Folder .. "/" .. game.GameId .. ".txt"))
                OrionLib:MakeNotification({
                    Name = "Configuration",
                    Content = "Auto-loaded configuration for the game " .. game.GameId .. ".",
                    Time = 5
                })
            end
        end)        
    end 
end



---------------------------------------------------------------------
-- ORION FILE-BASED THEME SYSTEM
---------------------------------------------------------------------

local HttpService = game:GetService("HttpService")

local THEME_FOLDER = "OrionThemes"

if type(isfolder) == "function" and type(makefolder) == "function" then
    if not isfolder(THEME_FOLDER) then
        makefolder(THEME_FOLDER)
    end
end

---------------------------------------------------------------------
-- COLOR UTILS
---------------------------------------------------------------------

local function HexToColor3(hex)
    hex = tostring(hex):gsub("#", "")

    if #hex ~= 6 then
        return Color3.new(1, 1, 1)
    end

    return Color3.fromRGB(
        tonumber(hex:sub(1, 2), 16) or 255,
        tonumber(hex:sub(3, 4), 16) or 255,
        tonumber(hex:sub(5, 6), 16) or 255
    )
end

local function Color3ToHex(col)
    return string.format(
        "#%02X%02X%02X",
        math.round(col.R * 255),
        math.round(col.G * 255),
        math.round(col.B * 255)
    )
end

---------------------------------------------------------------------
-- THEME STORAGE
---------------------------------------------------------------------

OrionLib.Themes = {
    Default = {
        Main = Color3.fromRGB(25,25,25),
        Second = Color3.fromRGB(32,32,32),
        Stroke = Color3.fromRGB(60,60,60),
        Divider = Color3.fromRGB(60,60,60),
        Text = Color3.fromRGB(240,240,240),
        TextDark = Color3.fromRGB(150,150,150)
    }
}

OrionLib.SelectedTheme = "Default"
OrionLib.ThemeObjects = OrionLib.ThemeObjects or {}

---------------------------------------------------------------------
-- REGISTER THEME OBJECT
---------------------------------------------------------------------

function OrionLib:AddThemeObject(obj, key)
    if not obj then
        return nil
    end

    OrionLib.ThemeObjects[key] =
        OrionLib.ThemeObjects[key] or {}

    table.insert(
        OrionLib.ThemeObjects[key],
        obj
    )

    local prop = ReturnProperty(obj)

    local theme =
        OrionLib.Themes[OrionLib.SelectedTheme]

    if prop and theme and theme[key] then
        obj[prop] = theme[key]
    end

    return obj
end

---------------------------------------------------------------------
-- APPLY THEME
---------------------------------------------------------------------

function OrionLib:ApplyTheme()

    pcall(function()
        OrionLib:UpdateGlobalSearch()
    end)

    local theme =
        OrionLib.Themes[OrionLib.SelectedTheme]

    if not theme then
        return
    end

    for key, objects in pairs(OrionLib.ThemeObjects) do

        local color = theme[key]

        if color then

            for i = #objects, 1, -1 do

                local obj = objects[i]

                if not obj or obj.Parent == nil then
                    table.remove(objects, i)
                else
                    local prop = ReturnProperty(obj)

                    if prop then
                        obj[prop] = color
                    end
                end

            end

        end

    end
end

---------------------------------------------------------------------
-- SAVE THEME FILE
---------------------------------------------------------------------

function OrionLib:SaveThemeFile(name)

    local theme =
        OrionLib.Themes[OrionLib.SelectedTheme]

    if not theme then
        return false
    end

    local data = {}

    for key, color in pairs(theme) do
        data[key] = Color3ToHex(color)
    end

    writefile(
        THEME_FOLDER .. "/orion-r_theme_" .. name .. ".json",
        HttpService:JSONEncode(data)
    )

    return true
end

---------------------------------------------------------------------
-- LOAD THEME FILE
---------------------------------------------------------------------

function OrionLib:LoadThemeFile(name)

    local path =
        THEME_FOLDER .. "/orion-r_theme_" .. name .. ".json"

    if not isfile(path) then
        return false
    end

    local success, data = pcall(function()
        return HttpService:JSONDecode(
            readfile(path)
        )
    end)

    if not success then
        warn("Orion Theme Loader: Invalid theme file")
        return false
    end

    local theme =
        OrionLib.Themes[OrionLib.SelectedTheme]

    for key, value in pairs(data) do
        theme[key] = HexToColor3(value)
    end

    OrionLib:ApplyTheme()

    return true
end

---------------------------------------------------------------------
-- DELETE THEME FILE
---------------------------------------------------------------------

function OrionLib:DeleteThemeFile(name)

    local path =
        THEME_FOLDER .. "/orion-r_theme_" .. name .. ".json"

    if isfile(path) then
        delfile(path)
        return true
    end

    return false
end
---------------------------------------------------------------------
-- AUTO-CREATE THEME FOLDER ON EXECUTION
---------------------------------------------------------------------

if type(isfolder) == "function" and type(makefolder) == "function" then
    if not isfolder("OrionThemes") then
        makefolder("OrionThemes")
    end
end

---------------------------------------------------------------------
-- BLIZT GLOBAL SEARCH (GUI + LOGIC)
---------------------------------------------------------------------

OrionLib.GlobalSearch = nil
OrionLib.SearchTargets = {}
OrionLib.TabRegistry = {}
OrionLib.SearchIndex = {}
OrionLib.SearchResultsContainer = nil

function OrionLib:RegisterSearchTarget(container)
    table.insert(OrionLib.SearchTargets, container)
end

function OrionLib:CreateGlobalSearch(parent)
    local GS = Instance.new("TextBox")
    GS.Name = "GlobalSearch"
    GS.PlaceholderText = "Search..."
    GS.Text = ""
    GS.ClearTextOnFocus = false
    GS.Size = UDim2.new(1, -20, 0, 32)
    GS.Position = UDim2.new(0, 10, 0, 10)
    GS.TextColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Text
    GS.TextSize = 14
    GS.Font = Enum.Font.Gotham
    GS.BorderSizePixel = 0
    GS.TextXAlignment = Enum.TextXAlignment.Left
    GS.BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Main
    GS.Parent = parent

    SetChildren(GS, {
        MakeElement("Padding", 0, 10, 0, 0),
        MakeElement("Corner", 0.35, 0)
    })

    local Icon = Instance.new("ImageLabel")
    Icon.Image = "rbxassetid://7072717695"
    Icon.ImageColor3 = Color3.fromRGB(200, 200, 200)
    Icon.BackgroundTransparency = 1
    Icon.AnchorPoint = Vector2.new(1, 0.5)
    Icon.Position = UDim2.new(1, -6, 0.5, 0)
    Icon.Size = UDim2.new(0, 18, 0, 18)
    Icon.Parent = GS

    OrionLib.GlobalSearch = GS
    return GS
end

function OrionLib:UpdateGlobalSearch()
    if not OrionLib.GlobalSearch then return end
    local theme = OrionLib.Themes[OrionLib.SelectedTheme]
    OrionLib.GlobalSearch.PlaceholderColor3 = theme.Text
    OrionLib.GlobalSearch.TextColor3 = theme.Text
    OrionLib.GlobalSearch.BackgroundColor3 = theme.Main
end

local function GetSearchText(obj)
    local parts = {}

    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
        table.insert(parts, obj.Text or "")
    end

    for _, descendant in ipairs(obj:GetDescendants()) do
        if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
            table.insert(parts, descendant.Text or "")
        end
    end

    return string.lower(table.concat(parts, " "))
end

local function FilterContainer(container, query)
	if not container or not container.Parent then
		return false
	end

	query = string.lower(tostring(query or ""))

	local found = false

	for _, obj in ipairs(container:GetChildren()) do
		if not obj:IsA("UIListLayout") and not obj:IsA("UIPadding") then
			local match = query == "" or GetSearchText(obj):find(query, 1, true) ~= nil

			if obj:IsA("GuiObject") then
				obj.Visible = match
			end

			if match then
				found = true
			end
		end
	end

	return found
end

function OrionLib:EnableGlobalSearch()
	if not OrionLib.GlobalSearch then
		return
	end

	if OrionLib.GlobalSearchConnection then
		OrionLib.GlobalSearchConnection:Disconnect()
		OrionLib.GlobalSearchConnection = nil
	end

	OrionLib.GlobalSearchConnection = AddConnection(
		OrionLib.GlobalSearch:GetPropertyChangedSignal("Text"),
		function()
			local query =
				string.lower(
					OrionLib.GlobalSearch.Text or ""
				)

			if query == "" then
				for _, tab in pairs(OrionLib.TabRegistry) do
					tab.TabButton.Visible = true
					tab.Container.Visible = false
				end

				if OrionLib.SearchResultsContainer then
					OrionLib.SearchResultsContainer.Visible = false

					for _, child in ipairs(
						OrionLib.SearchResultsContainer:GetChildren()
					) do
						if not child:IsA("UIListLayout")
						and not child:IsA("UIPadding") then
							child:Destroy()
						end
					end
				end

				if OrionLib.TabRegistry[1] then
					OrionLib.TabRegistry[1].Container.Visible = true
				end

				return
			end

			local totalMatches = 0

			for _, tab in pairs(OrionLib.TabRegistry) do
				local matched = false

				for _, entry in ipairs(OrionLib.SearchIndex) do
					if entry.Tab == tab.Name then
						local searchText = string.lower(
							(entry.Name or "") ..
							" " ..
							(entry.Tab or "")
						)

						if searchText:find(query, 1, true) then
							matched = true
							break
						end
					end
				end

				tab.TabButton.Visible = matched

				if matched then
					totalMatches += 1
				end
			end

			if OrionLib.SearchResultsContainer then

				for _, child in ipairs(
					OrionLib.SearchResultsContainer:GetChildren()
				) do
					if not child:IsA("UIListLayout")
					and not child:IsA("UIPadding") then
						child:Destroy()
					end
				end

				for _, tab in pairs(OrionLib.TabRegistry) do
					tab.Container.Visible = false
				end

				for _, entry in ipairs(OrionLib.SearchIndex) do
					local searchText = string.lower(
						(entry.Name or "") ..
						" " ..
						(entry.Tab or "")
					)

					if searchText:find(query, 1, true) then
						if entry.Create then
							pcall(function()
								entry.Create(
									OrionLib.SearchResultsContainer
								)

								for _, child in ipairs(
									OrionLib.SearchResultsContainer:GetChildren()
								) do
									if child:IsA("GuiObject") then
										child.Visible = true
									end
								end
							end)
						end
					end
				end

				OrionLib.SearchResultsContainer.Visible = true
			end

			if totalMatches == 0 then
				for _, tab in pairs(OrionLib.TabRegistry) do
					tab.TabButton.Visible = true
				end
			end
		end
	)
end

function OrionLib:MakeWindow(WindowConfig)
	local FirstTab = true
	local Minimized = false
	local Loaded = false
	local UIHidden = false

	WindowConfig = WindowConfig or {}
	WindowConfig.Name = WindowConfig.Name or "Orion Library"
	WindowConfig.ConfigFolder = WindowConfig.ConfigFolder or WindowConfig.Name
	WindowConfig.SaveConfig = WindowConfig.SaveConfig or false
	WindowConfig.HidePremium = WindowConfig.HidePremium or false
	if WindowConfig.IntroEnabled == nil then
		WindowConfig.IntroEnabled = true
	end
	WindowConfig.IntroText = WindowConfig.IntroText or "Orion Library"
	WindowConfig.CloseCallback = WindowConfig.CloseCallback or function() end
	WindowConfig.ShowIcon = WindowConfig.ShowIcon or false
	WindowConfig.Icon = WindowConfig.Icon or "rbxassetid://8834748103"
	WindowConfig.IntroIcon = WindowConfig.IntroIcon or "rbxassetid://8834748103"
	OrionLib.Folder = WindowConfig.ConfigFolder
	OrionLib.SaveCfg = WindowConfig.SaveConfig



	if WindowConfig.SaveConfig and type(isfolder) == "function" and type(makefolder) == "function" then
		if not isfolder(WindowConfig.ConfigFolder) then
			makefolder(WindowConfig.ConfigFolder)
		end
	end

	local TabHolder = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 4), {
        Size = UDim2.new(1, 0, 1, -95),
        Position = UDim2.new(0, 0, 0, 45)
    }), {
        MakeElement("List"),
        MakeElement("Padding", 8, 0, 0, 8)
    }), "Divider")

    AddConnection(TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        TabHolder.CanvasSize = UDim2.new(0, 0, 0, TabHolder.UIListLayout.AbsoluteContentSize.Y + 16)
    end)

    local CloseBtn = SetChildren(SetProps(MakeElement("Button"), {
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
        BackgroundTransparency = 1
    }), {
        AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072725342"), {
            Position = UDim2.new(0, 9, 0, 6),
            Size = UDim2.new(0, 18, 0, 18)
        }), "Text")
    })

    local MinimizeBtn = SetChildren(SetProps(MakeElement("Button"), {
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundTransparency = 1
    }), {
        AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072719338"), {
            Position = UDim2.new(0, 9, 0, 6),
            Size = UDim2.new(0, 18, 0, 18),
            Name = "Ico"
        }), "Text")
    })

    local DragPoint = SetProps(MakeElement("TFrame"), {
        Size = UDim2.new(1, 0, 0, 50)
    })

    local WindowStuff = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 10), {
        Size = UDim2.new(0, 150, 1, -50),
        Position = UDim2.new(0, 0, 0, 50)
    }), {
        AddThemeObject(SetProps(MakeElement("Frame"), {
            Size = UDim2.new(1, 0, 0, 10),
            Position = UDim2.new(0, 0, 0, 0)
        }), "Second"),
        AddThemeObject(SetProps(MakeElement("Frame"), {
            Size = UDim2.new(0, 10, 1, 0),
            Position = UDim2.new(1, -10, 0, 0)
        }), "Second"),
        AddThemeObject(SetProps(MakeElement("Frame"), {
            Size = UDim2.new(0, 1, 1, 0),
            Position = UDim2.new(1, -1, 0, 0)
        }), "Stroke"),
        TabHolder,
        SetChildren(SetProps(MakeElement("TFrame"), {
            Size = UDim2.new(1, 0, 0, 50),
            Position = UDim2.new(0, 0, 1, -50)
        }), {
            AddThemeObject(SetProps(MakeElement("Frame"), {
                Size = UDim2.new(1, 0, 0, 1)
            }), "Stroke"),
            AddThemeObject(SetChildren(SetProps(MakeElement("Frame"), {
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0, 32, 0, 32),
                Position = UDim2.new(0, 10, 0.5, 0)
            }), {
                SetProps(MakeElement("Image", "https://www.roblox.com/headshot-thumbnail/image?userId=".. LocalPlayer.UserId .."&width=420&height=420&format=png"), {
                    Size = UDim2.new(1, 0, 1, 0)
                }),
                AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://4031889928"), {
                    Size = UDim2.new(1, 0, 1, 0)
                }), "Second"),
                MakeElement("Corner", 1)
            }), "Divider"),
            SetChildren(SetProps(MakeElement("TFrame"), {
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0, 32, 0, 32),
                Position = UDim2.new(0, 10, 0.5, 0)
            }), {
                AddThemeObject(MakeElement("Stroke"), "Stroke"),
                MakeElement("Corner", 1)
            }),
            AddThemeObject(SetProps(MakeElement("Label", LocalPlayer.DisplayName, WindowConfig.HidePremium and 14 or 13), {
                Size = UDim2.new(1, -60, 0, 13),
                Position = WindowConfig.HidePremium and UDim2.new(0, 50, 0, 19) or UDim2.new(0, 50, 0, 12),
                Font = Enum.Font.GothamBold,
                ClipsDescendants = true
            }), "Text"),
            AddThemeObject(SetProps(MakeElement("Label", "", 12), {
                Size = UDim2.new(1, -60, 0, 12),
                Position = UDim2.new(0, 50, 1, -25),
                Visible = not WindowConfig.HidePremium
            }), "TextDark")
        })
    }), "Second")


    local WindowName = AddThemeObject(SetProps(MakeElement("Label", WindowConfig.Name, 14), {
        Size = UDim2.new(1, -30, 2, 0),
        Position = UDim2.new(0, 25, 0, -24),
        Font = Enum.Font.FredokaOne,
        TextSize = 20
    }), "Text")

    
	
	local GlobalSearch = OrionLib:CreateGlobalSearch(WindowStuff)
	GlobalSearch.Size = UDim2.new(1, -20, 0, 32)
	GlobalSearch.Position = UDim2.new(0, 10, 0, 10)

    local WindowTopBarLine = AddThemeObject(SetProps(MakeElement("Frame"), {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1)
    }), "Stroke")

    local MainWindow = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 10), {
        Parent = Orion,
        Position = UDim2.new(0.5, -307, 0.5, -172),
        Size = UDim2.new(0, 615, 0, 344),
        ClipsDescendants = true
    }), {
        SetChildren(SetProps(MakeElement("TFrame"), {
            Size = UDim2.new(1, 0, 0, 50),
            Name = "TopBar"
        }), {
            WindowName,
            WindowTopBarLine,
            AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 7), {
                Size = UDim2.new(0, 70, 0, 30),
                Position = UDim2.new(1, -90, 0, 10)
            }), {
                AddThemeObject(MakeElement("Stroke"), "Stroke"),
                AddThemeObject(SetProps(MakeElement("Frame"), {
                    Size = UDim2.new(0, 1, 1, 0),
                    Position = UDim2.new(0.5, 0, 0, 0)
                }), "Stroke"),
                CloseBtn,
                MinimizeBtn
            }), "Second")
        }),
        DragPoint,
        WindowStuff
    }), "Main")

	local SearchResultsContainer = AddThemeObject(
		SetChildren(
			SetProps(
				MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 5),
				{
					Size = UDim2.new(1, -150, 1, -50),
					Position = UDim2.new(0, 150, 0, 50),
					Parent = MainWindow,
					Visible = false,
					Name = "SearchResults"
				}
			),
			{
				MakeElement("List", 0, 6),
				MakeElement("Padding", 15, 10, 10, 15)
			}
		),
		"Divider"
	)

	OrionLib.SearchResultsContainer = SearchResultsContainer

	AddConnection(SearchResultsContainer.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		SearchResultsContainer.CanvasSize = UDim2.new(
			0,
			0,
			0,
			SearchResultsContainer.UIListLayout.AbsoluteContentSize.Y + 30
		)
	end)

---------------------------------------------------------------------
-- ReScale (Bottom-right resize handle)
---------------------------------------------------------------------

	local DEFAULT_WINDOW_SIZE = UDim2.new(0, 615, 0, 344)
	local lastExpandedSize = MainWindow.Size

	local resizing = false
	local resizeStartPos
	local resizeStartSize

	local ResizeHandle = Create("Frame", {
		Parent = MainWindow,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -8, 1, -8),
		Size = UDim2.new(0, 18, 0, 18),
		BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second,
		BorderSizePixel = 0,
		Name = "ResizeHandle",
		ZIndex = 20
	})

	MakeElement("Corner", 0, 6).Parent = ResizeHandle
	AddThemeObject(ResizeHandle, "Second")

	local ResizeIcon = MakeElement("Image", "arrow-down-right")
	ResizeIcon.Parent = ResizeHandle
	ResizeIcon.Size = UDim2.new(0, 14, 0, 14)
	ResizeIcon.Position = UDim2.new(0.5, -7, 0.5, -7)
	ResizeIcon.ImageTransparency = 0.25
	ResizeIcon.ImageColor3 = OrionLib.Themes[OrionLib.SelectedTheme].TextDark
	ResizeIcon.ZIndex = 21

	AddConnection(ResizeHandle.InputBegan, function(input)
		if Minimized then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = true
			resizeStartPos = UserInputService:GetMouseLocation()
			resizeStartSize = MainWindow.AbsoluteSize

			TweenService:Create(
				ResizeIcon,
				TweenInfo.new(0.15, Enum.EasingStyle.Quad),
				{
					ImageTransparency = 0
				}
			):Play()

		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			lastExpandedSize = DEFAULT_WINDOW_SIZE

			TweenService:Create(
				MainWindow,
				TweenInfo.new(
					0.35,
					Enum.EasingStyle.Quint,
					Enum.EasingDirection.Out
				),
				{
					Size = DEFAULT_WINDOW_SIZE
				}
			):Play()
		end
	end)

	AddConnection(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and resizing then
			resizing = false
			lastExpandedSize = MainWindow.Size

			TweenService:Create(
				ResizeIcon,
				TweenInfo.new(
					0.25,
					Enum.EasingStyle.Quad
				),
				{
					ImageTransparency = 0.25
				}
			):Play()
		end
	end)

	AddConnection(RunService.RenderStepped, function()
		if not resizing then
			return
		end

		local mousePos = UserInputService:GetMouseLocation()
		local delta = mousePos - resizeStartPos

		local newW = math.clamp(
			resizeStartSize.X + delta.X,
			350,
			1200
		)

		local newH = math.clamp(
			resizeStartSize.Y + delta.Y,
			200,
			900
		)

		MainWindow.Size = UDim2.fromOffset(
			newW,
			newH
		)

		lastExpandedSize = MainWindow.Size
	end)


	if WindowConfig.ShowIcon then
		WindowName.Position = UDim2.new(0, 50, 0, -24)
		local WindowIcon = SetProps(MakeElement("Image", WindowConfig.Icon), {
			Size = UDim2.new(0, 20, 0, 20),
			Position = UDim2.new(0, 25, 0, 15)
		})
		WindowIcon.Parent = MainWindow.TopBar
	end	

	AddDraggingFunctionality(DragPoint, MainWindow)

	AddConnection(CloseBtn.MouseButton1Up, function()
		MainWindow.Visible = false
		UIHidden = true
	    OrionLib:MakeNotification({
		    Name = "Interface Hidden",
		    Content = "Press " .. WindowConfig.ToggleUIButton.Name .. " to reopen the interface",
		    Time = 5
	    })
		WindowConfig.CloseCallback()
	end)

AddConnection(UserInputService.InputBegan, function(Input, Processed)
	if Processed then
		return
	end

	if Input.KeyCode == WindowConfig.ToggleUIButton then
		UIHidden = not UIHidden
		MainWindow.Visible = not UIHidden

		if UIHidden then
			if WindowConfig.UnlockMouse then
				UserInputService.MouseIconEnabled = true
			end

			OrionLib:MakeNotification({
				Name = "Interface Hidden",
				Content = "Press " .. WindowConfig.ToggleUIButton.Name .. " to reopen the interface",
				Time = 5
			})
		end
	end
end)

	AddConnection(MinimizeBtn.MouseButton1Up, function()
		if Minimized then
			TweenService:Create(MainWindow, TweenInfo.new(0.65, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {Size = lastExpandedSize}):Play()
			MinimizeBtn.Ico.Image = "rbxassetid://7072719338"
			wait(0.4)
			MainWindow.ClipsDescendants = false
			WindowStuff.Visible = true
			WindowTopBarLine.Visible = true
			-- SHOW RESIZE HANDLE
        	ResizeHandle.Visible = true
		else
			MainWindow.ClipsDescendants = true
			WindowTopBarLine.Visible = false
			MinimizeBtn.Ico.Image = "rbxassetid://7072720870"

			-- HIDE RESIZE HANDLE
        	ResizeHandle.Visible = false

			TweenService:Create(MainWindow, TweenInfo.new(0.65, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {Size = UDim2.new(0, WindowName.TextBounds.X + 140, 0, 50)}):Play()
			wait(0.3)
			WindowStuff.Visible = false	
		end
		Minimized = not Minimized    
	end)

	local function LoadSequence()
		MainWindow.Visible = false
		local LoadSequenceLogo = SetProps(MakeElement("Image", WindowConfig.IntroIcon), {
			Parent = Orion,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.4, 0),
			Size = UDim2.new(0, 28, 0, 28),
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			ImageTransparency = 1
		})

		local LoadSequenceText = SetProps(MakeElement("Label", WindowConfig.IntroText, 14), {
			Parent = Orion,
			Size = UDim2.new(1, 0, 1, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 19, 0.5, 0),
			TextXAlignment = Enum.TextXAlignment.Center,
			Font = Enum.Font.GothamBold,
			TextTransparency = 1
		})

		TweenService:Create(LoadSequenceLogo, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
		wait(0.8)
		TweenService:Create(LoadSequenceLogo, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -(LoadSequenceText.TextBounds.X/2), 0.5, 0)}):Play()
		wait(0.3)
		TweenService:Create(LoadSequenceText, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
		wait(2)
		TweenService:Create(LoadSequenceText, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
		MainWindow.Visible = true
		LoadSequenceLogo:Destroy()
		LoadSequenceText:Destroy()
	end 

	if WindowConfig.IntroEnabled then
		LoadSequence()
	end	

	local TabFunction = {}
    function TabFunction:MakeTab(TabConfig)
        TabConfig = TabConfig or {}
        TabConfig.Name = TabConfig.Name or "Tab"
        TabConfig.Icon = TabConfig.Icon or ""
        TabConfig.PremiumOnly = TabConfig.PremiumOnly or false

        local TabFrame = SetChildren(SetProps(MakeElement("Button"), {
            Size = UDim2.new(1, 0, 0, 30),
            Parent = TabHolder
        }), {
            AddThemeObject(SetProps(MakeElement("Image", TabConfig.Icon), {
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(0, 10, 0.5, 0),
                ImageTransparency = 0.4,
                Name = "Ico"
            }), "Text"),
            AddThemeObject(SetProps(MakeElement("Label", TabConfig.Name, 14), {
                Size = UDim2.new(1, -35, 1, 0),
                Position = UDim2.new(0, 35, 0, 0),
                Font = Enum.Font.GothamSemibold,
                TextTransparency = 0.4,
                Name = "Title"
            }), "Text")
        })
		local TabIndex = #OrionLib.TabRegistry + 1

		if not FirstTab then
			TabFrame.Ico.ImageTransparency = 1
			TabFrame.Title.TextTransparency = 1

			task.spawn(function()
				task.wait((TabIndex - 1) * 0.2)

				TweenService:Create(
					TabFrame.Title,
					TweenInfo.new(
						0.25,
						Enum.EasingStyle.Exponential,
						Enum.EasingDirection.Out
					),
					{
						TextTransparency = 0.4
					}
				):Play()

				task.wait(0.4)

				TweenService:Create(
					TabFrame.Ico,
					TweenInfo.new(
						0.65,
						Enum.EasingStyle.Exponential,
						Enum.EasingDirection.Out
					),
					{
						ImageTransparency = 0.4
					}
				):Play()
			end)
		end


        if GetIcon(TabConfig.Icon) ~= nil then
            TabFrame.Ico.Image = GetIcon(TabConfig.Icon)
        end 

		local Container = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 5), {
			Size = UDim2.new(1, -150, 1, -50),
			Position = UDim2.new(0, 150, 0, 50),
			Parent = MainWindow,
			Visible = false,
			Name = "ItemContainer"
		}), {
			MakeElement("List", 0, 6),
			MakeElement("Padding", 15, 10, 10, 15)
		}), "Divider")

		OrionLib:RegisterSearchTarget(Container)

		table.insert(OrionLib.TabRegistry, {
			TabButton = TabFrame,
			Container = Container,
			Name = TabConfig.Name
		})

        AddConnection(Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
            Container.CanvasSize = UDim2.new(0, 0, 0, Container.UIListLayout.AbsoluteContentSize.Y + 30)
        end)

        if FirstTab then
            FirstTab = false
            TabFrame.Ico.ImageTransparency = 0
            TabFrame.Title.TextTransparency = 0
            TabFrame.Title.Font = Enum.Font.GothamBlack
            Container.Visible = true
        end    

        AddConnection(TabFrame.MouseButton1Click, function()
            if OrionLib.SearchResultsContainer then
                OrionLib.SearchResultsContainer.Visible = false
            end

            for _, Tab in next, TabHolder:GetChildren() do
                if Tab:IsA("TextButton") then
                    Tab.Title.Font = Enum.Font.GothamSemibold

                    TweenService:Create(
                        Tab.Title,
                        TweenInfo.new(
                            0.4,
                            Enum.EasingStyle.Exponential,
                            Enum.EasingDirection.Out
                        ),
                        {
                            Position = UDim2.new(0, 35, 0, 0),
                            TextTransparency = 0.4
                        }
                    ):Play()

                    TweenService:Create(
                        Tab.Ico,
                        TweenInfo.new(
                            0.25,
                            Enum.EasingStyle.Exponential,
                            Enum.EasingDirection.Out
                        ),
                        {
                            ImageTransparency = 0.4
                        }
                    ):Play()
                end
            end

            for _, ItemContainer in next, MainWindow:GetChildren() do
                if ItemContainer.Name == "ItemContainer" then
                    ItemContainer.Visible = false

                    for _, Child in ipairs(ItemContainer:GetChildren()) do
                        if Child:GetAttribute("Animated") then
                            Child.Visible = false
                        end
                    end
                end
            end

            Container.Visible = true

            AnimationIndex = 0

            for _, Child in ipairs(Container:GetChildren()) do
                if Child:GetAttribute("Animated") then
                    AnimationIndex += 1

                    task.delay(AnimationIndex * 0.06, function()
                        if Child and Child.Parent then
                            Child.Visible = true
                            Child.BackgroundTransparency = 1

                            TweenService:Create(
                                Child,
                                TweenInfo.new(
                                    0.35,
                                    Enum.EasingStyle.Exponential,
                                    Enum.EasingDirection.Out
                                ),
                                {
                                    BackgroundTransparency = 0
                                }
                            ):Play()
                        end
                    end)
                end
            end
-- tab anims kkj8

            TabFrame.Ico.ImageTransparency = 0
            TabFrame.Title.TextTransparency = 0
            TabFrame.Title.Font = Enum.Font.GothamBlack

            TweenService:Create(
                TabFrame.Title,
                TweenInfo.new(
                    0.5,
                    Enum.EasingStyle.Exponential,
                    Enum.EasingDirection.Out
                ),
                {
                    Position = UDim2.new(0, 40, 0, 0),
                    TextTransparency = 0
                }
            ):Play()

            TweenService:Create(
                TabFrame.Ico,
                TweenInfo.new(
                    0.25,
                    Enum.EasingStyle.Exponential,
                    Enum.EasingDirection.Out
                ),
                {
                    ImageTransparency = 0
                }
            ):Play()

            Container.Visible = true
        end)


		local function GetElements(ItemParent)
			local ElementFunction = {}
			function ElementFunction:AddLabel(Text)
				local LabelFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundTransparency = 0.7,
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", Text, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke")
				}), "Second")

				local LabelFunction = {}
				function LabelFunction:Set(ToChange)
					LabelFrame.Content.Text = ToChange
				end
				return LabelFunction
			end
			function ElementFunction:AddParagraph(Text, Content)
				Text = Text or "Text"
				Content = Content or "Content"

				local ParagraphFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundTransparency = 0.7,
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", Text, 15), {
						Size = UDim2.new(1, -12, 0, 14),
						Position = UDim2.new(0, 12, 0, 10),
						Font = Enum.Font.GothamBold,
						Name = "Title"
					}), "Text"),
					AddThemeObject(SetProps(MakeElement("Label", "", 13), {
						Size = UDim2.new(1, -24, 0, 0),
						Position = UDim2.new(0, 12, 0, 26),
						Font = Enum.Font.GothamSemibold,
						Name = "Content",
						TextWrapped = true
					}), "TextDark"),
					AddThemeObject(MakeElement("Stroke"), "Stroke")
				}), "Second")
                RegisterAnimatedElement(ParagraphFrame)

				AddConnection(ParagraphFrame.Content:GetPropertyChangedSignal("Text"), function()
					ParagraphFrame.Content.Size = UDim2.new(1, -24, 0, ParagraphFrame.Content.TextBounds.Y)
					ParagraphFrame.Size = UDim2.new(1, 0, 0, ParagraphFrame.Content.TextBounds.Y + 35)
				end)

				ParagraphFrame.Content.Text = Content

				local ParagraphFunction = {}
				function ParagraphFunction:Set(ToChange)
					ParagraphFrame.Content.Text = ToChange
				end
				return ParagraphFunction
			end    
			function ElementFunction:AddButton(ButtonConfig)
				ButtonConfig = ButtonConfig or {}
				ButtonConfig.Name = ButtonConfig.Name or "Button"
				ButtonConfig.Callback = ButtonConfig.Callback or function() end
				ButtonConfig.Icon = ButtonConfig.Icon or "rbxassetid://3944703587"

				local Button = {}

				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})


                local ButtonFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 33),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", ButtonConfig.Name, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(SetProps(MakeElement("Image", ButtonConfig.Icon), {
						Size = UDim2.new(0, 20, 0, 20),
						Position = UDim2.new(1, -30, 0, 7),
					}), "TextDark"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					Click
				}), "Second")

                RegisterAnimatedElement(ButtonFrame)

				if ItemParent ~= OrionLib.SearchResultsContainer
				and ItemParent.Parent ~= OrionLib.SearchResultsContainer then
					table.insert(OrionLib.SearchIndex, {
						Type = "Button",
						Name = ButtonConfig.Name,
						Tab = TabConfig.Name,
						Config = ButtonConfig,
						Object = ButtonFrame,
						Parent = ItemParent,
						Create = function(parent)
							return GetElements(parent):AddButton(ButtonConfig)
						end
					})
				end
				AddConnection(Click.MouseEnter, function()
					TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
				end)

				AddConnection(Click.MouseLeave, function()
					TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
				end)

				AddConnection(Click.MouseButton1Up, function()
					TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
					spawn(function()
						ButtonConfig.Callback()
					end)
				end)

				AddConnection(Click.MouseButton1Down, function()
					TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 6)}):Play()
				end)

				function Button:Set(ButtonText)
					ButtonFrame.Content.Text = ButtonText
				end	

				return Button
			end    
			function ElementFunction:AddToggle(ToggleConfig)
				ToggleConfig = ToggleConfig or {}
				ToggleConfig.Name = ToggleConfig.Name or "Toggle"
				ToggleConfig.Default = ToggleConfig.Default or false
				ToggleConfig.Callback = ToggleConfig.Callback or function() end
				ToggleConfig.Color = ToggleConfig.Color or Color3.fromRGB(9, 99, 195)
				ToggleConfig.Flag = ToggleConfig.Flag or nil
				ToggleConfig.Save = ToggleConfig.Save or false

				local Toggle = {Value = ToggleConfig.Default, Save = ToggleConfig.Save}

				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})

				local ToggleBox = SetChildren(SetProps(MakeElement("RoundFrame", ToggleConfig.Color, 0, 4), {
					Size = UDim2.new(0, 24, 0, 24),
					Position = UDim2.new(1, -24, 0.5, 0),
					AnchorPoint = Vector2.new(0.5, 0.5)
				}), {
					SetProps(MakeElement("Stroke"), {
						Color = ToggleConfig.Color,
						Name = "Stroke",
						Transparency = 0.5
					}),
					SetProps(MakeElement("Image", "rbxassetid://3944680095"), {
						Size = UDim2.new(0, 20, 0, 20),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.new(0.5, 0, 0.5, 0),
						ImageColor3 = Color3.fromRGB(255, 255, 255),
						Name = "Ico"
					}),
				})

				local ToggleFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", ToggleConfig.Name, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					ToggleBox,
					Click
				}), "Second")

                RegisterAnimatedElement(ToggleFrame)

				if ItemParent ~= OrionLib.SearchResultsContainer
				and ItemParent.Parent ~= OrionLib.SearchResultsContainer then
					table.insert(OrionLib.SearchIndex, {
						Type = "Toggle",
						Name = ToggleConfig.Name,
						Tab = TabConfig.Name,
						Config = ToggleConfig,
                        Control = Toggle,
						Object = ToggleFrame,
						Parent = ItemParent,
                        Create = function(parent)
                            local cfg = table.clone(ToggleConfig)

                            cfg.Default = Toggle.Value
                            cfg.Callback = ToggleConfig.Callback

                            return GetElements(parent):AddToggle(cfg)
                        end
					})
				end

				function Toggle:Set(Value)
					Toggle.Value = Value
					TweenService:Create(ToggleBox, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Toggle.Value and ToggleConfig.Color or OrionLib.Themes.Default.Divider}):Play()
					TweenService:Create(ToggleBox.Stroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Color = Toggle.Value and ToggleConfig.Color or OrionLib.Themes.Default.Stroke}):Play()
					TweenService:Create(ToggleBox.Ico, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = Toggle.Value and 0 or 1, Size = Toggle.Value and UDim2.new(0, 20, 0, 20) or UDim2.new(0, 8, 0, 8)}):Play()
					ToggleConfig.Callback(Toggle.Value)
				end    

				Toggle:Set(Toggle.Value)

				AddConnection(Click.MouseEnter, function()
					TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
				end)

				AddConnection(Click.MouseLeave, function()
					TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
				end)

				AddConnection(Click.MouseButton1Up, function()
					TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
					SaveCfg(game.GameId)
					Toggle:Set(not Toggle.Value)
				end)

				AddConnection(Click.MouseButton1Down, function()
					TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 6)}):Play()
				end)

				if ToggleConfig.Flag then
					OrionLib.Flags[ToggleConfig.Flag] = Toggle
				end	
				return Toggle
			end  
			function ElementFunction:AddSlider(SliderConfig)
				SliderConfig = SliderConfig or {}
				SliderConfig.Name = SliderConfig.Name or "Slider"
				SliderConfig.Min = SliderConfig.Min or 0
				SliderConfig.Max = SliderConfig.Max or 100
				SliderConfig.Increment = SliderConfig.Increment or 1
				SliderConfig.Default = SliderConfig.Default or 50
				SliderConfig.Callback = SliderConfig.Callback or function() end
				SliderConfig.ValueName = SliderConfig.ValueName or ""
				SliderConfig.Color = SliderConfig.Color or Color3.fromRGB(9, 149, 98)
				SliderConfig.Flag = SliderConfig.Flag or nil
				SliderConfig.Save = SliderConfig.Save or false

				local Slider = {Value = SliderConfig.Default, Save = SliderConfig.Save}
				local Dragging = false

				local SliderDrag = SetChildren(SetProps(MakeElement("RoundFrame", SliderConfig.Color, 0, 5), {
					Size = UDim2.new(0, 0, 1, 0),
					BackgroundTransparency = 0.3,
					ClipsDescendants = true
				}), {
					AddThemeObject(SetProps(MakeElement("Label", "value", 13), {
						Size = UDim2.new(1, -12, 0, 14),
						Position = UDim2.new(0, 12, 0, 6),
						Font = Enum.Font.GothamBold,
						Name = "Value",
						TextTransparency = 0
					}), "Text")
				})

				local SliderBar = SetChildren(SetProps(MakeElement("RoundFrame", SliderConfig.Color, 0, 5), {
					Size = UDim2.new(1, -24, 0, 26),
					Position = UDim2.new(0, 12, 0, 30),
					BackgroundTransparency = 0.9
				}), {
					SetProps(MakeElement("Stroke"), {
						Color = SliderConfig.Color
					}),
					AddThemeObject(SetProps(MakeElement("Label", "value", 13), {
						Size = UDim2.new(1, -12, 0, 14),
						Position = UDim2.new(0, 12, 0, 6),
						Font = Enum.Font.GothamBold,
						Name = "Value",
						TextTransparency = 0.8
					}), "Text"),
					SliderDrag
				})

				local SliderFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
					Size = UDim2.new(1, 0, 0, 65),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", SliderConfig.Name, 15), {
						Size = UDim2.new(1, -12, 0, 14),
						Position = UDim2.new(0, 12, 0, 10),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					SliderBar
				}), "Second")

                RegisterAnimatedElement(SliderFrame)

				if ItemParent ~= OrionLib.SearchResultsContainer
				and ItemParent.Parent ~= OrionLib.SearchResultsContainer then
					table.insert(OrionLib.SearchIndex, {
						Type = "Slider",
						Name = SliderConfig.Name,
						Tab = TabConfig.Name,
						Config = SliderConfig,
                        Control = Slider,
						Object = SliderFrame,
						Parent = ItemParent,
						Create = function(parent)
							local cfg = table.clone(SliderConfig)

							cfg.Default = Slider.Value

							cfg.Callback = function(value)
								Slider:Set(value)
							end

							return GetElements(parent):AddSlider(cfg)
						end
					})
				end

				SliderBar.InputBegan:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then 
						Dragging = true 
					end 
				end)
				SliderBar.InputEnded:Connect(function(Input) 
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then 
						Dragging = false 
					end 
				end)

				UserInputService.InputChanged:Connect(function(Input)
					if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then 
						local SizeScale = math.clamp((Input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
						Slider:Set(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * SizeScale)) 
						SaveCfg(game.GameId)
					end
				end)

				function Slider:Set(Value)
					self.Value = math.clamp(Round(Value, SliderConfig.Increment), SliderConfig.Min, SliderConfig.Max)
					TweenService:Create(SliderDrag,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{Size = UDim2.fromScale((self.Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min), 1)}):Play()
					SliderBar.Value.Text = tostring(self.Value) .. " " .. SliderConfig.ValueName
					SliderDrag.Value.Text = tostring(self.Value) .. " " .. SliderConfig.ValueName
					SliderConfig.Callback(self.Value)
				end      

				Slider:Set(Slider.Value)
				if SliderConfig.Flag then				
					OrionLib.Flags[SliderConfig.Flag] = Slider
				end
				return Slider
			end  
			function ElementFunction:AddDropdown(DropdownConfig)
				DropdownConfig = DropdownConfig or {}
				DropdownConfig.Name = DropdownConfig.Name or "Dropdown"
				DropdownConfig.Options = DropdownConfig.Options or {}
				DropdownConfig.Default = DropdownConfig.Default or ""
				DropdownConfig.Callback = DropdownConfig.Callback or function() end
				DropdownConfig.Flag = DropdownConfig.Flag or nil
				DropdownConfig.Save = DropdownConfig.Save or false

				local Dropdown = {Value = DropdownConfig.Default, Options = DropdownConfig.Options, Buttons = {}, Toggled = false, Type = "Dropdown", Save = DropdownConfig.Save}
				local MaxElements = 5

				if not table.find(Dropdown.Options, Dropdown.Value) then
					Dropdown.Value = "..."
				end

				local DropdownList = MakeElement("List")

				local DropdownContainer = AddThemeObject(SetProps(SetChildren(MakeElement("ScrollFrame", Color3.fromRGB(40, 40, 40), 4), {
					DropdownList
				}), {
					Parent = ItemParent,
					Position = UDim2.new(0, 0, 0, 38),
					Size = UDim2.new(1, 0, 1, -38),
					ClipsDescendants = true
				}), "Divider")

				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})

				local DropdownFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent,
					ClipsDescendants = true
				}), {
					DropdownContainer,
					SetProps(SetChildren(MakeElement("TFrame"), {
						AddThemeObject(SetProps(MakeElement("Label", DropdownConfig.Name, 15), {
							Size = UDim2.new(1, -12, 1, 0),
							Position = UDim2.new(0, 12, 0, 0),
							Font = Enum.Font.GothamBold,
							Name = "Content"
						}), "Text"),
						AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072706796"), {
							Size = UDim2.new(0, 20, 0, 20),
							AnchorPoint = Vector2.new(0, 0.5),
							Position = UDim2.new(1, -30, 0.5, 0),
							ImageColor3 = Color3.fromRGB(240, 240, 240),
							Name = "Ico"
						}), "TextDark"),
						AddThemeObject(SetProps(MakeElement("Label", "Selected", 13), {
							Size = UDim2.new(1, -40, 1, 0),
							Font = Enum.Font.Gotham,
							Name = "Selected",
							TextXAlignment = Enum.TextXAlignment.Right
						}), "TextDark"),
						AddThemeObject(SetProps(MakeElement("Frame"), {
							Size = UDim2.new(1, 0, 0, 1),
							Position = UDim2.new(0, 0, 1, -1),
							Name = "Line",
							Visible = false
						}), "Stroke"), 
						Click
					}), {
						Size = UDim2.new(1, 0, 0, 38),
						ClipsDescendants = true,
						Name = "F"
					}),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					MakeElement("Corner")
				}), "Second")

				RegisterAnimatedElement(DropdownFrame)

				if ItemParent ~= OrionLib.SearchResultsContainer
				and ItemParent.Parent ~= OrionLib.SearchResultsContainer then
					table.insert(OrionLib.SearchIndex, {
						Type = "Dropdown",
						Name = DropdownConfig.Name,
						Tab = TabConfig.Name,
						Config = DropdownConfig,
						Control = Dropdown,
						Object = DropdownFrame,
						Parent = ItemParent,
						Create = function(parent)
							local cfg = table.clone(DropdownConfig)

							cfg.Default = Dropdown.Value

							cfg.Callback = function(value)
								Dropdown:Set(value)
							end

							return GetElements(parent):AddDropdown(cfg)
						end
					})
				end            

				AddConnection(DropdownList:GetPropertyChangedSignal("AbsoluteContentSize"), function()
					DropdownContainer.CanvasSize = UDim2.new(0, 0, 0, DropdownList.AbsoluteContentSize.Y)
				end)  

				local function AddOptions(Options)
					for _, Option in pairs(Options) do
						local OptionBtn = AddThemeObject(SetProps(SetChildren(MakeElement("Button", Color3.fromRGB(40, 40, 40)), {
							MakeElement("Corner", 0, 6),
							AddThemeObject(SetProps(MakeElement("Label", Option, 13, 0.4), {
								Position = UDim2.new(0, 8, 0, 0),
								Size = UDim2.new(1, -8, 1, 0),
								Name = "Title"
							}), "Text")
						}), {
							Parent = DropdownContainer,
							Size = UDim2.new(1, 0, 0, 28),
							BackgroundTransparency = 1,
							ClipsDescendants = true
						}), "Divider")

						AddConnection(OptionBtn.MouseButton1Click, function()
							Dropdown:Set(Option)
							SaveCfg(game.GameId)
						end)

						Dropdown.Buttons[Option] = OptionBtn
					end
				end	

				function Dropdown:Refresh(Options, Delete)
					if Delete then
						for _,v in pairs(Dropdown.Buttons) do
							v:Destroy()
						end    
						table.clear(Dropdown.Options)
						table.clear(Dropdown.Buttons)
					end
					Dropdown.Options = Options
					AddOptions(Dropdown.Options)
				end  

				function Dropdown:Set(Value)
					if not table.find(Dropdown.Options, Value) then
						Dropdown.Value = "..."
						DropdownFrame.F.Selected.Text = Dropdown.Value
						for _, v in pairs(Dropdown.Buttons) do
							TweenService:Create(v,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{BackgroundTransparency = 1}):Play()
							TweenService:Create(v.Title,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{TextTransparency = 0.4}):Play()
						end	
						return
					end

					Dropdown.Value = Value
					DropdownFrame.F.Selected.Text = Dropdown.Value

					for _, v in pairs(Dropdown.Buttons) do
						TweenService:Create(v,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{BackgroundTransparency = 1}):Play()
						TweenService:Create(v.Title,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{TextTransparency = 0.4}):Play()
					end	
					TweenService:Create(Dropdown.Buttons[Value],TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{BackgroundTransparency = 0}):Play()
					TweenService:Create(Dropdown.Buttons[Value].Title,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{TextTransparency = 0}):Play()
					return DropdownConfig.Callback(Dropdown.Value)
				end

				AddConnection(Click.MouseButton1Click, function()
					Dropdown.Toggled = not Dropdown.Toggled
					DropdownFrame.F.Line.Visible = Dropdown.Toggled
					TweenService:Create(DropdownFrame.F.Ico,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{Rotation = Dropdown.Toggled and 180 or 0}):Play()
					if #Dropdown.Options > MaxElements then
						TweenService:Create(DropdownFrame,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{Size = Dropdown.Toggled and UDim2.new(1, 0, 0, 38 + (MaxElements * 28)) or UDim2.new(1, 0, 0, 38)}):Play()
					else
						TweenService:Create(DropdownFrame,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{Size = Dropdown.Toggled and UDim2.new(1, 0, 0, DropdownList.AbsoluteContentSize.Y + 38) or UDim2.new(1, 0, 0, 38)}):Play()
					end
				end)

				Dropdown:Refresh(Dropdown.Options, false)
				Dropdown:Set(Dropdown.Value)
				if DropdownConfig.Flag then				
					OrionLib.Flags[DropdownConfig.Flag] = Dropdown
				end
				return Dropdown
			end







			function ElementFunction:AddBind(BindConfig)
				BindConfig.Name = BindConfig.Name or "Bind"
				BindConfig.Default = BindConfig.Default or Enum.KeyCode.Unknown
				BindConfig.Hold = BindConfig.Hold or false
				BindConfig.Callback = BindConfig.Callback or function() end
				BindConfig.Flag = BindConfig.Flag or nil
				BindConfig.Save = BindConfig.Save or false

				local Bind = {
	                Value = BindConfig.Default,
	                Binding = false,
	                Type = "Bind",
	                Save = BindConfig.Save
                }
				local Holding = false

				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})

				local BindBox = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
					Size = UDim2.new(0, 24, 0, 24),
					Position = UDim2.new(1, -12, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5)
				}), {
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					AddThemeObject(SetProps(MakeElement("Label", BindConfig.Name, 14), {
						Size = UDim2.new(1, 0, 1, 0),
						Font = Enum.Font.GothamBold,
						TextXAlignment = Enum.TextXAlignment.Center,
						Name = "Value"
					}), "Text")
				}), "Main")

				local BindFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", BindConfig.Name, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					BindBox,
					Click
				}), "Second")
                RegisterAnimatedElement(BindFrame)
				if ItemParent ~= OrionLib.SearchResultsContainer
				and ItemParent.Parent ~= OrionLib.SearchResultsContainer then
					table.insert(OrionLib.SearchIndex, {
						Type = "Bind",
						Name = BindConfig.Name,
						Tab = TabConfig.Name,
						Config = BindConfig,
                        Control = Bind,
						Object = BindFrame,
						Parent = ItemParent,
                        Create = function(parent)
                            local cfg = table.clone(BindConfig)

                            cfg.Default = Bind.Value

                            local SearchBind = GetElements(parent):AddBind(cfg)

                            local OriginalSet = SearchBind.Set

                            function SearchBind:Set(Key)
                                Bind:Set(Key)
                                OriginalSet(self, Key)
                            end

                            return SearchBind
                        end
					})
				end

				AddConnection(BindBox.Value:GetPropertyChangedSignal("Text"), function()
					--BindBox.Size = UDim2.new(0, BindBox.Value.TextBounds.X + 16, 0, 24)
					TweenService:Create(BindBox, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, BindBox.Value.TextBounds.X + 16, 0, 24)}):Play()
				end)

				AddConnection(Click.InputEnded, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						if Bind.Binding then return end
						Bind.Binding = true
						BindBox.Value.Text = ""
					end
				end)

				AddConnection(UserInputService.InputBegan, function(Input)
					if UserInputService:GetFocusedTextBox() then return end
					if (Input.KeyCode.Name == Bind.Value or Input.UserInputType.Name == Bind.Value) and not Bind.Binding then
						if BindConfig.Hold then
							Holding = true
							BindConfig.Callback(Holding)
						else
							BindConfig.Callback()
						end
					elseif Bind.Binding then
						local Key
						pcall(function()
							if not CheckKey(BlacklistedKeys, Input.KeyCode) then
								Key = Input.KeyCode
							end
						end)
						pcall(function()
							if CheckKey(WhitelistedMouse, Input.UserInputType) and not Key then
								Key = Input.UserInputType
							end
						end)
						Key = Key or Bind.Value
						Bind:Set(Key)
						SaveCfg(game.GameId)
					end
				end)

				AddConnection(UserInputService.InputEnded, function(Input)
					if Input.KeyCode.Name == Bind.Value or Input.UserInputType.Name == Bind.Value then
						if BindConfig.Hold and Holding then
							Holding = false
							BindConfig.Callback(Holding)
						end
					end
				end)

				AddConnection(Click.MouseEnter, function()
					TweenService:Create(BindFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
				end)

				AddConnection(Click.MouseLeave, function()
					TweenService:Create(BindFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
				end)

				AddConnection(Click.MouseButton1Up, function()
					TweenService:Create(BindFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
				end)

				AddConnection(Click.MouseButton1Down, function()
					TweenService:Create(BindFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 6)}):Play()
				end)

                function Bind:Set(Key)
                    Bind.Binding = false
                    Bind.Value = Key or Bind.Value
                    Bind.Value = Bind.Value.Name or Bind.Value
                    BindBox.Value.Text = Bind.Value

                    for _, entry in ipairs(OrionLib.SearchIndex) do
                        if entry.Control and entry.Control ~= Bind and entry.Type == "Bind" and entry.Name == BindConfig.Name then
                            entry.Control.Binding = false
                            entry.Control.Value = Bind.Value
                        end
                    end
                end

				Bind:Set(BindConfig.Default)
				if BindConfig.Flag then				
					OrionLib.Flags[BindConfig.Flag] = Bind
				end
				return Bind
			end  
			function ElementFunction:AddTextbox(TextboxConfig)
				TextboxConfig = TextboxConfig or {}
				TextboxConfig.Name = TextboxConfig.Name or "Textbox"
				TextboxConfig.Default = TextboxConfig.Default or ""
				TextboxConfig.TextDisappear = TextboxConfig.TextDisappear or false
				TextboxConfig.Callback = TextboxConfig.Callback or function() end

				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})

                local TextboxActual = AddThemeObject(Create("TextBox", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    PlaceholderColor3 = Color3.fromRGB(210,210,210),
                    PlaceholderText = "Input",
                    Font = Enum.Font.GothamSemibold,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    TextSize = 14,
                    ClearTextOnFocus = false
                }), "Text")

                local TextContainer = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
                    Size = UDim2.new(0, 24, 0, 24),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    AnchorPoint = Vector2.new(1, 0.5)
                }), {
                    AddThemeObject(MakeElement("Stroke"), "Stroke"),
                    TextboxActual
                }), "Main")

                local TextboxFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
                    Size = UDim2.new(1, 0, 0, 38),
                    Parent = ItemParent
                }), {
                    AddThemeObject(SetProps(MakeElement("Label", TextboxConfig.Name, 15), {
                        Size = UDim2.new(1, -12, 1, 0),
                        Position = UDim2.new(0, 12, 0, 0),
                        Font = Enum.Font.GothamBold,
                        Name = "Content"
                    }), "Text"),
                    AddThemeObject(MakeElement("Stroke"), "Stroke"),
                    TextContainer,
                    Click
                }), "Second")

                local Textbox = {}

                function Textbox:Set(Value)
                    TextboxActual.Text = Value
                    Textbox.Value = Value
                    TextboxConfig.Callback(Value)
                end

                Textbox.Value = TextboxActual.Text

                AddConnection(TextboxActual:GetPropertyChangedSignal("Text"), function()
                    Textbox.Value = TextboxActual.Text
                end)
                RegisterAnimatedElement(TextboxFrame)
				if ItemParent ~= OrionLib.SearchResultsContainer
				and ItemParent.Parent ~= OrionLib.SearchResultsContainer then
					table.insert(OrionLib.SearchIndex, {
                        Type = "Textbox",
                        Name = TextboxConfig.Name,
                        Tab = TabConfig.Name,
                        Config = TextboxConfig,
                        Control = Textbox,
                        Object = TextboxFrame,
                        Parent = ItemParent,
                        Create = function(parent)
                            local cfg = table.clone(TextboxConfig)

                            cfg.Default = Textbox.Value

                            cfg.Callback = function(value)
                                Textbox:Set(value)
                            end

                            return GetElements(parent):AddTextbox(cfg)
                        end
                    })
                end
				AddConnection(TextboxActual:GetPropertyChangedSignal("Text"), function()
					--TextContainer.Size = UDim2.new(0, TextboxActual.TextBounds.X + 16, 0, 24)
					TweenService:Create(TextContainer, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, TextboxActual.TextBounds.X + 16, 0, 24)}):Play()
				end)

				AddConnection(TextboxActual.FocusLost, function()
					TextboxConfig.Callback(TextboxActual.Text)
					if TextboxConfig.TextDisappear then
						TextboxActual.Text = ""
					end	
				end)

				TextboxActual.Text = TextboxConfig.Default

				AddConnection(Click.MouseEnter, function()
					TweenService:Create(TextboxFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
				end)

				AddConnection(Click.MouseLeave, function()
					TweenService:Create(TextboxFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
				end)

				AddConnection(Click.MouseButton1Up, function()
					TweenService:Create(TextboxFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
					TextboxActual:CaptureFocus()
				end)

				AddConnection(Click.MouseButton1Down, function()
					TweenService:Create(TextboxFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 6)}):Play()
				end)
            return Textbox
			end 
			function ElementFunction:AddColorpicker(ColorpickerConfig)
				ColorpickerConfig = ColorpickerConfig or {}
				ColorpickerConfig.Name = ColorpickerConfig.Name or "Colorpicker"
				ColorpickerConfig.Default = ColorpickerConfig.Default or Color3.fromRGB(255,255,255)
				ColorpickerConfig.Callback = ColorpickerConfig.Callback or function() end
				ColorpickerConfig.Flag = ColorpickerConfig.Flag or nil
				ColorpickerConfig.Save = ColorpickerConfig.Save or false

				local ColorH, ColorS, ColorV = Color3.toHSV(ColorpickerConfig.Default)
				local ColorInput
				local HueInput
				local Colorpicker = {Value = ColorpickerConfig.Default, Toggled = false, Type = "Colorpicker", Save = ColorpickerConfig.Save}

				local ColorSelection = Create("ImageLabel", {
					Size = UDim2.new(0, 18, 0, 18),
					Position = UDim2.new(ColorS, 0, 1 - ColorV, 0),
					ScaleType = Enum.ScaleType.Fit,
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "http://www.roblox.com/asset/?id=4805639000"
				})

				local HueSelection = Create("ImageLabel", {
					Size = UDim2.new(0, 18, 0, 18),
					Position = UDim2.new(0.5, 0, 1 - select(1, Color3.toHSV(Colorpicker.Value))),
					ScaleType = Enum.ScaleType.Fit,
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "http://www.roblox.com/asset/?id=4805639000"
				})

				local Color = Create("ImageLabel", {
					Size = UDim2.new(1, -25, 1, 0),
					Visible = false,
					Image = "rbxassetid://4155801252"
				}, {
					Create("UICorner", {CornerRadius = UDim.new(0, 5)}),
					ColorSelection
				})

				local Hue = Create("Frame", {
					Size = UDim2.new(0, 20, 1, 0),
					Position = UDim2.new(1, -20, 0, 0),
					Visible = false
				}, {
					Create("UIGradient", {Rotation = 270, Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 4)), ColorSequenceKeypoint.new(0.20, Color3.fromRGB(234, 255, 0)), ColorSequenceKeypoint.new(0.40, Color3.fromRGB(21, 255, 0)), ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(0.80, Color3.fromRGB(0, 17, 255)), ColorSequenceKeypoint.new(0.90, Color3.fromRGB(255, 0, 251)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 4))},}),
					Create("UICorner", {CornerRadius = UDim.new(0, 5)}),
					HueSelection
				})

				local ColorpickerContainer = Create("Frame", {
					Position = UDim2.new(0, 0, 0, 32),
					Size = UDim2.new(1, 0, 1, -32),
					BackgroundTransparency = 1,
					ClipsDescendants = true
				}, {
					Hue,
					Color,
					Create("UIPadding", {
						PaddingLeft = UDim.new(0, 35),
						PaddingRight = UDim.new(0, 35),
						PaddingBottom = UDim.new(0, 10),
						PaddingTop = UDim.new(0, 17)
					})
				})

				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})

				local ColorpickerBox = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
					Size = UDim2.new(0, 24, 0, 24),
					Position = UDim2.new(1, -12, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5)
				}), {
					AddThemeObject(MakeElement("Stroke"), "Stroke")
				}), "Main")

				local ColorpickerFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent
				}), {
					SetProps(SetChildren(MakeElement("TFrame"), {
						AddThemeObject(SetProps(MakeElement("Label", ColorpickerConfig.Name, 15), {
							Size = UDim2.new(1, -12, 1, 0),
							Position = UDim2.new(0, 12, 0, 0),
							Font = Enum.Font.GothamBold,
							Name = "Content"
						}), "Text"),
						ColorpickerBox,
						Click,
						AddThemeObject(SetProps(MakeElement("Frame"), {
							Size = UDim2.new(1, 0, 0, 1),
							Position = UDim2.new(0, 0, 1, -1),
							Name = "Line",
							Visible = false
						}), "Stroke"), 
					}), {
						Size = UDim2.new(1, 0, 0, 38),
						ClipsDescendants = true,
						Name = "F"
					}),
					ColorpickerContainer,
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
				}), "Second")
                RegisterAnimatedElement(ColorpickerFrame)
				if ItemParent ~= OrionLib.SearchResultsContainer
				and ItemParent.Parent ~= OrionLib.SearchResultsContainer then
					table.insert(OrionLib.SearchIndex, {
						Type = "Colorpicker",
						Name = ColorpickerConfig.Name,
						Tab = TabConfig.Name,
						Config = ColorpickerConfig,
                        Control = Colorpicker,
						Object = ColorpickerFrame,
						Parent = ItemParent,
                        Create = function(parent)
                            local cfg = table.clone(ColorpickerConfig)

                            cfg.Default = Colorpicker.Value

                            cfg.Callback = function(color)
                                Colorpicker:Set(color)
                                ColorpickerConfig.Callback(color)
                            end

                            return GetElements(parent):AddColorpicker(cfg)
                        end
					})
				end

				AddConnection(Click.MouseButton1Click, function()
					Colorpicker.Toggled = not Colorpicker.Toggled
					TweenService:Create(ColorpickerFrame,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{Size = Colorpicker.Toggled and UDim2.new(1, 0, 0, 148) or UDim2.new(1, 0, 0, 38)}):Play()
					Color.Visible = Colorpicker.Toggled
					Hue.Visible = Colorpicker.Toggled
					ColorpickerFrame.F.Line.Visible = Colorpicker.Toggled
				end)

				local function UpdateColorPicker()
					ColorpickerBox.BackgroundColor3 = Color3.fromHSV(ColorH, ColorS, ColorV)
					Color.BackgroundColor3 = Color3.fromHSV(ColorH, 1, 1)
					Colorpicker:Set(ColorpickerBox.BackgroundColor3)
					ColorpickerConfig.Callback(ColorpickerBox.BackgroundColor3)
					SaveCfg(game.GameId)
				end

				AddConnection(Color.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						if ColorInput then
							ColorInput:Disconnect()
						end
						ColorInput = AddConnection(RunService.RenderStepped, function()
							local ColorX = (math.clamp(Mouse.X - Color.AbsolutePosition.X, 0, Color.AbsoluteSize.X) / Color.AbsoluteSize.X)
							local ColorY = (math.clamp(Mouse.Y - Color.AbsolutePosition.Y, 0, Color.AbsoluteSize.Y) / Color.AbsoluteSize.Y)
							ColorSelection.Position = UDim2.new(ColorX, 0, ColorY, 0)
							ColorS = ColorX
							ColorV = 1 - ColorY
							UpdateColorPicker()
						end)
					end
				end)

				AddConnection(Color.InputEnded, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						if ColorInput then
							ColorInput:Disconnect()
						end
					end
				end)

				AddConnection(Hue.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						if HueInput then
							HueInput:Disconnect()
						end;

						HueInput = AddConnection(RunService.RenderStepped, function()
							local HueY = (math.clamp(Mouse.Y - Hue.AbsolutePosition.Y, 0, Hue.AbsoluteSize.Y) / Hue.AbsoluteSize.Y)

							HueSelection.Position = UDim2.new(0.5, 0, HueY, 0)
							ColorH = 1 - HueY

							UpdateColorPicker()
						end)
					end
				end)

				AddConnection(Hue.InputEnded, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						if HueInput then
							HueInput:Disconnect()
						end
					end
				end)

				function Colorpicker:Set(Value)
					Colorpicker.Value = Value
					ColorpickerBox.BackgroundColor3 = Colorpicker.Value
					ColorpickerConfig.Callback(Colorpicker.Value)
				end

				Colorpicker:Set(Colorpicker.Value)
				if ColorpickerConfig.Flag then				
					OrionLib.Flags[ColorpickerConfig.Flag] = Colorpicker
				end
				return Colorpicker
			end  
			return ElementFunction   
		end	

		local ElementFunction = {}

		function ElementFunction:AddSection(SectionConfig)
			SectionConfig.Name = SectionConfig.Name or "Section"

			local SectionFrame = SetChildren(SetProps(MakeElement("TFrame"), {
				Size = UDim2.new(1, 0, 0, 26),
				Parent = Container
			}), {
				AddThemeObject(SetProps(MakeElement("Label", SectionConfig.Name, 14), {
					Size = UDim2.new(1, -12, 0, 16),
					Position = UDim2.new(0, 0, 0, 3),
					Font = Enum.Font.GothamSemibold
				}), "TextDark"),
				SetChildren(SetProps(MakeElement("TFrame"), {
					AnchorPoint = Vector2.new(0, 0),
					Size = UDim2.new(1, 0, 1, -24),
					Position = UDim2.new(0, 0, 0, 23),
					Name = "Holder"
				}), {
					MakeElement("List", 0, 6)
				}),
			})

			AddConnection(SectionFrame.Holder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
				SectionFrame.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y + 31)
				SectionFrame.Holder.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y)
			end)

			local SectionFunction = {}
			for i, v in next, GetElements(SectionFrame.Holder) do
				SectionFunction[i] = v 
			end
			return SectionFunction
		end	

		for i, v in next, GetElements(Container) do
			ElementFunction[i] = v 
		end

		if TabConfig.PremiumOnly then
			for i, v in next, ElementFunction do
				ElementFunction[i] = function() end
			end    
			local listLayout = Container:FindFirstChild("UIListLayout")
			local padding = Container:FindFirstChild("UIPadding")
			if listLayout then listLayout:Destroy() end
			if padding then padding:Destroy() end
			SetChildren(SetProps(MakeElement("TFrame"), {
				Size = UDim2.new(1, 0, 1, 0),
				Parent = Container
			}), {
				AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://3610239960"), {
					Size = UDim2.new(0, 18, 0, 18),
					Position = UDim2.new(0, 15, 0, 15),
					ImageTransparency = 0.4
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", "Unauthorised Access", 14), {
					Size = UDim2.new(1, -38, 0, 14),
					Position = UDim2.new(0, 38, 0, 18),
					TextTransparency = 0.4
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://4483345875"), {
					Size = UDim2.new(0, 56, 0, 56),
					Position = UDim2.new(0, 84, 0, 110),
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", "Premium Features", 14), {
					Size = UDim2.new(1, -150, 0, 14),
					Position = UDim2.new(0, 150, 0, 112),
					Font = Enum.Font.GothamBold
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", "This part of the script is locked to Sirius Premium users. Purchase Premium in the Discord server (sirius.menu/discord)", 12), {
					Size = UDim2.new(1, -200, 0, 14),
					Position = UDim2.new(0, 150, 0, 138),
					TextWrapped = true,
					TextTransparency = 0.4
				}), "Text")
			})
		end
		return ElementFunction   
	end

	OrionLib:MakeNotification({
		Name = "Running v1.5.9",
		Content = "Enjoy!",
		Time = 5,
		Image = "heart"
	})

	OrionLib:EnableGlobalSearch()
	

	
	return TabFunction
end   

function OrionLib:Destroy()
	for _, connection in ipairs(OrionLib.Connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end
	table.clear(OrionLib.Connections)
	Orion:Destroy()
end

return OrionLib
