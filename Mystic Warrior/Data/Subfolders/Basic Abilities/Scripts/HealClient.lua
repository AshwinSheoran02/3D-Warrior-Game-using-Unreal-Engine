
local EQUIPMENT = script:FindAncestorByType('Equipment')

local myAbility = script:FindAncestorByType('Ability')
local VFX = script:GetCustomProperty("HealthSpiralVFX")
local positionOffsetVFX = script:GetCustomProperty("PositionOffsetVFX")

local myVFX = nil

function OnExecute_MyAbility(ability)

	local player = EQUIPMENT.owner

	local myPosition = player:GetWorldPosition() + positionOffsetVFX
	local myRotation = player:GetWorldRotation()
	
	myVFX = World.SpawnAsset(VFX, {position = myPosition, rotation = myRotation})
	
	myVFX:Play()
	
	Task.Wait(1)
	
	myVFX:Destroy()
	
end

myAbility.executeEvent:Connect(OnExecute_MyAbility)