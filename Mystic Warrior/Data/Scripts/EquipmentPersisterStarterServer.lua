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
    On player joining the game, this script equips the player with equipment that they purchased in the last game.

    Note: Attach EquipmentPersisterServer to any equipment you wish to save. Read more information in that script.
]]

-- Internal custom properties
local DEFAULT_EQUIPMENT = script:GetCustomProperty("DefaultEquipment")

-- bool EquipToPlayer(Player)
-- Equip the specified equipment
function EquipToPlayer(player, equipmentAsset)
    local instance = World.SpawnAsset(equipmentAsset)
    if Object.IsValid(player) then
        instance:Equip(player)
    else
        instance:Destroy()
    end
end

-- nil OnPlayerJoined(Player)
function OnPlayerJoined(player)
	local playerData = Storage.GetPlayerData(player)
    local equipped = false

	if type(playerData.equipment) ~= "table" then
		playerData.equipment = {}
	end

    if Object.IsValid(player) then
        for _, equipmentAssetId in pairs(playerData.equipment) do
            Task.Spawn(function() EquipToPlayer(player, equipmentAssetId) end)
            equipped = true
        end
    end

    if not equipped then
        EquipToPlayer(player, DEFAULT_EQUIPMENT)
    end
end

-- Initialize
Game.playerJoinedEvent:Connect(OnPlayerJoined)