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
local PROGRESS_PANEL = script:GetCustomProperty("ProgressPanel"):WaitForObject()
local PROGRESS_IMAGE = script:GetCustomProperty("ProgressImage"):WaitForObject()

-- Internal variables
local isBlocking = false
local lastTime = time()
local castDuration = 1

local INITIAL_WIDTH = PROGRESS_IMAGE.width

function Tick(deltaTime)
    if isBlocking then
        local progress = CoreMath.Lerp(0, 1, (time() - lastTime) / castDuration)
        PROGRESS_IMAGE.width = CoreMath.Round(INITIAL_WIDTH * (1 - progress))
    end
end

function OnBlocking (toggle, duration)
    isBlocking = toggle
    castDuration = duration

    if toggle then
        lastTime = time()
        PROGRESS_PANEL.visibility = Visibility.INHERIT
        PROGRESS_IMAGE.width = INITIAL_WIDTH
    else
        PROGRESS_PANEL.visibility = Visibility.FORCE_OFF
    end
end

-- Initialize
Events.Connect("BlockingDisplay", OnBlocking)