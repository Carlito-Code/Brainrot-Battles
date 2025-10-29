local baseXpPerLevel, multiplier = 100, 1.15
return function(currentLevel: number): number
	local nextLevel = currentLevel + 1
	return nextLevel * baseXpPerLevel * multiplier
end