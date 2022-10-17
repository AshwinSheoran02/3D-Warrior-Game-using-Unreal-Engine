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
Automatically gathers specified abilities under an equipment and cycles through them as they are used.
Primary use case is for melee weapons with a sequence of abilities.

Note: On ability that you want to ignore chaining, set a bool custom property "IsAbilityChain" to false.
--]]

-- Internal custom properties
local EQUIPMENT = script:FindAncestorByType('Equipment')
if not EQUIPMENT:IsA('Equipment') then
    error(script.name .. " should be part of Equipment object hierarchy.")
end

-- Internal variables
local abilities = {}
local abilityIndex = 1

-- nil OnAbilityRecovery()
function OnAbilityRecovery()
	if (#abilities > 1) then
		abilities[abilityIndex].isEnabled = false
		abilities[abilityIndex].owner = nil

		abilityIndex = abilityIndex + 1
		if (abilityIndex > #abilities) then
			abilityIndex = 1
		end

		abilities[abilityIndex].isEnabled = true
		abilities[abilityIndex].owner = EQUIPMENT.owner
	end
end

-- Initialize
-- Add to the table all abilities that connects to a chain
for _, ability in pairs(EQUIPMENT:FindDescendantsByType("Ability")) do

    -- Automatically assumes an ability as part of chain if it doesn't have "IsAbilityChain" property set to false
    if ability:GetCustomProperty("IsAbilityChain") == nil or ability:GetCustomProperty("IsAbilityChain") == true then
        table.insert(abilities, ability)
        ability.isEnabled = (#abilities == 1)
        ability.recoveryEvent:Connect(OnAbilityRecovery)
    end
end