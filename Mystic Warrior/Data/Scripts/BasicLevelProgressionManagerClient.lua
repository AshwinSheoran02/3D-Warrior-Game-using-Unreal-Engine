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
As part of the Basic Level Progression component, this script shows feedback when the player levels up.
With each XP increase player sends out events for Message Banner to display XP change.
With each level increase player spawns vfx and also sends out a message.

See BasicLevelProgressionManagerServer for more information on how this component works.
--]]

-- Internal custom properties
local ABLP = require(script:GetCustomProperty("API"))
local COMPONENT_ROOT = script:GetCustomProperty("ComponentRoot"):WaitForObject()
local LEVELS_LIST = script:GetCustomProperty("LevelsList"):WaitForObject()

-- User exposed properties
local LEVEL_RESOURCE = COMPONENT_ROOT:GetCustomProperty("LevelResource")
local XP_RESOURCE = COMPONENT_ROOT:GetCustomProperty("XPResource")
local LEVEL_UPGRADE_FX = COMPONENT_ROOT:GetCustomProperty("LevelUpgradeFX")

-- Constant variables
local LOCAL_PLAYER = Game.GetLocalPlayer()
local DURATION = 5

-- Internal variables
local levelsTable = {}
local lastXP = 0

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

-- string GetLevelResource(Player)
-- Get level resource key
function GetLevelResource()
    return LEVEL_RESOURCE
end

-- string GetXPResource(Player)
-- Get XP resource key
function GetXPResource()
    return XP_RESOURCE
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

-- int GetLastRequiredXPForPlayer(Player)
-- Get last required XP based on player current level resource
function GetLastRequiredXPForPlayer(player)
    local previousLevel = GetPlayerLevel(player) - 1
    if previousLevel <= 0 then
        previousLevel = 1
    end
    return levelsTable[previousLevel].requiredXP
end

-- int GetNextRequiredXPForPlayer(Player)
-- Get next required XP based on player current level resource
function GetNextRequiredXPForPlayer(player)
    local nextLevel = GetPlayerLevel(player) + 1
    if nextLevel > #levelsTable then
        nextLevel = #levelsTable
    end
    return levelsTable[nextLevel].requiredXP
end

-- int GetLastMaxHPForPlayer(Player)
-- Get next max HP based on player current level resource
function GetLastMaxHPForPlayer(player)
    local previousLevel = GetPlayerLevel(player) - 1
    if previousLevel <= 0 then
        previousLevel = 1
    end
    return levelsTable[previousLevel].maxHP
end

-- int GetNextMaxHPForPlayer(Player)
-- Get next max HP based on player current level resource
function GetNextMaxHPForPlayer(player)
    local nextLevel = GetPlayerLevel(player) + 1
    if nextLevel > #levelsTable then
        nextLevel = #levelsTable
    end
    return levelsTable[nextLevel].maxHP
end

-- nil OnResourceChanged(Player, string, number)
-- Spawns vfx and sending message on player level upgrade
function OnResourceChanged(player, resource, value)
    if resource == LEVEL_RESOURCE and player == LOCAL_PLAYER then
        Events.Broadcast("BannerMessage", string.format("%s %d", LEVEL_RESOURCE, value))

        local addedMaxHP = GetMaxHPAtLevel(value) - GetLastMaxHPForPlayer(player)
        Events.Broadcast("SubBannerMessage", string.format("Max HP + %d", addedMaxHP), DURATION, Color.GREEN)

        if LEVEL_UPGRADE_FX then
            local instance = World.SpawnAsset(LEVEL_UPGRADE_FX, {position = player:GetWorldPosition()})
            instance:AttachToPlayer(player, "root")
        end
    end

    if resource == XP_RESOURCE and player == LOCAL_PLAYER then
        local addedXP = value - lastXP
        if addedXP > 0 then
            Events.Broadcast("SubBannerMessage", string.format("%s + %d", XP_RESOURCE, addedXP), DURATION, Color.CYAN)
            lastXP = value
        end
    end

    -- Broadcast to kill feed
    if resource == LEVEL_RESOURCE then
        Events.Broadcast("LevelUp", player, value)
    end
end

-- Initialize
Init()

local functionTable = {}
functionTable.GetLevelResource = GetLevelResource
functionTable.GetXPResource = GetXPResource
functionTable.GetLastRequiredXPForPlayer = GetLastRequiredXPForPlayer
functionTable.GetNextRequiredXPForPlayer = GetNextRequiredXPForPlayer
functionTable.GetLastMaxHPForPlayer = GetLastMaxHPForPlayer
functionTable.GetNextMaxHPForPlayer = GetNextMaxHPForPlayer

ABLP.RegisterLevelProgressionManager(functionTable)

-- Delay to get the resource information
Task.Wait(1)
LOCAL_PLAYER.resourceChangedEvent:Connect(OnResourceChanged)
lastXP = LOCAL_PLAYER:GetResource(XP_RESOURCE)

