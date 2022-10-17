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
This component introduces concept of Level and XP to player.
The player level is increased based on required XP threshold. Both Level and XP are set as resources.
As part of pregression, with each level increase player also gets max HP increased.

Open the "Levels List" group in hierarchy that comes with this component to edit the progression per level.

Note:
    - You can make the level progression to follow a formula instead of the LEVELS_LIST table.
      (Edit the all the code with "levelsTable" reference)
    - Level and XP resources can be named differently if needed.
    - Max HP becomes full on player level increase.
--]]

-- Internal custom properties
local COMPONENT_ROOT = script:GetCustomProperty("ComponentRoot"):WaitForObject()
local LEVELS_LIST = script:GetCustomProperty("LevelsList"):WaitForObject()

-- User exposed properties
local LEVEL_RESOURCE = COMPONENT_ROOT:GetCustomProperty("LevelResource")
local XP_RESOURCE = COMPONENT_ROOT:GetCustomProperty("XPResource")
local MAX_LEVEL = #LEVELS_LIST:GetChildren()

-- Internal variables
local levelsTable = {}

-- nil Init()
-- Create the table of level information from the LEVELS_LIST group
function Init()
    for _, child in ipairs(LEVELS_LIST:GetChildren()) do
        local requiredXP = child:GetCustomProperty("RequiredXP")
        local maxHP = child:GetCustomProperty("MaxHP")
        table.insert(levelsTable,
        {
            requiredXP = requiredXP,
            maxHP = maxHP
        })
    end
end

-- int GetPlayerLevel(Player)
-- Get player level based on current XP resource
function GetPlayerLevel(player)
    local resultLevel = 1
    local currentXP = player:GetResource(XP_RESOURCE)

    for i, levelInfo in ipairs(levelsTable) do
        if currentXP >= levelInfo.requiredXP then
            resultLevel = i
        end
    end

    return resultLevel
end

-- int GetRequiredXPAtLevel(Player)
-- Get required XP based on current level
function GetRequiredXPAtLevel(level)
    return levelsTable[level].requiredXP
end

-- int GetMaxHPAtLevel(Player)
-- Get max HP based on current level
function GetMaxHPAtLevel(level)
    return levelsTable[level].maxHP
end

-- nil SetNewMaxHealth(Player)
-- Set player max HP based on level
function SetNewMaxHealth(player)
    local currentLevel = player:GetResource(LEVEL_RESOURCE)

    player.hitPoints = levelsTable[currentLevel].maxHP
    player.maxHitPoints = levelsTable[currentLevel].maxHP
end

-- nil UpdatePlayerLevel(Player)
-- Check and update player level resource
function UpdatePlayerLevel(player)
    local currentLevel = player:GetResource(LEVEL_RESOURCE)
    local nextLevel = GetPlayerLevel(player)

    if nextLevel ~= currentLevel then
        player:SetResource(LEVEL_RESOURCE, nextLevel)
        SetNewMaxHealth(player)
    end
end

-- nil OnResourceChanged(Player, string, number)
-- Checking if the XP resource is changed to update the level
function OnResourceChanged(player, resource, value)
    if resource == XP_RESOURCE then
        -- Prevent the XP resource to go above the max level threshold
        if value > GetRequiredXPAtLevel(MAX_LEVEL) then
            player:SetResource(XP_RESOURCE, GetRequiredXPAtLevel(MAX_LEVEL))
        else
            UpdatePlayerLevel(player)
        end
    end
end

-- nil OnPlayerJoined(Player)
-- Register resource changed event and update player level
function OnPlayerJoined(player)
    player.resourceChangedEvent:Connect(OnResourceChanged)

    -- Short wait time to load level data and player max HP
    Task.Wait(.1)
    UpdatePlayerLevel(player)
    SetNewMaxHealth(player)
end

-- Initialize
Init()
Game.playerJoinedEvent:Connect(OnPlayerJoined)