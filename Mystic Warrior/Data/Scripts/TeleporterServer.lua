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
local TRIGGER = script:GetCustomProperty("Trigger"):WaitForObject()

-- User exposed properties
local TARGET = COMPONENT_ROOT:GetCustomProperty("Target"):WaitForObject()
local DESTINATION_OFFSET = COMPONENT_ROOT:GetCustomProperty("DestinationOffset")
local TELEPORTER_COOLDOWN = COMPONENT_ROOT:GetCustomProperty("TeleporterCooldown")
local PER_PLAYER_COOLDOWN = COMPONENT_ROOT:GetCustomProperty("PerPlayerCooldown")

-- Check user properties
if TELEPORTER_COOLDOWN < 0.0 then
    warn("TeleporterCooldown cannot be negative")
    TELEPORTER_COOLDOWN = 0.0
end
if PER_PLAYER_COOLDOWN < 0.0 then
    warn("PerPlayerCooldown cannot be negative")
    PER_PLAYER_COOLDOWN = 0.0
end

-- Variables
local useTime = 0.0

-- nil TryTeleportPlayer(Player)
-- Try to teleport the player, checking appropriate conditions
function TryTeleportPlayer(player)
	-- Make sure we don't enter an infinite loop
	if _G.TeleporterServer.isTeleporting then
		return
	end
	if useTime + TELEPORTER_COOLDOWN > time() then
		return
	end
	if player.serverUserData.TeleporterServer_TeleportTime then
		if player.serverUserData.TeleporterServer_TeleportTime + PER_PLAYER_COOLDOWN >= time() then
			return
		end
	end
	_G.TeleporterServer.isTeleporting = true
	local destinationPosition = DESTINATION_OFFSET
	if TARGET then
		destinationPosition = destinationPosition + TARGET:GetWorldPosition()
	end
	player:SetWorldPosition(destinationPosition)

	Events.BroadcastToAllPlayers("PT_Internal", COMPONENT_ROOT.id, COMPONENT_ROOT:GetWorldPosition(), destinationPosition)
	useTime = time()
	player.serverUserData.TeleporterServer_TeleportTime = time()
	_G.TeleporterServer.isTeleporting = false
end

-- nil OnBeginOverlap(Trigger, Object)
-- Teleport any player who touches this
function OnBeginOverlap(trigger, other)
	if not other:IsA("Player") then
		return
	end
	if trigger.isInteractable then
		return
	end
	TryTeleportPlayer(other)
end

-- nil OnInteracted(Trigger, Player)
-- Teleport any player who interacts with this
function OnInteracted(trigger, player)
	TryTeleportPlayer(player)
end

-- Initialize
TRIGGER.beginOverlapEvent:Connect(OnBeginOverlap)
TRIGGER.interactedEvent:Connect(OnInteracted)

if not _G.TeleporterServer then
	_G.TeleporterServer = {}
	_G.TeleporterServer.isTeleporting = false
end