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
    This script broadcasts an event to server when the player purchases the specified equipment.
    It checks for player cost resource and required resource as conditions for equipment purchase.
    Additionally, it shows the cost and required resource in world text for player to see.
]]

-- Internal custom properties
local COMPONENT_ROOT = script:GetCustomProperty("ComponentRoot"):WaitForObject()
local TRIGGER = script:GetCustomProperty("Trigger"):WaitForObject()
local SPAWN_PARENT = script:GetCustomProperty("SpawnParent"):WaitForObject()
local NAME_LABEL = script:GetCustomProperty("NameLabel"):WaitForObject()
local COST_LABEL = script:GetCustomProperty("CostLabel"):WaitForObject()
local REQUIRED_RESOURCE_LABEL = script:GetCustomProperty("ResourceLabel"):WaitForObject()

-- User exposed variables
local EQUIPMENT_NAME = COMPONENT_ROOT:GetCustomProperty("EquipmentName")
local EQUIPMENT_ASSET = COMPONENT_ROOT:GetCustomProperty("EquipmentAsset")
local COST_RESOURCE = COMPONENT_ROOT:GetCustomProperty("CostResource")
local COST_AMOUNT = COMPONENT_ROOT:GetCustomProperty("CostAmount")
local REQUIRED_RESOURCE = COMPONENT_ROOT:GetCustomProperty("RequiredResource")
local REQUIRED_RESOURCE_AMOUNT = COMPONENT_ROOT:GetCustomProperty("RequiredResourceAmount")
local PURCHASE_SUCCESS_SOUND = COMPONENT_ROOT:GetCustomProperty("PurchaseSuccessSound")
local PURCHASE_FAIL_SOUND = COMPONENT_ROOT:GetCustomProperty("PurchaseFailSound")
local HEIGHT_OFFSET = COMPONENT_ROOT:GetCustomProperty("HeightOffset")
local DISPLAY_SIZE = COMPONENT_ROOT:GetCustomProperty("DisplaySize")

-- Constants
local LOCAL_PLAYER = Game.GetLocalPlayer()
local EQUIPMENT_SOURCE_ID = CoreString.Split(EQUIPMENT_ASSET,":")

-- Internal variables
local previewInstance = nil

-- nil HasEquippedEquipment(Player)
-- If player has the equipment from this purchase display
function HasEquippedEquipment(player)
    local result = false
    for _, equipment in ipairs(player:GetEquipment()) do
        if equipment.sourceTemplateId == EQUIPMENT_SOURCE_ID then
            result = true
        end
    end
    return result
end

-- nil ShowSubBannerMessage(string, Color)
-- Wrapper function to show message to Message Banner component
function ShowSubBannerMessage(message, color)
    if color == nil then
        color = Color.WHITE
    end

    -- Duration by default is 2 for this script
    Events.Broadcast("SubBannerMessage", message, 2, color)
end

-- nil OnInteracted(Trigger, Player)
-- Check whether or not player is allowed to buy / equip the equipment on interaction
function OnInteracted(trigger, player)

    if HasEquippedEquipment(player) then
        ShowSubBannerMessage(string.format("Already Owned %s", EQUIPMENT_NAME), Color.ORANGE)
        if PURCHASE_FAIL_SOUND then
            World.SpawnAsset(PURCHASE_FAIL_SOUND, {parent = SPAWN_PARENT})
        end
        return
    end

    local hasEnoughCostResource = true
    local hasEnoughRequiredResource = true
    local hasPurchasedBefore = IsEquipmentPurchased(player)

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

    if hasEnoughCostResource and hasEnoughRequiredResource and not hasPurchasedBefore then
        -- Purchase logic
        local success = Events.BroadcastToServer("EP", COMPONENT_ROOT.id)
        if success then
            ShowSubBannerMessage(string.format("Purchased %s!", EQUIPMENT_NAME), Color.GREEN)
            previewInstance.visibility = Visibility.FORCE_OFF

            if PURCHASE_SUCCESS_SOUND then
                World.SpawnAsset(PURCHASE_SUCCESS_SOUND, {parent = SPAWN_PARENT})
            end
        else
            ShowSubBannerMessage("Purchase Error. Try Again!", Color.RED)
            if PURCHASE_FAIL_SOUND then
                World.SpawnAsset(PURCHASE_FAIL_SOUND, {parent = SPAWN_PARENT})
            end
        end
    elseif hasPurchasedBefore then
        -- Purchased and reequipping logic
        local success = Events.BroadcastToServer("EP", COMPONENT_ROOT.id)
        if success then
            ShowSubBannerMessage(string.format("Equipped %s!", EQUIPMENT_NAME), Color.GREEN)
            previewInstance.visibility = Visibility.FORCE_OFF

            if PURCHASE_SUCCESS_SOUND then
                World.SpawnAsset(PURCHASE_SUCCESS_SOUND, {parent = SPAWN_PARENT})
            end
        else
            ShowSubBannerMessage("Equipping Error. Try Again!", Color.RED)
            if PURCHASE_FAIL_SOUND then
                World.SpawnAsset(PURCHASE_FAIL_SOUND, {parent = SPAWN_PARENT})
            end
        end
    else
        -- Purchase fail logic
        if not hasEnoughRequiredResource then
            ShowSubBannerMessage(string.format("Need %s %d to Purchase!", REQUIRED_RESOURCE, REQUIRED_RESOURCE_AMOUNT), Color.RED)
        elseif not hasEnoughCostResource then
            ShowSubBannerMessage(string.format("Not Enough %s!", COST_RESOURCE), Color.RED)
        end

        if PURCHASE_FAIL_SOUND then
            World.SpawnAsset(PURCHASE_FAIL_SOUND, {parent = SPAWN_PARENT})
        end
    end

    -- Giving some delay to avoid spamming interaction trigger
    trigger.isInteractable = false
    Task.Wait(1)
    trigger.isInteractable = true

    previewInstance.visibility = Visibility.INHERIT
