--[[
	NPCCampBehavior - Player Proximity
	by: standardcombo
	v0.9.0
	
	Works in conjunction with NPCSpawner and expects it as a sibling script.
		
	
	Camp Behavior
	
	The camp's behavior is driven by the scripts 'NPCSpawner' and
	'NPCCampBehavior_PlayerProximity'. These scripts define "When" and "How" to spawn NPCs.
	Each of the scripts has custom properties that can be tuned to adjust their behavior.
	
	The Proximity camp is characterized by two triggers, one small and one large--also called
	the "Inside Trigger" and the "Outside Trigger". Adjusting the position, type and size
	of these two triggers is essential to correctly setting up a proximity camp.
	
	The inside trigger is what detects players entering the camp and spawns the NPCs, while
	the outside trigger's job is to keep track of players who are present, so that when
	there are no more players in the camp the NPCs can be despawned.
	
	
	Spawn Points
	
	NPC camps are characterized by a number of spawn points that tell the spawner scripts
	"What" and "Where" to spawn. Each spawn point has references to the NPC templates which
	they will spawn. These are setup as custom properties. A spawn point can have any number
	of NPC templates assigned as custom properties. No specific names need to be given to
	those custom properties. The position and rotation of a spawn point determine the
	orientation of the NPCs that spawn from it. Spawn points are usually placed touching the
	ground and should be adjusted on uneven terrain.
	
	This assemblage of parts is what allows NPC camps to come in all forms, to spawn all
	kinds of NPCs, in various compositions, and to behave in different ways as players
	approach or leave the area.
	
	
	For more information check the tooltips on each of the script properties.
--]]

local INSIDE_TRIGGER = script:GetCustomProperty("InsideTrigger"):WaitForObject()
local OUTSIDE_TRIGGER = script:GetCustomProperty("OutsideTrigger"):WaitForObject()
local DESPAWN_DELAY = script:GetCustomProperty("DespawnDelay") or 4
local RESPAWN_COOLDOWN = script:GetCustomProperty("RespawnCooldown") or 15
local RESET_ON_ROUND_START = script:GetCustomProperty("ResetOnRoundStart")
local RESET_ON_ROUND_END = script:GetCustomProperty("ResetOnRoundEnd")

local CAMP_SPAWNER = script.parent:FindChildByName("NPCSpawner")

local playerCount = 0
local despawnCountdown = 0
local lastMinionCount = 0
local respawnCooldown = 0


function Reset()
	CAMP_SPAWNER.context.Despawn()
	
	despawnCountdown = 0
	lastMinionCount = 0
	respawnCooldown = 0
end

function Tick(deltaTime)	
	if (despawnCountdown > 0) then
		despawnCountdown = despawnCountdown - deltaTime
		
		if (despawnCountdown <= 0) then
			CAMP_SPAWNER.context.Despawn()
		end
	end
	
	if (respawnCooldown > 0) then
		respawnCooldown = respawnCooldown - deltaTime
	end
	
	local minionCount = CAMP_SPAWNER.context.minionCount
	if (minionCount == 0 and lastMinionCount > 0) then
		respawnCooldown = RESPAWN_COOLDOWN
	end
	lastMinionCount = minionCount
end

function OnBeginOverlapInner(theTrigger, player)
	if (not player:IsA("Player")) then return end
		
	if (CAMP_SPAWNER.context.minionCount == 0 and
		respawnCooldown <= 0) then
		
		CAMP_SPAWNER.context.Spawn()
		
		-- Aggro the minions
		Task.Wait()
		for _,minion in pairs(CAMP_SPAWNER.context.minions) do
			local aiScript = minion:FindChildByName("NPCAIServer")
			if aiScript then
				aiScript.context.SetTemporaryVisionHalfAngle(360, 1)
				aiScript.context.EngageNearest()
			end
		end
	end
end

function OnBeginOverlapOuter(theTrigger, player)
	if (not player:IsA("Player")) then return end
	
	playerCount = playerCount + 1
	
	despawnCountdown = 0
end

function OnEndOverlapOuter(theTrigger, player)
	if (not player:IsA("Player")) then return end
	
	playerCount = playerCount - 1
	
	if (playerCount <= 0) then
		despawnCountdown = DESPAWN_DELAY
		
		-- Send the minions home
		for _,minion in pairs(CAMP_SPAWNER.context.minions) do
			local aiScript = minion:FindChildByName("NPCAIServer")
			if aiScript then
				aiScript.context.SetTemporaryVisionRadius(0, 3)
				aiScript.context.SetTemporaryHearingRadius(0, 3)
				aiScript.context.ResumePatrol()
			end
		end
	end
end

INSIDE_TRIGGER.beginOverlapEvent:Connect(OnBeginOverlapInner)
OUTSIDE_TRIGGER.beginOverlapEvent:Connect(OnBeginOverlapOuter)
OUTSIDE_TRIGGER.endOverlapEvent:Connect(OnEndOverlapOuter)


if RESET_ON_ROUND_START then
	Game.roundStartEvent:Connect(Reset)
end

if RESET_ON_ROUND_END then
	Game.roundEndEvent:Connect(Reset)
end

