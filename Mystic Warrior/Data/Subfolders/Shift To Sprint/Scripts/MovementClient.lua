--[[
	You can modify speeds via the main folder in this template.
]]

local player = Game.GetLocalPlayer();

local SHIFT_ABILITY = "ability_feet"
local CROUCH_ABILITY = "ability_extra_41";
local SLOW_WALK_ABILITY = "ability_extra_10";

local currentStates = {
	Crouched = false;
	Running = false;
	Slow = false;
}

local isSprinting, isCrouching, isSlowWalk = false, false, false

local function InputBegan(playerObject, event)
	if event == SHIFT_ABILITY then
		isSprinting = true
	elseif event == SLOW_WALK_ABILITY then
		isSlowWalk = true;
	end
end

local function InputEnded(playerObject, event)
	if event == SHIFT_ABILITY then
		isSprinting = false
	elseif event == SLOW_WALK_ABILITY then
		isSlowWalk = false
	end
end

function Tick()
	isCrouching = player.isCrouching
	local didChange = false
	local newStates = {
		Crouched = isCrouching;
		Running = isSprinting;
		Slow = isSlowWalk;
	}
	for state, oldValue in pairs(currentStates) do
		if oldValue ~= newStates[state] then
			didChange = true
			break
		end
	end
	currentStates = newStates
	if didChange then
		Events.BroadcastToServer("changeMovementType", currentStates)
	end
end

local function Initiate()
	player.bindingPressedEvent:Connect(InputBegan)
	player.bindingReleasedEvent:Connect(InputEnded)
end

Initiate()