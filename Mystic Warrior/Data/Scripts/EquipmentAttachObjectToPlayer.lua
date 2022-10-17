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

--[[
    This is a utility script that attaches equipment child object to an the player owner's socket.
    The attached object reverts back to original parent once the equipment is unequipped.
--]]

-- Internal custom properties
local EQUIPMENT = script:FindAncestorByType('Equipment')
if not EQUIPMENT:IsA('Equipment') then
    error(script.name .. " should be part of Equipment object hierarchy.")
end
local OBJECT = script:GetCustomProperty("Object"):WaitForObject()

-- User exposed properties
local PLAYER_SOCKET = script:GetCustomProperty("PlayerSocket")
local LOCAL_POSITION = script:GetCustomProperty("LocalPosition")
local LOCAL_ROTATION = script:GetCustomProperty("LocalRotation")

-- Constants
local PARENT = OBJECT.parent
local ORIGINAL_LOCAL_TRANSFORM = OBJECT:GetTransform()

-- Internal variables
local attached = false

-- nil OnEquipped(Equipment, Player)
-- Attach to equipment owner's socket and set a new local position
function OnEquipped(equipment, player)
    if Object.IsValid(player) and player:IsA("Player") then
        OBJECT:AttachToPlayer(player, PLAYER_SOCKET)
        OBJECT:SetPosition(LOCAL_POSITION)
        OBJECT:SetRotation(LOCAL_ROTATION)
        attached = true
    end
end

-- nil OnUnequipped()
-- Returns the object back to original parent
function OnUnequipped()
    Task.Wait() -- Wait a frame so we can tell if the equipment was unequipped because it was destroyed
    -- If both the object or the equipment exists, then reattach back the objects
    if Object.IsValid(PARENT) and Object.IsValid(EQUIPMENT) then
        OBJECT:Detach()
        OBJECT.parent = PARENT
        OBJECT:SetTransform(ORIGINAL_LOCAL_TRANSFORM)
    else
        OBJECT:Destroy()
    end
    attached = false
end

-- nil Tick()
-- Always check if the equipment object is attached for every player (if the equipment has owner)
function Tick()
    if not attached and Object.IsValid(EQUIPMENT.owner) then
        OnEquipped(EQUIPMENT, EQUIPMENT.owner)
    end
end

-- Initialize
EQUIPMENT.equippedEvent:Connect(OnEquipped)
EQUIPMENT.unequippedEvent:Connect(OnUnequipped)

