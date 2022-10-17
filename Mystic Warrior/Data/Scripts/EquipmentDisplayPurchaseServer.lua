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
    This script listens to an event and equips the player with equipment that they purchase.
    It checks for player cost resource and required resource as conditions for equipment purchase.

    E.g. a Weapon that costs 15 coins and requires level 3.

    This script assumes that purchased equipment are saved as resources externally (see ResourcePersisterServer for more details).
]]

-- Internal custom properties
local COMPONENT_ROOT = script:GetCustomProperty("ComponentRoot"):WaitForObject()

-- User exposed variables
local EQUIPMENT_ASSET = COMPONENT_ROOT:GetCustomProperty("EquipmentAsset")
local COST_RESOURCE = COMPONENT_ROOT:GetCustomProperty("CostResource")
local COST_AMOUNT = COMPONENT_ROOT:GetCustomProperty("CostAmount")
local REQUIRED_RESOURCE = COMPONENT_ROOT:GetCustomProperty("RequiredResource")
local REQUIRED_RESOURCE_AMOUNT = COMPONENT_ROOT:GetCustomProperty("RequiredResourceAmount")

-- Constants
local EQUIPMENT_SOURCE_ID = CoreString.Split(EQUIPMENT_ASSET,":")

-- nil SavePurchasedEquipment(Player)
-- Saves EQUIPMENT_ASSET id as resource of a purchased item
function SavePurchasedEquipment(player)
    -- This resource will communicate to client scripts whether or not you purchased the equipment
    player:SetResource(EQUIPMENT_SOURCE_ID, 1)
end

-- bool IsEquipmentPurchased(player)
-- Whether or not the player purchased the EQUIPMENT_ASSET
function IsEquipmentPurchased(player)
    if player:GetResource(EQUIPMENT_SOURCE_ID) ~= 0 then
        return true
    end

    return false
end

-- bool EquipToPlayer(Player)
-- Equip the specified equipment and destroys previous equipment at the same socket
function EquipToPlayer(player)
    local equipmentInstance = World.SpawnAsset(EQUIPMENT_ASSET)
    for _, currentEquipment in ipairs(player:GetEquipment()) do
        if currentEquipment.socket == equipmentInstance.socket then
            currentEquipment:Destroy()
        end
    end
    equipmentInstance:Equip(player)
end

-- bool OnEquipmentPurchase(Player, string)
-- Checks the conditions to purchase equipment for player
function OnEquipmentPurchase(player, rootId)
    if rootId ~= COMPONENT_ROOT.id then return end

    if IsEquipmentPurchased(player) then
        EquipToPlayer(player)
        return
    end

    local hasEnoughCostResource = true
    local hasEnoughRequiredResource = true

    if COST_RESOURCE ~= "" then
        local costResource = player:GetResource(COST_RESOURCE)
        if costResource < COST_AMOUNT then
            hasEnoughCostResource = false
        end
    end

    if REQUIRED_RESOURCE ~= "" then
        local requiredResource = player:GetResource(REQUIRED_RESOURCE)
        if requiredResource < REQUIRED_RESOURCE_AMOUNT then
            hasEnoughRequiredResource = false
        end
    end

    -- Allow purchase if both conditions are met
    if hasEnoughCostResource and hasEnoughRequiredResource then
        player:AddResource(COST_RESOURCE, -COST_AMOUNT)
        EquipToPlayer(player)
        SavePurchasedEquipment(player)
    end
end

-- Initialize
-- "EP" stands for Equipment Purchase. This event is called from EquipmentDisplayPurchaseClient script.
Events.ConnectForPlayer("EP", OnEquipmentPurchase)