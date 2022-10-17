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

-- User exposed properties
local START_POINT_EFFECTS = COMPONENT_ROOT:GetCustomProperty("StartPointEffects")
local END_POINT_EFFECTS = COMPONENT_ROOT:GetCustomProperty("EndPointEffects")

-- nil OnPlayerTeleport(Vector3, Vector3)
-- Create effects for a teleport
function OnPlayerTeleport(id, startPosition, endPosition)
	if COMPONENT_ROOT.id == id then
		if START_POINT_EFFECTS then
			World.SpawnAsset(START_POINT_EFFECTS, {position = startPosition})
		end
		if END_POINT_EFFECTS then
			World.SpawnAsset(END_POINT_EFFECTS, {position = endPosition})
		end
	end
end

-- Initialize
Events.Connect("PT_Internal", OnPlayerTeleport)