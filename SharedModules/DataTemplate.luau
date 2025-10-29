-- DATA CONTAINER --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Configuration = require(ReplicatedStorage.Configurations.Configuration)

local Data = {
	version = Configuration.dataVersion,
	template = {
		cash = Configuration.startingCash,
		energy = Configuration.startingEnergy,
		equipped = {
			[1] = {
				Name = "Test",
				Level = 1,
				Xp = 0,
			},
		},
		gamepasses = {},
		maxUnitsOnField = Configuration.starterMaxUnits,
		inventory = {},
	},
}

export type DataBrainrot = {
	Name: string,
	Level: number,
	Xp: number,
}

export type Data = typeof(Data)

return Data
