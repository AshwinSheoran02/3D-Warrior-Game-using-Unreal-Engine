local NavMeshGenerator = require(script:GetCustomProperty("NavMeshGenerator"))
local NAVMESH_FOLDER = script:GetCustomProperty("NAVMESH_FOLDER"):WaitForObject()

local NavMesh = {}
_G.NavMesh = NavMesh

NavMesh.rectangles = NavMeshGenerator.GetRectangles(NAVMESH_FOLDER)

function pointToNode(point) -- get a "node" from the point by projecting it onto the nearest rectangle
	local minDistanceSquared, closestPoint, closestRectangle = math.huge
	for _, rectangle in pairs(NavMesh.rectangles) do
		local projection = NavMeshGenerator.closestPointOnRectangle(point, rectangle)
		local distanceSquared = (point - projection).sizeSquared
		if distanceSquared < minDistanceSquared then
			minDistanceSquared, closestPoint, closestRectangle = distanceSquared, projection, rectangle
		end
	end
	return {position = closestPoint, connectedRectangles = {closestRectangle}}
end

local MinHeap = {New = function()
	local heap = {}
	return {Insert = function(self, value)
		local valueIndex = #heap + 1
		while true do -- bubble up
			local parentIndex = valueIndex//2
			if parentIndex == 0 or value >= heap[parentIndex] then
				heap[valueIndex] = value
				break
			else
				heap[valueIndex], valueIndex = heap[parentIndex], parentIndex
			end
		end
	end, Extract = function(self)
		local value, parent, parentIndex = heap[1], table.remove(heap), 1
		while true do -- bubble down
			local leftChild, rightChild = heap[parentIndex*2], heap[parentIndex*2+1]
			if not leftChild or (parent <= leftChild and (not rightChild or parent <= rightChild)) then
				if parentIndex ~= #heap+1 then heap[parentIndex] = parent end
				return value
			elseif parent > leftChild and (not rightChild or leftChild <= rightChild) then
				heap[parentIndex], parentIndex = leftChild, parentIndex*2
			elseif parent > rightChild then
				heap[parentIndex], parentIndex = rightChild, parentIndex*2+1
			end
		end
	end, heap = heap}
end}

