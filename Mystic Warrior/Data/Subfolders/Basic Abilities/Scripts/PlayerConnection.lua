local EQUIPMENT = script.parent


local equiped = false



function OnPlayerJoined(player)
	player.canMount = false
	
	if not equiped then
		EQUIPMENT:Equip(player)
		equiped = true
	end
end

Game.playerJoinedEvent:Connect(OnPlayerJoined)

