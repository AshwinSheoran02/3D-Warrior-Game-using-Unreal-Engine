--[[
	You can modify speeds via the main folder in this template.
]]
local containerFolder = script.parent.parent

local function CanRun()
	-- any condition you want (stamina checking etc)
	return true
end

local function UpdateWalkSpeed(player, states)
	local prefix = states.Crouched and "Crouch" or ""
	local speedType = states.Running and "Run" or "Walk"

	if speedType == "Run" then
		if not CanRun() then
			speedType = "Walk"
		end
	end

	local speed = containerFolder:GetCustomProperty(prefix..speedType.."Speed")
	if states.Slow then
		speed = speed * containerFolder:GetCustomProperty("SlowWalkModifier")
	end
	player.maxWalkSpeed = speed
	player.maxSwimSpeed = speed
end

Events.ConnectForPlayer("changeMovementType", UpdateWalkSpeed)