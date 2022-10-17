--[[
Copyright 2020 Manticore Games, Inc.

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
local BLACKLIST_RESOURCES = script:GetCustomProperty("ResourcesToIgnore"):WaitForObject()

local SHOW_FLY_UP_TEXT = COMPONENT_ROOT:GetCustomProperty("ShowFlyUpText")
local DURATION = COMPONENT_ROOT:GetCustomProperty("TextDuration")

local LOCAL_PLAYER = Game.GetLocalPlayer()

local currentResources = {}
local resourcesToIgnore = {}

function OnResourceChanged(player, resource, value)
    if player ~= LOCAL_PLAYER then return end
    if resourcesToIgnore[resource] then return end

    if currentResources[resource] and SHOW_FLY_UP_TEXT then
        if value > currentResources[resource] then
            Events.Broadcast("SubBannerMessage", string.format("+%d %s", value - currentResources[resource], resource), DURATION, Color.ORANGE)
        elseif value < currentResources[resource] then
            Events.Broadcast("SubBannerMessage", string.format("%d %s", value - currentResources[resource], resource), DURATION, Color.RED)
        end
    end

    currentResources[resource] = value
end

-- Initialize
for _, child in ipairs(BLACKLIST_RESOURCES:GetChildren()) do
    local resourceToIgnore = child:GetCustomProperty("Resource")
    resourcesToIgnore[resourceToIgnore] = true
end

LOCAL_PLAYER.resourceChangedEvent:Connect(OnResourceChanged)