function NavMesh.FindPath(startPoint, endPoint)
	local startNode = pointToNode(startPoint)
	local endNode = pointToNode(endPoint)
	local endRectangle = endNode.connectedRectangles[1]
	
	local pathNodeMetatable = {
		__le = function(a, b) return a.lengthPlusHeuristic <= b.lengthPlusHeuristic end,
		__lt = function(a, b) return a.lengthPlusHeuristic < b.lengthPlusHeuristic end
	}
	
	local priorityQueue = MinHeap.New()
	priorityQueue:Insert(setmetatable({path = {startNode}, length = 0, lengthPlusHeuristic = 0}, pathNodeMetatable))
	local visitedNodes = {}
	
	local clock = os.clock()
	local solutionPath = nil
	local iterations = 0
	while priorityQueue.heap[1] and not solutionPath do
		iterations = iterations + 1
		local currentElement = priorityQueue:Extract()
		local currentNode = currentElement.path[#currentElement.path]
		if not visitedNodes[currentNode] then
			visitedNodes[currentNode] = true
			for _, rectangle in pairs(currentNode.connectedRectangles) do
				if rectangle == endRectangle then
					solutionPath = currentElement.path
					solutionPath[#solutionPath + 1] = endNode
					break
				end
				for _, node in pairs(rectangle.nodes) do
					if not visitedNodes[node] then
						local newPath = {table.unpack(currentElement.path)}
						newPath[#newPath + 1] = node
						local newLength = currentElement.length + (currentNode.position - node.position).size
						priorityQueue:Insert(setmetatable({
							path = newPath,
							length = newLength,
							lengthPlusHeuristic = newLength + (node.position - endNode.position).size
						}, pathNodeMetatable))
					end
				end
			end
		end
	end
	if iterations > 100 then
		--print("path found in "..((os.clock() - clock)*1000).." ms "..iterations)
	end
	
	if solutionPath then
		-- remove unnecessary nodes when a straight line is possible
		-- changes in elevation like ramps are a complicated edge case. todo
		
		local startNodeIndex = 1
		while startNodeIndex <= #solutionPath - 2 do
			--[[local startNode = solutionPath[startNodeIndex] -- WIP
			
			local startNodeRectangleDict = {}
			for _, rect in pairs(startNode.connectedRectangles) do
				currentNodeRectangleDict[rect] = true
			end
			
			local currentRect -- current rectangle that the line is being projected onto
			local function setCurrentRect(newRect)
				currentRect = newRect
				local connectedRectangles = {}
				for _, node in pairs(currentRect.nodes) do
					for _, rect in pairs(node.connectedRectangles) do
						if rect ~= currentRect then
							connectedRectanges[rect] = true
						end
					end
				end
			end
			setCurrentRect(node1.connectedRectangles[1])
			
			local currentShortcut = {startNode.position}
			for skipNodeIndex = startNodeIndex + 2, #solutionPath do
				local currentNode = solutionPath[skipNodeIndex - 2]
				local betweenNode = solutionPath[skipNodeIndex - 1]
				local skipNode = solutionPath[skipNodeIndex]
				
				local currentNodeRectangleDict = {}
				local betweenNodeRectangleDict = {}
				local skipNodeRectangleDict = {}
				local node2RectangleDict = {}
				for _, rect in pairs(currentNode.connectedRectangles) do
					currentNodeRectangleDict[rect] = true
				end
				for _, rect in pairs(betweenNode.connectedRectangles) do
					betweenNodeRectangleDict[rect] = true
				end
				for _, rect in pairs(skipNode.connectedRectangles) do
					skipNodeRectangleDict[rect] = true
				end
				
				local node2projection = node2.position - currentRect.normal * (currentRect.normal .. (node2.position - currentRect.vertices[1]))
				-- find where the projected line intersects a rectangle that's connected to the in-between node and node1 and node2
				for _, rect in pairs(solutionPath[skipNodeIndex - 1].connectedRectangles) do
					if node1RectangleDict[rect] and node2RectangleDict[rect] then
						local linePoint, rectPoint = NavMeshGenerator.closestPointsBetweenLineSegmentAndRectangle(node1.position, node2projection, rect)
						local intersections = {}
						if linePoint then -- not coplanar
							if (linePoint - rectPoint).sizeSquared < 1 then
								intersections[#intersections + 1] = linePoint
							end
						else -- coplanar, check for edge intersections
							for _, edge in pairs(rect.edges) do
								local linePoint, edgePoint = NavMeshGenerator.closestPointsBetweenTwoLineSegments(node1.position, node2projection, edge[1], edge[2])
								if linePoint and (linePoint - edgePoint).sizeSquared < 1 then -- line intersects this edge
									intersections[#intersections + 1] = linePoint
								end
							end
						end
						if #intersections == 2 then
							local linePoint, borderPoint = NavMeshGenerator.closestPointsBetweenTwoLineSegments(node1.position, node2projection, intersections[1], intersections[2])
							if linePoint and (linePoint - borderPoint).sizeSquared < 1 then -- shortcut is valid
								setCurrentRect(rect)
								currentShortcut[#currentShortcut + 1] = 
								break
							end
						end
					end
				end
			end]]
			
			local node1 = solutionPath[startNodeIndex]
			
			local importantRectangleDict = {}
			for _, rect in pairs(node1.connectedRectangles) do
				importantRectangleDict[rect] = true
			end
			
			while solutionPath[startNodeIndex + 2] do
				local node2 = solutionPath[startNodeIndex + 2]
				-- check if the line exits the walkable space. if it doesn't then remove the node in-between
				for _, rect in pairs(solutionPath[startNodeIndex + 1].connectedRectangles) do
					importantRectangleDict[rect] = true -- also list rectangles connected to the in-between node
				end
				for _, rect in pairs(node2.connectedRectangles) do
					importantRectangleDict[rect] = true
				end
				local intersections = {} -- list all intersections with the rectangles in importantRectangleDict. order them by distance from one end of the line segment.
				for rect in pairs(importantRectangleDict) do
					local linePoint, rectPoint = NavMeshGenerator.closestPointsBetweenLineSegmentAndRectangle(node1.position, node2.position, rect)
					if linePoint then -- not coplanar
						if (linePoint - rectPoint).sizeSquared < 1 then
							intersections[#intersections + 1] = linePoint
						end
					else -- line is on the same plane as the rectangle, do edge intersection checks instead
						for _, edge in pairs(rect.edges) do
							local linePoint, edgePoint = NavMeshGenerator.closestPointsBetweenTwoLineSegments(node1.position, node2.position, edge[1], edge[2])
							if linePoint and (linePoint - edgePoint).sizeSquared < 1 then -- line intersects this edge
								intersections[#intersections + 1] = linePoint
							end
						end
					end
				end
				table.sort(intersections, function(a, b)
					return (a - node1.position).sizeSquared < (b - node1.position).sizeSquared
				end)
				
				local canSkipNode = true -- iterate over each adjacent pair of intersections and ensure the midpoint between them is on a walkable surface.
				for i = 1, #intersections - 1 do
					local point1, point2 = intersections[i], intersections[i+1]
					local midpoint = (point1 + point2) / 2
					local isOnSurface = false
					for rect in pairs(importantRectangleDict) do -- check whether the midpoint is on a rectangle
						if (NavMeshGenerator.closestPointOnRectangle(midpoint, rect) - midpoint).sizeSquared < 1 then
							isOnSurface = true -- found a rectangle that the midpoint is on
							break
						end
					end
					if not isOnSurface then -- the midpoint of these intersections is outside the walkable space
						canSkipNode = false
					end
				end
				if canSkipNode then
					table.remove(solutionPath, startNodeIndex + 1)
				else
					break
				end
			end
			
			startNodeIndex = startNodeIndex + 1
		end
		
		for i = 1, #solutionPath do -- convert nodes to positions
			solutionPath[i] = solutionPath[i].position
			if NavMeshGenerator.SHOW_DEBUG_LINES and i > 1 then
				CoreDebug.DrawLine(solutionPath[i-1], solutionPath[i], {duration = 1, thickness = 20, color = Color.New(0, .5, 1)})
			end
		end
		return solutionPath
	else
		warn("no path was found between "..tostring(startPoint).." and "..tostring(endPoint))
	end
end