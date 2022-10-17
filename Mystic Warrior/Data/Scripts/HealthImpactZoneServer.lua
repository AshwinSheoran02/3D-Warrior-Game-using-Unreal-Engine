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
local TRIGGER = script:GetCustomProperty("Trigger"):WaitForObject()

local HEALTH_CHANGE = COMPONENT_ROOT:GetCustomProperty("HealthChange")
local CHANGE_RATE = COMPONENT_ROOT:GetCustomProperty("ChangeRate")

-- Internal variables
local impactedPlayers = {}

function Tick()
    for player, lastTime in pairs(impactedPlayers) do
        if lastTime ~= nil and time() - lastTime > CHANGE_RATE then
            player:ApplyDamage(Damage.New(HEALTH_CHANGE))
            impactedPlayers[player] = time()
        end
    end
end

function OnBeginOverlap(trigger, other)
	if other:IsA("Player") then
        impactedPlayers[other] = time() - CHANGE_RATE
	end
end

function OnEndOverlap(trigger, other)
	if other:IsA("Player") then
        impactedPlayers[other] = nil
	end
end

function OnPlayerLeft(player)
    impactedPlayers[player] = nil
end

-- Initialize
TRIGGER.beginOverlapEvent:Connect(OnBeginOverlap)
TRIGGER.endOverlapEvent:Connect(OnEndOverlap)

Game.playerLeftEvent:Connect(OnPlayerLeft)