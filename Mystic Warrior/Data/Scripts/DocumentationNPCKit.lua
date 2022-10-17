--[[
	NPC AI Kit
	v0.9.0
	by: standardcombo

	Known Issues with NPC AI Kit
	============================

	- Consumes a large amount of the networking budget.
	- Ranged NPCs may try to attack through walls and don't adapt to obstacles when targeting.

	Combat
	======

	The weapons with type "Weapon" has a script called DestructableWeaponServer or DestructableWeaponAOE
	that makes it deal damage to NPCs. Add those script to any Core weapon to make it compatible with the NPC Kit.

	The weapons with type "Equipment" has a script called MeleeAbilityServer that makes it deal damage to NPCs.
	Add that script to any Core weapon to make it compatible with the NPC Kit. Add this script to other melee weapons
	to make them compatible with the NPC Kit.


	NPC Camps & Spawn Points
	========================

	Each NPC example has a set of Spawn Points and a combination of spawn scripts that determine
	when/how the NPCs spawn. Each minion Spawn Point has a list of possible NPCs it can spawn, added
	to it as custom properties. To change which NPCs spawn, configure the spawn points. You can add
	or remove spawn points to increase/decrease the amount of NPCs spawned at each camp.

	NPC camps are characterized by a number of spawn points that tell the spawner scripts
	"What" and "Where" to spawn. Each spawn point has references to the NPC templates which
	they will spawn. These are setup as custom properties. A spawn point can have any number
	of NPC templates assigned as custom properties. No specific names need to be given to
	the custom properties on spawn points. The position and rotation of a spawn point
	determine the orientation of the NPCs that spawn from it. Spawn points are usually
	placed touching the ground and should be adjusted on uneven terrain.

	This assemblage of parts is what allows NPC camps to come in all forms, to spawn all
	kinds of NPCs, in various compositions, and to behave in different ways as players
	approach or leave the area.

	You 'can' add NPCs directly into the hierarchy and they will work, but won't respawn if killed.
	That's what the camps and spawn points are for.

	See comments in each of the spawn scripts for details about their specific spawn behaviors.

	Waypoints
	=========

	The patrolling behavior of the NPCs is determined by the design of the waypoint objects.
	This example comes with three waypoints: "main", "A" and "B".

	Each waypoint has an area defined by its child trigger. Each waypoint also has
	references to other waypoints, forming a network. When an NPC enters a waypoint's area,
	it looks at the list of other waypoints that have been assigned as custom properties
	and selects one of them at random. The NPC is directed to go to the chosen waypoint and
	the cycle continues until the NPC exits the patrolling state--for example if they are
	engaged in combat.

	If a waypoint only has one destination assigned to it then that is always chosen as
	the next patrol destination. If a waypoint has no destination waypoints assigned to it
	then it behaves as an end point. NPCs that reach a waypoint with no destinations are
	put to "sleep".


	Creating Your Own NPCs
	======================

	1. Select an existing NPC as a starting point. Add it to the hierarchy.
	2. Right-click and create a new template. Give it a unique name.
	3. Customize it visually. See the NPC - Skeletons for examples of this.
	4. Customize the Collider. Change the Collider's Visibility to see it in
	   relationship to the rest of the NPC.
	5. Customize its properties, such as movement speed, damage and health.
	6. Right-click the NPC in the hierarchy and "Update Template From This".


	Adding NPCs to a Game
	=====================

	1. You can position your NPCs directly in the game to test their behaviors.
	   However, they won't respawn if killed.
	2. Add a spawn camp, such as the NPC Camp - Always Spawn.
	3. Right-click the camp and "Deinstance" it.
	4. Select one of the camp's spawn points where your NPC should appear.
	5. From Project Content, drag your NPC template onto the Properties view
	   to add it as a custom property on the spawn point.
	6. Delete your NPC templates from the hierarchy. They should be spawned with
	   Camps and Spawn Points instead of being directly placed.

	Teams
	=====

	NPCs have a Team property that is copied from the NPCSpawner object in their camp. If their team
	is the same as a player, they will treat that player as an ally. If they are a different team
	they will be treated as enemies. NPCs that are on different teams will attack each other.


	More Comments
	=============

	See comments in the different NPC AI scripts for more details about their behaviors.
--]]


