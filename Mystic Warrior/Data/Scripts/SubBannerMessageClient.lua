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

local COMPONENT_ROOT = script:GetCustomProperty("ComponentRoot"):WaitForObject()

local BACKGROUND = COMPONENT_ROOT:GetCustomProperty("Background"):WaitForObject()
local BANNER_TEXT = COMPONENT_ROOT:GetCustomProperty("BannerText"):WaitForObject()
local OFFSET_DISTANCE = COMPONENT_ROOT:GetCustomProperty("OffsetDistance")

-- Variables
local startTime = time()
local startOffset = BANNER_TEXT.y

function Tick(deltaTime)
    local currentTimeFraction = (time() - startTime) / COMPONENT_ROOT.lifeSpan
    if currentTimeFraction > 1 then
        COMPONENT_ROOT:Destroy()
        return
    end

    local textColor = BANNER_TEXT:GetColor()
    textColor.a = 1 - currentTimeFraction
    BANNER_TEXT:SetColor(textColor)
    BANNER_TEXT.y = startOffset - math.ceil(OFFSET_DISTANCE * currentTimeFraction)

    local bgColor = BACKGROUND:GetColor()
    bgColor.a = 1 - currentTimeFraction
    BACKGROUND:SetColor(bgColor)
    BACKGROUND.y = startOffset - math.ceil(OFFSET_DISTANCE * currentTimeFraction)
end

Task.Wait()