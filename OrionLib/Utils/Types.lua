-- OrionLib Gen 2 - init snippet
-- Place in OrionLib/init.lua or require from your loader

local OrionLib = {
    Flags = {},
    Theme = nil,
    ScreenGui = nil,
    Folder = nil,
    SaveCfg = false
}

-- require core modules (adjust paths if needed)
local Core = script:FindFirstChild("Core") or script.Core
local Elements = script:FindFirstChild("Elements") or script.Elements
local Utils = script:FindFirstChild("Utils") or script.Utils

OrionLib.Theme = require(Core:WaitForChild("Theme"))
OrionLib.Config = require(Core:WaitForChild("Config"))
OrionLib.Notifications = require(Core:WaitForChild("Notifications"))(OrionLib)
OrionLib.Drag = require(Core:WaitForChild("Drag"))
OrionLib.Rescale = require(Core:WaitForChild("Rescale"))
OrionLib.Window = require(Core:WaitForChild("Window"))

-- elements
OrionLib.Button = require(Elements:WaitForChild("Button"))
OrionLib.Toggle = require(Elements:WaitForChild("Toggle"))
OrionLib.Slider = require(Elements:WaitForChild("Slider"))
OrionLib.Dropdown = require(Elements:WaitForChild("Dropdown"))
OrionLib.Section = require(Elements:WaitForChild("Section"))
OrionLib.Paragraph = require(Elements:WaitForChild("Paragraph"))

-- utils
OrionLib.Icons = require(Utils:WaitForChild("Icons"))
OrionLib.ColorUtils = require(Utils:WaitForChild("ColorUtils"))
OrionLib.Animations = require(Utils:WaitForChild("Animations"))

-- create window
local win = OrionLib.Window.Create(OrionLib, {
    Name = "Orion Library",
    ConfigFolder = "OrionConfig",
    SaveConfig = true,
    IntroEnabled = true,
    IntroText = "Orion Library",
    IntroIcon = "rbxassetid://8834748103"
})

-- expose API
OrionLib.MakeWindow = function(cfg) return win end

return OrionLib
