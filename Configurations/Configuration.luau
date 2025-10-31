-- DATA CONTAINER --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _Assets = ReplicatedStorage.Assets
local Data = {
	startingCash = 500,
	startingEnergy = 100,
	maxEnergy = 100,
	energyRegenRate = 1,
	energyRegenInterval = 1,
	stockAmount = 20,
	groupId = 0,
	equippableUnitsMax = 4,
	starterMaxUnits = 12,
	unitUpgradeAmount = 2,
	dataVersion = 2,
	xpPerHit = 10,
}

export type Data = typeof(Data)

return Data
