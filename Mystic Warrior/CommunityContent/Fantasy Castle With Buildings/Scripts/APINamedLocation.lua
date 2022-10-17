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

--[[
Named locations enable a map to feature volumes with set names, and other components to know the name of the location
where the player is (usually just to display it on screen). Locations are described by the following properties:
{
	string name										The name of the location
	Color textColor									Color UI text should be
	Color backgroundColor							Color UI background should be
}
Named locations are a purely client-side concept. Locations
must broadcast the following events:

LocationEntered(Player player, table locationProperties)
LocationExited(Player player, table locationProperties)
--]]

local API = {}

-- nil RegisterLocation(table, Trigger) [Client]
-- Called once by each location at startup to register itself
function API.RegisterLocation(properties, triggerVolume)
	-- Generate the table if it doesn't exist
	if not _G.APIRegisteredLocations then
		_G.APIRegisteredLocations = {}
	end

	_G.APIRegisteredLocations[triggerVolume] = properties
end

-- string GetPlayerLocation(Player) [Client]
-- Returns the properties of the location where the player is or nil
function API.GetPlayerLocation(player)
	if not _G.APIRegisteredLocations then
		return nil
	end

	for triggerVolume, properties in pairs(_G.APIRegisteredLocations) do
		if triggerVolume:IsOverlapping(player) then
			return properties
		end
	end

	return nil
end

return API
