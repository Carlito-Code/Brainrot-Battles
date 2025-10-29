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


return CirclePositions