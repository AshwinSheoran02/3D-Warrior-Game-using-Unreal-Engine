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
local SPAWN_PARENT = script:GetCustomProperty("SpawnParent"):WaitForObject()

-- User exposed properties
local OBJECT_ASSET_REFERENCE = COMPONENT_ROOT:GetCustomProperty("ObjectAssetReference")
local RESPAWN_DELAY = COMPONENT_ROOT:GetCustomProperty("RespawnDelay")
local HEIGHT_OFFSET = COMPONENT_ROOT:GetCustomProperty("HeightOffset")

-- Check user properties
if not OBJECT_ASSET_REFERENCE then
    warn("Object to spawn was not provided.")
end

-- Variables
local currentInstance = nil

-- nil Reset()
-- Spawns the object under the spawn parent object
function RespawnObject()
    if SPAWN_PARENT then
        currentInstance = World.SpawnAsset(OBJECT_ASSET_REFERENCE, {parent = SPAWN_PARENT})
    end
end

-- nil OnChildRemoved(CoreObject)
-- Respawns the object after a delay
function OnChildRemoved(object)
    Task.Spawn(RespawnObject, RESPAWN_DELAY)
end

-- Initialize
RespawnObject()

-- Set the height offset for the object to hover above the ground
if SPAWN_PARENT then
    SPAWN_PARENT:SetPosition(SPAWN_PARENT:GetPosition() + Vector3.UP * HEIGHT_OFFSET)
    SPAWN_PARENT.childRemovedEvent:Connect(OnChildRemoved)
end