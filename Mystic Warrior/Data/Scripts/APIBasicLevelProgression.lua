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

local API = {}

-- nil RegisterLevelProgressionManager(table) [Client]
-- Register manager with table of functions
function API.RegisterLevelProgressionManager(functionTable)
	-- Generate the table if it doesn't exist
	if not _G.APIBasicLevelProgression then
        _G.APIBasicLevelProgression = {}
    else
        error("A game cannot have multiple level progression managers.")
	end

	_G.APIBasicLevelProgression = functionTable
end

function API.GetLevelResource(player)
	if _G.APIBasicLevelProgression then
		return _G.APIBasicLevelProgression.GetLevelResource(player)
	end

	return 1
end

function API.GetXPResource(player)
	if _G.APIBasicLevelProgression then
		return _G.APIBasicLevelProgression.GetXPResource(player)
	end

	return 0
end

function API.GetLastRequiredXPForPlayer(player)
	if _G.APIBasicLevelProgression then
		return _G.APIBasicLevelProgression.GetLastRequiredXPForPlayer(player)
	end

	return 0
end


function API.GetNextRequiredXPForPlayer(player)
	if _G.APIBasicLevelProgression then
		return _G.APIBasicLevelProgression.GetNextRequiredXPForPlayer(player)
	end

	return 0
end

return API