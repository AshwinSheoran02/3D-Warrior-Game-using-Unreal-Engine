
local EQUIPMENT = script:FindAncestorByType('Equipment')

local myAbility = script.parent
local healAmount = myAbility:GetCustomProperty("HealAmount")



-- function to connect event handlers to ability events 
function ConnectAbilityEvents_MyAbility(ability)
	
	ability.executeEvent:Connect(OnExecute_MyAbility)
	
end

--heals the Player
function OnExecute_MyAbility(ability)

	local player = EQUIPMENT.owner
	
	player.hitPoints = player.hitPoints + healAmount
	if player.hitPoints > player.maxHitPoints then
		player.hitPoints = player.maxHitPoints
	end
	
end


-- call to connect events to ability. 
-- this does not give the ability to player, that need to be handled separately depending on how ability is created in game
ConnectAbilityEvents_MyAbility(myAbility)

--------------------------------------------------------------------------------