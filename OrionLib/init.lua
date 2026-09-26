-- OrionLib Gen 2 - init.lua
-- Loads all modules and exposes the public API

local OrionLib = {}

-- // Load Core Modules
local Core = script:WaitForChild("Core")
local Theme        = require(Core:WaitForChild("Theme"))
local Notifications = require(Core:WaitForChild("Notifications"))
local Window       = require(Core:WaitForChild("Window"))
local Drag         = require(Core:WaitForChild("Drag"))
local Config       = require(Core:WaitForChild("Config"))

-- Optional future modules
local Rescale      = nil
local RGBBorder    = nil

pcall(function()
    Rescale   = require(Core:WaitForChild("Rescale"))
end)

pcall(function()
    RGBBorder = require(Core:WaitForChild("RGBBorder"))
end)

-- // Load Utils
local Utils = script:WaitForChild("Utils")
local Icons        = require(Utils:WaitForChild("Icons"))
local Animations   = require(Utils:WaitForChild("Animations"))
local ColorUtils   = require(Utils:WaitForChild("ColorUtils"))
local Types        = require(Utils:WaitForChild("Types"))

-- // Load Elements
local ElementsFolder = script:WaitForChild("Elements")
local Elements = {
    Button    = require(ElementsFolder:WaitForChild("Button")),
    Toggle    = require(ElementsFolder:WaitForChild("Toggle")),
    Slider    = require(ElementsFolder:WaitForChild("Slider")),
    Dropdown  = require(ElementsFolder:WaitForChild("Dropdown")),
    Label     = require(ElementsFolder:WaitForChild("Label")),
    Paragraph = require(ElementsFolder:WaitForChild("Paragraph")),
    Section   = require(ElementsFolder:WaitForChild("Section"))
}

-- attach modules to library
OrionLib.Theme        = Theme
OrionLib.Drag         = Drag
OrionLib.Config       = Config
OrionLib.Elements     = Elements
OrionLib.Icons        = Icons
OrionLib.Animations   = Animations
OrionLib.ColorUtils   = ColorUtils
OrionLib.Types        = Types
OrionLib.Rescale      = Rescale
OrionLib.RGBBorder    = RGBBorder

-- Initialize Notifications with OrionLib if the module returns a factory
-- (the Notifications module provided earlier can be required as a function or used directly)
local ok, notif = pcall(function() return Notifications end)
if ok and type(notif) == "table" and type(notif.Create) == "function" then
    OrionLib.Notifications = notif
else
    -- if Notifications is a factory that expects OrionLib, call it
    local ok2, created = pcall(function() return Notifications(OrionLib) end)
    OrionLib.Notifications = ok2 and created or Notifications
end

-- Window module (we expect Window.Create(OrionLib, config))
OrionLib.Window = Window

-- // Public API

function OrionLib:MakeWindow(config)
    -- Use the Create API from the Window module
    if type(self.Window) == "table" and type(self.Window.Create) == "function" then
        return self.Window.Create(self, config)
    elseif type(self.Window) == "function" then
        -- fallback if Window module exported a constructor function
        return self.Window(self, config)
    else
        error("Window module does not expose Create or constructor")
    end
end

function OrionLib:MakeNotification(config)
    -- Prefer Notifications.Create(holderOrLib, config) or Notifications(OrionLib, config)
    if self.Notifications and type(self.Notifications.Create) == "function" then
        -- Notifications.Create expects (holderOrLib, cfg, Theme) in some variants
        return self.Notifications.Create(self, config)
    elseif type(self.Notifications) == "function" then
        return self.Notifications(self, config)
    else
        error("Notifications module not available or has unexpected API")
    end
end

function OrionLib:Init()
    if type(self.Config) == "table" and type(self.Config.Init) == "function" then
        pcall(function() self.Config.Init(self) end)
    end
end

return OrionLib
