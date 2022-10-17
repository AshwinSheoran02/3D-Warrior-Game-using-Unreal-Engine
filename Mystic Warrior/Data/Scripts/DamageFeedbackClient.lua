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
local HIT_INDICATOR = script:GetCustomProperty("HitIndicator"):WaitForObject()
local HEALTH_CHANGE_POST_PROCESS = script:GetCustomProperty("HealthChangePostProcess"):WaitForObject()

-- User exposed properties
local DAMAGE_TEXT_DURATION = COMPONENT_ROOT:GetCustomProperty("DamageTextDuration")
local TARGET_DAMAGE_TEXT_COLOR = COMPONENT_ROOT:GetCustomProperty("TargetDamageTextColor")
local SELF_DAMAGE_TEXT_COLOR = COMPONENT_ROOT:GetCustomProperty("SelfDamageTextColor")
local SHOW_FLY_UP_TEXT = COMPONENT_ROOT:GetCustomProperty("ShowFlyUpText")
local IS_BIG_TEXT = COMPONENT_ROOT:GetCustomProperty("DisplayBigText")
local SHOW_HIT_FEEDBACK = COMPONENT_ROOT:GetCustomProperty("ShowHitFeedback")
local SHOW_HEALTH_CHANGE_EFFECT = COMPONENT_ROOT:GetCustomProperty("ShowHealthChangeEffect")
local HIT_FEEDBACK_SOUND = COMPONENT_ROOT:GetCustomProperty("HitFeedbackSound"):WaitForObject()

-- Constant variables
local LOCAL_PLAYER = Game.GetLocalPlayer()
local HIT_INDICATOR_DURATION = .5
local HEALTH_CHANGE_EFFECT_DURATION = .8

local effectStrength = 0.0
local targetEffectStrength = 0
local lastTime = 0

function Tick()
    local fraction = (time() - lastTime) / (HEALTH_CHANGE_EFFECT_DURATION / 2)
    if fraction > 1 then
        fraction = 1
    elseif fraction < 0 then
        fraction = 0
    end

    if targetEffectStrength == 1 then
        effectStrength = CoreMath.Lerp(0, 1, fraction)
    else
        effectStrength = CoreMath.Lerp(1, 0, fraction)
    end

    HEALTH_CHANGE_POST_PROCESS:SetSmartProperty("Effect Strength", effectStrength)
end

-- nil TriggerHitIndicator()
-- Displays the hit indicator once local player hit an enemy
function TriggerHitIndicator()
    HIT_INDICATOR.visibility = Visibility.INHERIT

    Task.Wait(HIT_INDICATOR_DURATION)

    HIT_INDICATOR.visibility = Visibility.FORCE_OFF
end

-- nil TriggerHitPostProcess(Color)
-- Displays the health change post process. Can represent increase or decrease in health.
function TriggerHitPostProcess(color)
    if not color then
        color = Color.RED
    end

    HEALTH_CHANGE_POST_PROCESS:SetSmartProperty("Tint C", color)
    lastTime = time()
    targetEffectStrength = 1

    Task.Wait(HEALTH_CHANGE_EFFECT_DURATION)

    lastTime = time()
    targetEffectStrength = 0
end

-- ShowFlyUpText(number, Vector3)
-- Display damage at position
function ShowFlyUpText(damage, position, color)
    if not SHOW_FLY_UP_TEXT then return end

    local newColor = color
    if not color then
        newColor = TARGET_DAMAGE_TEXT_COLOR
    end

    UI.ShowFlyUpText(string.format("%.0f", damage), position,
    {duration = DAMAGE_TEXT_DURATION,
    color = newColor,
    isBig = IS_BIG_TEXT})
end

-- nil DisplayDamage(float, Vector3, Player, Player)
-- Displays the fly up text on source player the damage or
-- shows damage direction to the target player
function DisplayDamage(damage, position, targetPlayer, sourcePlayer)
    if sourcePlayer == LOCAL_PLAYER then
        if position ~= Vector3.ZERO then
            -- Show fly up damage text at the specified position
            ShowFlyUpText(damage, position, TARGET_DAMAGE_TEXT_COLOR)
        end

        -- Play the damage feedback sound to the source player
        if HIT_FEEDBACK_SOUND then
            HIT_FEEDBACK_SOUND:Play()
        end

        -- Show the hit indicator feedback for this damage
        if SHOW_HIT_FEEDBACK then
            TriggerHitIndicator()
        end
    elseif targetPlayer == LOCAL_PLAYER then
        if damage > 0 then
            if Object.IsValid(sourcePlayer) then
                UI.ShowDamageDirection(sourcePlayer)
                ShowFlyUpText(damage, position, SELF_DAMAGE_TEXT_COLOR)
            elseif position ~= Vector3.ZERO then
                UI.ShowDamageDirection(position)
                ShowFlyUpText(damage, position, SELF_DAMAGE_TEXT_COLOR)
            end

            if SHOW_HEALTH_CHANGE_EFFECT then
                TriggerHitPostProcess(Color.RED)
            end
        elseif damage == 0 then
            UI.ShowFlyUpText("BLOCKED", LOCAL_PLAYER:GetWorldPosition(),
                {duration = DAMAGE_TEXT_DURATION,
                color = Color.CYAN,
                isBig = IS_BIG_TEXT})
        else
            if SHOW_HEALTH_CHANGE_EFFECT then
                TriggerHitPostProcess(Color.GREEN)
                ShowFlyUpText(math.abs(damage), LOCAL_PLAYER:GetWorldPosition(), Color.GREEN)
            end
        end
    end
end

-- Initialize
Events.Connect("PlayerDamage", DisplayDamage)

HIT_INDICATOR.visibility = Visibility.FORCE_OFF