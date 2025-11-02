-- DATA CONTAINER --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Configuration = require(ReplicatedStorage.Configurations.Configuration)

local Data = {
	version = Configuration.dataVersion,
	template = {
		cash = Configuration.startingCash,
		energy = Configuration.startingEnergy,
		equipped = {
			["guid"] = true,
		},
		gamepasses = {},
		maxUnitsOnField = Configuration.starterMaxUnits,
		inventory = {
			["guid"] = {
				Name = "BombardiroCrocodilo",
				Level = 5,
				Xp = 0,
			},
		},
	},
}

export type DataBrainrot = {
	Name: string,
	Level: number,
	Xp: number,
}

export type Data = typeof(Data)

return Data
