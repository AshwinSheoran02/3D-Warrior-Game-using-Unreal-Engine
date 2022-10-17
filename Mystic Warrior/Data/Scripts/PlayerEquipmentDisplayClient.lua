--[[
Copyright 2020 Manticore Games, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
--]]

--[[
    Tracks player's current equipment at the specified socket.
    This script takes the icon information from the equipment and display it on UI.
    If the equipment is Weapon type, this script will display ammo information too.
]]

-- Internal custom properties
local AOI = require(script:GetCustomProperty("API"))
local COMPONENT_ROOT = script:GetCustomProperty("ComponentRoot"):WaitForObject()
local EQUIPMENT_ICON = script:GetCustomProperty("EquipmentIcon"):WaitForObject()
local EQUIPMENT_NAME_TEXT = script:GetCustomProperty("EquipmentNameText"):WaitForObject()
local AMMO_TEXT = script:GetCustomProperty("WeaponAmmoText"):WaitForObject()
local BACKGROUND_TINT = script:GetCustomProperty("BackgroundTint"):WaitForObject()

-- User exposed properties
local SOCKET = COMPONENT_ROOT:GetCustomProperty("Socket")

-- Constants
local LOCAL_PLAYER = Game.GetLocalPlayer()
local DEFAULT_IMAGE = EQUIPMENT_ICON:GetImage()
local DEFAULT_COLOR = BACKGROUND_TINT:GetColor()
local INITIAL_AMMO_TEXT_COLOR = AMMO_TEXT:GetColor()

function Tick()
    for _, equipment in ipairs(LOCAL_PLAYER:GetEquipment()) do
        if Object.IsValid(equipment) and equipment:GetAttachedToSocketName() == SOCKET then
            EQUIPMENT_NAME_TEXT.visibility = Visibility.INHERIT
            EQUIPMENT_NAME_TEXT.text = equipment.name

            if AOI.GetObjectIcon(equipment) then
                EQUIPMENT_ICON:SetImage(AOI.GetObjectIcon(equipment))
                BACKGROUND_TINT:SetColor(AOI.GetObjectColor(equipment))
            else
                EQUIPMENT_ICON:SetImage(DEFAULT_IMAGE)
                BACKGROUND_TINT:SetColor(DEFAULT_COLOR)
            end

            if equipment:IsA("Weapon") then
                AMMO_TEXT.visibility = Visibility.INHERIT
                if equipment.maxAmmo < 0 then
                    AMMO_TEXT.text = "∞"
                else
                    if equipment.currentAmmo == 0 then
                        AMMO_TEXT:SetColor(Color.PINK)
                    else
                        AMMO_TEXT:SetColor(INITIAL_AMMO_TEXT_COLOR)
                    end
                    AMMO_TEXT.text = string.format("%d", equipment.currentAmmo)
                end
            else
                AMMO_TEXT.visibility = Visibility.FORCE_OFF
            end
        end
    end
end

-- Initialize
EQUIPMENT_NAME_TEXT.visibility = Visibility.FORCE_OFF
AMMO_TEXT.visibility = Visibility.FORCE_OFF