end

-- bool IsEquipmentPurchased(player)
-- Whether or not the player purchased the EQUIPMENT_ASSET
function IsEquipmentPurchased(player)
    if player:GetResource(EQUIPMENT_SOURCE_ID) ~= 0 then
        return true
    end

    return false
end

-- nil UpdateWorldTexts()
-- Update world text for cost and required resource info
-- You can add more information about the equipment by adjusting this function
function UpdateWorldTexts()
    NAME_LABEL.text = string.format("%s", EQUIPMENT_NAME)

    if IsEquipmentPurchased(LOCAL_PLAYER) then
        COST_LABEL.text = "Purchased"
        REQUIRED_RESOURCE_LABEL.text = ""
        TRIGGER.interactionLabel = string.format("Equip %s", EQUIPMENT_NAME)
    else
        if COST_AMOUNT > 0 then
            COST_LABEL.text = string.format("%d %s", COST_AMOUNT, COST_RESOURCE)
            REQUIRED_RESOURCE_LABEL.text = string.format("%s %d", REQUIRED_RESOURCE, REQUIRED_RESOURCE_AMOUNT)
        else
            COST_LABEL.text = "Free"
            REQUIRED_RESOURCE_LABEL.text = string.format("%s %d", REQUIRED_RESOURCE, REQUIRED_RESOURCE_AMOUNT)
        end
        TRIGGER.interactionLabel = string.format("Purchase %s", EQUIPMENT_NAME)
    end

end

-- nil OnResourceChanged(Player, string, number)
-- Checks for changes in cost and required resources and equipment asset id
function OnResourceChanged(player, resource, value)
    if player ~= LOCAL_PLAYER then return end

    if resource == COST_RESOURCE and not IsEquipmentPurchased(player) then
        if value < COST_AMOUNT then
            COST_LABEL:SetColor(Color.RED)
        else
            COST_LABEL:SetColor(Color.WHITE)
        end
    elseif resource == REQUIRED_RESOURCE and not IsEquipmentPurchased(player) then
        if value < REQUIRED_RESOURCE_AMOUNT then
            REQUIRED_RESOURCE_LABEL:SetColor(Color.RED)
        else
            REQUIRED_RESOURCE_LABEL:SetColor(Color.WHITE)
        end
    elseif EQUIPMENT_SOURCE_ID == resource and value ~= 0 then
        COST_LABEL:SetColor(Color.GREEN)
        REQUIRED_RESOURCE_LABEL:SetColor(Color.GREEN)

        UpdateWorldTexts()
    end
end


-- Initialize
TRIGGER.interactedEvent:Connect(OnInteracted)

LOCAL_PLAYER.resourceChangedEvent:Connect(OnResourceChanged)

SPAWN_PARENT:SetPosition(SPAWN_PARENT:GetPosition() + Vector3.UP * HEIGHT_OFFSET)
SPAWN_PARENT:SetScale(Vector3.ONE * DISPLAY_SIZE)

previewInstance = World.SpawnAsset(EQUIPMENT_ASSET, {parent = SPAWN_PARENT})
previewInstance.collision = Collision.FORCE_OFF

UpdateWorldTexts()
OnResourceChanged(LOCAL_PLAYER, COST_RESOURCE, LOCAL_PLAYER:GetResource(COST_RESOURCE))
OnResourceChanged(LOCAL_PLAYER, REQUIRED_RESOURCE, LOCAL_PLAYER:GetResource(REQUIRED_RESOURCE))
OnResourceChanged(LOCAL_PLAYER, EQUIPMENT_SOURCE_ID, LOCAL_PLAYER:GetResource(EQUIPMENT_SOURCE_ID))