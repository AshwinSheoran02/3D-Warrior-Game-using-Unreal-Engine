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
local AS = require(script:GetCustomProperty("API"))
local COMPONENT_ROOT = script:GetCustomProperty("ComponentRoot"):WaitForObject()
local TEXT_BOX = script:GetCustomProperty("TextBox"):WaitForObject()
local PROGRESS_BAR = script:GetCustomProperty("ProgressBar"):WaitForObject()
local PANEL = script:GetCustomProperty("Panel"):WaitForObject()

-- User exposed properties
local MIN_CAST_TIME = COMPONENT_ROOT:GetCustomProperty("MinCastTime")
local SHOW_NAME = COMPONENT_ROOT:GetCustomProperty("ShowName")
local BINDING = COMPONENT_ROOT:GetCustomProperty("Binding")
local LOCAL_PLAYER = Game.GetLocalPlayer()

-- Player GetViewedPlayer()
-- Returns which player the local player is spectating (or themselves if not spectating)
function GetViewedPlayer()
    local specatatorTarget = AS.GetSpectatorTarget()

    if AS.IsSpectating() and specatatorTarget then
        return specatatorTarget
    end

    return LOCAL_PLAYER
end

function Tick(deltaTime)
    local player = GetViewedPlayer()
    PROGRESS_BAR.visibility = Visibility.FORCE_OFF
    TEXT_BOX.visibility = Visibility.FORCE_OFF
    PANEL.visibility = Visibility.FORCE_OFF

    if player then
        for _, ability in pairs(player:GetAbilities()) do
            if BINDING == "" or BINDING == ability.actionBinding then
                if ability:GetCurrentPhase() == AbilityPhase.CAST then

                    PANEL.visibility = Visibility.INHERIT
                    local remainingTime = ability:GetPhaseTimeRemaining()
                    local totalTime = ability.castPhaseSettings.duration

                    if totalTime >= MIN_CAST_TIME then
                        PROGRESS_BAR.visibility = Visibility.INHERIT
                        PROGRESS_BAR.progress = CoreMath.Clamp(1.0 - remainingTime / totalTime, 0.0, 1.0)

                        if SHOW_NAME then
                            TEXT_BOX.visibility = Visibility.INHERIT
                            TEXT_BOX.text = ability.name
                        end

                        return
                    end
                end
            end
        end
    end
end

-- Initialize
TEXT_BOX.visibility = Visibility.FORCE_OFF
PROGRESS_BAR.visibility = Visibility.FORCE_OFF
