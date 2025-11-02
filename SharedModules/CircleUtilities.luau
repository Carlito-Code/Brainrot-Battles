-- Circle Position Utility
-- Calculates evenly distributed positions around a center point

local CirclePositions = {}

--[[
	GetCirclePositions - Calculate positions evenly distributed in a circle
	
	Parameters:
		centerCF (CFrame) - The center point and orientation
		radius (number) - Distance from center for each position
		count (number) - Number of positions to generate
		startAngle (number, optional) - Starting angle in radians (default: 0)
		yOffset (number, optional) - Height offset from center (default: 0)
		
	Returns:
		table - Array of Vector3 positions around the circle
		
	Example:
		local positions = CirclePositions.GetCirclePositions(
			CFrame.new(0, 5, 0),
			10,
			8
		)
]]

function CirclePositions.GetCirclePositions(
	centerCF: CFrame,
	radius: number,
	count: number,
	startAngle: number?,
	yOffset: number?
): { Vector3 }
	local positions = {}
	startAngle = startAngle or 0
	yOffset = yOffset or 0

	local angleStep = (2 * math.pi) / count
	local centerPosition = centerCF.Position
	local centerRight = centerCF.RightVector
	local centerLookVector = centerCF.LookVector

	for i = 1, count do
		local angle = startAngle + (i - 1) * angleStep
		local x = math.cos(angle) * radius
		local z = math.sin(angle) * radius

		-- Transform the position relative to the center CFrame's orientation
		local localPosition = centerRight * x + centerLookVector * z
		local worldPosition = centerPosition + localPosition + Vector3.new(0, yOffset, 0)

		table.insert(positions, worldPosition)
	end

	return positions
end

-- Get a single position at a specific index in the circle
function CirclePositions.GetCirclePosition(
	centerCF: CFrame,
	radius: number,
	index: number,
	totalCount: number,
	startAngle: number?,
	yOffset: number?
): Vector3
	startAngle = startAngle or 0
	yOffset = yOffset or 0

	local angleStep = (2 * math.pi) / totalCount
	local angle = startAngle + (index - 1) * angleStep

	local x = math.cos(angle) * radius
	local z = math.sin(angle) * radius

	local centerPosition = centerCF.Position
	local centerRight = centerCF.RightVector
	local centerLookVector = centerCF.LookVector

	local localPosition = centerRight * x + centerLookVector * z
	return centerPosition + localPosition + Vector3.new(0, yOffset, 0)
end

return CirclePositions
