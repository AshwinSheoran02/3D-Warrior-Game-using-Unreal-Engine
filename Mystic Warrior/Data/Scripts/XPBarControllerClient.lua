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
local ABLP = require(script:GetCustomProperty("API"))
local TEXT_BOX = script:GetCustomProperty("TextBox"):WaitForObject()
local PROGRESS_BAR = script:GetCustomProperty("ProgressBar"):WaitForObject()

-- Constant variables
local LOCAL_PLAYER = Game.GetLocalPlayer()

function OnResourceChanged(player, resource, value)
    if resource == ABLP.GetXPResource() and player == LOCAL_PLAYER then
        local nextXP = ABLP.GetNextRequiredXPForPlayer(LOCAL_PLAYER)
        local previousXP = ABLP.GetLastRequiredXPForPlayer(LOCAL_PLAYER)

        if value >= nextXP then
            TEXT_BOX.text = "MAX"
        else
            TEXT_BOX.text = string.format("XP: %d / %d", value, nextXP)
        end

        if previousXP == 0 then
            PROGRESS_BAR.progress = (value - previousXP) / nextXP
        else
            PROGRESS_BAR.progress = (value - previousXP) / (nextXP - previousXP)
        end
    end
end

LOCAL_PLAYER.resourceChangedEvent:Connect(OnResourceChanged)

Task.Wait()
OnResourceChanged(LOCAL_PLAYER, ABLP.GetXPResource(), LOCAL_PLAYER:GetResource(ABLP.GetXPResource()))