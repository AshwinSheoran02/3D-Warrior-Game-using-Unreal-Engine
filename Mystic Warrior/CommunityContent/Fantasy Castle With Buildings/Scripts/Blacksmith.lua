local MESH = script.parent

local allObjects = MESH:GetChildren()

for _, obj in ipairs(allObjects) do
    if obj:IsA("Folder") then
        local socketName = obj.name
        local pos = obj:GetWorldPosition()
        local rot = obj:GetWorldRotation()

        MESH:AttachCoreObject(Bone_Human_Humerus_01, left_rist)

        obj:SetWorldPosition(pos)
        obj:SetWorldRotation(rot)
    end
end