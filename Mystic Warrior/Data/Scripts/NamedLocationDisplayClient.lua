--[[
Copyright 2019 Manticore Games, Inc. 

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit
persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

-- Internal custom properties
local COMPONENT_ROOT = script:GetCustomProperty("ComponentRoot"):WaitForObject()
local POPUP_TEXT = script:GetCustomProperty("PopupText"):WaitForObject()
local POPUP_PANEL = script:GetCustomProperty("PopupPanel"):WaitForObject()
local POPUP_BACKGROUND = script:GetCustomProperty("PopupBackground"):WaitForObject()
local STATIC_TEXT = script:GetCustomProperty("StaticText"):WaitForObject()
local STATIC_PANEL = script:GetCustomProperty("StaticPanel"):WaitForObject()
local STATIC_BACKGROUND = script:GetCustomProperty("StaticBackground"):WaitForObject()

-- User exposed properties
local POPUP_TEXT_DURATION = COMPONENT_ROOT:GetCustomProperty("PopupTextDuration")

-- Variables
local popupTime = 0.0

-- nil OnLocationEntered(Player, table)
-- Handles the LocationEntered event and updates UI
function OnLocationEntered(player, properties)
    if player == Game.GetLocalPlayer() then
        POPUP_PANEL.visibility = Visibility.INHERIT
        POPUP_TEXT.text = properties.name
        POPUP_TEXT:SetColor(properties.textColor)
        POPUP_BACKGROUND:SetColor(properties.backgroundColor)
        STATIC_PANEL.visibility = Visibility.INHERIT
        STATIC_TEXT.text = properties.name
        STATIC_TEXT:SetColor(properties.textColor)
        STATIC_BACKGROUND:SetColor(properties.backgroundColor)
        popupTime = time()
    end
end

-- nil OnLocationEntered(Player, table)
-- Handles the LocationExited event and hides UI
function OnLocationExited(player, properties)
    if player == Game.GetLocalPlayer() then
        POPUP_PANEL.visibility = Visibility.FORCE_OFF
        STATIC_PANEL.visibility = Visibility.FORCE_OFF
    end
end

-- nil Tick(float)
-- Handles popup text timing out
function Tick(deltaTime)
    if time() > popupTime + POPUP_TEXT_DURATION then
        POPUP_PANEL.visibility = Visibility.FORCE_OFF
    end
end

-- Initialize
POPUP_PANEL.visibility = Visibility.FORCE_OFF
STATIC_PANEL.visibility = Visibility.FORCE_OFF

Events.Connect("LocationEntered", OnLocationEntered)
Events.Connect("LocationExited", OnLocationExited)
