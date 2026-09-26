-- OrionLib Gen 2 - init.lua
-- Loads all modules and exposes the public API

local OrionLib = {}

-- // Load Core Modules
local Theme        = require(script.Core.Theme)
local Notifications = require(script.Core.Notifications)
local Window       = require(script.Core.Window)
local Drag         = require(script.Core.Drag)
local Config       = require(script.Core.Config)

-- Optional future modules
local Rescale      = nil
local RGBBorder    = nil

pcall(function()
    Rescale   = require(script.Core.Rescale)
end)

pcall(function()
    RGBBorder = require(script.Core.RGBBorder)
end)

-- // Load Utils
local Icons        = require(script.Utils.Icons)
local Animations   = require(script.Utils.Animations)
local ColorUtils   = require(script.Utils.ColorUtils)
local Types        = require(script.Utils.Types)

-- // Load Elements
local Elements = {
    Button    = require(script.Elements.Button),
    Toggle    = require(script.Elements.Toggle),
    Slider    = require(script.Elements.Slider),
    Dropdown  = require(script.Elements.Dropdown),
    Label     = require(script.Elements.Label),
    Paragraph = require(script.Elements.Paragraph),
    Section   = require(script.Elements.Section)
}

OrionLib.Theme        = Theme
OrionLib.Notifications = Notifications
OrionLib.Window       = Window
OrionLib.Drag         = Drag
OrionLib.Config       = Config
OrionLib.Elements     = Elements
OrionLib.Icons        = Icons
OrionLib.Animations   = Animations
OrionLib.ColorUtils   = ColorUtils
OrionLib.Types        = Types

-- // Public API

function OrionLib:MakeWindow(config)
    return Window.new(self, config)
end

function OrionLib:MakeNotification(config)
    return Notifications.new(self, config)
end

function OrionLib:Init()
    Config.Init(self)
end

return OrionLib
