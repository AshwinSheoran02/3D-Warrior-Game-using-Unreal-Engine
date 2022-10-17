--[[
	Animated Mesh Costume
	v1.0
	by: standardcombo
	
	Attaches objects to an NPC to customize its visuals.
	
	Automatically detects the animated mesh object that should be setup as
	its sibling in the hierarchy.
	
	Automatically detects siblings with names that match socket names on the
	animated mesh and attaches those groups to the mesh sockets.
	E.g. A group named "head" will attach to the animated mesh's head.
	
	Expects the animated mesh to be in the "bind" stance as the template is
	spawned. If the animated mesh is not in the "bind" stance, then
	attachments will appear out of place.
--]]

local MESH = script.parent:FindDescendantByType("AnimatedMesh")

local allObjects = script.parent:GetChildren()

for _,obj in ipairs(allObjects) do
	if obj:IsA("Folder") then
		local socketName = obj.name
		local pos = obj:GetWorldPosition()
		local rot = obj:GetWorldRotation()
		
		MESH:AttachCoreObject(obj, socketName)
		
		obj:SetWorldPosition(pos)
		obj:SetWorldRotation(rot)
	end
end