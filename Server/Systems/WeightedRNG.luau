local weightedRNG = {}

function weightedRNG.get(rarities: { [string]: number }, luck: number)
	if not luck then
		luck = 1
	end
	local total = 0
	for _, amount in rarities do
		total += amount
	end
	local currentRange, currentRarity = math.huge, nil
	for i = 1, luck do
		local rng = Random.new():NextNumber(0, total)
		local currentTotal = 0
		for rarity, range in rarities do
			currentTotal += range
			if rng <= currentTotal then
				if currentRange > range then
					currentRange = range
					currentRarity = rarity
				end
			end
		end
	end
	return currentRarity
end

return weightedRNG
